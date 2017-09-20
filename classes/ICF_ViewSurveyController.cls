/* Controller associated with pages rendering the survey.
 * Used by ICF_SurveyPage, ResultsPage, ICF_TakeSurvey
 */
global virtual without sharing class ICF_ViewSurveyController {
    public String  qQuestion       { get; set; }
    public Boolean qRequired       { get; set; }
    public String  qChoices        { get; set; } 
    public String surveyName       { get; set; }
    public String surveyHeader     { get; set; }
    
    //BCH added 12/03/2015
    public String surveyFooter     { get; set; }
    public String surveyLanguage   { get; set; }
    public String selectedLanguage { get; set; }

    public String surveyId {
        get;
        set{
            this.surveyId = value;
            init();
        }
    }
    public Boolean renderSurveyPreview        { get; set; }
    public String questionName                { get; set; }
    public String questionType                { get; set; }
    public Boolean questionRequired           { get; set; }
    public List<SelectOption> singleOptions   { get; set; }
    public List<question> allQuestions        { get; set; }
    public List<String> responses             { get; set; }
    public Integer allQuestionsSize           { get; set; }
    public String  templateURL                { get; set; }
    public String  surveyThankYouText         { get; set; }
    public String surveyContainerCss          { get; set; }
    public String  surveyThankYouURL          { get; set; }
    public String  caseId                     { get; set; }
    public String  accountId                  { get; set; }
    public String contactId                   { get; set; }
    public String taskId                      { get; set; }
    public String anonymousAnswer             { get; set; }
    public List<SelectOption> anonymousOrUser { get; set; }
    public Boolean isInternal                 { get; set; }
    public String baseURL                     { get; set; }
    
    public String userId                      { get; set; }
    public String userName                    { get; set; }
    public String surveyTakerId               { get; set; }
    public Boolean thankYouRendered           { get; set; }
    public Boolean surveyAlreadyTaken         { get; set; }
    public List<String> newOrder              { get; set; }
    
    //bch 05/02/2015 Added to handle question types and also new submission process
    public List<String> emailAddresses        { get; set; }
    public List<Contact> contactIds           { get; set; }
    public List<ICF_SurveyTaker__c > srvts    { get; set; }
    public String contactOwnerId              { get; set; }
    public List<User> userIds                 { get; set; }
    public ICF_Survey__c mSurvey              { get; set; }
    public Boolean isExpiredOrArchived        { get; set; }
    public Map<String, String> mGetParams     { get; set; }  

//------------------------------------------------------------------------------//
    public ICF_ViewSurveyController(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Survey_Language__c', 'Expiration_Date__c', 'Survey_Status__c', 'Available_Languages__c'});
        }
        // Get url parameters
        mGetParams = ApexPages.currentPage().getParameters();
        surveyId = mGetParams.get('id');
        caseId = mGetParams.get('caId');
        contactId = mGetParams.get('cId');
        accountId = mGetParams.get('accId');
        taskId = mGetParams.get('tId');
        selectedLanguage = mGetParams.get('lg');
        String vRenderSurveyPreview = mGetParams.get('preview');
        mSurvey = (ICF_Survey__c)stdController.getRecord();
        
        if (selectedLanguage == null || ''.equals(selectedLanguage)) {
            selectedLanguage = mSurvey.Survey_Language__c;
        }
        isExpiredOrArchived = false;
        if (mSurvey.Expiration_Date__c != null) {
            isExpiredOrArchived = System.today() >= mSurvey.Expiration_Date__c;
        }
        isExpiredOrArchived |= (mSurvey.Survey_Status__c == ICF_AP_Constant.STATUS_ARCHIVED);

        if (caseId == null || caseId.length() < 5) {
            caseId = 'none';
        }
        if (contactId == null || contactId.length() < 5) {
            contactId = 'none';
        }
        if (accountId == null || accountId.length() < 5) {
            accountId = 'none';
        }
        if (taskId == null || taskId.length() < 5) {
            taskId = 'none';
        }
        // By default the preview is not showing up
        if (vRenderSurveyPreview != null && vRenderSurveyPreview == 'y')  {
            renderSurveyPreview = true;
        } else {
            renderSurveyPreview = false;
        }
        
        if(!renderSurveyPreview) {
            checkIfSurveyIsAlreadyTaken();
        }
            
        init();
    }

    /*public PageReference redirectMobiles(){
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
         
        // Some devices use custom headers for the user-agent.
        if (userAgent==null || userAgent.length()==0) {
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_OPERAMINI_PHONE_UA');
        }       
        if (userAgent==null || userAgent.length()==0) {
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_SKYFIRE_PHONE');
        }

        String deviceReg = '(?i)(iphone|ipod|ipad|blackberry|android|palm|windows\\s+ce)';
        String desktopReg = '(?i)(windows|linux|os\\s+[x9]|solaris|bsd)';
        String botReg = '(?i)(spider|crawl|slurp|bot)';
         
        Boolean isDevice=false, isDesktop=false, isBot=false;
         
        Matcher m = Pattern.compile(deviceReg).matcher(userAgent);
        if (m.find()){
            isDevice = true;
        } else { 
            m = Pattern.compile(desktopReg).matcher(userAgent);
            if (m.find()) {
                isDesktop = true;
            }
             
            m = Pattern.compile(botReg).matcher(userAgent);
            if (m.find()) {
                isBot = true;
            }
        }
        // Default is mobile - unless a desktop or bot user-agent identified.                  
        if (!isDevice && (isDesktop || isBot)) {
            return null; // no redirect.                        
        }
        PageReference vPrMobile = Page.ICF_TakeSurvey_Mobile;
        vPrMobile.setRedirect(true);
        vPrMobile.getParameters().putAll(ApexPages.currentPage().getParameters());

        return vPrMobile; // redirect.
    }*/


    public void init() {
        if (surveyId != null) {
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<question>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous', System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User', 'User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            anonymousAnswer = 'Anonymous';
            isInternal = true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;

            userId = UserInfo.getUserId();
            userName = UserInfo.getName();

            String profileId = UserInfo.getProfileId();
            try {
                Profile p = [select Id, UserType from Profile where Id = :profileId];
                if (p.UserType == 'Guest') {
                    isInternal = false;
                } else {
                    isInternal = true;
                }
            } catch (Exception e) {
                isInternal = false;
            }
            thankYouRendered = false;

            // Translation
            translateSurvey();
        }
    }
    
    //check if survey is already taken by a contact and
    //display a thank you message
    private void checkIfSurveyIsAlreadyTaken() {
        surveyAlreadyTaken = false;
        list<Task> t = [Select Id, Status From Task Where Id = :taskId And ICF_SurveyId__c = :surveyId And (WhoId = null or (WhoId <> null and WhoId = :contactId)) limit 1];
        if(t.isEmpty() || t.get(0).Status == ICF_AP_Constant.TaskStatusCompleted ) {
            surveyAlreadyTaken = true;
        } else if(!t.isEmpty() && t.get(0).Status == ICF_AP_Constant.TaskStatusExpired) {
            isExpiredOrArchived = true;
        }
    }

    //* Called during the setup of the page.
    // Retrieve questions and responses from DB and inserts them in 2 lists. 
    public Integer setupQuestionList() {
        getAQuestion();
        return allQuestions.size();
    }


    //* Sets the survey's name variable
    //  param: sID   The survey ID as specified in the DB    
    public void setSurveyNameAndThankYou(String sId) {
        ICF_Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, Survey_Header__c, Survey_Container_CSS__c, Survey_Footer__c, Survey_Language__c FROM ICF_Survey__c WHERE Id = :sId];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        surveyFooter = s.Survey_Footer__c;
        surveyLanguage = s.Survey_Language__c;
        templateURL = s.URL__c + 'id=' + sId; //+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null) {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyContainerCss = s.Survey_Container_CSS__c;
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

    //*------------------------------------------------------------------------------//
   // When requested from the page - when the user clicks on 'Update Order' -
   //     this function will reorganize the list so that it is displayed in the new order   
    public Pagereference refreshQuestionList() {
        setupQuestionList();
        return null;
    }

//------------------------------------------------------------------------------//
   

    //*Redirects the page that displays the detailed results of the survey,
    //    from all users who took the survey.
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id=' + surveyId);
    }


//------------------------------------------------------------------------------//

//------------------------------------------------------------------------------//

    public List<String> getResponses() {
        List<ICF_SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From ICF_SurveyQuestionResponse__c limit 100];
        List<String> resp = new List<String>();
        for (ICF_SurveyQuestionResponse__c r : qr) {
            resp.add(r.Response__c);
        }

        return resp;
    }


    public String getLastQuestionNumber() {
        Integer i = 0;
        for (Question vQuestion : allQuestions) {
            if (!vQuestion.isMatrixChild) {
                i++;
            }
        }
        return i + '';
    }


    //* Class: question
    //  Retrieves the question information and puts it in the question object
    

    // BCH 03/02/2015 Add new question types
    public class question {
        public String name                        { get; set; }
        public String id                          { get; set; }
        public String question                    { get; set; }
        public String subQuestion                 { get; set; }
        public String orderNumber                 { get; set; }
        public String choices                     { get; set; }
        public String selectedOption              { get; set; }
        public List<String> selectedOptions       { get; set; }
        public List<SelectOption> singleOptions   { get; set; }
        public List<SelectOption> multiOptions    { get; set; }
        public List<SelectOption> matrixOptions   { get; set; }
        public Boolean required                   { get; set; }
        public String questionType                { get; set; }
        public String surveyName                  { get; set; }
        public String renderFreeText              { get; set; }
        public String renderSelectRadio           { get; set; }
        public String renderSelectCheckboxes      { get; set; }
        public String renderSelectRow             { get; set; }
        public List<String> responses             { get; set; }
        public String singleOptionsForChart       { get; set; }
        public String qResultsForChart            { get; set; }
        public List<String> strList               { get; set; } // The question's option as a list of string
        public List<Integer> resultsCounts        { get; set; } // The count of each response to a question's choices
        public List<SelectOption> rowOptions      { get; set; }
        public boolean noData                     { get; set; }
        public String renderPicklist              { get; set; }
        public String renderEmail                 { get; set; }
        public String renderPhone                 { get; set; }
        public List<SelectOption> picklistOptions { get; set; }
        public String renderMatrixRadio           { get; set; }
        public String renderMatrixCheckBox        { get; set; }
        public Boolean isMatrixMaster             { get; set; }
        public Boolean isMatrixChild              { get; set; }
        public List<Question> childsQuestions     { get; set; }
        public Boolean isSmileyQuestion           { get; set; }

        public Question() {}

        //* Fills up the question object
        //  param:    Survey_Question__c
        public Question(ICF_Survey_Question__c sq, Integer pOrder) {
            name = sq.Name;
            id = sq.Id;
            question = sq.Question__c;
            orderNumber = pOrder + '';
            choices = sq.Choices__c;
            required = sq.Required__c;
            questionType = sq.Type__c;
            subQuestion = sq.Sub_Question__c;
            singleOptionsForChart = ' ';
            selectedOption = '';
            selectedOptions = new List<String>();
            resetAllRenderFields();
            isSmileyQuestion = sq.Is_Smiley_matrix__c;  
            if (sq.Type__c == 'Single Select--Vertical') {
                renderSelectRadio = 'true';
                singleOptions = stringToSelectOptions(choices);
            } else if (sq.Type__c == 'Multi-Select--Vertical') {
                renderSelectCheckboxes = 'true';
                multiOptions = stringToSelectOptions(choices);
            } else if (sq.Type__c == 'Single Select--Horizontal') {
                rowOptions = stringToSelectOptions(choices);
                renderSelectRow = 'true';
            } else if (sq.Type__c == 'Free Text') {
                renderFreeText = 'true';
                choices = '';
            } else if (sq.Type__c == 'Email') {
                renderEmail = 'true';
                choices = '';
            } else if (sq.Type__c == 'Picklist') {
                picklistOptions = stringToSelectOptionsPL(choices);
                renderPicklist = 'true';
            } else if (sq.Type__c == 'Phone') {
                renderPhone = 'true';
            } else if (sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
                renderMatrixCheckBox = 'true';                
                matrixOptions = stringToSelectOptions(choices);
            } else if (sq.Type__c == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) {
                renderMatrixRadio = 'true';
                matrixOptions = stringToSelectOptions(choices);
            }
            isMatrixMaster = sq.Survey_Questions_Childs__r != null;
            isMatrixChild = sq.Survey_Question_Parent__c != null;
             // Matrix sub questions
            if (sq.Survey_Questions_Childs__r != null) {
                childsQuestions = new List<Question>();
                for (ICF_Survey_Question__c vSubQ : sq.Survey_Questions_Childs__r) {
                    Question vSubQuestion = new Question();
                    vSubQuestion.Id = vSubQ.Id;
                    vSubQuestion.choices = vSubQ.Choices__c;
                    vSubQuestion.subQuestion = vSubQ.Sub_Question__c;                    
                    vSubQuestion.matrixOptions = stringToSelectOptions(vSubQ.Choices__c);
                    vSubQuestion.selectedOptions = new List<String>();
                    vSubQuestion.isSmileyQuestion = vSubQ.Is_Smiley_matrix__c;  
                    childsQuestions.add(vSubQuestion);
                }
            }
        }

        public void resetAllRenderFields() {
            renderSelectCheckboxes = 'false';
            renderSelectRadio      = 'false';
            renderFreeText         = 'false';
            renderSelectRow        = 'false';
            renderEmail            = 'false';
            renderPicklist         = 'false';
            renderPhone            = 'false';
            renderMatrixRadio      = 'false';                
            renderMatrixCheckBox   = 'false';
        }


        //* Splits up the string as given by the user and adds each option
        // *  to a list to be displayed as option on the Visualforce page
        // *  param: str   String as submitted by the user
        // *  returns the List of SelectOption for the visualforce page
        // *
        private List<SelectOption> stringToSelectOptionsPL(String str) {
            if (str == '') {
                return new List<SelectOption>();
            }
            strList = str.split('\n');

            List<SelectOption> returnVal = new List<SelectOption>();
            returnVal.add(new SelectOption('', ''));
            Integer i = 0;
            for (String s : strList) {
                if (s != '' && s != 'null' && s != null) {
                    singleOptionsForChart += s.trim() + '|';
                    s = s.replaceAll('\\s+$', '');
                    returnVal.add(new SelectOption(s, s));
                    System.debug('*****VALUES: ' + s);
                    i++;                    
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length() - 1);
            return returnVal;
        }

        //** Splits up the string as given by the user and adds each option
        // *  to a list to be displayed as option on the Visualforce page
        // *  param: str   String as submitted by the user
        // *  returns the List of SelectOption for the visualforce page
        // *
        private List<SelectOption> stringToSelectOptions(String str) {
            if (str == '') {
                return new List<SelectOption>();
            }
            strList = str.split('\n');

            List<SelectOption> returnVal = new List<SelectOption>();
            Integer i = 0;
            for (String s : strList) {
                if (s != ''&& s != 'null' && s != null) {
                    singleOptionsForChart += s.trim() + '|';
                    s = s.replaceAll('\\s+$', '');
                    returnVal.add(new SelectOption(s, s));
                    System.debug('*****VALUES: ' + s);
                    i++;                    
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length() - 1);
            return returnVal;
        }
    }

    //** Fills up the List of questions to be displayed on the Visualforce page
    //*
    public List<Question> getAQuestion() {
        qQuestion = '';
        qChoices = '';

        List<ICF_Survey_Question__c> allQuestionsObject =
            [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, s.Is_Smiley_matrix__c,
                 s.OrderNumber__c, s.Name, s.Choices__c, s.Sub_Question__c, s.Survey_Question_Parent__c, s.Send_to_EKOMI_as__c, 
                 (SELECT Id, Sub_Question__c, Choices__c, Is_Smiley_matrix__c FROM Survey_Questions_Childs__r ORDER BY OrderNumber__c)
            FROM ICF_Survey_Question__c s
            WHERE s.Survey__c = : surveyId ORDER BY s.OrderNumber__c];
        allQuestions = new List<question>();

        Integer currentOrder = 1;
        for (ICF_Survey_Question__c q : allQuestionsObject) {
            // Do not add childs questions
            if (q.Survey_Question_Parent__c == null) {                
                Question theQ = new Question(q, currentOrder);
                allQuestions.add(theQ);
                currentOrder++;
            }
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }

    public void submitResults() {
        List <ICF_SurveyQuestionResponse__c> sqrList = new List<ICF_SurveyQuestionResponse__c>();
        //add the email address in the list
        emailAddresses = new List<String>();


        for (question q : allQuestions) {
            ICF_SurveyQuestionResponse__c sqr = new ICF_SurveyQuestionResponse__c();
            if (q.renderSelectRadio == 'true') {

                if (q.required &&  (q.selectedOption == null || q.selectedOption == '')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }

                if (q.selectedOption == null || q.selectedOption == '') {
                    sqr.Response__c = '';
                } else {
                   sqr.Response__c = q.selectedOption;//q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            } else if (q.renderFreeText == 'true') {
                if (q.required && q.choices == '') {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }
                //System.debug('*****Select Radio ' + q.choices);

                //sqr.Response__c = q.choices;
                sqr.Free_Response__c = q.choices; //Added by AA
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            } else if (q.renderSelectCheckboxes == 'true') {
                if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }

                for (String opt : q.selectedOptions) {
                    sqr = new ICF_SurveyQuestionResponse__c();
                    if (opt == '' || opt == null) {
                        sqr.Response__c = '';
                    } else {
                       sqr.Response__c = opt;//q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            } else if (q.renderSelectRow == 'true') {
                if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }

                if (q.selectedOption == null || q.selectedOption == '') {
                    sqr.Response__c = '';
                } else {
                    sqr.Response__c = q.selectedOption;//q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            //BCH 03/02 Handle new question types
            else if (q.renderEmail == 'true') {
                if (q.required && q.choices == '') {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;

                }
                System.debug('*****Select Email ' + q.choices);

                sqr.Response__c = q.choices;
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
                if (String.isNotEmpty(q.choices)) {
                    emailAddresses.add(q.choices);
                }

            } // DLX
            else if (q.renderPhone == 'true') {
                if (q.required && q.choices == '') {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;

                }
                System.debug('*****Select Phone ' + q.choices);

                sqr.Response__c = q.choices;
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);

            } else if (q.renderPicklist == 'true') {
                System.debug('#############q.selectedOption1:' + q.selectedOption);
                if (q.required && (q.selectedOption == null || q.selectedOption == '' || q.selectedOption == '0')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }

                if (q.selectedOption == null || q.selectedOption == '') {
                   sqr.Response__c = '';
                } else {
                    system.debug('#####q.selectedOption2:' + q.selectedOption);
                   sqr.Response__c = q.selectedOption;//q.picklistOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            } else if (q.renderMatrixRadio == 'true') {
                if (q.required && (q.selectedOption == null || q.selectedOption == '' || q.selectedOption == '0')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }
                // Add main question
                if (q.selectedOption == null || q.selectedOption == '') {
                   sqr.Response__c = '';
                } else {
                    system.debug('#####q.selectedOption2:' + q.selectedOption);
                   sqr.Response__c = q.selectedOption;//q.picklistOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
                // Then add childs questions
                for (Question vQuestion : q.childsQuestions) {
                    ICF_SurveyQuestionResponse__c vChildQuestionResponse = new ICF_SurveyQuestionResponse__c();
                    if (vQuestion.selectedOption == null || vQuestion.selectedOption == '') {
                       vChildQuestionResponse.Response__c = '';
                    } else {
                       vChildQuestionResponse.Response__c = vQuestion.selectedOption;//q.picklistOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    vChildQuestionResponse.Survey_Question__c = vQuestion.Id;
                    sqrList.add(vChildQuestionResponse);

                }
            } else if (q.renderMatrixCheckBox == 'true') {
                if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields : ' + q.question));
                    //return pref;
                    return;
                }
                //Main question
                for (String opt : q.selectedOptions) {
                    sqr = new ICF_SurveyQuestionResponse__c();
                    if (opt == '' || opt == null) {
                        sqr.Response__c = '';
                    } else {
                       sqr.Response__c = opt;
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }

                 // Then add childs questions
                for (Question vQuestion : q.childsQuestions) {
                    for (String opt : vQuestion.selectedOptions) {
                        ICF_SurveyQuestionResponse__c vChildQuestionResponse = new ICF_SurveyQuestionResponse__c();
                        if (opt == null || opt == '') {
                           vChildQuestionResponse.Response__c = '';
                        } else {
                           vChildQuestionResponse.Response__c = opt; 
                        }
                        vChildQuestionResponse.Survey_Question__c = vQuestion.Id;
                        sqrList.add(vChildQuestionResponse);
                    }
                }
            }
        }
        
        /***** 
        * Start: TCF_Feb202017: Added new logic
        * Logic to check whether send to EKOMI flag is enabled in survey level
        * Once survey eligeble then filter with Send To EKOMI as in question level
        *
        *****/
        
        List <ICF_Survey_Question__c> elgQstList = new List<ICF_Survey_Question__c>();
        ICF_Survey__c surveyDtls = [SELECT Name, Id, Send_To_EKOMI__c FROM ICF_Survey__c WHERE Id = :surveyId];
        String EKOMIUnigueIdConcat = surveyDtls.Name + taskId;
        /*
        String strRatingQstn = '';
        Integer intRatingAnswer;
        String strReviewQstn = '';
        String strRevAnser = '';
        List<ICF_Survey_Question__c> allQuestionsObjectToCheck =
            [Select Type__c, Id, Survey__c, Required__c, Question__c, Is_Smiley_matrix__c,
                 OrderNumber__c, Name, Choices__c, Sub_Question__c, Survey_Question_Parent__c, Send_to_EKOMI_as__c
            FROM ICF_Survey_Question__c
            WHERE Survey__c = : surveyId ORDER BY OrderNumber__c];
            
        if(surveyDtls.Send_To_EKOMI__c) {
            for (ICF_Survey_Question__c qtn : allQuestionsObjectToCheck) {
                if(qtn.Send_to_EKOMI_as__c != null && (qtn.Send_to_EKOMI_as__c == 'Review' || qtn.Send_to_EKOMI_as__c == 'Rating')) {
                    for(ICF_SurveyQuestionResponse__c sqrObj : sqrList) {
                        if(qtn.Send_to_EKOMI_as__c == 'Rating' && sqrObj.Survey_Question__c == qtn.Id) {
                            strRatingQstn = qtn.Question__c;
                            intRatingAnswer = ICF_AP_Constant.mapRatingAndInteger.get(sqrObj.Response__c);
                        }
                        if(qtn.Send_to_EKOMI_as__c == 'Review' && sqrObj.Survey_Question__c == qtn.Id) {
                            strReviewQstn = qtn.Question__c;
                            strRevAnser = sqrObj.Free_Response__c;
                        }
                    }
                    
                }
            }
        }
        
        system.debug('strRatingQstn ###'+strRatingQstn);
        system.debug('intRatingAnswer ###'+intRatingAnswer);
        system.debug('strReviewQstn ####'+strReviewQstn);
        system.debug('strRevAnser ###'+strRevAnser);
        */
        //End: TCF_Feb202017: Added new logic
        
        // moved a part from the code of the AddSurveyTaker method to isolate this particular change
        if (emailAddresses.size() > 0) {
            List <ICF_SurveyQuestionResponse__c> sqrListTotal = new List<ICF_SurveyQuestionResponse__c>();
            //Could be potentially an idea to put part of the where clause in a customLabel? although careful of size limitation
            //contactIds = [Select Id, OwnerId from Contact where (Email in: emailAddresses) ];
            String soslEmailAddresses = String.join(emailAddresses, ' OR ');
            contactIds = (List<Contact>)[FIND :soslEmailAddresses IN Email FIELDS RETURNING Contact][0];
            System.debug('#################### contactIds ' + contactIds);
            System.debug('#################### emailAddresses ' + emailAddresses);
            for (String vEmail : emailAddresses) {
                System.debug('####################' + vEmail);
            }
            Set<ID> OwnerIds = new Set<ID>();
            Map <Id, Boolean> UserCheck = new Map<Id, Boolean>();
            for (Contact ct : contactIds) {
                OwnerIds.add(ct.OWnerId);
            }
            //System.debug('######contactIds:'+contactIds);
            if (contactIds.size() > 0) {
                //need to handle scenario where Contact Owner is inactive
                //System.debug('######contactIds.size():'+contactIds.size());
                srvts = new List<ICF_SurveyTaker__c>();
                userIds = [Select Id, IsActive from User where Id in:OwnerIds];
                for (User us : userIds) {
                    UserCheck.put(us.Id, us.IsActive);
                }
                
                for (Contact ctn : contactIds) {
                    Boolean check = UserCheck.get(ctn.OwnerId);
                    //Id i = Id.valueOf(a);
                    //System.debug('######ctn:'+ctn.Id);
                    String userId;
                    //Assumption: no handling of case link or user in this particular process
                    caseId = null;
                    userId = null;
                    contactId = ctn.Id;
                    
                    ICF_SurveyTaker__c st = new ICF_SurveyTaker__c();
                    st.Contact__c = contactId;
                    st.Survey__c = surveyId;
                    st.Taken__c = 'false';
                    st.Case__c = caseId;
                    st.User__c = userId;
                    st.DeliveryTask_Id__c = taskId;
                    //TCF_Feb282017: Added new logic
                   // st.TCF_EKOMI_Unique_Id__c = EKOMIUnigueIdConcat;
                    System.debug('#######check:' + check);
                    //if contact owner is inactive then default the owner of the survey taken
                    if (check == true) {
                        st.OwnerId = ctn.OwnerId;
                    } else {
                        //To Be adapted
                        st.OwnerId = ctn.OwnerId;
                    }
                    System.debug('#######st.OwnerId:' + st.OwnerId);
                    srvts.add(st);
                }
                //System.debug('######srvts:'+srvts);
                //System.debug('######srvts.size:'+srvts.size());
                insert srvts;                
                List <ICF_SurveyQuestionResponse__c> sqrListFinal = new List<ICF_SurveyQuestionResponse__c>();
                for (ICF_SurveyTaker__c svtc : srvts ) {
                    List <ICF_SurveyQuestionResponse__c> sqrList2 = sqrList.deepClone();
                    //System.debug('######svtc.Id:'+svtc.Id);
                    for (ICF_SurveyQuestionResponse__c sqr : sqrList2) {                        
                        sqr.SurveyTaker__c = svtc.Id;
                        //System.debug('#########sqr:'+sqr);
                    }
                    sqrListFinal.AddAll(sqrList2);
                    sqrList2.clear();                    
                }
                insert sqrListFinal;
                //System.debug('######thankYouRendered'+thankYouRendered);
                thankYouRendered = true;
                //if the contact is not found, we still insert that
            } else if (contactIds.size() == 0) {
                ICF_SurveyTaker__c st = new ICF_SurveyTaker__c();
                st.Survey__c = surveyId;
                st.Taken__c = 'false';
                //TCF_Feb282017: Added new logic
                //st.TCF_EKOMI_Unique_Id__c = EKOMIUnigueIdConcat;
                insert st;                
                for (ICF_SurveyQuestionResponse__c sqr : sqrList) {                    
                    sqr.SurveyTaker__c = st.Id;
                        //System.debug('#########sqr:'+sqr);
                }
                insert sqrList;               
                st.QRAdded__c = true;
                update st;
                //System.debug('######thankYouRendered'+thankYouRendered);
                thankYouRendered = true;
            }
        } else {
            //new line 15/04/2016
            String freetxt ='';
            if (AddSurveyTaker()) {
                for (ICF_SurveyQuestionResponse__c sqr : sqrList) {
                    //new line 15/04/2016
                    if (sqr.Free_Response__c <> null) freetxt += sqr.Free_Response__c;
                    sqr.SurveyTaker__c = surveyTakerId;
                }
                insert sqrList;
                ICF_SurveyTaker__c st = [Select Id, QRAdded__c, TCF_EKOMI_Unique_Id__c From ICF_SurveyTaker__c Where Id = :surveyTakerId];
                st.CustomerFeedback__c = freetxt;
                st.QRAdded__c = true;
                //TCF_Feb282017: Added new logic
                //st.TCF_EKOMI_Unique_Id__c = EKOMIUnigueIdConcat;
                update st;
                //System.debug('######thankYouRendered'+thankYouRendered);
                thankYouRendered = true;
            }
        }
        if (thankYouRendered) {
            List<Task> taskList = [Select Id, Status From Task Where Id = : taskId]; 
            if (taskList.size() > 0) {
                taskList[0].Status = ICF_AP_Constant.TaskStatusCompleted;
                update taskList[0];
            }
        }
    }


    private Boolean AddSurveyTaker() {
        String userId;

        if (surveyId == null) {
            return false;
        }
        if (caseId.toUpperCase() == 'NONE' || caseId.length() < 5)
            caseId = null;
        if (accountId.toUpperCase() == 'NONE' || accountId.length() < 5)
            accountId = null;
        if (contactId.toUpperCase() == 'NONE' || contactId.length() < 5)
            contactId = null;
        if (taskId.toUpperCase() == 'NONE' || taskId.length() < 5)
            taskId = null;
        if (anonymousAnswer != 'Anonymous') {
            userId = UserInfo.getUserId();
        } else {
            userId = null;
        }

        if (anonymousAnswer != 'Anonymous' && (contactId != null || caseId != null)) {
            List<ICF_SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From ICF_SurveyTaker__c Where Contact__c = :contactId and Survey__c = :surveyId and Case__c = :caseId and User__c = :UserId and Account__c = :accountId];
            if (check != null && check.size() > 0) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));

                return false;
            }
        }
        
        ICF_SurveyTaker__c st = new ICF_SurveyTaker__c();
        
        //AA - 09/12/2015: link the survey taken record to the business object (case,policy,claim...)
        String val ='';
        map<String,ICF_Survey_Taken_Mapping__c> mapSTMappingField = ICF_Survey_Taken_Mapping__c.getAll();
        list<Task> task = [Select Id, ICF_business_object__c From Task Where Id = : taskId]; 
        
        if(!task.isEmpty() && string.IsNotBlank(task.get(0).ICF_business_object__c)) {
            for(String field : mapSTMappingField.keySet()) {        
                val = mapSTMappingField.get(field).Value_From__c;
                string businessObjName = ICF_AP_Utility.findObjectAPINameById(task.get(0).ICF_business_object__c);
                if(String.IsNotBlank(businessObjName)) {                            
                    if(businessObjName.toLowerCase().equals(val.toLowerCase())) {
                        st.put(field, Id.valueOf(task.get(0).ICF_business_object__c));
                        break;
                    } 
                }           
            }
        }
        
        st.Contact__c = contactId;
        st.Account__c = accountId;
        st.Survey__c = surveyId;
        st.Taken__c = 'false';
        st.Case__c = caseId;
        st.User__c = userId;
        st.DeliveryTask_Id__c = taskId;
                          
        insert st;
        surveyTakerId = st.Id;
        return true;
    }

    //*
    //* Translate the survey : Get back values from the custom settings and modify it on the survey object
    //*
    private void translateSurvey() {
        System.debug('################### translation : ' + selectedLanguage);
        if (selectedLanguage != null && selectedLanguage != mSurvey.Survey_Language__c) {
            String vSelectedLanguage = selectedLanguage;
            List<ICF_SurveyTranslation__c> vSurveyTranslationCS = [SELECT ID, Name, SurveyId__c, TranslatedValue__c, Language__c FROM ICF_SurveyTranslation__c WHERE SurveyId__c = :surveyId AND Language__c = :vSelectedLanguage];

            Map<String, ICF_SurveyTranslation__c> vSurveyTranslationCSMap  = ICF_AP01_SurveyTranslation.getSurveyTranslationCSAsMap(vSurveyTranslationCS);

            if (mSurvey != null) {
                // Translate header
                String vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.HEADER); 
                mSurvey.Survey_Header__c = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, mSurvey.Survey_Header__c);

                // Translate footer
                vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.FOOTER); 
                mSurvey.Survey_Footer__c = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, mSurvey.Survey_Footer__c);

                // Translate thank you text
                vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.THANKYOU); 
                mSurvey.Thank_You_Text__c = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, mSurvey.Thank_You_Text__c);
                
                // Translate description
                vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.DESCRIPTION); 
                mSurvey.Survey_Description__c = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, mSurvey.Survey_Description__c);

                // Translate all questions
                for (Question vSurveyQuestion : allQuestions) {
                    Integer vOrderNumber = Integer.valueOf(vSurveyQuestion.orderNumber) - 1;
                    vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSurveyQuestion.Id, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.QUESTION);
                    String vTranslatedQuestion = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, vSurveyQuestion.question);
                    if (vTranslatedQuestion != null && vTranslatedQuestion != '') {
                        vSurveyQuestion.question = vTranslatedQuestion;
                    }

                    // If parent of childsQuestion : translate first sub question
                    if (vSurveyQuestion.childsQuestions != null) {
                        vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSurveyQuestion.Id, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.SUB_QUESTION);                    
                        vSurveyQuestion.subQuestion = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, vSurveyQuestion.subQuestion);
                        
                        // Translate child questions
                        for (Question vSubQuestion : vSurveyQuestion.childsQuestions) {
                            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSubQuestion.Id, null, vSelectedLanguage, ICF_AP01_SurveyTranslation.SUB_QUESTION);
                            vSubQuestion.subQuestion = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, vSubQuestion.subQuestion);
                        }
                    }

                    // Translate choices
                    if (vSurveyQuestion.questionType == 'Single Select--Vertical') {
                        vSurveyQuestion.singleOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage);
                    } else if (vSurveyQuestion.questionType == 'Multi-Select--Vertical') {
                        vSurveyQuestion.multiOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage);
                    } else if (vSurveyQuestion.questionType == 'Single Select--Horizontal') {          
                        vSurveyQuestion.rowOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage);
                    } else if (vSurveyQuestion.questionType == 'Picklist') {
                        vSurveyQuestion.picklistOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage, true);
                    } else if (vSurveyQuestion.questionType == 'Multi-Select--Vertical') {
                        vSurveyQuestion.picklistOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage, true);
                    } else if (vSurveyQuestion.questionType == ICF_AP_Constant.QTYPE_MATRIX_MULTI_SELECT) {
                        vSurveyQuestion.matrixOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage, false);
                    } else if (vSurveyQuestion.questionType == ICF_AP_Constant.QTYPE_MATRIX_SINGLE_SELECT) {
                        vSurveyQuestion.matrixOptions = ICF_AP01_SurveyTranslation.getChoicesAsSelectOptions(vSurveyQuestion.choices, vSurveyQuestion.Id, vSelectedLanguage, false);                        
                    }
                }
            }
        }
    }

    /*
    * Redirect to the current URL but with the good language parameter
    */
    public PageReference changeLanguage() {
        PageReference vPr = Apexpages.currentPage();
      
        String vLanguageAsked = vPr.getParameters().get('pLanguage');
        vPr.getParameters().clear(); 
        mGetParams.put('lg', vLanguageAsked); 
        System.debug('################ vLanguageAsked : ' + vLanguageAsked);
        vPr.getParameters().putAll(mGetParams);
        vPr.setRedirect(true);

        return vPr;
    }

    /*
    * Language wrapper object
    */
    public class Language {
        public Language() {}
        public String languageCode  { get; set; }
        public String flagURL       { get; set; }
        public String languageLabel { get; set; }
    }

    //*
    //* Get possible languages to translate
    //*
    public List<Language> getLanguages() {
        List<Language> vAllLanguages = new List<Language>();
        
        if (mSurvey.Available_Languages__c != null) {
            Set<String> vSplittedValues = new Set<String>(mSurvey.Available_Languages__c.split(','));

            Schema.DescribeFieldResult vFieldResult = User.LanguageLocaleKey.getDescribe();
            List<Schema.PicklistEntry> vPicklistValues = vFieldResult.getPicklistValues();

            for (Schema.PicklistEntry vPicklistEntry : vPicklistValues) {
                if (vSplittedValues.contains(vPicklistEntry.getValue())) {
                    Language vLanguage = getLanguageFromCode(vPicklistEntry.getValue(), vPicklistEntry.getLabel()); 
                    vAllLanguages.add(vLanguage);
                }
            }
        }
        // add us if no language (shouldn't happen)
        if (vAllLanguages.size() == 0) {
            Language vLanguage = getLanguageFromCode('en_US', 'English');       
            vAllLanguages.add(vLanguage);
        }

        return vAllLanguages;
    }

    /*
    * Return the selected language with image
    */
    public Language getSelectedLanguageWrap() {
        List<Language> vAllLanguages = getLanguages();

        if (selectedLanguage == null) {
            if (vAllLanguages == null) {
                return null;
            } else {
                return vAllLanguages.get(0);
            }
        }

        if (vAllLanguages != null) {
            for (Language vLanguage : vAllLanguages) {
                if (vLanguage.languageCode == selectedLanguage) {
                    return vLanguage;
                }
            }
        }

        return getLanguageFromCode(selectedLanguage, '');
    }


    /*
    * Get wrapped language with image
    */
    private Language getLanguageFromCode(String pCode, String pLabel) {
        if (pCode == null) {
            return null;
        }

        Language vLanguage = new Language();
        vLanguage.languageCode = pCode;
        vLanguage.languageLabel = pLabel;
        ICF_Survey_Flag_Mapping__c vFlagCS = ICF_Survey_Flag_Mapping__c.getInstance(pCode);
        if (vFlagCS != null) {
             vLanguage.flagURL = vFlagCS.Flag_Img_Id__c;
        }

        return vLanguage;
    }

}