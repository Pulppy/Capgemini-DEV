public with sharing class ICF_SurveyManagerController {

    private ApexPages.StandardController stdControl;
    public ICF_Survey__c mSurvey { get; set; }
    public String logoUrl { get; set; }
    public List<String> languagesNotSelected { get; set; }
    public List<String> languagesSelected { get; set; }

    public List<String> languagesNotSelectedInProgress { get; set; }
    public List<String> languagesSelectedInProgress { get; set; }

    // URL manage    
    public String surveySite { get; set; }
    public List<Selectoption>  sitesPicklist { get; set; }
    public Map<String, ICF_SurveySitesUtil.SurveySiteInfo> sitesMap { get;set; }
    public Organization currentOrg { get;set; }
    private String subdomain { get; set; }
    public String POD {get; set;}
    public String selectedURLType {get; set;}

   
    public Document document {
        get {
            if (document == null) {
                document = new Document();
            }
            return document;
        }
        set;
    }

    public ICF_SurveyManagerController(ApexPages.StandardController stdController){
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Available_Languages__c', 'Survey_Site__c', 'Survey_Logo__c'});
        }
        mSurvey = (ICF_Survey__c) stdController.getRecord();
        this.stdControl = stdController;
        
        if (mSurvey.Survey_Logo__c != null) {
            logoUrl = '/servlet/servlet.FileDownload?file=' + mSurvey.Survey_Logo__c;
        } else {
            logoUrl = '';
        }
        initLanguages();

        // URL managing
        currentOrg = [select Id, InstanceName, OrganizationType, IsSandbox  from Organization limit 1];
        setupPOD();
        setupSitesPicklist();
        if (mSurvey.Survey_Site__c != null) {
            surveySite = mSurvey.Survey_Site__c;
        } else {
            surveySite = 'Internal';
        }
    }

    //**
    //* Add document and save the survey
    //*
    public PageReference saveSurvey() {
        Folder vFolder = null;
        try {
            vFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'ICF_Survey_Folder'];
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No folder named ICF_Survey_Folder'));
            return null;
        }

        // Check the email template exists
        if (String.isNotBlank(mSurvey.EmailTemplate__c)) {
            try {
                //Id vEmailTemplateID = ID.valueOf(mSurvey.Email_Template__c);
                EmailTemplate vEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :mSurvey.EmailTemplate__c];
                if (vEmailTemplate == null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.LABS_SF_Err_EmailTemplate));
                    return null;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.LABS_SF_Err_EmailTemplate));
                return null;
            }            
        }
        if (String.isNotBlank(mSurvey.Reminder_EmailTemplate__c)) {
            try {
                EmailTemplate vEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :mSurvey.Reminder_EmailTemplate__c];
                if (vEmailTemplate == null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.LABS_SF_Err_ReminderEmailTemplate));
                    return null;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.LABS_SF_Err_ReminderEmailTemplate));
                return null;
            }            
        }

        if (document.body != null && vFolder != null) {
            document.AuthorId = UserInfo.getUserId();
            document.FolderId = vFolder.ID; 
            document.IsPublic = true;

            List<Document> vDocument = [Select Id FROM Document WHERE Name=:document.Name];

            try {
                if (mSurvey.Survey_Logo__c != null) {
                    document.Id = mSurvey.Survey_Logo__c;
                    update document;
                } else {
                    insert document;
                }
                mSurvey.Survey_Logo__c = document.id;
                logoUrl = '/servlet/servlet.FileDownload?file=' + mSurvey.Survey_Logo__c;
                
                update mSurvey;
            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading file'));
                return null;
            } finally {
                document.body = null; // clears the viewstate
                document = new Document();
            }
        }
        // Add selected languages
        mSurvey.Available_Languages__c = '';
        for (String vLanguage : languagesSelected) {
            mSurvey.Available_Languages__c += vLanguage + ',';
        }
        mSurvey.Survey_Site__c = surveySite;
        mSurvey.URL__c = surveyURLBase + surveyURL;

        return stdControl.save();
    }

    //**
    //* Delete the logo and so save the survey
    //*
    public PageReference deleteLogo() {
        if (mSurvey.Survey_Logo__c != null) {
            try {
                List<Document> vDocument = [Select Id FROM Document WHERE Id=:mSurvey.Survey_Logo__c];
                if (vDocument != null && vDocument.size() > 0) {
                    delete vDocument;
                }
                mSurvey.Survey_Logo__c = null;
                ICF_Survey__c vSurveyRetrieved = [SELECT Id, Survey_Logo__c FROM ICF_Survey__c WHERE Id = :mSurvey.Id];
                vSurveyRetrieved.Survey_Logo__c = null;
                update vSurveyRetrieved;
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error deleting file'));
                return null;
            }
        }
        return null;
    }

    //**
    //* Return the values of survey status picklist 
    //*
    public List<SelectOption> getStatusPL() { 
        return ICF_AP_Utility.getStandardPicklistValues(ICF_Survey__c.Survey_Status__c, false);
    }

    //**
    //* Return the values of survey languages picklist 
    //*
    public List<SelectOption> getLanguagesPL() {
        return getAllLanguagesSelected();
    }

    //**
    //* Return the values of survey languages picklist 
    //*
    public List<SelectOption> getDeliveryChannelsPL() {
        return ICF_AP_Utility.getStandardPicklistValues(ICF_Survey__c.Survey_Delivery_Channel__c, false);
    }
    
    //**
    //* Start: TCF_Feb182017: Added new logic to return send to EKOMI checkbox value
    //*
    public List<SelectOption> getCheckboxvalue() {
        return ICF_AP_Utility.getStandardPicklistValues(ICF_Survey__c.Send_To_EKOMI__c, false);
    }
    
    //*
    //* Return true if the status is archived or closed
    //*
    public Boolean getIsArchived() {
        return mSurvey.Survey_Status__c == ICF_AP_Constant.STATUS_ARCHIVED;
    }


    //*
    //* Return all the languages availables not selected
    //*
    public List<SelectOption> getAllLanguagesNotSelected() {
        Set<String> vNotSelectedValues = new Set<String>(languagesNotSelected);
        List<SelectOption> vAllLanguagesSO = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            if (vNotSelectedValues.contains(picklistEntry.getValue())) {                
                SelectOption vSO = new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel());
                vAllLanguagesSO.add(vSO);
            }
        }

        return vAllLanguagesSO;
    }


    //*
    //* Return all the languages availables selected
    //*
     public List<SelectOption> getAllLanguagesSelected() {
        Set<String> vSelectedValues = new Set<String>(languagesSelected);
        List<SelectOption> vAllLanguagesSO = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            if (vSelectedValues.contains(picklistEntry.getValue())) {                
                SelectOption vSO = new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel());
                vAllLanguagesSO.add(vSO);
            }
        }

        return vAllLanguagesSO;
    }

    //*
    //* Init languages
    //*
    public void initLanguages() {
        languagesNotSelected = new List<String>();
        languagesSelected = new List<String>();

        // Get all values from schema
        Schema.DescribeFieldResult vFieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> vPicklistValues = vFieldResult.getPicklistValues();
        for (Schema.PicklistEntry vPicklistEntry : vPicklistValues) {
            languagesNotSelected.add(vPicklistEntry.getValue());
        }

        // Retrieve Saved values and modify lists in consequence
        Set<String> vSavedLanguages = getSavedLanguages(mSurvey.Available_Languages__c);
        for (String vLanguage : vSavedLanguages) {
            removeValueFromUnselectedAndAddToSelected(vLanguage);
        }
        if (mSurvey.Available_Languages__c == null) {
            removeValueFromUnselectedAndAddToSelected(ICF_AP_Constant.DEFAULT_LANGUAGE);
        }

    }

    //*
    //* REturn the selectOption list of selected languages
    //*
    public List<SelectOption> getLanguagesSelectedSO() {
        return getAllLanguagesSelected();
    }

    
    //*
    //* REturn the selectOption list of unselected languages
    //*
    public List<SelectOption> getLanguagesNotSelectedSO() {
        return getAllLanguagesNotSelected();
    }


    //*
    //* Return a set of string 
    //*
    public Set<String> getSavedLanguages(String pSelectedLanguages) {
        if (pSelectedLanguages == null) {
            return new Set<String>();
        }
        List<String> vSplittedValues = pSelectedLanguages.split(',');
        return new Set<String>(vSplittedValues);
    }


    //*
    //* Select a language : remove it from left list and move it to the right
    //*
    public void selectLanguage() {
        for (String vLanguage : languagesNotSelectedInProgress) {
            removeValueFromUnselectedAndAddToSelected(vLanguage);
        }
        
    }

    //*
    //* Unselect a language : remove it from right list and move it to the left
    //*
    public void unselectLanguage() {
        if (languagesSelected.size() - languagesSelectedInProgress.size() == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.LABS_SF_Err_Languages));
        } else {
        for (String vLanguage : languagesSelectedInProgress) {
            removeValueFromSelectedAndAddToUnselected(vLanguage);
            }
        }
    }


    //*
    //* Remove the value from the not selected list and add it to the selected list
    //*
    public void removeValueFromUnselectedAndAddToSelected(String pValue) {
        Integer i = 0;
        for (String vLanguage : languagesNotSelected) {
            if (vLanguage == pValue) {
                languagesNotSelected.remove(i);
                languagesSelected.add(pValue);
                break;
            }
            i++;
        }
    }

    //*
    //* Remove the value from the selected list and add it to the not selected list
    //*
    public void removeValueFromSelectedAndAddToUnselected(String pValue) {
        Integer i = 0;
        for (String vLanguage : languagesSelected) {
            if (vLanguage == pValue) {
                languagesSelected.remove(i);
                languagesNotSelected.add(pValue);
                break;
            }
            i++;
        }
    }


    //*
    //* setup the list picklist
    //*
    private void setupSitesPicklist() {
        sitesMap = new Map<String, ICF_SurveySitesUtil.SurveySiteInfo>();
        for (ICF_SurveySitesUtil.SurveySiteInfo vSite : ICF_SurveySitesUtil.getSiteList()) {
            sitesMap.put(vSite.Id, vSite);
        }

        if (sitesMap.values().size() > 0) {
            subdomain = sitesMap.values().get(0).Subdomain;
        }
        String pathPrefix;
        sitesPicklist = new List<Selectoption>();
        sitesPicklist.add(new Selectoption('Internal', System.Label.LABS_SF_Internal));
        for (ICF_SurveySitesUtil.SurveySiteInfo current : sitesMap.values()) {
            sitesPicklist.add(new Selectoption(current.Id, current.Name));
        }
    }


    //*
    //* Get the survey URL Base
    //*
    public String surveyURLBase {
        get{
            if (surveySite == '--SELECT SITE--') {
                POD = '';
                return null;
            }

            String vOrgName = '';
            if (currentOrg.IsSandbox && ICF_SurveySitesUtil.SandboxName != null) {
                vOrgName = ICF_SurveySitesUtil.SandboxName + '-';
            } else {
                // Check if the label value is not equals to keyword 'null'
                if (String.isNotEmpty(System.Label.LABS_SF_Survey_URL_Prefix) && System.Label.LABS_SF_Survey_URL_Prefix != 'null') {
                    vOrgName = System.Label.LABS_SF_Survey_URL_Prefix;
                }
            }

            String vDomain = setupUrlSubDomain(surveySite);
            String vPathPrefix = setupPathPrefix(surveySite);
            vPathPrefix = (vPathPrefix == null || vPathPrefix == '') ?  '' : vPathPrefix + '/';
            String vPOD = POD;
            String vSuffix = currentOrg.IsSandbox ? '.force.com/' : '.secure.force.com/';
            String vInstanceName = currentOrg.IsSandbox ? ('.' + currentOrg.InstanceName) : '';
            String vProtocol = 'http://';
            String vURL = vProtocol + vOrgName + vDomain +  vInstanceName + vSuffix + vPathPrefix + 'ICF_TakeSurvey?';
            if (surveySite == 'Internal' || selectedURLType == 'Chatter') {
                vURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'ICF_TakeSurvey?';
            }
            return vURL;
        }
        set;
    }


    private void setupPOD() {
        String urlToSplit = URL.getSalesforceBaseUrl().toExternalForm();
        List<String> splitURL = urlToSplit.split('\\.');
        Integer loc = -1;
        Integer i;
        for (i = 0; i < splitURL.size(); i++) {

            if (splitURL.get(i) == 'visual' || splitURL.get(i)  == 'salesforce') {
                loc = i - 1;
                break;
            }
        }

        if (loc == -1) {
            pod = 'NO_POD';
            return;
        }

        if (splitURL.get(loc + 1) == 'visual') {
            pod = splitURL.get(loc);
        } else {
            pod = 'NO_POD';
        }
    }

    public String surveyURL {
        get {
            return 'id=' + mSurvey.Id;
        }
        set;
    }
 
    @testVisible
    private boolean checkSubdomain(String subdomain) {
        if (subdomain == null)
            return false;
        else if (subdomain.contains('developer-edition'))
            return true;
        else
            return false;
    }

    @testVisible
    private String setupUrlSubDomain(String pSite) {
        if (pSite == null || pSite == 'EMPTY') {
            return '';
        } else if (sitesMap != null && sitesMap.containsKey(pSite)){
            return sitesMap.get(pSite).subdomain;
        }

        return '/';     
    }
    @testVisible
    private String setupPathPrefix(String pSite) {
        if (pSite == null || pSite == 'EMPTY') {
            return '';
        } else if (sitesMap != null && sitesMap.containsKey(pSite)){
            return sitesMap.get(pSite).prefix;
        }

        return '/';     
    }
}