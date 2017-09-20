public without sharing class ICF_VFC02_SurveyTranslation {
    
    public static final String SURVEY_OBJECT = 'ICF_Survey__c';
    public static final String TYPE_TEXTAREA = 'Textarea';
    public static final String TYPE_INPUTTEXT = 'InputText';
    public Boolean mustBeReloaded { get; set; } // Used to reload the survey -- if question has been added for example
    public ICF_Survey__c mySurvey { get; set; }
    public List<ICF_Survey_Question__c> surveyQuestions { get; set; }
    public String selectedLanguage { get; set; }
    public List<ICF_AP01_SurveyTranslation.TranslateQuestion> translateQuestions { get; set; } 
    public List<ICF_AP01_SurveyTranslation.TranslateInfos> translateInfos { get; set; }    

    public Id surveyId {
        get;
        set {
            this.surveyId = value;
            if (mustBeReloaded == null || mustBeReloaded) {
                init();
            }
        }
    }


    public ICF_VFC02_SurveyTranslation() {
        mustBeReloaded = true;
    }

    public void init() {
        if (surveyId != null) {         
            mySurvey = [SELECT Id, Name, Survey_Header__c, Available_Languages__c, Survey_Footer__c, Survey_Language__c, 
                Thank_You_Text__c, Email_Template__c, URL__c, Survey_Description__c
                FROM ICF_Survey__c 
                WHERE Id = :surveyId];
            surveyQuestions = [SELECT Id, Choices__c, OrderNumber__c, Question__c, Survey_Question_Parent__c, Sub_Question__c,
                    (SELECT Id, Sub_Question__c, OrderNumber__c FROM Survey_Questions_Childs__r ORDER BY OrderNumber__c) 
                FROM ICF_Survey_Question__c 
                WHERE Survey__c = :surveyId AND Survey_Question_Parent__c = null
                ORDER BY OrderNumber__c];
            mustBeReloaded = false;
        }
    }


    //*
    //* Load all the wrapper objects from the cs if exists
    //*
    public PageReference loadWrapperTranslations() { 
    	System.debug('##########AA - selectedLanguage:'+selectedLanguage);
        if (selectedLanguage == null || selectedLanguage == '') {
            translateInfos = null;
            translateQuestions = null;
            System.debug('##########AA - translateInfos:'+translateInfos);
            System.debug('##########AA - translateQuestions:'+translateQuestions);
        } else {
            List<ICF_SurveyTranslation__c> vSurveyTranslationCS = [SELECT ID, Name, SurveyId__c, TranslatedValue__c, Language__c FROM ICF_SurveyTranslation__c WHERE SurveyId__c = :surveyId AND Language__c = :selectedLanguage];

            Map<String, ICF_SurveyTranslation__c> vSurveyTranslationCSMap  = ICF_AP01_SurveyTranslation.getSurveyTranslationCSAsMap(vSurveyTranslationCS);
            // Handle infos
            //Header
            translateInfos = new List<ICF_AP01_SurveyTranslation.TranslateInfos>();
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoHeader = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            String vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.HEADER);
            vTranslateInfoHeader.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoHeader.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vHeaderLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Survey_Header__c').getDescribe().getLabel();
            vTranslateInfoHeader.value = (String.isEmpty(mySurvey.Survey_Header__c) ? vHeaderLabel : mySurvey.Survey_Header__c);
            vTranslateInfoHeader.name = vName;
            vTranslateInfoHeader.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoHeader);
            
            // Email Template
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoEmailTemplate = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.EMAIL_TEMPLATE);
            vTranslateInfoEmailTemplate.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoEmailTemplate.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vTranslateInfoEmailTemplateLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('EmailTemplate__c').getDescribe().getLabel();
            vTranslateInfoEmailTemplate.value = vTranslateInfoEmailTemplateLabel;
            vTranslateInfoEmailTemplate.name = vName;
            vTranslateInfoEmailTemplate.type = TYPE_INPUTTEXT;
            translateInfos.add(vTranslateInfoEmailTemplate);            
            
            //Description
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoDesc = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.DESCRIPTION);
            vTranslateInfoDesc.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoDesc.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vDescriptionLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Survey_Description__c').getDescribe().getLabel();
            vTranslateInfoDesc.value = (String.isEmpty(mySurvey.Survey_Description__c) ? vHeaderLabel : mySurvey.Survey_Description__c);
            vTranslateInfoDesc.name = vName;
            vTranslateInfoDesc.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoDesc);
            
            // Reminder Email Template
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoRemEmailTemplate = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.REMINDER_EMAIL_TEMPLATE);
            vTranslateInfoRemEmailTemplate.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoRemEmailTemplate.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vTranslateInfoRemEmailTemplateLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Reminder_EmailTemplate__c').getDescribe().getLabel();
            vTranslateInfoRemEmailTemplate.value = vTranslateInfoRemEmailTemplateLabel;
            vTranslateInfoRemEmailTemplate.name = vName;
            vTranslateInfoRemEmailTemplate.type = TYPE_INPUTTEXT;
            translateInfos.add(vTranslateInfoRemEmailTemplate);
            
            // Footer
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoFooter = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.FOOTER);
            vTranslateInfoFooter.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoFooter.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vFooterLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Survey_Footer__c').getDescribe().getLabel();
            vTranslateInfoFooter.value = (String.isEmpty(mySurvey.Survey_Footer__c) ? vFooterLabel : mySurvey.Survey_Footer__c);
            vTranslateInfoFooter.name = vName;
            vTranslateInfoFooter.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoFooter);
            
            // SMS Template
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoSMSTemplate = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.SMS_TEMPLATE);
            vTranslateInfoSMSTemplate.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoSMSTemplate.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vTranslateInfoSMSTemplateLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('SMS_Template__c').getDescribe().getLabel();
            vTranslateInfoSMSTemplate.value = vTranslateInfoSMSTemplateLabel;
            vTranslateInfoSMSTemplate.name = vName;
            vTranslateInfoSMSTemplate.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoSMSTemplate);            

            // Thank you text
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoThankYou = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.THANKYOU);
            vTranslateInfoThankYou.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoThankYou.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vThankYouLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Thank_You_Text__c').getDescribe().getLabel();
            vTranslateInfoThankYou.value = (String.isEmpty(mySurvey.Thank_You_Text__c) ? vThankYouLabel : mySurvey.Thank_You_Text__c);
            vTranslateInfoThankYou.name = vName;
            vTranslateInfoThankYou.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoThankYou);
            
            // Reminder SMS Template
            ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfoRemSMSTemplate = new ICF_AP01_SurveyTranslation.TranslateInfos(); 
            vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.REMINDER_SMS_TEMPLATE);
            vTranslateInfoRemSMSTemplate.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
            vTranslateInfoRemSMSTemplate.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
            String vTranslateInfoRemSMSTemplateLabel = Schema.getGlobalDescribe().get(SURVEY_OBJECT).getDescribe().fields.getMap().get('Reminder_SMS_Template__c').getDescribe().getLabel();
            vTranslateInfoRemSMSTemplate.value = vTranslateInfoRemSMSTemplateLabel;
            vTranslateInfoRemSMSTemplate.name = vName; 
            vTranslateInfoRemSMSTemplate.type = TYPE_TEXTAREA;
            translateInfos.add(vTranslateInfoRemSMSTemplate);            

            // Add all questions and choices in the wrapper
            List<ICF_AP01_SurveyTranslation.TranslateQuestion> vTranslateElementList = new List<ICF_AP01_SurveyTranslation.TranslateQuestion>();
            for (ICF_Survey_Question__c vSurveyQuestion : surveyQuestions) {

                if (vSurveyQuestion.Survey_Question_Parent__c == null) { // DO not add subquestion
                    ICF_AP01_SurveyTranslation.TranslateQuestion vTranslateQuestion = new ICF_AP01_SurveyTranslation.TranslateQuestion();
                    
                    // Question
                    vTranslateQuestion.translateChoices = new List<ICF_AP01_SurveyTranslation.TranslateChoice>();
                    vTranslateQuestion.order = Integer.valueOf(vSurveyQuestion.OrderNumber__c);
                    vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSurveyQuestion.Id, null, selectedLanguage, ICF_AP01_SurveyTranslation.QUESTION);
                    vTranslateQuestion.value = vSurveyQuestion.Question__c;
                    vTranslateQuestion.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
                    vTranslateQuestion.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
                    vTranslateQuestion.questionId = vSurveyQuestion.Id;
                    vTranslateQuestion.name = vName;
                    
                    // Choices
                    if (vSurveyQuestion.Choices__c != null && vSurveyQuestion.Choices__c != '') {
                        vTranslateQuestion.translateChoices.addAll(ICF_AP01_SurveyTranslation.getChoicesAsTranslateElements(vSurveyQuestion.Choices__c, vSurveyQuestion.Id, selectedLanguage, vSurveyTranslationCSMap));    
                    }
                    if (vSurveyQuestion.Sub_Question__c != null) {
                        List<ICF_AP01_SurveyTranslation.TranslateSubQuestion> vSubQuestions = new List<ICF_AP01_SurveyTranslation.TranslateSubQuestion>();
                        // First element to translate (included in the main question
                        ICF_AP01_SurveyTranslation.TranslateSubQuestion vTranslateSubQuestion = new ICF_AP01_SurveyTranslation.TranslateSubQuestion();
                        vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSurveyQuestion.Id, null, selectedLanguage, ICF_AP01_SurveyTranslation.SUB_QUESTION);
                        vTranslateSubQuestion.name = vName;
                        vTranslateSubQuestion.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
                        vTranslateSubQuestion.questionId = vSurveyQuestion.Id;
                        vTranslateSubQuestion.value = vSurveyQuestion.Sub_Question__c;
                        vTranslateSubQuestion.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
                        vSubQuestions.add(vTranslateSubQuestion);
                    
                        if (vSurveyQuestion.Survey_Questions_Childs__r != null) {
                            vTranslateQuestion.translateSubQuestions = new List<ICF_AP01_SurveyTranslation.TranslateSubQuestion>();
                            for (ICF_Survey_Question__c vSurveySubQuestion : vSurveyQuestion.Survey_Questions_Childs__r) {
                                vTranslateSubQuestion = new ICF_AP01_SurveyTranslation.TranslateSubQuestion();
                                vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(vSurveySubQuestion.Id, null, selectedLanguage, ICF_AP01_SurveyTranslation.SUB_QUESTION);
                                vTranslateSubQuestion.name = vName;
                                vTranslateSubQuestion.csId = ICF_AP01_SurveyTranslation.getCSIdFromMap(vSurveyTranslationCSMap, vName);
                                vTranslateSubQuestion.questionId = vSurveySubQuestion.Id;
                                vTranslateSubQuestion.value = vSurveySubQuestion.Sub_Question__c;
                                vTranslateSubQuestion.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(vSurveyTranslationCSMap, vName, '');
                                vSubQuestions.add(vTranslateSubQuestion);
                            }
                        }
                        // Add all subquestions to question object
                        vTranslateQuestion.translateSubQuestions = vSubQuestions;
                    }

                    vTranslateElementList.add(vTranslateQuestion);
                }
                
            }
            translateQuestions = vTranslateElementList;
        }
        return null;
    }

    /*
    * Returns true if email template exists
    */
    public boolean isEmailTemplateValid(ICF_AP01_SurveyTranslation.TranslateInfos pEmailTemplateInfo) {
        // Check the email template exists
        if (String.isNotBlank(pEmailTemplateInfo.translatedValue)) {
            try {
                String vEmailTemplateName = pEmailTemplateInfo.translatedValue;
                //Id vEmailTemplateID = ID.valueOf(vEmailTemplateIdAsString);
                EmailTemplate vEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :vEmailTemplateName];
                if (vEmailTemplate == null) {
                    return false;
                }
            } catch (Exception e) {
                return false;
            }            
        }
        return true;
    }


    //**
    //* Save the Translation in custom settings
    //*
    public PageReference saveTranslation() {
        if (selectedLanguage != null) {
            List<ICF_SurveyTranslation__c> vSurveyTranslations = new List<ICF_SurveyTranslation__c>();
            
            String vInfoEmailTemplateName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.EMAIL_TEMPLATE);
            String vInfoRemEmailTemplateName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(surveyId, null, selectedLanguage, ICF_AP01_SurveyTranslation.REMINDER_EMAIL_TEMPLATE);
            // Save infos
            if (translateInfos != null) {
                for (ICF_AP01_SurveyTranslation.TranslateInfos vTranslateInfo : translateInfos) {
                    ICF_SurveyTranslation__c vSurveyTranslationInfo = new ICF_SurveyTranslation__c();
                    vSurveyTranslationInfo.name = vTranslateInfo.name;
                    vSurveyTranslationInfo.TranslatedValue__c = vTranslateInfo.translatedValue;
                    vSurveyTranslationInfo.SurveyId__c = surveyId;
                    vSurveyTranslationInfo.Language__c = selectedLanguage;
                    vSurveyTranslationInfo.Id = vTranslateInfo.csId;
                    vSurveyTranslations.add(vSurveyTranslationInfo);
                    if (vTranslateInfo.name == vInfoEmailTemplateName || vTranslateInfo.name == vInfoRemEmailTemplateName) {
                        if (!isEmailTemplateValid(vTranslateInfo)) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error : ' + System.Label.LABS_SF_Err_EmailTemplate + ' : ' + vTranslateInfo.translatedValue));
                            return null;
                        }
                    }
                }
            }

            // Save questions
            if (translateQuestions != null) {
                for (ICF_AP01_SurveyTranslation.TranslateQuestion vTranslateQuestion : translateQuestions) {
                    ICF_SurveyTranslation__c vSurveyTranslationQuestion = new ICF_SurveyTranslation__c();
                    vSurveyTranslationQuestion.name = vTranslateQuestion.name;
                    vSurveyTranslationQuestion.TranslatedValue__c = vTranslateQuestion.translatedValue;
                    vSurveyTranslationQuestion.SurveyId__c = surveyId;
                    vSurveyTranslationQuestion.Language__c = selectedLanguage;
                    vSurveyTranslationQuestion.QuestionId__c = vTranslateQuestion.questionId;
                    vSurveyTranslationQuestion.Id = vTranslateQuestion.csId;
                    vSurveyTranslations.add(vSurveyTranslationQuestion);

                    // Save picklist values
                    if (vTranslateQuestion.translateChoices != null) {
                        for (ICF_AP01_SurveyTranslation.TranslateChoice vTranslateChoice : vTranslateQuestion.translateChoices) {
                            ICF_SurveyTranslation__c vSurveyTranslationChoice = new ICF_SurveyTranslation__c();
                            vSurveyTranslationChoice.Name = vTranslateChoice.name;
                            vSurveyTranslationChoice.TranslatedValue__c = vTranslateChoice.translatedValue;
                            vSurveyTranslationChoice.OriginalValue__c = vTranslateChoice.value;
                            vSurveyTranslationChoice.QuestionId__c = vTranslateChoice.questionId;
                            vSurveyTranslationChoice.SurveyId__c = surveyId;
                            vSurveyTranslationChoice.Language__c = selectedLanguage;
                            vSurveyTranslationChoice.Id = vTranslateChoice.csId;
                            vSurveyTranslations.add(vSurveyTranslationChoice);
                        }
                    }

                    // Save sub questions
                    if (vTranslateQuestion.translateSubQuestions != null) {
                        for (ICF_AP01_SurveyTranslation.TranslateSubQuestion vSubQuestion : vTranslateQuestion.translateSubQuestions) {
                            ICF_SurveyTranslation__c vSurveyTranslationSubQ = new ICF_SurveyTranslation__c();
                            vSurveyTranslationSubQ.Name = vSubQuestion.name;
                            vSurveyTranslationSubQ.TranslatedValue__c = vSubQuestion.translatedValue;
                            vSurveyTranslationSubQ.OriginalValue__c = vSubQuestion.value;
                            vSurveyTranslationSubQ.QuestionId__c = vSubQuestion.questionId;
                            vSurveyTranslationSubQ.SurveyId__c = surveyId;
                            vSurveyTranslationSubQ.Language__c = selectedLanguage;
                            vSurveyTranslationSubQ.Id = vSubQuestion.csId;
                            vSurveyTranslations.add(vSurveyTranslationSubQ);
                        }
                    }
                }
            }
            try {
                upsert vSurveyTranslations;
            } catch (DMLException e) {                
                for (Integer i = 0; i < e.getNumDML(); i++) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getDMLMessage(i)));
                }
                return null;
            }
        }
        // Reload to reload Ids
        loadWrapperTranslations();
        
        return null;
    }


    //*
    //* Get possible languages to translate
    //*
    public List<SelectOption> getLanguages() {
        List<SelectOption> vAllLanguagesSO = new List<SelectOption>();
        
        if (mySurvey.Available_Languages__c != null) {
            Set<String> vSplittedValues = new Set<String>(mySurvey.Available_Languages__c.split(','));

            Schema.DescribeFieldResult vFieldResult = User.LanguageLocaleKey.getDescribe();
            List<Schema.PicklistEntry> vPicklistValues = vFieldResult.getPicklistValues();

            vAllLanguagesSO.add(new SelectOption('', System.Label.LABS_SF_SELECTTYPE));
            for (Schema.PicklistEntry vPicklistEntry : vPicklistValues) {
                if (mySurvey.Survey_Language__c != vPicklistEntry.getValue() && vSplittedValues.contains(vPicklistEntry.getValue())) {                
                    SelectOption vSO = new SelectOption(vPicklistEntry.getValue(), vPicklistEntry.getLabel());
                    vAllLanguagesSO.add(vSO);
                }
            }
        }

        return vAllLanguagesSO;
    }

}