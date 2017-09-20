public without sharing class AgentKPITriggerHandler {
    
	public static void OnBeforeUpdate(Map<Id, Agent_KPI__c> oldAgentKPIMap, Map<Id, Agent_KPI__c> newAgentKPIMap) {
		Set<Id> agentKPIShareRemoveSet = new Set<Id>();													// List of Agent KPI IDs to recalculate the sharing
		String sharingFields = SharingManagement__c.getValues('Agent_KPI__c').Sharing_Field__c;			// Field names taken from SharingManagement custom settings that indicates the filed to use for sharing
		List<String> sharingFieldList = sharingFields.split(';');										// List of field names that would be used for sharing

		for(Id agentKPIId: newAgentKPIMap.keySet()) {
			Agent_KPI__c newAgentKPI = newAgentKPIMap.get(agentKPIId);
			Agent_KPI__c oldAgentKPI = oldAgentKPIMap.get(agentKPIId);

			for(String s: sharingFieldList) {
				if(oldAgentKPI.get(s) != newAgentKPI.get(s)) {
					agentKPIShareRemoveSet.add(agentKPIId);
				}
			}
		}

		if(agentKPIShareRemoveSet.size() > 0) {
			delete [SELECT Id FROM Agent_KPI__Share WHERE ParentId IN :agentKPIShareRemoveSet AND RowCause = 'manual'];
		}
	}

	public static void onBeforeInsert(List<Agent_KPI__c> newAgentKPIs) {

	}

	public static void onAfterInsert(List<Agent_KPI__c> newAgentKPIs, Map<Id, Agent_KPI__c> newAgentKPIMap) {
		System.debug(PAD.canRun('SharingManagement'));
		if(PAD.canRun('SharingManagement')) {
			SharingManagement.CreateSharing(newAgentKPIs, 'Agent_KPI__c');
		}
	}

	public static void onAfterUpdate(Map<Id, Agent_KPI__c> oldAgentKPIMap, Map<Id, Agent_KPI__c> newAgentKPIMap) {
		String sharingFields = SharingManagement__c.getValues('Agent_KPI__c').Sharing_Field__c;
		List<String> sharingFieldList = sharingFields.split(';');
		Map<Id, Agent_KPI__c> pendingAgentKPIUpdate = new Map<Id, Agent_KPI__c>();

		for(Id agentKPIId: newAgentKPIMap.keySet()) {
			Agent_KPI__c newAgentKPI = newAgentKPIMap.get(agentKPIId);
			Agent_KPI__c oldAgentKPI = oldAgentKPIMap.get(agentKPIId);

			for(String s: sharingFieldList) {
				if(oldAgentKPI.get(s) != newAgentKPI.get(s)) {
					pendingAgentKPIUpdate.put(agentKPIId, newAgentKPI);
				}
			}
		}

		if(pendingAgentKPIUpdate.size() > 0 && PAD.canRun('SharingManagement')) {
			SharingManagement.CreateSharing(pendingAgentKPIUpdate.values(), 'Agent_KPI__c');
		}
	}

}