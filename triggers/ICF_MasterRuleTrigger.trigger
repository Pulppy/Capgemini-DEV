trigger ICF_MasterRuleTrigger on ICF_MasterRules__c (before insert, before update) {
/*************************************************************************************
Trigger Name - MasterRuleTrigger
Version - 1.0
Created Date - 05-10-2015
Function - Trigger to manage processes on Master Rule object

-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 05-10-2015   AA    1.0     Initial version
--------------------------------------------------------------------------------------
*/
	if(ICF_PAD.canTrigger('ICF_MasterRuleTriggerHandler')) {
		
	    ICF_MasterRuleTriggerHandler handler = new ICF_MasterRuleTriggerHandler();
	    
	    if(Trigger.isInsert && Trigger.isBefore){
	        handler.checkSObjectField(trigger.new);
	    }
	    else if(Trigger.isUpdate && Trigger.isBefore){
	        handler.checkSObjectField(trigger.new);
	    }
	}
}