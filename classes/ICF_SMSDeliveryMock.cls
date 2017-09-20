global class ICF_SMSDeliveryMock implements ICF_ISMSDelivery  {
	  global Map<Id,Task> sendSMS(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pSMSList, Map<Id,Task> pTaskList, Set<Id> pReminderTasks) {
	  	for (Task vTask : pTaskList.values()) {
	  		vTask.Status = ICF_AP_Constant.TaskStatusSent;
	  	}
	    return pTaskList;
	  }
}