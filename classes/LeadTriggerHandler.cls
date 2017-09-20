public without sharing class LeadTriggerHandler {
    
	public static void onBeforeUpdate(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
		Map<Id, List<Lead>> ownerIdToLead = new Map<Id, List<Lead>>();						// Map of Lead Owner Ids to Leads
		Set<Id> ownerIds = new Set<Id>();													// Set of Lead owner Ids
		Map<String,Lead> ap12MapWithAgentCodeToLead = new Map<String,Lead>();				// Map of Id and Agent Codes keys to Lead record
		Set<Id> leadShareRemoveSet = new Set<Id>();											// List of Lead IDs to recalculate the sharing
		String sharingFields = SharingManagement__c.getValues('Lead').Sharing_Field__c;		// Field names taken from SharingManagement custom settings that indicates the field to use for sharing
		List<String> sharingFieldList = sharingFields.split(';');							// List of field names that would be used for sharing

	    for(Id leadId: newLeadMap.keySet()) {
	    	Lead newLead = newLeadMap.get(leadId);
	    	Lead oldLead = oldLeadMap.get(leadId);
	        //AP12
	        if(PAD.canRun('AP12') 
	            &&newLead.OwnerId != oldLead.OwnerId 
				&&newLead.OwnerId.getSObjectType() == User.SObjectType
			) {
				Id ownerId = newLead.OwnerId;
				ownerIds.add(ownerId);

				if(ownerIdToLead.get(ownerId) == null) {
					ownerIdToLead.put(ownerId, new List<Lead>());
				}
				ownerIdToLead.get(ownerId).add(newLead);
	        }//end of AP12

	        // Recalculate Lead sharing
	        for(String s: sharingFieldList) {
	        	if(oldLead.get(s) != newLead.get(s)) {
	        		leadShareRemoveSet.add(leadId);
	        	}
	        }
	    }

	    // TODO: ap12MapWithAgentCodeToLead cannot handle multiple leads belonging to the same user!
	    if(ownerIds.size() > 0) {
	    	for(User u: [SELECT Agent_Code__c, Id FROM User WHERE Id IN :ownerIds]) {
	    		for(Lead l: ownerIdToLead.get(u.Id)) {
	    			ap12MapWithAgentCodeToLead.put(l.Id + ';' + u.Agent_Code__c, l);
	    		}
	    	}
	    }
	   
	    if(PAD.canRun('AP12')) { 
	        if(ap12MapWithAgentCodeToLead.size() > 0) {
				AP12TargetAssignmentToLead.updateTargetAssignment(ap12MapWithAgentCodeToLead);
	        }
	    }

	    // Delete old SharingManagement
	    if(leadShareRemoveSet.size() > 0) {
	    	delete [SELECT Id FROM LeadShare WHERE LeadId IN :leadShareRemoveSet AND RowCause = 'manual'];
	    }
	}

	public static void onAfterUpdate(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
		// Invoke SharingManagement
		Set<Id> leadShareRemoveSet = new Set<Id>();											// List of Lead IDs to recalculate the sharing
		String sharingFields = SharingManagement__c.getValues('Lead').Sharing_Field__c;		// Field names taken from SharingManagement custom settings that indicates the field to use for sharing
		List<String> sharingFieldList = sharingFields.split(';');							// List of field names that would be used for sharing
		List<Task> taskList = new List<Task>();												// List of tasks to be assigned to ASM/RSM according to ASM_Notice_Date_Time__c & RSM_Notice_Date_Time__c
		Set<Id> targetIds = new Set<Id>();
		Map<Id, Lead> pendingLeadUpdate = new Map<Id, Lead>();

		for(Id leadId: newLeadMap.keySet()) {
			Lead newLead = newLeadMap.get(leadId);
			Lead oldLead = oldLeadMap.get(leadId);

			for(String s: sharingFieldList) {
				if(oldLead.get(s) != newLead.get(s)) {
					pendingLeadUpdate.put(leadId, newLead);
				}
			}

			if(newLead.Target_ASM_UM__c != null && newLead.ASM_Notice_Date_Time__c != null && oldLead.ASM_Notice_Date_Time__c == null) {
				targetIds.add(newLead.Target_ASM_UM__c);
			} else if(newLead.Target_RSM_AM__c != null && newLead.RSM_Notice_Date_Time__c != null && oldLead.RSM_Notice_Date_Time__c == null) {
				targetIds.add(newLead.Target_RSM_AM__c);
			}

			/*if(newLead.Target_ASM_UM__c != null &&
				oldLead.ASM_Notice_Date_Time__c == null &&
				newLead.ASM_Notice_Date_Time__c != null) {

				DateTime dt = newLead.ASM_Notice_Date_Time__c;
				// TODO: Create new Task and assign to ASM
				taskList.add(new Task(
					OwnerId = newLead.OwnerId,
					ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
					//WhatId = leadId,
					WhoId = leadId,
					Subject = 'Notice',
					Type = 'Lead Management'
				));
			} else if(newLead.Target_RSM_AM__c != null &&
						oldLead.RSM_Notice_Date_Time__c == null &&
						newLead.RSM_Notice_Date_Time__c != null) {

				DateTime dt = newLead.RSM_Notice_Date_Time__c;
				// TODO: Create new Task and assign to RSM
				taskList.add(new Task(
					OwnerId = newLead.OwnerId,
					ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
					WhoId = leadId,
					Subject = 'Notice',
					Type = 'Lead Management'
				));
			}*/
		}

		System.debug(targetIds);
		if(targetIds.size() > 0) {
			// Notify RSM or ASM
			Map<Id, Target__c> targetsMap = new Map<Id, Target__c>([SELECT OwnerId FROM Target__c WHERE Id IN :targetIds]);

			for(Id leadId: newLeadMap.keySet()) {
				Lead newLead = newLeadMap.get(leadId);
				Lead oldLead = oldLeadMap.get(leadId);

				if(newLead.Target_ASM_UM__c != null && newLead.ASM_Notice_Date_Time__c != null && oldLead.ASM_Notice_Date_Time__c == null) {
					DateTime dt = newLead.ASM_Notice_Date_Time__c;
					// Create new Task and assign to ASM
					taskList.add(new Task(
						OwnerId = targetsMap.get(newLead.Target_ASM_UM__c).OwnerId,
						ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
						//WhatId = leadId,
						WhoId = newLead.Id,
						Subject = 'Notice',
						Type = 'Lead Management'
					));
				} else if(newLead.Target_RSM_AM__c != null && newLead.RSM_Notice_Date_Time__c != null && oldLead.RSM_Notice_Date_Time__c == null) {
					DateTime dt = newLead.RSM_Notice_Date_Time__c;
					taskList.add(new Task(
						OwnerId = targetsMap.get(newLead.Target_RSM_AM__c).OwnerId,
						ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
						//WhatId = leadId,
						WhoId = newLead.Id,
						Subject = 'Notice',
						Type = 'Lead Management'
					));
				}
			}
		}

		if(pendingLeadUpdate.size() > 0 && PAD.canRun('SharingManagement')) {
			SharingManagement.CreateSharing(pendingLeadUpdate.values(), 'Lead');
		}

		System.debug(taskList);
		if(taskList.size() > 0) {
			insert taskList;
		}
	}

	public static void onBeforeInsert(List<Lead> newLeads) {
		List<Lead> leadList = new List<Lead>();

	    Set<Id> userIds = new Set<Id>();
	    Map<Id, String> userIdToAgentCode = new Map<Id, String>();
	    for(Lead l: newLeads) {
	    	if(l.OwnerId.getSObjectType() == User.SObjectType) {
	    		userIds.add(l.OwnerId);
	    		leadList.add(l);
	    	}
	    }
	    if(userIds.size() > 0) {
	    	for(User u: [SELECT Agent_Code__c FROM User WHERE Id IN :userIds]) {
	    		userIdToAgentCode.put(u.Id, u.Agent_Code__c);
	    	}
	    }


	    if(PAD.canRun('AP12')) {
	        if(leadList.size() > 0) {
				//AP12TargetAssignmentToLead.insertTargetAssignment(leadList, agentcode);
				AP12TargetAssignmentToLead.insertTargetAssignment(leadList, userIdToAgentCode);
	        }
	    }

	}

	public static void onAfterInsert(List<Lead> newLeads, Map<Id, Lead> newLeadMap) {
		List<Task> taskList = new List<Task>();
		Set<Id> targetIds = new Set<Id>();

		for(Lead l : newLeads) {
			if(l.Target_ASM_UM__c != null && l.ASM_Notice_Date_Time__c != null) {
				targetIds.add(l.Target_ASM_UM__c);
			} else if(l.Target_RSM_AM__c != null && l.RSM_Notice_Date_Time__c != null) {
				targetIds.add(l.Target_RSM_AM__c);
			}
		}

		Map<Id, Target__c> targetsMap = new Map<Id, Target__c>([SELECT OwnerId FROM Target__c WHERE Id IN :targetIds]);

		for(Lead l : newLeads) {
			if(l.Target_ASM_UM__c != null && l.ASM_Notice_Date_Time__c != null) {
				DateTime dt = l.ASM_Notice_Date_Time__c;
				// Create new Task and assign to ASM
				taskList.add(new Task(
					//OwnerId = l.OwnerId, //l.Target_ASM_UM__c,
					OwnerId = targetsMap.get(l.Target_ASM_UM__c).OwnerId,
					ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
					//WhatId = leadId,
					WhoId = l.Id,
					Subject = 'Notice',
					Type = 'Lead Management'
				));
			} else if(l.Target_RSM_AM__c != null && l.RSM_Notice_Date_Time__c != null) {
				DateTime dt = l.RSM_Notice_Date_Time__c;
				taskList.add(new Task(
					//OwnerId = l.OwnerId, //l.Target_RSM_AM__c,
					OwnerId = targetsMap.get(l.Target_RSM_AM__c).OwnerId,
					ActivityDate = Date.newInstance(dt.year(), dt.month(), dt.day()),
					//WhatId = leadId,
					WhoId = l.Id,
					Subject = 'Notice',
					Type = 'Lead Management'
				));
			}
		}

		System.debug(taskList);
		if(taskList.size() > 0) {
			insert taskList;
		}

		// Invoke SharingManagement
		System.debug(PAD.canRun('SharingManagement'));
		if(PAD.canRun('SharingManagement'))
		{
		    SharingManagement.CreateSharing(newLeads,'Lead');
		}
	}

}