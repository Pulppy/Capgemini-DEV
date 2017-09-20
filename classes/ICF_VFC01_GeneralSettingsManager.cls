public with sharing class ICF_VFC01_GeneralSettingsManager {

    public ICF_Survey__c mSurvey { get; set; }

    // Custom settting configuration
    public ICF_SurveyConf__c mSurveyConfEMail { get; set; }
    public ICF_SurveyConf__c mSurveyConfSMS { get; set; }
    // TCF_Feb172017: Added new logic
    public ICF_SurveyConf__c mSurveyConfEKOMI { get; set; }


    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ICF_VFC01_GeneralSettingsManager(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Survey_Delivery_Channel__c','Send_To_EKOMI__c'});
        }
        this.mSurvey = (ICF_Survey__c)stdController.getRecord();
        initConfiguration();
    }

    /*
    * Retrieve or create the configuration custom setting
    */
    public void initConfiguration() {
        mSurveyConfEMail = ICF_SurveyConf__c.getInstance(ICF_AP_Constant.SURVEY_CONFIGURATION_EMAIL);
        mSurveyConfSMS = ICF_SurveyConf__c.getInstance(ICF_AP_Constant.SURVEY_CONFIGURATION_SMS);
        // TCF_Feb172017: Added new logic
        mSurveyConfEKOMI = ICF_SurveyConf__c.getInstance(ICF_AP_Constant.SURVEY_CONFIGURATION_EKOMI);

        if (mSurveyConfEMail == null) {
            mSurveyConfEMail = new ICF_SurveyConf__c();
            mSurveyConfEMail.Name = ICF_AP_Constant.SURVEY_CONFIGURATION_EMAIL;
        }

        if (mSurveyConfSMS == null) {
            mSurveyConfSMS = new ICF_SurveyConf__c();            
            mSurveyConfSMS.Name = ICF_AP_Constant.SURVEY_CONFIGURATION_SMS;
        }
        
        // TCF_Feb172017: Added new logic
        if (mSurveyConfEKOMI == null) {
            mSurveyConfEKOMI = new ICF_SurveyConf__c();            
            mSurveyConfEKOMI.Name = ICF_AP_Constant.SURVEY_CONFIGURATION_EKOMI;
        }
       

    }

    /*
    * Save the configuration
    */
    public PageReference saveConfig() {
        try {
            List<ICF_SurveyConf__c> vConfigToUpdate = new List<ICF_SurveyConf__c>{ mSurveyConfSMS, mSurveyConfEMail };
            upsert vConfigToUpdate;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception occured : ' + e.getMessage()));
            return null;
        }

        return null;
    }

    /*
    * if true, must display SMS configuration
    */
    public Boolean getMustDisplaySMSConfig() {
        return mSurvey.Survey_Delivery_Channel__c != 'Email';
    }


    /*
    * if true, must display SMS configuration
    */
    public Boolean getMustDisplayEmailConfig() {
        return mSurvey.Survey_Delivery_Channel__c != 'SMS';
    }
    
    /*
    * TCF_Feb172017: Added new logic
    * if true, must display EKOMI
    */
    public Boolean getMustDisplayEKOMIConfig() {
        return mSurvey.Send_To_EKOMI__c != false;
    }
    
    
}