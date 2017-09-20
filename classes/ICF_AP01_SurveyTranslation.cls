public with sharing class ICF_AP01_SurveyTranslation {
    public ICF_AP01_SurveyTranslation() {}

    public static final String HEADER = '_H_';
    public static final String FOOTER = '_F_';
    public static final String THANKYOU = '_TY_';
    public static final String EMAIL_TEMPLATE = '_ET_';
    public static final String REMINDER_EMAIL_TEMPLATE = '_REMIND_ET_';
    public static final String DESCRIPTION = '_D_';
    public static final String SMS_TEMPLATE = '_SMS_';
    public static final String REMINDER_SMS_TEMPLATE = '_REMIND_SMS_';
    public static final String QUESTION = 'Question';
    public static final String CHOICE = 'Choice';
    public static final String SUB_QUESTION = '_SQ_';

    public class TranslateChoice {
        public Id csID                { get; set; }
        public String value           { get; set; }
        public String translatedValue { get; set; }
        public Id questionId          { get; set; }
        public String name            { get; set; }
    }

    public class TranslateSubQuestion { 
        public Id csID                { get; set; }
        public String value           { get; set; }
        public String translatedValue { get; set; }
        public Id questionId          { get; set; }
        public String name            { get; set; }
    }

    public class TranslateQuestion {
        public Id csID                                          { get; set; }
        public String value                                     { get; set; }
        public String translatedValue                           { get; set; }
        public Id questionId                                    { get; set; }
        public String name                                      { get; set; }
        public Integer order                                    { get; set; }
        public List<TranslateSubQuestion> translateSubQuestions { get; set; }
        public List<TranslateChoice> translateChoices           { get; set; }
        public Integer choicesSize { 
            get {
                return translateChoices == null ? 0 : translateChoices.size();
            }
        }
        public Boolean pairNumberOfChoice {
            get {
                return Math.mod(choicesSize, 2) == 0;
            }
        }
        
    }

    public class TranslateInfos {
        public Id csID { get; set; }
        public String value { get; set; }
        public String translatedValue { get; set; }
        public String name { get; set; }
        public String type { get; set; }
    }

    //*
    //* Get the key from the element
    //*
    public static String getCSKeyFromTranslateElement(String pParentId, Integer pChoiceIndex, String pSelectedLanguage, String pType) {
        if (pType == QUESTION) {
            return pParentId + '_' + pSelectedLanguage;
        } else if (pType == CHOICE) {
            return pParentId + '_' + pChoiceIndex + '_' + pSelectedLanguage;            
        } else if (pType == SUB_QUESTION) {
            return pParentId + pType + pSelectedLanguage;            
        } else if (pType == HEADER || pType == FOOTER || pType == THANKYOU || pType == EMAIL_TEMPLATE || pType == SMS_TEMPLATE || pType == DESCRIPTION || pType == REMINDER_SMS_TEMPLATE || pType == REMINDER_EMAIL_TEMPLATE) {
            return pParentId + pType + pSelectedLanguage;
        } 
        return null;
    }

    //**
    //* Get list of choices from the choices as string
    //*
    public static List<TranslateChoice> getChoicesAsTranslateElements(String pValues, String pQuestionId, String pSelectedLanguage, Map<String, ICF_SurveyTranslation__c> pSurveyTranslationsCS){
        if (pValues == '') {
            return new List<ICF_AP01_SurveyTranslation.TranslateChoice>();
        }
        List<String> vStringSplitted = new List<String>();
        vStringSplitted = pValues.split('\n');

        List<ICF_AP01_SurveyTranslation.TranslateChoice> vTranslateEltsList = new List<ICF_AP01_SurveyTranslation.TranslateChoice>();
        Integer i = 0;
        String vName = '';
        for (String vCurrentValue : vStringSplitted) {
            if (vCurrentValue != 'null' && vCurrentValue!= null && vCurrentValue != '') {
                String vValueReWorked = vCurrentValue.replace(' ', '%20');
                
                ICF_AP01_SurveyTranslation.TranslateChoice vTranslatedChoice = new ICF_AP01_SurveyTranslation.TranslateChoice();
                
                // Question
                vName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(pQuestionId, i, pSelectedLanguage, CHOICE);
                vTranslatedChoice.value = vCurrentValue;
                vTranslatedChoice.translatedValue = ICF_AP01_SurveyTranslation.getTranslatedValueFromMap(pSurveyTranslationsCS, vName, vTranslatedChoice.translatedValue);
                vTranslatedChoice.csID = ICF_AP01_SurveyTranslation.getCSIdFromMap(pSurveyTranslationsCS, vName);
                vTranslatedChoice.questionId = pQuestionId;
                vTranslatedChoice.name = vName;
                vTranslateEltsList.add(vTranslatedChoice);

                i++;
            }               
        }

        return vTranslateEltsList;
    } 

    //**
    //* Get list of choices from the choices as string
    //*
    public static List<SelectOption> getChoicesAsSelectOptions(String pValues, String pQuestionId, String pSelectedLanguage){
        return getChoicesAsSelectOptions(pValues, pQuestionId, pSelectedLanguage, false);
    }

    //**
    //* Get list of choices from the choices as string
    //*
    public static List<SelectOption> getChoicesAsSelectOptions(String pValues, String pQuestionId, String pSelectedLanguage, Boolean pIsPickList){
        List<String> vValuesSplitted = new List<String>();
        if (pValues == '') {
          return new List<SelectOption>();
        }
        vValuesSplitted = pValues.split('\n');

        List<SelectOption> vSOList = new List<SelectOption>();
        Integer i = 0;
        String vCSName;
        // Add a blank value to the picklist
        if (pIsPickList) {
             vSOList.add(new SelectOption('', ''));
        }
        for (String s : vValuesSplitted) {
          if (s != '' && s != 'null' && s != null) {
            vCSName = ICF_AP01_SurveyTranslation.getCSKeyFromTranslateElement(pQuestionId, i, pSelectedLanguage, ICF_AP01_SurveyTranslation.CHOICE);

            ICF_SurveyTranslation__c vCSQuestion = ICF_AP01_SurveyTranslation.getTranslationInstance(vCSName);
            if (vCSQuestion != null && vCSQuestion.TranslatedValue__c != null) {
                s = s.replaceAll('\\s+$', '');
                vSOList.add(new SelectOption(s, vCSQuestion.TranslatedValue__c));
            } else {
                s = s.replaceAll('\\s+$', '');
                vSOList.add(new SelectOption(s, s));
            }

            i++;          
          }
        }

        return vSOList;
    }


    //**
    //* Return a map of the survey translation with name as key
    //*
    public static Map<String, ICF_SurveyTranslation__c> getSurveyTranslationCSAsMap(List<ICF_SurveyTranslation__c> pSurveyTranslationsCS) {
        Map<String, ICF_SurveyTranslation__c> vMapSurveyTranslationsCSMap = new Map<String, ICF_SurveyTranslation__c>();
        if (pSurveyTranslationsCS != null) {
            for (ICF_SurveyTranslation__c vTranslationCS : pSurveyTranslationsCS) {
                vMapSurveyTranslationsCSMap.put(vTranslationCS.Name, vTranslationCS);
            }
        }

        return vMapSurveyTranslationsCSMap;
    }


    //**
    //* get translated value from instance
    //* 
    public static ICF_SurveyTranslation__c getTranslationInstance(String pName) {
        return ICF_SurveyTranslation__c.getInstance(pName);
    }

    //**
    //* get translated value from map if exists
    //* 
    public static String getTranslatedValueFromMap(Map<String, ICF_SurveyTranslation__c> pSurveyTranslationsCS, String pValue, String pOriginalValue) {
        return (pSurveyTranslationsCS.containsKey(pValue)
            && pSurveyTranslationsCS.get(pValue).TranslatedValue__c != null  
            && String.isNotEmpty(pSurveyTranslationsCS.get(pValue).TranslatedValue__c.trim())) ? pSurveyTranslationsCS.get(pValue).TranslatedValue__c : pOriginalValue;
    }

    //**
    //* get id from map if exists
    //* 
    public static String getCSIdFromMap(Map<String, ICF_SurveyTranslation__c> pSurveyTranslationsCS, String pValue) {
        return pSurveyTranslationsCS.containsKey(pValue) ? pSurveyTranslationsCS.get(pValue).Id : null;
    }

}