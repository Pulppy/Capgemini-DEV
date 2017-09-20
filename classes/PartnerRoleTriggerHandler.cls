public without sharing class PartnerRoleTriggerHandler{
    
    public static boolean IS_SKIP_UPDATE_HIERARCHY = false;
    
    public static void createRenamePublicGroups(Set<String> agentCodes, Set<String> regionCodes, Set<String> branchCodes) {
        Set<String> groupNames = new Set<String>();
        
        for (String ac : agentCodes) {
            if (!String.isBlank(ac)) {
                groupNames.add('PR_' + ac);
            }
        }

        for(String bc : branchCodes) {
            if(!String.isBlank(bc)) {
                bc = bc.replace(' ', '_'); // some branch codes have spaces in it
                groupNames.add('PR_B_' + bc);
            }
        }

        for(String rc: regionCodes) {
            if(!String.isBlank(rc)) {
                groupNames.add('PR_R_' + rc);
            }
        }

        Map<String, Group> groupMap = new Map<String, Group>();
        for (Group g : [SELECT Id, Name, DeveloperName, DoesIncludeBosses 
                        FROM Group 
                        WHERE DeveloperName IN :groupNames
                        AND Type = 'Regular']) {
            groupMap.put(g.DeveloperName, g);
        }

        for (String devName : groupNames) {
            Group g = groupMap.get(devName);
            if (g != null && !g.Name.startsWith('TBU_')) {
                g.Name = 'TBU_' + g.Name;
                g.DoesIncludeBosses = false;
            } else {
                String agentCode = devName.substring(3);
                groupMap.put(devName, new Group(Name = 'TBU_' + agentCode, 
                                                    DeveloperName = devName, 
                                                    Type = 'Regular', 
                                                    DoesIncludeBosses = false, 
                                                    DoesSendEmailToMembers = false));
            }
        }

        System.debug(groupMap.values());
        Database.upsert(groupMap.values(), false);
    }

    public static void UpdateOwner(List<Partner_Role__c> PartnerRoleList){
        
        Set<String> AgentCodeSet = new Set<String>();
        
        For(Partner_Role__c MyRole : PartnerRoleList){
            AgentCodeSet.add(MyRole.Agent_Code__c);
        }
        
        Map<String,Id> AgentCodeIdMap = new Map<String,Id>();
        
        for(User MyUser : [select Id, Agent_code__c 
                            FROM User where Agent_code__c in: AgentCodeSet
                            AND IsActive = true]){
            AgentCodeIdMap.put(MyUser.Agent_code__c,MyUser.Id);
        }
        
        for(Partner_Role__c MyRole : PartnerRoleList){
            if(AgentCodeIdMap.get(MyRole.Agent_Code__c) != null) {
                MyRole.OwnerId = AgentCodeIdMap.get(MyRole.Agent_Code__c);
            }
        }
    
    
    }
    
    @future
    public static void restructurePartnerRoleLevelInFuture(List<String> agencyCodeList) {
        restructurePartnerRoleLevel(agencyCodeList);
    }
    
    public static void restructurePartnerRoleLevel(List<String> agencyCodeList) {
        
        Map<Id, Partner_Role__c> originalMap = new Map<Id, Partner_Role__c>([SELECT Id, Parent_Code__c, Parent_Role__c, Agency_Code__c,agent_Role__c, District_Code__c, Unit_Code__c,  Agent_Code__c, level_num__c
                                        FROM Partner_Role__c 
                                        WHERE Agency_code__c IN :agencyCodeList
                                        //AND Agent_Role__c IN ('MM2','MM1','MA')
                                        ORDER BY level_num__c]);
                             
        Map<Id, Partner_Role__c> cloneMap = originalMap.deepclone();                              

        //Map<Level Index, Map<PartnerRoleId, Partner ROle
        Map<Decimal, Map<String, Partner_Role__c>> levelAgentMap = new Map<Decimal, Map<String, Partner_Role__c>>();
        Decimal currentLevelIndex = 1;
        
        Set<Id> tempList;
        Map<String, Partner_Role__c> previousLevelMap;
        
        while(!cloneMap.isEmpty()) {
            tempList = cloneMap.keySet();

            
            for(String prID : tempList) {
                if(levelAgentMap.get(currentLevelIndex) == null) {
                    levelAgentMap.put(currentLevelIndex, new Map<String, Partner_Role__c>());
                }
                
                Partner_Role__c currentPR = cloneMap.get(prID);
                if(currentLevelIndex == 1) {
                    
                    if(currentPR.Parent_Role__c == null) {
                        currentPR.Level_Num__c = currentLevelIndex;
                        currentPR.hierarchy_Code__c = currentPR.agent_Code__C;
                        //currentPR.Hierarchy_Code__c = currentPR.
                        levelAgentMap.get(currentLevelIndex).put(prID, currentPR);
                        cloneMap.remove(prID);
                        
                    }
                    
                } else {
                    Partner_Role__c parentRole = previousLevelMap.get(currentPR.parent_Role__c);
                   
                    if(parentRole != null) {
                        system.debug('1');
                        currentPR.Level_Num__c = currentLevelIndex;
                        if(currentPR.agent_Code__c.containsIgnoreCase('S2') && currentPR.parent_Role__c == '' ){   //Added feb 17 2016 for INC0036033 All top level S2 should have hierarchy code as S1
                           currentPR.hierarchy_Code__c = (String.valueof(currentPR.agent_Code__c).substring(0, 6)) + 'S1';
                           
                        }
                        else if(currentPR.agent_Code__c.containsIgnoreCase('S') || currentPR.agent_Code__c.containsIgnoreCase('AXA')){   //Added, May 18th PRB0041544 Added AXA condition for consultants, Aug6 2015 TEE15070884 if else condition to Update parent hierarchy code to all Secretaries
                           currentPR.hierarchy_Code__c = parentRole.hierarchy_Code__c; 
                        }
                        else{
                            currentPR.hierarchy_Code__c = parentRole.hierarchy_Code__c + '.' + currentPR.agent_Code__C;  //Original line of code
                        }
                       
                        levelAgentMap.get(currentLevelIndex).put(prID, currentPR);
                        cloneMap.remove(prID);
                    } else if(originalMap.get(currentPR.parent_Role__c) == null) {
        
                        cloneMap.remove(prID);
                    }

                }
                

                
            }
            
            previousLevelMap = levelAgentMap.get(currentLevelIndex);
            system.debug('$$$$ ' + currentLevelIndex + ' -- '  + previousLevelMap);
            if(previousLevelMap.isEmpty()) {
                break;
                 
            } else {
                currentLevelIndex++;
            }
            
        }
        
        system.debug(levelAgentMap);
        
        List<Partner_Role__c> prToUpdateList = new List<Partner_Role__c>();
        for(Map<String, Partner_Role__c> tempPRMAp : levelAgentMap.values()) {
            prToUpdateList.addAll(tempPRMap.values());
            
        }
        
        IS_SKIP_UPDATE_HIERARCHY=TRUE;
        update(prToUpdateList);
        
        

    }
    
    
         
    /*@future
    public static void updateBrokerUserContact(Set<String> brokerCodes) {
        List<User> userList = [SELECT Id, 
                                        Email,
                                        FederationIdentifier, 
                                        Agent_Code__c, 
                                        ContactId, 
                                        Contact.Account.AccountNumber, 
                                        Contact.AccountId,
                                        Contact.Email,
                                        Contact.Staff_Identifier__c FROM User WHERE Agent_Code__c in :brokerCodes];
        SSOHandler.updateSSOUserContactAccount(userList);
    }*/

    
}