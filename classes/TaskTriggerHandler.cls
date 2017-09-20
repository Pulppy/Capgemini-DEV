public with sharing class TaskTriggerHandler {


	public static void OnBeforeInsert(List<Task> newTaskList) {

	}

	/**
	* function: onAfterInsert
	* if Task is related to Lead, Rollups all tasks and update Last_Activity_Date__c if the date is older
	* 
	*/
	public static void OnAfterInsert(List<Task> newTaskList, Map<Id, Task> newTaskMap) {
		//Map<Id, List<Task>> leadIdToTasks = new Map<Id, List<Task>>();
		Map<Id, List<Task>> leadIdToTasks 	= new Map<Id, List<Task>>();
		String leadPrefix 				  	= Schema.SobjectType.Lead.getKeyPrefix(); // Get the prefix of lead to determine whether a task is a lead task
		List<Lead> leadToUpdate				= new List<Lead>();

		for(Task t: newTaskList) {
			if(t.WhoId != null && ((String)t.WhoId).startsWith(leadPrefix)) {
				if(leadIdToTasks.get(t.WhoId) == null) {
					leadIdToTasks.put(t.WhoId, new List<Task>());
				}
				leadIdToTasks.get(t.WhoId).add(t);
				//leadIdToTasks.put(t.WhoId, t);
			}
		}

		System.debug(leadIdToTasks);
		System.debug(leadPrefix);

		if(leadIdToTasks.size() > 0) {
			// Retrieve the leads which belong to the tasks
			for(Lead l: [SELECT Last_Activity_Date__c FROM Lead WHERE Id IN :leadIdToTasks.keySet()]) {
				for(Task t: leadIdToTasks.get(l.Id)) {
					// For each Task in each lead, check if the task date is later than lead's last activity date
					if(l.Last_Activity_Date__c == null || l.Last_Activity_Date__c < t.ActivityDate) {
						// If it is then update last activity date to be the task's activity date
						l.Last_Activity_Date__c = t.ActivityDate;
						leadToUpdate.add(l);
					}
				}
			}
		}

		System.debug(leadToUpdate);

		if(leadToUpdate.size() > 0) {
			update leadToUpdate;
		}
	}

	public static void OnBeforeUpdate(Map<Id, Task> oldTaskMap, Map<Id, Task> newTaskMap) {

	}

	public static void OnAfterUpdate(Map<Id, Task> oldTaskMap, Map<Id, Task> newTaskMap) {

	}
    
}