trigger ICF_FieldTemplateTrigger on ICF_FieldTemplate__c (before insert, before update) {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_FieldTemplateTrigger
-- - Author        : aazafrar 
-- - Description   : Trigger before insert/update on FieldTemplate (Survey App)
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 05-10-2015   AA    1.0     Initial version
--------------------------------------------------------------------------------------
*/

	if(ICF_PAD.canTrigger('ICF_FieldTemplateTriggerHandler')) {				       
        ICF_FieldTemplateTriggerHandler.checkSObjectField(Trigger.new);	         
    }
}