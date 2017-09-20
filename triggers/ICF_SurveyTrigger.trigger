trigger ICF_SurveyTrigger on ICF_Survey__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_SurveyTrigger
-- - Author        : dlx 
-- - Description   : Trigger Survey
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 07-08-2015   DLX    1.0     Initial version
--------------------------------------------------------------------------------------
*/

    // Remove all CS translations values on deletion
    if (Trigger.isUpdate && Trigger.isAfter) {
        if (ICF_PAD.canTrigger('ICF_AP02_SurveyHandler')) { 
            ICF_AP02_SurveyHandler.removeAllCustomSettingsTranslation(Trigger.newMap);
        }
    }

}