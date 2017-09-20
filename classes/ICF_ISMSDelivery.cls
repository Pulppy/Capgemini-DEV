global interface ICF_ISMSDelivery { 
	Map<Id, Task> sendSMS(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pSMSList, Map<Id, Task> pTaskList, Set<Id> pReminderTasks);
}