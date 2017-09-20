public with sharing class EventTriggerHandler {
    
	public static void OnBeforeInsert(List<Event> newEventList) {

	}

	/**
	* function: onAfterInsert
	* if Event is related to Lead, Rollups all Events and update Last_Activity_Date__c if the date is older
	* 
	*/
	public static void OnAfterInsert(List<Event> newEventList, Map<Id, Event> newEventMap) {
		//Map<Id, List<Event>> leadIdToEvents = new Map<Id, List<Event>>();
		Map<Id, List<Event>> leadIdToEvents 	= new Map<Id, List<Event>>();
		String leadPrefix 				  		= Schema.SobjectType.Lead.getKeyPrefix(); // Get the prefix of lead to determine whether a Event is a lead Event
		List<Lead> leadToUpdate					= new List<Lead>();

		for(Event t: newEventList) {
			if(t.WhoId != null && ((String)t.WhoId).startsWith(leadPrefix)) {
				if(leadIdToEvents.get(t.WhoId) == null) {
					leadIdToEvents.put(t.WhoId, new List<Event>());
				}
				leadIdToEvents.get(t.WhoId).add(t);
				//leadIdToEvents.put(t.WhoId, t);
			}
		}

		System.debug(leadIdToEvents);
		System.debug(leadPrefix);

		if(leadIdToEvents.size() > 0) {
			// Retrieve the leads which belong to the Events
			for(Lead l: [SELECT Last_Activity_Date__c FROM Lead WHERE Id IN :leadIdToEvents.keySet()]) {
				for(Event t: leadIdToEvents.get(l.Id)) {
					// For each Event in each lead, check if the Event date is later than lead's last activity date
					if(l.Last_Activity_Date__c == null || l.Last_Activity_Date__c < t.ActivityDate) {
						// If it is then update last activity date to be the Event's activity date
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

	public static void OnBeforeUpdate(Map<Id, Event> oldEventMap, Map<Id, Event> newEventMap) {

	}

	public static void OnAfterUpdate(Map<Id, Event> oldEventMap, Map<Id, Event> newEventMap) {

	}

}