global interface ICF_IEmailDelivery {
	
	Map<Id, Task> sendEmails(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pEmailList,  Map<Id, Task> pMapTaskUpdates, Set<Id> pRemindTasks);

}