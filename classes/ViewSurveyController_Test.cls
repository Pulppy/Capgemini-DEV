@istest(SeeAllData=true)
private class ViewSurveyController_Test{ 
    //------------------------------------------------------------------------------//
    //------------------------------------------------------------------------------//
    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        System.debug(tu.surveyId);
        Apexpages.currentPage().getParameters().put('id',tu.surveyId); 
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc); 
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        //System.assert(tu.surveyId != null);
		
        String ICFprofileId = [Select id from profile where name = 'ICF Profile' limit 1].id;
        
        //user guest = [Select id from user where id='005O0000003yz6I'];
        user guest = [Select id from user where profileid=:ICFprofileId limit 1];
        System.runAs(guest){
        	vsc.submitResults();
        }
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.thankYouRendered);

		vsc.getResponses();
        vsc.resultPage();
        vsc.getAQuestion();
        //test something
    }


    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }

	private static Testmethod void testCheckRequired() {
	    ICF_Survey_Question__c question = new ICF_Survey_Question__c();
        question.Required__c = true;
        
        system.assert(ViewSurveyController.CheckRequired('NO RESPONSE', question)==false);
        system.assert(ViewSurveyController.CheckRequired('test', question)==true);
    }

}