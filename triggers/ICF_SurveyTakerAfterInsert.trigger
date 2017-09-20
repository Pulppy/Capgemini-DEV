trigger ICF_SurveyTakerAfterInsert on ICF_SurveyTaker__c (after insert) {

    PAD.getInstance().reload();

    /*if (PAD.canRun('AP07')) {
        AP07ICF.checkRespondedSurveyPast180Days(trigger.new);
    }*/
    
}