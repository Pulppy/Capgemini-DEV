public without sharing class SharingManagement{

    /**
    * function: createSharing
    * Polymorphically creates apex manual sharing for a list of object.
    * Based on SharingManagement__c custom settings and Public Groups created by Partner Role Sharing (PartnerRoleTrigger + PartnerRoleTriggerHandler)
    * Parameter: List of objects to be shared, and the name of the object in string
    * Return: void
    */
    public static void CreateSharing(List<sObject> MyObjectList, String ObjectName){
        Map<String,Set<String>> SharingRecordMap = new Map<String,Set<String>>();
        Map<String, String> SharingRecordTypeMap = new Map<String, String>();
        Map<String,Set<String>> SharingRecordAccountMap = new Map<String,Set<String>>();
        
        SharingManagement__c MySM = SharingManagement__c.getValues(ObjectName);
        String MyFields = MySM.Sharing_Field__c;
        List<String> MyFieldList = MyFields.split(';');

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(ObjectName);
        Map<String, Schema.sObjectField> objFields = objType.getDescribe().fields.getMap();
        Map<String, Schema.DisplayType> fieldTypes = new Map<String, Schema.DisplayType>();
        for (String f : MyFieldList) {
            fieldTypes.put(f, objFields.get(f).getDescribe().getType());
        }

        Set<String> userIdSet = new Set<String>();
        Set<String> userAgentCodeSet = new Set<String>();
        
        Map<String, List<String>> agentIdToGroupsMap = new Map<String, List<String>>();
        // Key - It can be a SFDC Id / Agent Code
        Map<String, String> AgentIdToGroupMap = new Map<String, String>();
        Map<String, String> GroupNameIdMap = new Map<String, String>();
        
        for(sObject MyRecord : MyObjectList){
            for(String MyField : MyFieldList){
                String val = String.valueOf(MyRecord.get(MyField));
                if (fieldTypes.get(MyField) == Schema.DisplayType.Reference) {
                    if (String.isNotBlank(val)) {
                        userIdSet.add(val);
                    }
                } else if (fieldTypes.get(MyField) == Schema.DisplayType.String) {
                    if (String.isNotBlank(val)) {
                        userAgentCodeSet.add(val);
                        //AgentIdToGroupMap.put(val, 'PR_' + val);
                    }
                } else {
                    MyRecord.addError('ERROR - SharingManagement - Only Reference and Text fields are supported!');
                }
            }
        }
        
        // Retrieve Group List (Based on Agent Codes, Region Codes and Branch Codes)
        // if the input given to this function is an ownerId
        if (!userIdSet.isEmpty()) {
            for(User MyUser : [SELECT Id, Agent_code__c, Region_Code__c, Branch_Code__c
                                FROM User 
                                WHERE Id in :UserIdSet
                                AND Agent_Code__c != null
                                AND Agent_Code__c != '']){
                //AgentIdToGroupMap.put(MyUser.Id,'PR_'+MyUser.Agent_code__c);

                if(agentIdToGroupsMap.get(myUser.Id) == null) {
                    agentIdToGroupsMap.put(myUser.Id, new List<String>());
                }

                if(myUser.Branch_Code__c != null) {
                    myUser.Branch_Code__c = myUser.Branch_Code__c.replace(' ', '_');
                    agentIdToGroupsMap.get(myUser.Id).add('PR_B_' + myUser.Branch_Code__c);
                }

                agentIdToGroupsMap.get(myUser.Id).add('PR_R_' + myUser.Region_Code__c);
                agentIdToGroupsMap.get(myUser.Id).add('PR_' + myUser.Agent_code__c);
            }
        }

        // Retrieve Group List (Based on Agent Codes, Region Codes and branch Codes)
        // if the input given to this function is agent code
        if(!userAgentCodeSet.isEmpty()) {
            for(Partner_Role__c pr : [SELECT Id, Agent_code__c, Region__c, Branch__c
                                        FROM Partner_Role__c
                                        WHERE Agent_Code__c IN :userAgentCodeSet]) {

                if(agentIdToGroupsMap.get(pr.Agent_Code__c) == null) {
                    agentIdToGroupsMap.put(pr.Agent_Code__c, new List<String>());
                }

                if(pr.Branch__c != null) {
                    pr.Branch__c = pr.Branch__c.replace(' ', '_');
                    agentIdToGroupsMap.get(pr.Agent_Code__c).add('PR_B_' + pr.Branch__c);
                }
                if(pr.Region__c != null) {
                    agentIdToGroupsMap.get(pr.Agent_Code__c).add('PR_R_' + pr.Region__c);
                }

                agentIdToGroupsMap.get(pr.Agent_Code__c).add('PR_' + pr.Agent_Code__c);
                
                
            }
        }

        /*for(Group MyGroup : [SELECT Id, DeveloperName 
                            FROM Group 
                            WHERE DeveloperName IN :AgentIdToGroupMap.values()
                            AND Type = 'Regular']){
            GroupNameIdMap.put(MyGroup.DeveloperName,MyGroup.Id);
        }*/

        // Consolidates all groups from all agents into one list
        List<String> groupList = new List<String>();
        for(String agentId: agentIdToGroupsMap.keySet()) {
            for(String publicGroup: agentIdToGroupsMap.get(agentId)) {
                groupList.add(publicGroup);
            }
        }

        for(Group myGroup: [SELECT Id, DeveloperName
                            FROM Group
                            WHERE DeveloperName IN :groupList
                            AND Type = 'Regular']) {
            GroupNameIdMap.put(myGroup.DeveloperName, myGroup.Id);
        }

        System.debug(agentIdToGroupsMap);
        System.debug(GroupNameIdMap);

        for (sObject record : MyObjectList) {
            String recordId = String.valueOf(record.get('Id'));
            if(ObjectName != 'Season__c' && ObjectName != 'MDRT__c' && ObjectName != 'Agent_KPI__c'){
                SharingRecordTypeMap.put(recordId, String.valueOf(record.get('RecordTypeId')));
            }

            for (String fieldName : MyFieldList) {
                Set<String> MyFieldValuesSet = new Set<String>();

                if(agentIdToGroupsMap.get(String.valueOf(record.get(fieldName))) == null) {
                    continue;
                }
                
                for(String groupName: agentIdToGroupsMap.get(String.valueOf(record.get(fieldName)))) {
                    System.debug(groupName);
                    String groupId = GroupNameIdMap.get(groupName);
                    if (!MyFieldValuesSet.contains(groupName) && !String.isBlank(groupId)) {
                        if(SharingRecordMap.get(recordId) == null){
                            SharingRecordMap.put(recordId, new Set<String>());
                        }
                        MyFieldValuesSet.add(groupName);
                        SharingRecordMap.get(recordId).add(groupId);

                        if (ObjectName.equalsIgnoreCase('Policy__c')) {
                            //FIX: Check if Customer__c or Insured__c is null before creating sharing rules for those accounts
                            String customerId = String.valueOf(record.get('Customer__c'));
                            System.debug(LoggingLevel.ERROR, 'Sharing - Customer ID - ' + customerId);
                            String insuredId = String.valueOf(record.get('Insured__c'));
                            System.debug(LoggingLevel.ERROR, 'Sharing - Insured ID - ' + insuredId);

                            if (!String.isBlank(customerId)) {
                                if(SharingRecordAccountMap.get(customerId) == null){
                                   SharingRecordAccountMap.put(customerId, new Set<String>()); 
                                }
                                SharingRecordAccountMap.get(customerId).add(groupId);
                            }

                            if (!String.isBlank(insuredId)) {
                                if(SharingRecordAccountMap.get(insuredId) == null){
                                   SharingRecordAccountMap.put(insuredId, new Set<String>()); 
                                }
                                SharingRecordAccountMap.get(insuredId).add(groupId);
                            }
                        }
                    }
                }
            }
        }
        
        if(ObjectName == 'Lead'){
            CreateLeadSharing(SharingRecordMap);
        } else if(ObjectName == 'Account'){
            CreateAccountSharing(SharingRecordMap);                                                                                                                                                
            CreateCustomerSharing(SharingRecordAccountMap);
        } else if(ObjectName == 'Target__c') {
            CreateTargetSharing(SharingRecordMap, SharingRecordTypeMap);
        } else if(ObjectName == 'Policy__c'){
            CreatePolicySharing(SharingRecordMap);
            CreateCustomerSharing(SharingRecordAccountMap);
        } else if(ObjectName == 'Agent_KPI__c') {
            CreateAgentKPISharing(SharingRecordMap);
        }
    }

    public static void CreateAgentKPISharing(Map<String, Set<String>> SharingRecordMap) {
        List<Agent_KPI__Share> agentKPIShareList = new List<Agent_KPI__Share>();

        for(Id MyRecordId: SharingRecordMap.keySet()) {
            for(Id MyUserGroupId: SharingRecordMap.get(MyRecordId)) {
                agentKPIShareList.add(new Agent_KPI__Share(AccessLevel = 'Read', ParentId = MyRecordId, UserOrGroupId = MyUserGroupId ));
            }
        }

        insert agentKPIShareList;
    }

    public static void CreateLeadSharing(Map<String,Set<String>> SharingRecordMap){
        
        List<LeadShare> LeadShareList = new List<LeadShare>();

        for(Id MyRecordId : SharingRecordMap.keySet()){
            for(Id MyUserGroupId : SharingRecordMap.get(MyRecordId)){
                LeadShareList.add(new LeadShare(LeadAccessLevel = 'Read', LeadId = MyRecordId, UserOrGroupId = MyUserGroupId));
            }
        }
        
        insert LeadShareList;
    }
    
    public static void CreateAccountSharing(Map<String,Set<String>> SharingRecordMap){
        
        List<AccountShare> AccountShareList = new List<AccountShare>();
        
        for(Id MyRecordId : SharingRecordMap.keySet()){
            for(Id MyUserGroupId : SharingRecordMap.get(MyRecordId)){
                AccountShareList.add(new AccountShare(AccountAccessLevel = 'Read', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', AccountId = MyRecordId, UserOrGroupId = MyUserGroupId ));
            }
        }
        
        insert AccountShareList;
    }
    
    public static void CreateCustomerSharing(Map<String,Set<String>> SharingRecordMap){
        
        List<AccountShare> AccountShareList = new List<AccountShare>();
        
        for(String MyRecordId : SharingRecordMap.keySet()){
            for(Id MyGroupId : SharingRecordMap.get(MyRecordId)){
                AccountShareList.add(new AccountShare(AccountAccessLevel = 'Read', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', AccountId = MyRecordId, UserOrGroupId = MyGroupId));
            }
        }
        
        insert AccountShareList;
    }
    
    public static void CreatePolicySharing(Map<String,Set<String>> SharingRecordMap){
        
        List<Policy__Share> PolicyShareList = new List<Policy__Share>();
        
        for(Id MyRecordId : SharingRecordMap.keySet()){
            for(Id MyUserGroupId : SharingRecordMap.get(MyRecordId)){
                PolicyShareList.add(new Policy__Share(AccessLevel = 'Read', ParentId = MyRecordId, UserOrGroupId = MyUserGroupId ));
            }
        }
        
        insert PolicyShareList;
    }

    public static void CreateTargetSharing(Map<String,Set<String>> SharingRecordMap, Map<String, String> SharingRecordTypeMap){
        Map<Id, RecordType> editRt = new Map<Id, RecordType>([SELECT Id, DeveloperName 
                                                                    FROM RecordType
                                                                    WHERE DeveloperName IN (
                                                                        'Performance_Target'
                                                                    )
                                                                    AND IsActive = true
        ]);
        List<Target__Share> TargetShareList = new List<Target__Share>();
        
        for(Id MyRecordId : SharingRecordMap.keySet()){
            String accessLv = 'Read';
            if (String.isNotBlank(SharingRecordTypeMap.get(MyRecordId)) &&
                editRt.get(SharingRecordTypeMap.get(MyRecordId)) != null) {
                accessLv = 'Edit';
            }
            for(Id MyUserGroupId : SharingRecordMap.get(MyRecordId)){
                TargetShareList.add(new Target__Share(AccessLevel = accessLv, ParentId = MyRecordId, UserOrGroupId = MyUserGroupId ));
            }
        }
        
        insert TargetShareList;
    }
}