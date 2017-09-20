public without sharing class PolicyTriggerHandler{

    // private static User integrationUser = GlobalUtility.getIntegrationUser();
    private static SharingManagement__c MySM = SharingManagement__c.getValues('Policy__c');    
    private static Schema.SObjectType objType = Schema.getGlobalDescribe().get('Policy__c');
    
    private static final String RT_APPLICATION     = 'Application';
    private static final String RT_POLICY_REGISTER = 'Policy_Register';

    public static void OnBeforeInsert(List<Policy__c> NewPolicyList){
        // Change the ownership of Policy to the Agent based on the Partner Role lookup
        List<String> agentCodes = new List<String>();
        Map<String, User> agentCodesToUser = new Map<String, User>();

        for(Policy__c newPolicy: newPolicyList) {
            System.debug(newPolicy.Servicing_Agent1__c);
            System.debug(newPolicy.Servicing_Agent_Text__c);

            if(newPolicy.Servicing_Agent1__c != null) {
                agentCodes.add(newPolicy.Servicing_Agent_Text__c);
            }
        }

        // Retrieve agents (if exist)
        if(agentCodes.size() > 0) {
            // Create a map of agent codes to agent users
            for(User u : [SELECT Agent_Code__c FROM User WHERE Agent_Code__c IN :agentCodes]) {
                agentCodesToUser.put(u.Agent_Code__c, u);
            }

            // Assign each user to a policy according to the agent code
            if(agentCodesToUser.size() > 0) {
                for(Policy__c newPolicy: newPolicyList) {
                    if(newPolicy.Servicing_Agent1__c != null && agentCodesToUser.get(newPolicy.Servicing_Agent_Text__c) != null) {
                        newPolicy.OwnerId = agentCodesToUser.get(newPolicy.Servicing_Agent_Text__c).Id;
                    }
                }
            }
        }
    }    
    
    
    /**
     * After Insert, create the sharing rules associated to the Policy and Account
     * Update the Prospect if Opportunity ID is populated
     * Link to a Campaign if the campaign linking rules are valid
     */
    public static void OnAfterInsert(List<Policy__c> NewPolicyList, Map<Id, Policy__c> NewPolicyMap){
        //List<MergeProspectCustomerBatch.ProspectMasterMergeEntry> mergeList = new List<MergeProspectCustomerBatch.ProspectMasterMergeEntry>();
        
        System.debug(PAD.canRun('SharingManagement'));
        if(PAD.canRun('SharingManagement'))
        {
            SharingManagement.CreateSharing(NewPolicyList,'Policy__c');
        }
    }
        
    
    public static void OnBeforeUpdate(Map<Id,Policy__c> OldPolicyMap, Map<Id,Policy__c> NewPolicyMap){
        List<String> agentCodes = new List<String>();
        List<Policy__c> changedPolicies = new List<Policy__c>();
        Map<String, User> agentCodesToUser = new Map<String, User>();
        Set<Id> policyShareRemoveSet = new Set<Id>();
        String MyFields = MySM.Sharing_Field__c;
        List<String> MyFieldList = MyFields.split(';');
        
        for(Id MyPolicyId : OldPolicyMap.keySet()){
            Policy__c newPolicy = NewPolicyMap.get(MyPolicyId);
            Policy__c oldPolicy = OldPolicyMap.get(MyPolicyId);

            for (String s : MyFieldList) {
                if (oldPolicy.get(s) != newPolicy.get(s)) {
                    policyShareRemoveSet.add(MyPolicyId);
                }
            }
            if(oldPolicy.Servicing_Agent1__c != newPolicy.Servicing_Agent1__c) {
                //newPolicy.OwnerId = newPolicy.Servicing_Agent1__c;
                agentCodes.add(newPolicy.Servicing_Agent_Text__c);
                changedPolicies.add(newPolicy);
            }

            // Update Policy Lapsed Date, where P04 = Lapsed
            if(oldPolicy.Policy_status__c != newPolicy.Policy_status__c &&
                (newPolicy.Policy_status__c == 'P04' || newPolicy.Policy_status__c == 'P09')) {
                
                newPolicy.Policy_Lapse_Date__c = System.TODAY();
            }
        }

        if(agentCodes.size() > 0) {
            for(User u: [SELECT Agent_Code__c FROM User WHERE Agent_Code__c IN :agentCodes]) {
                agentCodesToUser.put(u.Agent_Code__c, u);
            }

            if(agentCodesToUser.size() > 0) {
                for(Policy__c changedPolicy: changedPolicies) {
                    if(agentCodesToUser.get(changedPolicy.Servicing_Agent_Text__c) != null) {
                        changedPolicy.OwnerId = agentCodesToUser.get(changedPolicy.Servicing_Agent_Text__c).Id;
                    }
                }
            }
        }

        if(policyShareRemoveSet.size() > 0) {
            delete [SELECT Id FROM Policy__Share WHERE ParentId IN :policyShareRemoveSet AND RowCause = 'manual'];
        }
    }
    
    public static void OnAfterUpdate(Map<Id,Policy__c> OldPolicyMap, Map<Id,Policy__c> NewPolicyMap){
        
        String MyFields = MySM.Sharing_Field__c;
        List<String> MyFieldList = MyFields.split(';');

        Map<String, Schema.sObjectField> objFields = objType.getDescribe().fields.getMap();
        Map<String, Schema.DisplayType> fieldTypes = new Map<String, Schema.DisplayType>();
        for (String f : MyFieldList) {
            fieldTypes.put(f, objFields.get(f).getDescribe().getType());
        }

        Map<Id, Policy__c> PendingSharingUpdate = new Map<Id, Policy__c>();
        //List<Policy__c> NewPolicyList = new List<Policy__c>();
        //Set<Id> NewPolicyIdSet = new Set<Id>();
        Set<Id> AccountIdSet = new Set<Id>();
                
        //List<MergeProspectCustomerBatch.ProspectMasterMergeEntry> mergeList = new List<MergeProspectCustomerBatch.ProspectMasterMergeEntry>();
        
        
        ////////////////////////////////////////////
        // First query out all the beneficiaries
        ////////////////////////////////////////////
        //Map<String, List<Account>> polIdToBeneMap = new Map<String, List<Account>>();
        //Map<Id, Set<Id>> polAsaIdToBeneList = new Map<Id, Set<Id>>();
        //Set<Id> accountSharingRulesToDelete = new Set<Id>();
        
        for (Id MyPolicyId : OldPolicyMap.keySet()){
            Policy__c oldPolicy = OldPolicyMap.get(MyPolicyId);
            Policy__c newPolicy = NewPolicyMap.get(MyPolicyId);

            for (String s : MyFieldList) {
                if (oldPolicy.get(s) != newPolicy.get(s)) {
                    PendingSharingUpdate.put(MyPolicyId, newPolicy);
                    AccountIdSet.add(newPolicy.Customer__c);
                    AccountIdSet.add(newPolicy.Insured__c);
                    break;
                }
            }
            
            // Sharing Rules Fix for Change of Insured/Owner
            // We want to ensure that if the Insured or Owner is ever changed, we update
            // the security permissions of the old Insured/Owner and the new Insured/Owner
            if(oldPolicy.Customer__c != newPolicy.Customer__c){
                AccountIdSet.add(newPolicy.Customer__c);
                AccountIdSet.add(oldPolicy.Customer__c);
            }
            if(oldPolicy.Insured__c != newPolicy.Insured__c){
                AccountIdSet.add(newPolicy.Insured__c);
                AccountIdSet.add(oldPolicy.Insured__c);
            }
            
        } // End-of-for (Id MyPolicyId : OldPolicyMap.keySet())
        
        // Policy Sharing Rules
        if(!PendingSharingUpdate.isEmpty() && PAD.canRun('SharingManagement')){
            SharingManagement.CreateSharing(PendingSharingUpdate.values(),'Policy__c');
        }
    }
}