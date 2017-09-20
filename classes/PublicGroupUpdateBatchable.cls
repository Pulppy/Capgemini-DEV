global class PublicGroupUpdateBatchable implements Database.Batchable<sObject>, Database.Stateful {
/*
// PublicGroupUpdateBatchable
----------------------------------------------------------------------
-- - Name          : PublicGroupUpdateBatchable 
-- - Author        : Genio Wibawa
-- - Description   : Batch Job to Update Public Group Membership
--                   Based on Partner Role information
--                   
-- Maintenance History:
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-May-2017   GBW     1.0     Created
----------------------------------------------------------------------
**********************************************************************
*/
	/**
	* function: start
	* Queries all partner role records needed to be audited based on all TBU public groups
	* Return: Database.QueryLocator
	* Parameter: Database.BatchableContext
	*/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		/*String query = 'SELECT Id, Name, DeveloperName, OwnerId, DoesIncludeBosses ' +
                       'FROM Group ' + 
                       'WHERE Name LIKE \'TBU_%\' ' + 
                       'AND DeveloperName LIKE \'PR_%\' ' + 
                       'AND Type = \'Regular\'';
		*/
        List<Group> groups = [SELECT Id, Name, DeveloperName, OwnerId, DoesIncludeBosses 
                                FROM Group 
                                WHERE Name LIKE 'TBU_%' 
                                AND DeveloperName LIKE 'PR_%' 
                                AND Type = 'Regular'];

        Set<String> agentCodes = new Set<String>();
        for (Group g : groups) {
            String code = g.DeveloperName.substring(3);
            if (!String.isBlank(code)) {
                agentCodes.add(code);
            }
        }

        String query = 'SELECT Id, OwnerId, Agent_Code__c, ' +
                       'Parent_Code__c, Parent_Role__c, Branch__c, ' +
                       'Channel__c, Position_Code__c, Region__c ' +
                       'FROM Partner_Role__c ' +
                       'WHERE Agent_Code__c IN :agentCodes';

        System.debug(query);

        return Database.getQueryLocator(query);
	}

	/**
	* function execute
	* Adds or Deletes public group member based on the partner role information
	* Return: void
	* Parameters: Database.BatchableContext, List of Partner Role records
	*/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		// TODO: Do we need broker group and Channel differentiation?
		//List<Group> brokerAdminGroupList=[select id,name,developername,type from group where developername='Broker_Super_Admin' and type='Role' ];
		//Set<String> brokerPRSet = new Set<String>();

		Set<String> agentCodes = new Set<String>();								// Set of Agent Codes in all Partner Role scope
		Set<String> regionCodes = new Set<String>();							// Set of Region Codes in all Partner Role scope
		Set<String> branchCodes = new Set<String>();							// Set of Branch Codes (' ' replaced with '_') in all Partner Role Scope		
		Set<String> groupNames = new Set<String>();							// All Public Group DeveloperName (From Agent Code, Region, and Branch Code) in all Partner Role Scope
		Map<String,String> agentCodeParentCodeMap = new Map<String,String>();	// Map of Each public group and its parents, in order to put parent group as a member of child group

		for(sObject obj : scope ){
			Partner_Role__c pr = (Partner_Role__c) obj;
		    //Broker Phase 1 - determine if the agent is partner
		    /*if(pr.Position_Code__c == '05' && pr.Channel__c == 'OT') {
		        brokerPRSet.add(pr.Agent_Code__c);
		    }*/
		    
		    agentCodes.add(pr.Agent_Code__c);
		    groupNames.add('PR_'+pr.Agent_Code__c);
		    if(!String.isBlank(pr.Region__c)) {
		    	regionCodes.add(pr.Region__c);
		    	groupNames.add('PR_R_' + pr.Region__c);
		    	if(!String.isBlank(pr.Branch__c)) {
		    		branchCodes.add(pr.Branch__c);
		    		String branchCode = pr.Branch__c.replace(' ', '_');

		    		groupNames.add('PR_B_' + branchCode);
		    		agentCodeParentCodeMap.put('PR_B_' + branchCode, 'PR_R_' + pr.Region__c);
		    	}
		    }
		    if(pr.Parent_Role__c != null){
		        agentCodeParentCodeMap.put('PR_'+pr.Agent_Code__c, 'PR_'+pr.Parent_Code__c);
		    }
		}

		// Deletes all group members and recalculate new ones later
		List<GroupMember> groupMemberToDelete = new List<GroupMember>();
		if(groupNames.size() > 0){
		    for(GroupMember gm : [select Id, UserOrGroupId from GroupMember where Group.DeveloperName in:groupNames]){
		        if(string.valueOf(gm.UserOrGroupId).startsWith('00G')){
		            groupMemberToDelete.add(gm);
		        }
		    }
		    
		    if(!groupMemberToDelete.isEmpty()){
		    	System.debug(groupMemberToDelete);
		        delete groupMemberToDelete;
		    }
		}

		List<GroupMember> groupOwners = new List<GroupMember>();			// List of Users with Agent Codes matching Public Group names
		List<GroupMember> groupMembers = new List<GroupMember>();			// List of Parent Groups inside each public group
		Map<String,String> parentGroupCodeIdMap = new Map<String,String>();	// Maps Group Developername to Group ID

		// Maps Agents and their Users
		Map<String, Set<Id>> userMap = new Map<String, Set<Id>>();
		Map<String, Set<Id>> branchUserMap = new Map<String, Set<Id>>();
		Map<String, Set<Id>> regionUserMap = new Map<String, Set<Id>>();
		for (User u : [SELECT Id, Agent_Code__c, Region_Code__c,
						Branch_Code__c, UserRole.Name
						FROM User 
						WHERE Agent_Code__c IN :agentCodes
						OR (Region_Code__c IN :regionCodes AND UserType = 'PowerPartner')
						OR (Branch_Code__c IN :branchCodes AND UserType = 'PowerPartner')]) {

			if(!String.isEmpty(u.Agent_Code__c)) {
				Set<Id> userIdSet = userMap.get(u.Agent_Code__c);
				if (userIdSet == null) {
				    userIdSet = new Set<Id>();
				}
				userIdSet.add(u.Id);
				userMap.put(u.Agent_Code__c, userIdSet);
			}

			if(!String.isEmpty(u.Region_Code__c) && u.userRole.Name == 'RADD') {
				if(regionUserMap.get(u.Region_Code__c) == null) {
					regionUserMap.put(u.Region_Code__c, new Set<Id>());
				}
				regionUserMap.get(u.Region_Code__c).add(u.Id);
		    }
		    if(!String.isEmpty(u.Branch_Code__c) && u.userRole.Name == 'ADD') {
		    	u.Branch_Code__c = u.Branch_Code__c.replace(' ', '_');
		    	if(branchUserMap.get(u.Branch_Code__c) == null) {
		    		branchUserMap.put(u.Branch_Code__c, new Set<Id>());
		    	}
		    	branchUserMap.get(u.Branch_Code__c).add(u.Id);
		    }
		}

		// Gets all Parent Groups based on Parent_Role__c field for each Partner_Role__c record retrieved
		for(Group g : [select Id, DeveloperName from Group where DeveloperName in: agentCodeParentCodeMap.values()]){
		    parentGroupCodeIdMap.put(g.DeveloperName, g.Id);
		}

		System.debug(agentCodes);
		System.debug(regionCodes);
		System.debug(branchCodes);
		System.debug(groupNames);
		System.debug(agentCodeParentCodeMap);
		System.debug(userMap);
		System.debug(regionUserMap);
		System.debug(branchUserMap);
		System.debug(parentGroupCodeIdMap);

		// Retrieves every public group and adds group owners and group members to each group
		for(Group g : [select Id, DeveloperName from Group where DeveloperName in: groupNames]){
		    String code = g.DeveloperName.substring(3);
		    Set<Id> userIdSet = userMap.get(code);

		    if (userIdSet != null && !userIdSet.isEmpty()) {
		        for (Id uid : userIdSet) {
		            groupOwners.add(
		            	new GroupMember(GroupId=g.Id,UserOrGroupId=uid)
		            );
		        }
		    } else if(regionUserMap.get(code) != null && regionUserMap.get(code).size() > 0){
		    	for (Id uid: regionUserMap.get(code)) {
		    		groupOwners.add(
		    			new GroupMember(GroupId = g.Id, UserOrGroupId = uid)
		    		);
		    	}
		    } else if(branchUserMap.get(code) != null && branchUserMap.get(code).size() > 0) {
		    	for (Id uid: branchUserMap.get(code)) {
		    		groupOwners.add(
		    			new GroupMember(GroupId = g.Id, UserOrGroupId = uid)
		    		);
		    	}
		    }

		    if (parentGroupCodeIdMap.get(agentCodeParentCodeMap.get(g.DeveloperName)) != null) {
		    	//System.debug(parentGroupCodeIdMap.get(agentCodeParentCodeMap.get(g.DeveloperName)));
		        groupMembers.add(
		        	new GroupMember(
		        		GroupId=g.Id,
		        		UserOrGroupId=parentGroupCodeIdMap.get(agentCodeParentCodeMap.get(g.DeveloperName)))
		        );    
		    }
		    
		    // TODO: Do we need broker?
		    //Broker Phase 1 - add role as new group member
		    /*if(brokerPRSet.contains(code) && brokerAdminGroupList.size()>0) {
		        groupMembers.add(new GroupMember(GroupId=g.Id, 
		                                            UserOrGroupId=brokerAdminGroupList[0].Id)
		        );
		    }*/
		}

		// Group owners should be added, use Database.insert to prevent any Exceptions
		Database.insert(groupOwners);
		if(groupMembers.size() > 0) {
			insert groupMembers;
		}
	}

	/**
	* function: finish
	* Sends an email indicating that the batch job is complete
	* Return: void
	* Parameter: Database.BatchableContext
	*/
	global void finish(Database.BatchableContext BC) {
		String mailBody = 'Dear ' + UserInfo.getName() + '<br/>PublicGroupUpdateBatchable has finished executing.' +
						  '<br/>Time of completion is ' + System.now();

	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	    mail.setToAddresses(new String[]{UserInfo.getUserEmail()});
	    mail.setSenderDisplayName('PublicGroupUpdateBatchable');
	    mail.setSubject('PublicGroupUpdateBatchable');
	    mail.setHtmlBody(mailBody);

	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}

}