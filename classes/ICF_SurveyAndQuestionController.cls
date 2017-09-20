global virtual with sharing class ICF_SurveyAndQuestionController { // extends SurveyAndQuestionController{


    //BCH update 03/02/2015 - need to handle 2 new question types email and picklist*/
    public List<SelectOption> picklistOptions     { get; set; }
    public String  showPicklist                   { get; set; }
    public String  showPicklistPreview            { get; set; }
    public String  showEmail                      { get; set; }
    public String  showEmailPreview               { get; set; }
    public String  showPhone                      { get; set; }
    public String  showPhonePreview               { get; set; }
    
    
    public List<SelectOption> questionTypeOptions { get; set; }
    public String  showBasicValues                { get; set; }
    public String  showSingleSelect               { get; set; }
    public String  showSingleSelectPreview        { get; set; }
    public String  showMultiSelect                { get; set; }
    public String  showMultiSelectPreview         { get; set; }
    public String  showFreeText                   { get; set; }
    public String  showFreeTextPreview            { get; set; }
    public String  showRowQuestion                { get; set; }
    public String  showRowQuestionPreview         { get; set; }
    public String  showMatrixSingleSelect         { get; set; }
    public String  showMatrixSingleSelectPreview  { get; set; }
    public String  showMatrixMultiSelect          { get; set; }
    public String  showMatrixMultiSelectPreview   { get; set; }
    public String  showSelectQuestionType         { get; set; }
    public List<SelectOption> singleOptions       { get; set; }
    public List<SelectOption> multiOptions        { get; set; }
    public List<SelectOption> rowOptions          { get; set; }
    public List<SelectOption> matrixOptions       { get; set; }
    public String  questionReference              { get; set; }
    public String  reportId                       { get; set; }
    private Boolean saveAndNew;
    private String  surveyRef;
    private String surveyOrderNumber;
    private ICF_Survey_Question__c questionToUpdate;
    /***/
    public String qQuestion        { get; set; }
    public Boolean qRequired       { get; set; }
    public Boolean qSmileyQuestion { get; set; }
    public String qChoices         { get; set; }
    public String qSubQuestions    { get; set; }
    public String surveyName       { get; set; }
    public String surveyHeader     { get; set; }

    //BCH added on 12/03/2015
    public String surveyFooter         { get; set; }
    public String surveyLanguage       { get; set; }    
    public String surveyId             { get; set; }
    public String renderSurveyPreview  { get; set; }
    public String questionName         { get; set; }
    public String questionType         { get; set; }
    public Boolean questionRequired    { get; set; }
    public List<question> allQuestions { get; set; }
    public List<String> responses      { get; set; }
    public Integer allQuestionsSize    { get; set; }
    public String  templateURL         { get; set; }
    public String  surveyThankYouText  { get; set; }
    public String  surveyThankYouURL   { get; set; }
    public String  caseId              { get; set; }
    public List<String> newOrder       { get; set; }
    public String newOrderW            { get; set; }
	
    //TCF_Feb172017 START: New variables for ICF
    public Boolean surveySendToEKOMI					{ get; set; }
    public String qSendToEKOMIAs						{ get; set; }
    public List<SelectOption> sendToEKOMIAsOptions		{ get; set; }
	//TCF_Feb172017 END: New variables for ICF
	
    public  ICF_SurveyAndQuestionController (ApexPages.StandardController stdController) {
        /**/
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        newOrder = new List<String>();
        if (caseId == null || caseId.length() < 5) {
            caseId = 'none';
        }
        // By default the preview is not showing up
        renderSurveyPreview = 'false';

        if (surveyId != null) {
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<question>();
            setSurveyNameAndThankYou(surveyId);
        }
        /**/
        surveyRef = surveyId;
        setupQuestionTypeOptions();
        resetViewsToFalse(true);
        showSelectQuestionType = 'False';
        ICF_ReportFinderUtil rfu = new ICF_ReportFinderUtil();
        reportId = rfu.findReportId('ICF Survey with Questions and Responses');
		
        //TCF_Feb172017 START: Call setupSendToEKOMIAsOptions method
        setupSendToEKOMIAsOptions();
        //TCF_Feb172017 END: Call setupSendToEKOMIAsOptions method    
    }

    public Pagereference makeNewQuestionLink() {
        questionReference = null;
        resetViewsToFalse(true);
        return null;
    }

    public Pagereference editQuestion() {
        if (questionReference == null)
            return null;
        setupEditQuestion();
        showSelectQuestionType = 'True';
        return null;
    }

    public Pagereference addQuestion() {
        showSelectQuestionType = 'True';
        resetViewsToFalse(true);
        return null;
    }

    private void setupEditQuestion() {
        System.debug('################ setupEditQuestion');
        questionToUpdate = [Select Type__c, Question__c, Id, Required__c, Choices__c,
                                OrderNumber__c, Survey__c, Name, Sub_Question__c, Is_Smiley_matrix__c, Send_To_EKOMI_as__c, //TCF_Feb172017 : Added Send_To_EKOMI_as__c to query
                                (SELECT Id, Sub_Question__c, OrderNumber__c FROM Survey_Questions_Childs__r ORDER BY OrderNumber__c)
                                From ICF_Survey_Question__c
                                where Id = :questionReference];
        questionType = questionToUpdate.Type__c;
        setupQuestionFields();
        setupEditFields(questionToUpdate);
    }

    //BCH update 03/02/2015 - handle the 2 new types
    public Pagereference setupQuestionFields() {
        System.debug('######################## Type ---->' + questionType);
        resetViewsToFalse(false);
        if (questionType == 'Multi-Select--Vertical') {
            showMultiSelect = 'True';
        } else if (questionType == 'Single Select--Vertical') {
            showSingleSelect = 'True';
        } else if (questionType == 'Free Text') {
            showFreeText = 'True';
        } else if (questionType == 'Single Select--Horizontal') {
            showRowQuestion = 'True';
        } else if (questionType == 'Email') {
            showEmail = 'True';
        } else if (questionType == 'Picklist') {
            showPicklist = 'True';
        } else if (questionType == 'Phone') {
            showPhone = 'True';
        } else if (questionType == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) {
            showMatrixSingleSelect = 'True';
        } else if (questionType == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
            showMatrixMultiSelect = 'True';
        }

        return null;
    }

    private void setupEditFields(ICF_Survey_Question__c q) {
        qQuestion = q.Question__c;
        qRequired = q.Required__c;
        qSmileyQuestion = q.Is_Smiley_matrix__c;
        qChoices  = q.Choices__c;
        qSendToEKOMIAs = q.Send_to_EKOMI_as__c; //TCF_Feb172017 :  Added Send_to_EKOMI_as__c
        // Matrix 
        if (q.Survey_Questions_Childs__r != null && q.Survey_Questions_Childs__r.size() > 0) {
            qSubQuestions = q.Sub_Question__c;
            for (ICF_Survey_Question__c vSubQuestion : q.Survey_Questions_Childs__r) {
                qSubQuestions += '\n' + vSubQuestion.Sub_Question__c;                 
            }
        } else {
            qSubQuestions = null;
        }
        surveyRef = q.Survey__c;        
    }

    private void setupQuestionTypeOptions() {
        //get picklist values
        Schema.DescribeFieldResult fieldResult = ICF_Survey_Question__c.Type__c.getDescribe();
        List<Schema.PicklistEntry>  ple = fieldResult.getPicklistValues();

        //set/add them to selectOption list
        questionTypeOptions = new List<SelectOption>();
        questionTypeOptions.add(new SelectOption('--SELECT--', System.Label.LABS_SF_SELECTTYPE));
        for (Schema.PicklistEntry pe : ple) {
            questionTypeOptions.add(new SelectOption(pe.getLabel(), pe.getValue()));
        }
    }
    
    //TCF_Feb172017 START: Create method for getting picklist values of Send to EKOMI as custom field
    private void setupSendToEKOMIAsOptions() {
        //get picklist values
        Schema.DescribeFieldResult fieldResult = ICF_Survey_Question__c.Send_To_EKOMI_as__c.getDescribe();
        List<Schema.PicklistEntry>  ple = fieldResult.getPicklistValues();

        //set/add them to selectOption list
        sendToEKOMIAsOptions = new List<SelectOption>();
        sendToEKOMIAsOptions.add(new SelectOption('--SELECT--', System.Label.LABS_SF_SELECTTYPE));
        for (Schema.PicklistEntry pe : ple) {
            sendToEKOMIAsOptions.add(new SelectOption(pe.getLabel(), pe.getValue()));
        }
    }
	//TCF_Feb172017 END: Create method for getting picklist values of Send to EKOMI as custom field
    
    //BCH update 03/02/2015 to reset the new field types
    private void resetViewsToFalse(Boolean clearFields) {
        showPicklist                  = 'False';
        showPicklistPreview           = 'False';
        showEmail                     = 'False';
        showEmailPreview              = 'False';
        showSingleSelect              = 'False';
        showSingleSelectPreview       = 'False';
        showMultiSelect               = 'False';
        showMultiSelectPreview        = 'False';
        showFreeText                  = 'False';
        showFreeTextPreview           = 'False';
        showRowQuestion               = 'False';
        showRowQuestionPreview        = 'False';
        showPhone                     = 'False';
        showPhonePreview              = 'False';
        showMatrixSingleSelect        = 'False';
        showMatrixSingleSelectPreview = 'False';
        showMatrixMultiSelect         = 'False';
        showMatrixMultiSelectPreview  = 'False';

        qRequired = true;
        if (clearFields) {
            qChoices  = '';
            qQuestion = '';
            qSubQuestions = '';
            qSendToEKOMIAs = ''; //TCF_Feb172017 :  Clear qSendToEKOMIAs variable
        }
    }


    public Pagereference saveAndNewQuestion() {
        saveAndNew = True;
        if (questionReference == null || questionReference.length() < 5)
            return saveNewQuestion();
        else
            return updateQuestion();
    }

    public Pagereference controllerSavQuestion() {
        if (questionReference == null || questionReference.length() < 5) {
            return saveNewQuestion();
        } else {
            return updateQuestion();
        }
    }

    private Pagereference updateQuestion() {
        //questionToUpdate is setup in an earlier call to editQuestion()
        questionToUpdate.Name = questionToName(qQuestion);
        questionToUpdate.Choices__c = qChoices;
        questionToUpdate.Required__c = qRequired;
        questionToUpdate.Type__c = questionType;
        questionToUpdate.Question__c = qQuestion;
        //TCF_Feb172017 START:  Added Send_to_EKOMI_as__c  
        if(surveySendToEKOMI == true) {
        	questionToUpdate.Send_To_EKOMI_as__c = qSendToEKOMIAs;   
        }
        //TCF_Feb172017 END:  Added Send_to_EKOMI_as__c 
        questionToUpdate.Is_Smiley_matrix__c = qSmileyQuestion;
        
        // Retrieve list of sub questions      

        List<ICF_Survey_Question__c> vQuestionsToUpdate = new List<ICF_Survey_Question__c>();
        List<ICF_Survey_Question__c> vQuestionsToDelete = new List<ICF_Survey_Question__c>();
        List<ICF_Survey_Question__c> vQuestionsToAdd = new List<ICF_Survey_Question__c>();
        if (qSubQuestions != null) {  
            List<String> vSubQuestions = ICF_AP_Utility.stringToStringList(qSubQuestions);

            if (qSmileyQuestion) {
                List<String> vChoices = ICF_AP_Utility.stringToStringList(qChoices);
                if (vChoices == null || vChoices.size() != 5) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_ICF_SmileyMatrixNoChoices));
                    return null;
                }
            }
            if (vSubQuestions != null && vSubQuestions.size() > 1) {
                questionToUpdate.Sub_Question__c = vSubQuestions[0];
                vSubQuestions.remove(0); // Remove the main question 

                // 3 possibilities : Same number of questions than previously : update
                // new list > old one : Update and add
                // New list < old one : Update and delete
                // 1st Case more old questions than new --> delete to do
                System.debug('################### vSubQuestions.size() : ' + vSubQuestions.size());
                System.debug('################### questionToUpdate.Survey_Questions_Childs__r.size() : ' + questionToUpdate.Survey_Questions_Childs__r.size());
                // First possibility : more old values
                if (vSubQuestions.size() < questionToUpdate.Survey_Questions_Childs__r.size()) {
                    Integer i = 0;
                    for (String vSubQuestion : vSubQuestions) {
                        System.debug('################### i : ' + i);
                        System.debug('################### questionToUpdate.Survey_Questions_Childs__r.size() : ' + questionToUpdate.Survey_Questions_Childs__r.size());
                         
                        ICF_Survey_Question__c vCurrentSubQuestion = questionToUpdate.Survey_Questions_Childs__r[i];
                        vCurrentSubQuestion = updateQuestionInfos(vCurrentSubQuestion, qChoices, questionToName(qQuestion), qRequired, questionType, qQuestion, vSubQuestion, null);              
                        vQuestionsToUpdate.add(vCurrentSubQuestion);
                        
                        i++;
                    }
                    for (Integer j = i; j < questionToUpdate.Survey_Questions_Childs__r.size(); j++) {
                        vQuestionsToDelete.Add(questionToUpdate.Survey_Questions_Childs__r[j]);
                    }
                // 2nd case more new Questions than old --> Add to do
                } else if (vSubQuestions.size() > questionToUpdate.Survey_Questions_Childs__r.size())  { 
                    Integer i = 0;
                    Integer lastOrderNumber = Integer.valueOf(questionToUpdate.OrderNumber__c);
                    for (String vSubQuestion : vSubQuestions) {
                        System.debug('################### i : ' + i);                        
                        Boolean vIsNew = true;
                        ICF_Survey_Question__c vCurrentSubQuestion = new ICF_Survey_Question__c();
                        // if old question (already exists)
                        if (i < questionToUpdate.Survey_Questions_Childs__r.size()) {
                            vIsNew = false;
                            vCurrentSubQuestion = questionToUpdate.Survey_Questions_Childs__r[i];     
                        }
                        vCurrentSubQuestion = updateQuestionInfos(vCurrentSubQuestion, qChoices, questionToName(qQuestion), qRequired, questionType, qQuestion, vSubQuestion, questionToUpdate.Id);              
                        vCurrentSubQuestion.OrderNumber__c = lastOrderNumber + i + 1;
                        if (vIsNew) {
                            System.debug('################### vQuestionsToAdd ' + vCurrentSubQuestion);      
                            vCurrentSubQuestion.Survey__c = surveyRef;    
                            vQuestionsToAdd.Add(vCurrentSubQuestion);
                        } else {
                            System.debug('################### vQuestionsToUpdate ' + vCurrentSubQuestion);       
                            vQuestionsToUpdate.add(vCurrentSubQuestion);
                        }
                        i++;
                    }
                // Sames number of questions
                } else {
                    Integer i = 0;
                    for (String vSubQuestion : vSubQuestions) { 
                        System.debug('################### Survey_Questions_Childs__r' + questionToUpdate.Survey_Questions_Childs__r);
                        ICF_Survey_Question__c vCurrentSubQuestion = questionToUpdate.Survey_Questions_Childs__r[i];     
                        vCurrentSubQuestion = updateQuestionInfos(vCurrentSubQuestion, qChoices, questionToName(qQuestion), qRequired, questionType, qQuestion, vSubQuestion, null);              

                        vQuestionsToUpdate.add(vCurrentSubQuestion);
                        i++;
                    }
                }
            }
        }

        try {
            // If case of multiple question
            if (vQuestionsToUpdate != null) {
                vQuestionsToUpdate.add(questionToUpdate);
                update vQuestionsToUpdate;
                insert vQuestionsToAdd;
                delete vQuestionsToDelete;
                // Reorder
                reupdateOrderList();
                
            } else {
                // normal case
                update questionToUpdate;                
            }
            resetViewsToFalse(true);
            questionReference = null;
        } catch (Exception e) {
            System.debug('##########################' + e);
            Apexpages.addMessages(e);
        }

        return saveOrUpdateReturn();
    }

    private ICF_Survey_Question__c updateQuestionInfos(ICF_Survey_Question__c pQuestion, String pChoices, String pName, Boolean pRequired, String pType, String pQuestionTitle, String pSubQuestion, String pParentId) {
        if (pQuestion == null) {
            return null;
        }
        pQuestion.Choices__c = pChoices;
        pQuestion.Name = pName;
        pQuestion.Required__c = pRequired;
        pQuestion.Type__c = pType;
        pQuestion.Question__c = pQuestionTitle;
        pQuestion.Sub_Question__c = pSubQuestion;
        if (pParentId != null) {
            pQuestion.Survey_Question_parent__c = pParentId; 
        }
        return pQuestion;
    }


    private Pagereference saveOrUpdateReturn() {
        setupQuestionList();
        Pagereference pr = new Pagereference('/apex/ICF_SurveyPage?id=' + surveyRef);
        questionType = '--SELECT--';
        if (saveAndNew != null  && saveAndNew == true) {
            saveAndNew = False;
            showSelectQuestionType = 'True';
            return pr;
        } else {
            showSelectQuestionType = 'False';
            return pr;
        }
    }

    private Integer getNewQuestionNum() {
        if (allQuestions == null)
            return 0;
        else {
            // Sub questions addition 
            Integer vSubQuestionsSize = 0;
            for (Question vQuestion : allQuestions) {
                if (vQuestion.childQuestions != null) {
                    vSubQuestionsSize += vQuestion.childQuestions.size();
                }
            }

            return allQuestions.size() + vSubQuestionsSize;
        }
    }

    private Pagereference saveNewQuestion() {
        if (questionType == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT || questionType == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
            System.debug('############### questionType : ' + questionType);
            // Split subQuestions
            List<String> vAllSubQuestions = qSubQuestions.split('\\r|\n');
            List<ICF_Survey_Question__c> vQuestionsToSave = new List<ICF_Survey_Question__c>();
            Integer i = getNewQuestionNum();
            Integer vFirstQuesionIndex = i;
            System.debug('############### vFirstQuesionIndex : ' + vFirstQuesionIndex);

            for (String vSubQuestion : vAllSubQuestions) {
                // skip blank lines
                if (!String.isEmpty(vSubQuestion.trim())) {
                    ICF_Survey_Question__c vQuestion = new ICF_Survey_Question__c();
                    vQuestion.Survey__c = surveyRef;
                    vQuestion.Name = questionToName(qQuestion);
                    vQuestion.Sub_Question__c = vSubQuestion;
                    vQuestion.Choices__c = qChoices;
                    vQuestion.Required__c = qRequired;
                    vQuestion.Type__c = questionType;
                    vQuestion.OrderNumber__c = i;
                    vQuestion.Question__c = qQuestion;
                    vQuestionsToSave.add(vQuestion);
                    i++;
                }
            }            
            System.debug('############### vQuestionsToSave : ' + vQuestionsToSave);

            try {
                // Insert First Question
                ICF_Survey_Question__c vFirstQuestion = vQuestionsToSave[0];
                //TCF_Feb172017 START: Added Send_to_EKOMI_as__c for insert 
                    if(surveySendToEKOMI == true) {
                      vFirstQuestion.Send_to_EKOMI_as__c = qSendToEKOMIAs; 
                    }
                //TCF_Feb172017 END: Added Send_to_EKOMI_as__c for insert 
                insert vFirstQuestion;                
                System.debug('############### vFirstQuestion : ' + vFirstQuestion);
                // Remove the first question, parent of all the others
                vQuestionsToSave.remove(0);
                for (ICF_Survey_Question__c vQuestion : vQuestionsToSave) {
                    vQuestion.Survey_Question_Parent__c = vFirstQuestion.Id;
                }
                System.debug('############### vQuestionsToSave : ' + vQuestionsToSave);
                insert vQuestionsToSave;

            } catch (Exception e) {
                Apexpages.addMessages(e);
                return null;
            }
        } else {
            ICF_Survey_Question__c newQuestion = new ICF_Survey_Question__c();
            newQuestion.Survey__c = surveyRef;
            newQuestion.Name = questionToName(qQuestion);
            newQuestion.Choices__c = qChoices;
            newQuestion.Required__c = qRequired;
            newQuestion.Type__c = questionType;
            newQuestion.OrderNumber__c = getNewQuestionNum();
            newQuestion.Question__c = qQuestion;
            //TCF_Feb172017 START: Added Send_to_EKOMI_as__c for insert 
            if(surveySendToEKOMI == true) {
            	newQuestion.Send_to_EKOMI_as__c = qSendToEKOMIAs; 
            }
            //TCF_Feb172017 END: Added Send_to_EKOMI_as__c for insert 
            resetViewsToFalse(true);
            try {
                insert newQuestion;
            } catch (Exception e) {
                System.debug(e);
            }
        }

        return saveOrUpdateReturn();
    }

    private String questionToName(String q) {
        if (q.length() < 75)
            return q;
        else
            return q.substring(0, 75) + '...';
    }

    public Pagereference previewQuestion() {
        if (questionType  == 'Multi-Select--Vertical') {
            showMultiSelectPreview = 'True';
            multiOptions = stringToSelectOptions(qChoices);
        } else if (questionType == 'Single Select--Vertical') {
            showSingleSelectPreview = 'True';
            singleOptions = stringToSelectOptions(qChoices);
        } else if (questionType == 'Free Text') {
            showFreeTextPreview = 'True';
        } else if (questionType == 'Single Select--Horizontal') {
            showRowQuestionPreview = 'True';
            rowOptions = stringToSelectOptions(qChoices);
        } else if (questionType == 'Email') {
            showEmailPreview = 'True';
        } else if (questionType == 'Phone') {
            showPhonePreview = 'True';
        } else if (questionType == 'Picklist') {
            showPicklistPreview = 'True';
            picklistOptions = stringToSelectOptions(qChoices);
        } else if (questionType == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) {
            showMatrixSingleSelectPreview = 'True';
            matrixOptions = stringToSelectOptions(qChoices);
        } else if (questionType == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
            showMatrixMultiSelectPreview = 'True';
            matrixOptions = stringToSelectOptions(qChoices);
        }

        return null;
    }


    private List<SelectOption> stringToSelectOptions(String str) {
        List<String> strList = str.split('\\r|\n');
        List<SelectOption> returnVal = new List<SelectOption>();
        for (String s : strList) {
            returnVal.add(new SelectOption(s, s));
        }
        return returnVal;
    }


    public Integer setupQuestionList() {
        getAQuestion();
        return allQuestions.size();
    }


    /** Sets the survey's name variable
    *  param: sID The survey ID as specified in the DB
    */
    public void setSurveyNameAndThankYou(String sId) {
        //TCF_Feb172017 START: Added Send_To_EKOMI__c to the query
        //ICF_Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c,  Survey_Header__c, Survey_Footer__c, Survey_Language__c FROM ICF_Survey__c WHERE Id = :sId];
        ICF_Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c,  Survey_Header__c, Survey_Footer__c, Survey_Language__c, Send_To_EKOMI__c FROM ICF_Survey__c WHERE Id = :sId];
        surveySendToEKOMI = s.Send_To_EKOMI__c;
        //TCF_Feb172017 END: Added Send_To_EKOMI__c to the query
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        surveyFooter = s.Survey_Footer__c;
        surveyLanguage = s.Survey_Language__c;
        templateURL = s.URL__c + 'id=' + sId; //+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
    }

//------------------------------------------------------------------------------//
    public Pagereference updateSurveyName() {
        ICF_Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c FROM ICF_Survey__c WHERE Id = :surveyId];
        s.Name = surveyName;
        try {
            update s;
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }

//------------------------------------------------------------------------------//
    public Pagereference updateSurveyThankYouAndLink() {
        ICF_Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c FROM ICF_Survey__c WHERE Id = :surveyId];
        s.Thank_You_Text__c = surveyThankYouText;
        try {
            update s;
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }

    public void reupdateOrderList() {
        List<ICF_Survey_Question__c> qsToUpdate = new List<ICF_Survey_Question__c>();

        List<ICF_Survey_Question__c> vQuestionList = [SELECT Id, OrderNumber__c,
                                                                (SELECT Id, Sub_Question__c, OrderNumber__c FROM Survey_Questions_Childs__r ORDER BY OrderNumber__c) 
                                                            FROM ICF_Survey_Question__c 
                                                            WHERE Survey__c = :surveyId
                                                            AND Survey_Question_Parent__c = null
                                                            ORDER BY OrderNumber__c];

        Integer vOrder = 0;
        for (ICF_Survey_Question__c vQuestion : vQuestionList) {
            vQuestion.OrderNumber__c = vOrder;
            qsToUpdate.add(vQuestion);
            vOrder++;

            if (vQuestion.Survey_Questions_Childs__r != null) {
                for (ICF_Survey_Question__c vChild : vQuestion.Survey_Questions_Childs__r) {  
                    vChild.OrderNumber__c = vOrder;

            System.debug('########### Add child : ' + vChild.Id);
                    qsToUpdate.add(vChild);          
                    vOrder++;
                }
            } 
            System.debug('########### Add Question : ' + vQuestion.Id);
        }

        update qsToUpdate;
    }

    public PageReference updateOrderList() {
        system.debug('############new ordder list:' + newOrderW);
        if (newOrderW.length() <= 0) {
            return null;
        }

        newOrderW = newOrderW.substring(0, newOrderW.length() - 1);

        List<String> idsToUpdate = newOrderW.split(',', -1);
        
        List<ICF_Survey_Question__c> qsToUpdate = new List<ICF_Survey_Question__c>();

        Map<Id, ICF_Survey_Question__c> vQuestionMap = new Map<Id, ICF_Survey_Question__c>(
                [SELECT Id, OrderNumber__c,
                    (SELECT Id, Sub_Question__c, OrderNumber__c FROM Survey_Questions_Childs__r ORDER BY OrderNumber__c) 
                FROM ICF_Survey_Question__c 
                WHERE Id IN :idsToUpdate]);

        Integer vOrder = 0;
        for (Integer i = 0; i < idsToUpdate.size(); i++) {
            //Check if the record hasn't been deleted 
            ICF_Survey_Question__c vQuestion = vQuestionMap.get(idsToUpdate.get(i));
            if (vQuestion != null) {
                vQuestion.OrderNumber__c = vOrder;
                qsToUpdate.add(vQuestion);
                vOrder++;

                if (vQuestion.Survey_Questions_Childs__r != null) {
                    for (ICF_Survey_Question__c vChild : vQuestion.Survey_Questions_Childs__r) {  
                        vChild.OrderNumber__c = vOrder;

                        qsToUpdate.add(vChild);          
                        vOrder++;
                    }
                } 
            }
        }
        update qsToUpdate;

        // Prevent defect on double click
        newOrderW += ',';

        return null;
    }

    //------------------------------------------------------------------------------//
    /** When requested from the page - when the user clicks on 'Update Order' -
        this function will reorganize the list so that it is displayed in the new order
     */
    public Pagereference refreshQuestionList() {
        setupQuestionList();
        return null;
    }



//------------------------------------------------------------------------------//


    /** Redirects the page that displays the detailed results of the survey,
        from all users who took the survey.
     */
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id=' + surveyId);
    }


    //------------------------------------------------------------------------------//
    public Pagereference deleteRefresh() {
        System.debug('############# deleteRefresh');
        //Delete the question
        if (questionReference != null ) {
            ICF_Survey_Question__c vQuestion = [Select Id, Name, Type__c, (SELECT Id FROM Survey_Questions_Childs__r) FROM ICF_Survey_Question__c WHERE Id = : questionReference];
            if (vQuestion.Type__c == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT || vQuestion.Type__c == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
                List<ICF_Survey_Question__c> vSubQuestionsToDelete = new List<ICF_Survey_Question__c>();
                for (ICF_Survey_Question__c vSubQuestion : vQuestion.Survey_Questions_Childs__r) {
                    vSubQuestionsToDelete.add(vSubQuestion);
                }

                delete vSubQuestionsToDelete;
            }
                    
            delete vQuestion;
            questionReference = null;
        }
        allQuestions.clear();
        // Reorder the questions
        Double j = 0.0;
        List<ICF_Survey_Question__c> allQuestionsObject =
            [Select Type__c, Id, Survey__c, Required__c,
             Question__c, OrderNumber__c, Name, Choices__c, Sub_Question__c, 
             (SELECT Id FROM Survey_Questions_Childs__r)
             From ICF_Survey_Question__c
             WHERE Survey__c = : surveyId
                               order by OrderNumber__c];
        for (Integer i = 0; i < allQuestionsObject.size(); i++) {
            allQuestionsObject[i].OrderNumber__c = j;
            question theQ = new question(allQuestionsObject[i]);
            allQuestions.add(theQ);
            j = j + 1.0;
        }
        responses = getResponses();
        // update all others question with new order
        try {
            update allQuestionsObject;
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
        return saveOrUpdateReturn();
    }

//------------------------------------------------------------------------------//

    /**
     */
    public List<String> getResponses() {
        List<ICF_SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From ICF_SurveyQuestionResponse__c limit 100];
        List<String> resp = new List<String>();
        for (ICF_SurveyQuestionResponse__c r : qr) {
            resp.add(r.Response__c);
        }

        return resp;
    }

    /** Class: question
     *  Retrieves the question information and puts it in the question object
     */
    //update BCH 03/02/2015 - handle new types Email and picklist
    public class Question {
        public String name                          { get; set; }
        public String id                            { get; set; }
        public String question                      { get; set; }
        public String orderNumber                   { get; set; }
        public String choices                       { get; set; }
        public List<SelectOption> singleOptions     { get; set; }
        public List<SelectOption> multiOptions      { get; set; }
        public Boolean required                     { get; set; }
        public String questionType                  { get; set; }
        public String surveyName                    { get; set; }
        public String renderFreeText                { get; set; }
        public String renderSelectRadio             { get; set; }
        public String renderSelectCheckboxes        { get; set; }
        public String renderSelectRow               { get; set; }
        public List<String> responses               { get; set; }
        public String singleOptionsForChart         { get; set; }
        public String qResultsForChart              { get; set; }
        public List<String> strList                 { get; set; } // The question's option as a list of string
        public List<Integer> resultsCounts          { get; set; } // The count of each response to a question's choices
        public List<SelectOption> rowOptions        { get; set; }
        public boolean  noData                      { get; set; }
        public List<String> picklistStringOptions   { get; set; }
        public List<SelectOption> matrixOptions     { get; set; }
        public String renderEmail                   { get; set; }
        public String renderPhone                   { get; set; }
        public String renderPicklist                { get; set; }
        public String renderSingleMatrix            { get; set; }
        public String renderMultiMatrix             { get; set; }
        
        // Sub questions
        public String subQuestion                   { get; set; }
        public Question parentQuestion              { get; set; }
        public List<Question> childQuestions        { get; set; }

        /** Fills up the question object
         *  param:  Survey_Question__c
           */
        public Question(ICF_Survey_Question__c sq) {
            name = sq.Name;
            id = sq.Id;
            System.debug('in Question found one with id ' + id);
            question = sq.Question__c;
            orderNumber = String.valueOf(sq.OrderNumber__c);
            choices = sq.Choices__c;
            required = sq.Required__c;
            questionType = sq.Type__c;
            subQuestion = sq.Sub_Question__c;
            singleOptionsForChart = ' ';

            if (sq.Type__c == 'Single Select--Vertical') {
                resetRenderVariableToFalse();
                renderSelectRadio = 'true';
                singleOptions     = stringToSelectOptions(choices);
            } else if (sq.Type__c == 'Multi-Select--Vertical') {
                resetRenderVariableToFalse();
                renderSelectCheckboxes = 'true';
                multiOptions           = stringToSelectOptions(choices);
            } else if (sq.Type__c == 'Single Select--Horizontal') {
                resetRenderVariableToFalse(); 
                rowOptions      = stringToSelectOptions(choices); 
                renderSelectRow = 'true'; 
            } else if (sq.Type__c == 'Free Text') {                
                resetRenderVariableToFalse(); 
                renderFreeText = 'true';
            } else if (sq.Type__c == 'Email') {
                resetRenderVariableToFalse(); 
                renderEmail = 'true';
            } else if (sq.Type__c == 'Phone') {
                resetRenderVariableToFalse(); 
                renderPhone = 'true';
            } else if (sq.Type__c == 'Picklist') {
                resetRenderVariableToFalse();
                picklistStringOptions = stringToSelectOptionsString(choices);
                renderPicklist        = 'true';
            } else if (sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT || sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) {                
                resetRenderVariableToFalse();
                matrixOptions = stringToSelectOptions(choices);
                renderSingleMatrix  = (sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) ? 'true' : 'false';
                renderMultiMatrix   = (sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) ? 'true' : 'false';
            }

        }

        public Question(ICF_Survey_Question__c sq, Question pParent) {
            Question vQuestion = new Question(sq);
            if (pParent.childQuestions == null) {
                pParent.childQuestions = new List<Question>();
            }
            vQuestion.parentQuestion = pParent;
            pParent.childQuestions.add(vQuestion);
        }

        /*
        * Reset all rendering variables to false
        */
        public void resetRenderVariableToFalse() {            
            renderFreeText         = 'false';
            renderSelectRadio      = 'false';
            renderSelectCheckboxes = 'false';
            renderSelectRow        = 'false';
            renderEmail            = 'false';
            renderPhone            = 'false';
            renderPicklist         = 'false';
            renderSingleMatrix     = 'false';
            renderMultiMatrix      = 'false';
        }

        /** Splits up the string as given by the user and adds each option
         *  to a list to be displayed as option on the Visualforce page
         *  param: str String as submitted by the user
         *  returns the List of SelectOption for the visualforce page
           */
        private List<SelectOption> stringToSelectOptions(String str) {
            if (str == '') {
                return new List<SelectOption>();
            }
            strList = str.split('\n');

            List<SelectOption> returnVal = new List<SelectOption>();
            for (String s : strList) {
                if (s != '') {
                    returnVal.add(new SelectOption(s, s));
                    if (s != 'null' && s != null) {
                        String sBis = s.replace(' ', '%20');
                        singleOptionsForChart += s.trim() + '|';
                    }
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length() - 1);
            return returnVal;
        }

        /**
         *  Added by NGO
         *  Splits up the string as given by the user and adds each option
         *  to a list to be displayed as option on the Visualforce page
         *  param: str String as submitted by the user
         *  returns the List of String for the visualforce page
         */
        private List<String> stringToSelectOptionsString(String str) {
            if (str == '') {
                return new List<String>();
            }
            strList = str.split('\n');

            List<String> returnVal = new List<String>();
            for (String s : strList) {
                if (s != '') {
                    returnVal.add(s);
                    if (s != 'null' && s != null) {
                        String sBis = s.replace(' ', '%20');
                        singleOptionsForChart += s.trim() + '|';
                    }
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length() - 1);
            return returnVal;
        }

    }


    /** Fills up the List of questions to be displayed on the Visualforce page
     */
    public List<question> getAQuestion() {
        List<ICF_Survey_Question__c> allQuestionsObject =
            [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c,
                s.OrderNumber__c, s.Name, s.Choices__c, s.Sub_Question__c, s.Survey_Question_Parent__c
             From ICF_Survey_Question__c s
             WHERE s.Survey__c = :surveyId 
             ORDER BY s.OrderNumber__c];
        allQuestions = new List<question>();

        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (ICF_Survey_Question__c q : allQuestionsObject) {
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt);
            }
            old_OrderNumber = q.OrderNumber__c;
            // Create the question POCO
            Question vQuestion;
            if (q.Survey_Question_Parent__c != null) {
                // Parent Question should be already added because sorted by orderNumber
                Question vParent = getQuestionById(allQuestions, q.Survey_Question_Parent__c);
                if (vParent != null) {
                    vQuestion = new question(q, vParent);
                }
            } else {
                vQuestion = new question(q);
                allQuestions.add(vQuestion);
            }
        }
        allQuestionsSize = allQuestions.size();

        return allQuestions;
    }


    public Question getQuestionById(List<Question> pQuestions, String pId) {
        for (Question vQuestion : pQuestions) {
            if (vQuestion.Id == pId) {
                return vQuestion;
            }
        }

        return null;
    }

}