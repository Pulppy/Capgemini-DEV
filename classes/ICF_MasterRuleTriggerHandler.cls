/*************************************************************************************
Class Name - ICF_MasterRuleTriggerHandler
Version - 1.0
Created Date - 05-10-2015
Function - Class to Manage MasterRuleTrigger

-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 05-10-2015   AA    1.0     Initial version
--------------------------------------------------------------------------------------
*/
public with sharing class ICF_MasterRuleTriggerHandler {   
    
    public void checkSObjectField(list<ICF_MasterRules__c> listMR) {   
    	
    	Id masterRuleRtId = [Select Id From RecordType Where DeveloperName = : ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_MASTERRULE limit 1].Id; 
	    	    
	    for(ICF_MasterRules__c mr : listMR) { 
	    	if(mr.RecordTypeId == masterRuleRtId) {
		    	if(string.IsNotBlank(mr.Select__c) && string.IsNotBlank(mr.Sobject__c) && !ICF_AP_Utility.IsFieldExists(mr.Sobject__c, mr.Select__c)) {
		    		mr.addError(System.Label.LABS_SF_DETAILRULEINVALIDFIELD);
		    	}
	    	}
	    }	    
	}
   
}