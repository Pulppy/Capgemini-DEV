public without sharing class TargetTriggerHandler {
    
	public static void OnBeforeInsert(List<Target__c> newTargets) {

	}

	public static void OnAfterInsert(List<Target__c> newTargets, Map<Id, Target__c> newTargetMap) {
		System.debug(PAD.canRun('SharingManagement'));
		if(PAD.canRun('SharingManagement'))
		{
		    SharingManagement.CreateSharing(newTargets,'Target__c');
		}
	}

	public static void OnBeforeUpdate(Map<Id, Target__c> oldTargetMap, Map<Id, Target__c> newTargetMap) {
		Set<Id> targetShareRemoveSet = new Set<Id>();												// List of Target IDs to recalculate the sharing
		String sharingFields = SharingManagement__c.getValues('Target__c').Sharing_Field__c;		// Field names taken from SharingManagement custom settings that indicates the field to use for sharing
		List<String> sharingFieldList = sharingFields.split(';');									// List of field names that would be used for sharing

		for(Id targetId: newTargetMap.keySet()) {
			Target__c newTarget = newTargetMap.get(targetId);
			Target__c oldTarget = oldTargetMap.get(targetId);

			for(String s: sharingFieldList) {
				if(oldTarget.get(s) != newTarget.get(s)) {
					targetShareRemoveSet.add(targetId);
				}
			}
		}

		if(targetShareRemoveSet.size() > 0) {
			delete [SELECT Id FROM Target__Share WHERE ParentId IN :targetShareRemoveSet AND RowCause = 'manual'];
		}
	}

	public static void OnAfterUpdate(Map<Id, Target__c> oldTargetMap, Map<Id, Target__c> newTargetMap) {
		String sharingFields = SharingManagement__c.getValues('Target__c').Sharing_Field__c;		// Field names taken from SharingManagement custom settings that indicates the field to use for sharing
		List<String> sharingFieldList = sharingFields.split(';');									// List of field names that would be used for sharing
		Map<Id, Target__c> pendingTargetUpdate = new Map<Id, Target__c>();

		for(Id targetId: newTargetMap.keySet()) {
			Target__c newTarget = newTargetMap.get(targetId);
			Target__c oldTarget = oldTargetMap.get(targetId);

			for(String s: sharingFieldList) {
				if(oldTarget.get(s) != newTarget.get(s)) {
					pendingTargetUpdate.put(targetId, newTarget);
				}
			}
		}

		if(pendingTargetUpdate.size() > 0 && PAD.canRun('SharingManagement')) {
			SharingManagement.CreateSharing(pendingTargetUpdate.values(), 'Target__c');
		}
	}
}