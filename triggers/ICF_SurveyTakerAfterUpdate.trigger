trigger ICF_SurveyTakerAfterUpdate on ICF_SurveyTaker__c (after update) {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_SurveyTakerAfterUpdate
-- - Author        : aazafrar 
-- - Description   : Trigger after insert on SurveyTaker
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 10-08-2015   AA    1.0     Initial version
-- Mar-02-2017  SS    2.0     Updated for TCF_ICF to initiate callout upon reply
--------------------------------------------------------------------------------------
*/ 

    if(ICF_PAD.canTrigger('ICF_SurveyTakerTriggerHandler')) {       
        //-Identify the previously generated task and update its status
        ICF_SurveyTakerTriggerHandler.updateTaskStatus(trigger.new);
        
        //- Check active rules and execute the associated actions
        if(trigger.new[0].QRAdded__c == true) {
            ICF_SurveyTakerTriggerHandler.processSurveyTakenResults(trigger.new[0]);//s.Taken__c = true 
        }
        
        //Start: TCF_Mar022017: Added new logic
        for(ICF_SurveyTaker__c  newSurTakenObj : trigger.new) {
            ICF_SurveyTaker__c  oldSurTakenObj  = Trigger.oldMap.get(newSurTakenObj.Id);
            if(newSurTakenObj.Reply_to_eKomi_customer_review__c != oldSurTakenObj.Reply_to_eKomi_customer_review__c) {
                
            }
        }
        //End: TCF_Mar022017: Added new logic 
    }
}