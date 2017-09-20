public with sharing class ICF_FieldTemplateTriggerHandler {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_FieldTemplateTriggerHandler
-- - Author        : aazafrar 
-- - Description   : Trigger Handler Class / called by ICF_FieldTemplateTrigger
--					 Check existence of a field on fieldSet sobject data
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 05-10-2015   AA    1.0     Initial version
-- 26-10-2015    AA    1.1    move IsFieldExists method to ICF_AP_Utility class
--------------------------------------------------------------------------------------
*/

	public static void checkSObjectField(list<ICF_FieldTemplate__c> listFT) {      
	    set<ID> fsIDs = new set<ID>();
	    	    
	    for(ICF_FieldTemplate__c ft : listFT) {
	    	fsIDs.add(ft.FieldSet__c);
	    }
	    
	    for(ICF_Field_Set__c fs : [Select Id, Sobject__c From ICF_Field_Set__c Where Id in :fsIDs]) {
	    	for(ICF_FieldTemplate__c ft : listFT) {
	    		if(fs.Id.equals(ft.FieldSet__c)) {
	    			if(!ICF_AP_Utility.IsFieldExists(fs.Sobject__c, ft.Name)) {
	    				ft.addError(System.Label.LABS_SF_DETAILRULEINVALIDFIELD);
	    			}
	    		}
	    	}
	    }
	}	
}