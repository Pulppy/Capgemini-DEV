public with sharing class ICF_AP02_SurveyHandler {

    /*
    * Remove all custom setting translation
    */
    public static void removeAllCustomSettingsTranslation(Map<Id, ICF_Survey__c> pSurveyMap) {

        List<Id> vSurveysToArchived = new List<Id>();
        // Get all the survey getting archived
        for (ICF_Survey__c vSurvey : pSurveyMap.values()) {
            if (vSurvey.Survey_Status__c == ICF_AP_Constant.STATUS_ARCHIVED) {
                vSurveysToArchived.Add(vSurvey.Id);
            }
        }
        // Get all translations
        List<ICF_SurveyTranslation__c> vTranslationsToDelete = [SELECT Id FROM ICF_SurveyTranslation__c WHERE SurveyId__c IN :vSurveysToArchived];

        // Remove it
        if (vTranslationsToDelete != null) {
            delete vTranslationsToDelete;
        }
    }
}