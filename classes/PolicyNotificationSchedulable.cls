global without sharing class PolicyNotificationSchedulable implements Schedulable, Database.Stateful {
    
	global void execute(SchedulableContext SC) {
		// Notifies Agents on Policy events described in CS_Notification_Management__c customs settings
		Database.executeBatch(new PolicyNotificationBatch(), 2000);
	}

}