@isTest
private class SurveyManagerController_Test {
    @isTest(seeAllData=True)
    private static void doTest(){
        PageReference pageRef = Page.SurveyManagerPage;
        Test.setCurrentPage(pageRef);

        ICF_Survey__c s = new ICF_Survey__c();
        s.Name = 'test survey';
        s.Submit_Response__c = 'response';
        insert s;
        ApexPages.StandardController sc = new ApexPages.StandardController(s);

        SurveyManagerController con = new SurveyManagerController(sc);
        con.save();
        System.assertEquals(con.surveyId, s.Id);
        //String url = con.getResults().getUrl();
        //System.assertEquals(url, '/'+con.reportId + '?pv0='  + con.surveyId);
    }
}