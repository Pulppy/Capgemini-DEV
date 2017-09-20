public with sharing class ICF_viewSurveyResultsComponentController {

    public String surveyId {get; set;}
    public String reportId {get; set;}
    public String reportNoParamsId {get; set;}
    public PageReference results;

    public ICF_viewSurveyResultsComponentController() {
        ICF_ReportFinderUtil rfu = new ICF_ReportFinderUtil();
        reportId = rfu.findReportId(System.Label.LABS_SF_ICF_Survey_with_Questions_and_Responses);
        reportNoParamsId = rfu.findReportId(System.Label.LABS_SF_ICF_Survey_No_Params);
    }

    public pageReference getResults() {
        surveyId = surveyId.substring(0, 15);
        return new PageReference('/' + reportId + '?pv0=' + surveyId);
    }

    public String getResultsPreview() {
        surveyId = surveyId.substring(0, 15);
        return '/' + reportId + '?pv0=' + surveyId + '&isdtp=vw';
    }

    private static testmethod void testResultController() {
        ICF_Survey__c mySurvey = new ICF_Survey__c();
        mySurvey.Submit_Response__c = 'empty';
        insert mySurvey;

        ICF_viewSurveyResultsComponentController vsr = new ICF_viewSurveyResultsComponentController();
        vsr.surveyId = mySurvey.Id;

        String mySurveyId = mySurvey.Id;
        PageReference pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0, 15));
        System.assertEquals(pageRef.getURL(), vsr.getResults().getURL());

        pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0, 15));
        System.assertEquals('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0, 15) + '&isdtp=vw', vsr.getResultsPreview());
    }

}