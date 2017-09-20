public with sharing class ICF_viewShareSurveyComponentCtrl {

    public Id surveyId {
        get;
        set {
            this.surveyId = value;
            init();
        }
    }

    public String selectedLanguage { get; set; }
    public ICF_Survey__c mySurvey {get; set;}
    public List<SelectOption> urlType {get; set;}
    public String selectedURLType {get; set;}
    public String POD {get; set;}
    public List<Selectoption>  sitesPicklist {get; set;}
    public String surveySite {get; set;}
    public String showAddSitesMessage {get; set;}
    private String subdomain;
    private boolean useTopLevelDomain;
    public String siteInfo  {get; set;}
    
    public Map<String, ICF_SurveySitesUtil.SurveySiteInfo> sitesMap {get;set;}
    public Organization currentOrg {get;set;}



    public String surveyURL {
        get {
            if (selectedURLType == 'Email Link, Anonymous' || selectedURLType == 'Chatter') {
                return 'id=' + surveyId + '&cId=none&caId=none' + '&lg=' + selectedLanguage;
            } else if (selectedURLType == 'Email Link w/ Contact Merge') {
                return 'id=' + surveyId + '&cId={!Contact.Id}&caId=none' + '&lg=' + selectedLanguage;
            } else {
                return 'id=' + surveyId +  '&cId={!Contact.Id}&caId={!Case.id}' + '&lg=' + selectedLanguage;
            }
        }

        set;
    }

    public String surveyURLBase {
        get{
            if (surveySite == '--SELECT SITE--') {
                POD = '';
                return null;
            }


            String vSandboxName = '';
            if (currentOrg.IsSandbox) {
                vSandboxName = ICF_SurveySitesUtil.SandboxName + '-';
            }

            String vDomain = setupUrlSubDomain(surveySite);
            String vPathPrefix = setupPathPrefix(surveySite);
            vPathPrefix = vPathPrefix == null ?  '' : vPathPrefix + '/';
            String vPOD = POD;
            String vSuffix = '.force.com/';
            String vURL = 'http://' + vSandboxName + vDomain + '.' + currentOrg.InstanceName + vSuffix + vPathPrefix + 'ICF_TakeSurvey?';
            if (surveySite == 'Internal' || selectedURLType == 'Chatter') {
                vURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'ICF_TakeSurvey?'; 
            }
            return vURL;
        }
        set;
    }

    public ICF_viewShareSurveyComponentCtrl () {
        urlType = new List<SelectOption>();
        urlType.add(new SelectOption('Email Link w/ Contact Merge', System.Label.LABS_SF_Email_Link_w_Contact_Merge));
        urlType.add(new SelectOption('Email Link w/ Contact & Case Merge', System.Label.LABS_SF_Email_Link_w_Contact_Case_Merge));
        urlType.add(new SelectOption('Email Link, Anonymous', System.Label.LABS_SF_Email_Link_Anonymous));
        urlType.add(new SelectOption('Chatter', System.Label.LABS_SF_Chatter));
        selectedURLType = 'Chatter';

        setupPOD();
        setupSitesPicklist();
        siteInfo = Site.getDomain();

        init();
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


    private void setupSitesPicklist() {
        sitesMap = new Map<String, ICF_SurveySitesUtil.SurveySiteInfo>();
        for (ICF_SurveySitesUtil.SurveySiteInfo vSite : ICF_SurveySitesUtil.getSiteList()) {
            sitesMap.put(vSite.Id, vSite);
        }

        if (sitesMap.values().size() > 0) {
            subdomain = sitesMap.values().get(0).Subdomain;
        }
        useTopLevelDomain = false;
        String pathPrefix;
        sitesPicklist = new List<Selectoption>();
        sitesPicklist.add(new Selectoption('Internal', System.Label.LABS_SF_Internal));
        for (ICF_SurveySitesUtil.SurveySiteInfo current : sitesMap.values()) {
            sitesPicklist.add(new Selectoption(current.Id, current.Name));
        }

        surveySite = 'Internal';
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

    public void init() {
        if (surveyId != null && mySurvey == null) {
            mySurvey = [Select Id, Name, Survey_Header__c, Thank_You_Text__c, Available_Languages__c,  Survey_Language__c, URL__c FROM ICF_Survey__c where Id = :surveyId];
            selectedLanguage = mySurvey.Survey_Language__c;
            currentOrg = [select Id, InstanceName, OrganizationType, IsSandbox  from Organization limit 1];
        }
    }

    public PageReference setSelectedLanguage() {
        String vLanguageParameter = Apexpages.currentPage().getParameters().get('pSelectedLanguage');
        if (vLanguageParameter != null) {
            selectedLanguage = vLanguageParameter;
        }

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
                if (vSplittedValues.contains(vPicklistEntry.getValue())) {                
                    SelectOption vSO = new SelectOption(vPicklistEntry.getValue(), vPicklistEntry.getLabel());
                    vAllLanguagesSO.add(vSO);
                }
            }
        }

        return vAllLanguagesSO;
    }


    
}