/********************************************************************************

Apex Class Name - PolicyNotificationBatch
Version - 1.0
Created Date - February 26, 2013
Function - Apex Batch used to query all the Policy for which task need to be created

Modification Log :
--------------------------------------------------------------------------------

* Developer             Date                Description
* -----------------    ------------         -----------------------
* Surjakanta Sasmal    26/02/2014           Original Version
********************************************************************************/

global class PolicyNotificationBatch implements Database.Batchable<sObject> {

    /*
     * Method Name: Start
     * Description: Query All the Policy for which tasks need to be created.

     * Return Type: Database.QueryLocator
     * Parameter: Database.BatchableContext
     */

    global Database.QueryLocator start(Database.BatchableContext BC) {
    	List<String> fieldNames = new List<String>();
        Set<String> leadFieldNames = new Set<String>();
    	for(CS_Notification_Management__c notif: CS_Notification_Management__c.getAll().values()) {
    		if(notif.sObject_Name__c == 'Policy__c') {
    			fieldNames.add(notif.Field_Name__c);
                if(notif.Target_Sobject_Name__c == 'Lead') {
                    leadFieldNames.add(notif.First_Name__c);
                    leadFieldNames.add(notif.Last_Name__c);
                    leadFieldNames.add(notif.Salutation__c);
                    leadFieldNames.add(notif.Mobile__c);
                    leadFieldNames.add(notif.Phone__c);

                }
    		}
    	}

        List<String> combinedFieldNames = new List<String>();
        combinedFieldNames.addAll(fieldNames);
        combinedFieldNames.addAll(leadFieldNames);
        String selectFields = String.join(combinedFieldNames, ',');
        /*String selectFields = String.join(fieldNames, ',');
        if(leadFieldNames.size() > 0) {
            selectFields += ',' + String.join(leadFieldNames, ',');
        }*/

    	// Prepare Query to Fetch Account
    	String policyQueryStr = 'SELECT Id, Customer__r.PersonContactId, Insured__r.PersonContactId, Servicing_Agent_Text__c, RecordType.DeveloperName, ' +
    							selectFields + ' FROM Policy__c ' +
    							'WHERE Servicing_Agent_Text__c != NULL AND (Progress_Status__c = \'' + AP_Constant.PolicyProgressStatus3 + '\' OR Progress_Status__c = \'' + AP_Constant.PolicyProgressStatus1 + '\') AND ( ' +
    							String.join(fieldNames, ' = TRUE OR ') + ' = TRUE)';

        System.debug('### policyQueryStr ### ' + policyQueryStr);

        return Database.getQueryLocator(policyQueryStr);

    }

    /*
    * Method Name: Execute
    * Description:

    * Return Type: nil
    * Parameter: Database.BatchableContext, List<sObject>

    */

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<String> agentCodes = new Set<String>();
        Map<String, Id> userMap = new Map<String, Id>();

        for (sObject obj : scope) {
            Policy__c p = (Policy__c) obj;
            agentCodes.add(p.Servicing_Agent_Text__c);
        }

        for (User u : [SELECT Id, Agent_Code__c FROM User 
                        WHERE Agent_Code__c IN :agentCodes 
                        AND IsActive = TRUE]) {
            userMap.put(u.Agent_Code__c, u.Id);
        }

        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();

        //Fetch task information from Custom Settings
        CS_Notification_Management__c anniversaryReminder 	 	= CS_Notification_Management__c.getInstance('Policy_Anniversary');
        CS_Notification_Management__c overduePremiumReminder 	= CS_Notification_Management__c.getInstance('Policy_OverduePremium');
        CS_Notification_Management__c premiumDueReminder 	 	= CS_Notification_Management__c.getInstance('Policy_PremiumDue');
        CS_Notification_Management__c lapseReminder 			= CS_Notification_Management__c.getInstance('Policy_Lapse');
        CS_Notification_Management__c ownerBirthdayReminder 	= CS_Notification_Management__c.getInstance('Account_Birthday');
        CS_Notification_Management__c insuredBirthdayReminder 	= CS_Notification_Management__c.getInstance('Insured_Birthday');
        CS_Notification_Management__c pendingCase               = CS_Notification_Management__c.getInstance('Policy_PendingCase');
        CS_Notification_Management__c maturityReminder          = CS_Notification_Management__c.getInstance('Policy_Maturity');
        CS_Notification_Management__c paidupReminder            = CS_Notification_Management__c.getInstance('Policy_Paidup');


        Date todayDate = System.today();

        //set target date for each task notification type
        Date targetDateAnniversary 		= Date.valueOf(GlobalUtility.TargetWorkingDay(todayDate, Integer.ValueOf(anniversaryReminder.Due_Date__c)));
        Date targetDateOverduePremium 	= Date.valueOf(GlobalUtility.TargetWorkingDay(todayDate, Integer.ValueOf(overduePremiumReminder.Due_Date__c)));
        Date targetDatePremiumDue 		= Date.valueOf(GlobalUtility.TargetWorkingDay(todayDate, Integer.ValueOf(premiumDueReminder.Due_Date__c)));
        Date targetDateLapse 			= Date.valueOf(GlobalUtility.TargetWorkingDay(todayDate, Integer.ValueOf(lapseReminder.Due_Date__c)));
        Date targetDatePendingCase      = Date.valueOf(GlobalUtility.TargetWorkingDay(todayDate, Integer.ValueOf(pendingCase.Due_Date__c)));

        for(sObject s : scope){
            Policy__c plcy = (Policy__c)s;

            // Find the Agents to assign new task to and skip if none found
            Id ownerId = userMap.get(plcy.Servicing_Agent_Text__c);
            if(ownerId == null) {
            	continue;
            }

            if (plcy.Notif_Anniversary__c == true){
                taskList.add(new Task(
                	OwnerId = ownerId,
                	ActivityDate = targetDateAnniversary,
                	WhatId = plcy.Id,
                	//WhoId = plcy.Customer__r.PersonContactId,
                	WhoId = plcy.Customer__c,
                	Subject = anniversaryReminder.Activity_Subject__c,
                	Type = anniversaryReminder.Activity_Type__c
                ));
            }
            if (plcy.Notif_OverduePremium__c == true){
                taskList.add(new Task(
                	OwnerId = ownerId,
                	ActivityDate = targetDateOverduePremium,
                	WhatId = plcy.Id,
                	//WhoId = plcy.Customer__r.PersonContactId,
                	WhoId = plcy.Customer__c,
                	Subject = overduePremiumReminder.Activity_Subject__c,
                	Type = overduePremiumReminder.Activity_Type__c
                ));
            }
            if (plcy.Notif_PremiumDue__c == true){
                taskList.add(new Task(
                	OwnerId = ownerId,
                	ActivityDate = targetDatePremiumDue,
                	WhatId = plcy.Id,
                	//WhoId = plcy.Customer__r.PersonContactId,
                	WhoId = plcy.Customer__c,
                	Subject = premiumDueReminder.Activity_Subject__c,
                	Type = premiumDueReminder.Activity_Type__c
                ));
            }
            if (plcy.Notif_Lapse__c == true){
                taskList.add(new Task(
                	OwnerId = ownerId,
                	ActivityDate = targetDateLapse,
                	WhatId = plcy.Id,
                	//WhoId = plcy.Customer__r.PersonContactId,
                	WhoId = plcy.Customer__c,
                	Subject = lapseReminder.Activity_Subject__c,
                	Type = lapseReminder.Activity_Type__c
                ));
            }
            if (plcy.Notif_NewPendingPolicy__c == true) {
                taskList.add(new Task(
                    OwnerId = ownerId,
                    ActivityDate = targetDatePendingCase,
                    WhatId = plcy.Id,
                   // WhoId = plcy.Customer__r.PersonContactId,
                    WhoId = plcy.Customer__c,
                    Subject = pendingCase.Activity_Subject__c,
                    Type = pendingCase.Activity_Type__c
                ));
            }
            if (plcy.Notif_Owner_Birthday__c == true) {
                leadList.add(new Lead(
                    firstName = String.valueOf(plcy.getSObject(ownerBirthdayReminder.First_Name__c.split('\\.')[0]).get(ownerBirthdayReminder.First_Name__c.split('\\.')[1])),
                    lastName = String.valueOf(plcy.getSObject(ownerBirthdayReminder.Last_Name__c.split('\\.')[0]).get(ownerBirthdayReminder.Last_Name__c.split('\\.')[1])),
                    salutation = String.valueOf(plcy.getSObject(ownerBirthdayReminder.Salutation__c.split('\\.')[0]).get(ownerBirthdayReminder.Salutation__c.split('\\.')[1])),
                    mobilePhone = String.valueOf(plcy.getSObject(ownerBirthdayReminder.Mobile__c.split('\\.')[0]).get(ownerBirthdayReminder.Mobile__c.split('\\.')[1])),
                    phone = String.valueOf(plcy.getSObject(ownerBirthdayReminder.Phone__c.split('\\.')[0]).get(ownerBirthdayReminder.Phone__c.split('\\.')[1])),
                    leadSource = ownerBirthdayReminder.Lead_Source__c,
                    Policy_No__c = plcy.Id,
                    OwnerId = ownerId
                ));
            }
            if (plcy.Notif_Insured_Birthday__c == true) {
                leadList.add(new Lead(
                    firstName = String.valueOf(plcy.getSObject(insuredBirthdayReminder.First_Name__c.split('\\.')[0]).get(insuredBirthdayReminder.First_Name__c.split('\\.')[1])),
                    lastName = String.valueOf(plcy.getSObject(insuredBirthdayReminder.Last_Name__c.split('\\.')[0]).get(insuredBirthdayReminder.Last_Name__c.split('\\.')[1])),
                    salutation = String.valueOf(plcy.getSObject(insuredBirthdayReminder.Salutation__c.split('\\.')[0]).get(insuredBirthdayReminder.Salutation__c.split('\\.')[1])),
                    mobilePhone = String.valueOf(plcy.getSObject(insuredBirthdayReminder.Mobile__c.split('\\.')[0]).get(insuredBirthdayReminder.Mobile__c.split('\\.')[1])),
                    phone = String.valueOf(plcy.getSObject(insuredBirthdayReminder.Phone__c.split('\\.')[0]).get(insuredBirthdayReminder.Phone__c.split('\\.')[1])),
                    leadSource = insuredBirthdayReminder.Lead_Source__c,
                    Policy_No__c = plcy.Id,
                    OwnerId = ownerId
                ));
            }
            if(plcy.Notif_Paidup__c == true) {
                leadList.add(new Lead(
                    firstName = String.valueOf(plcy.getSObject(paidupReminder.First_Name__c.split('\\.')[0]).get(paidupReminder.First_Name__c.split('\\.')[1])),
                    lastName = String.valueOf(plcy.getSObject(paidupReminder.Last_Name__c.split('\\.')[0]).get(paidupReminder.Last_Name__c.split('\\.')[1])),
                    salutation = String.valueOf(plcy.getSObject(paidupReminder.Salutation__c.split('\\.')[0]).get(paidupReminder.Salutation__c.split('\\.')[1])),
                    mobilePhone = String.valueOf(plcy.getSObject(paidupReminder.Mobile__c.split('\\.')[0]).get(paidupReminder.Mobile__c.split('\\.')[1])),
                    phone = String.valueOf(plcy.getSObject(paidupReminder.Phone__c.split('\\.')[0]).get(paidupReminder.Phone__c.split('\\.')[1])),
                    leadSource = paidupReminder.Lead_Source__c,
                    Policy_No__c = plcy.Id,
                    OwnerId = ownerId
                ));
            }
            if(plcy.Notif_Maturity__c == true) {
                leadLIst.add(new Lead(
                    firstName = String.valueOf(plcy.getSObject(maturityReminder.First_Name__c.split('\\.')[0]).get(maturityReminder.First_Name__c.split('\\.')[1])),
                    lastName = String.valueOf(plcy.getSObject(maturityReminder.Last_Name__c.split('\\.')[0]).get(maturityReminder.Last_Name__c.split('\\.')[1])),
                    salutation = String.valueOf(plcy.getSObject(maturityReminder.Salutation__c.split('\\.')[0]).get(maturityReminder.Salutation__c.split('\\.')[1])),
                    mobilePhone = String.valueOf(plcy.getSObject(maturityReminder.Mobile__c.split('\\.')[0]).get(maturityReminder.Mobile__c.split('\\.')[1])),
                    phone = String.valueOf(plcy.getSObject(maturityReminder.Phone__c.split('\\.')[0]).get(maturityReminder.Phone__c.split('\\.')[1])),
                    leadSource = maturityReminder.Lead_Source__c,
                    Policy_No__c = plcy.Id,
                    OwnerId = ownerId
                ));
            }
        }

        System.debug(taskList);
        if(taskList.size() > 0){
            insert taskList;
        }

        System.debug(leadList);
        if(leadList.size() > 0) {
            insert leadList;
        }
    }


    /*
    * Method Name: finish
    * Description: Method executed at the end of the Batch.
                   Not used currently
    * Return Type: nil
    * Parameter: Database.BatchableContext

    */

    global void finish(Database.BatchableContext info){

    }

}