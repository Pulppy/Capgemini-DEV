global with sharing class ICF_GSurveysController {

    public String surveyDelete                       {get; set;}
    public String newSurveyName                      {get; set;}
    public List<miniSurvey>allSurveys                {get; set;}
    public String username                           {get; set;}
    public String userId                             {get; set;}
    public String POD                                {get; set;}
    public List<Selectoption>  sitesPicklist         {get; set;}
    public String surveySite                         {get; set;}
    public String showAddSitesMessage                {get; set;}
    private String subdomain;
    private boolean useTopLevelDomain;

    public String siteInfo  {get; set;}

    public ICF_GSurveysController(ApexPages.StandardController stdController) {
        username = System.Userinfo.getUserId();
        setAllSurveys();
        setupSitesPicklist();
        siteInfo = Site.getDomain();
    }


    private void setupSitesPicklist() {
        List<ICF_SurveySitesUtil.SurveySiteInfo> sites = ICF_SurveySitesUtil.getSiteList();
        if (sites.size() > 0) {
            subdomain = sites[0].Subdomain;
        }
        useTopLevelDomain = false;
        String pathPrefix;
        sitesPicklist = new List<Selectoption>();
        setupShowSites(sites.size());
        sitesPicklist.add(new Selectoption('--SELECT SITE--', System.Label.LABS_SF_SELECTSITE ));
        sitesPicklist.add(new Selectoption('Internal', System.Label.LABS_SF_Internal));
        for (ICF_SurveySitesUtil.SurveySiteInfo s : sites) {
            if (s.prefix == null)
                pathPrefix = 'EMPTY';
            else
                pathPrefix = s.prefix;
            sitesPicklist.add(new Selectoption(pathPrefix, s.Name));
        }
    }

    private void setupShowSites(Integer i) {
        if (i > 0) {
            showAddSitesMessage = 'false';
        } else {
            showAddSitesMessage = 'true';
        }
    }

    private void setAllSurveys() {
        List<ICF_Survey__c> surveys = [Select Id, Name from ICF_Survey__c where IsDeleted = false order by Name];

        if (allSurveys == null) {
            allSurveys = new List<miniSurvey>();
        } else {
            allSurveys.clear();
        }
        for (ICF_Survey__c s : surveys) {
            allSurveys.add(new miniSurvey(s.Name, s.Id));
        }
    }

    public Pagereference makeNewSurvey() {
        if (newSurveyName == null) {
            POD = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Name_Is_Required));
            return null;
        }
        if (surveySite == '--SELECT SITE--') {
            POD = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Site_Is_Required));
            return null;
        }



        String urlPrefix = setupUrlPrefix(surveySite);
        String domain = setupDomainForSurvey(POD);
        String urlToSave = domain + '/' + urlPrefix + 'ICF_TakeSurvey?';
        if (surveySite == 'Internal') {
            urlToSave = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'ICF_TakeSurvey?';
        }

        ICF_Survey__c s = new ICF_Survey__c();
        s.Name = newSurveyName;
        s.URL__c = urlToSave;
        s.Submit_Response__c = 'empty';
        s.Survey_Status__c = ICF_AP_Constant.STATUS_DRAFT;
        try {
            insert s;
            createAnonSurveyTaker(s.Id);
            return new Pagereference('/apex/ICF_SurveyManagerPage?id=' + s.Id);
        } catch (Exception e) {
            return null;
        }
    }

    private static void createAnonSurveyTaker(String surveyId) {
        list <ICF_SurveyTaker__c> sTakers = [select id from ICF_SurveyTaker__c where Survey__c = :surveyId and Contact__c = null and Case__c = null];
        if (sTakers != null && sTakers.size() > 0)
            return;
        ICF_SurveyTaker__c st = new ICF_SurveyTaker__c();
        st.Case__c = null;
        st.Survey__c = surveyId;
        st.Contact__c = null;
        insert st;
    }

    private String setupDomainForSurvey(String pod) {
        if (pod != 'NO_POD' && !useTopLevelDomain && checkSubdomain(subdomain)) {
            return 'http://' + subdomain + '.' + pod + '.force.com';
        } else if (pod != 'NO_POD' && useTopLevelDomain && checkSubdomain(subdomain)) {
            return 'http://' + subdomain + '.' + pod;
        } else if (useTopLevelDomain) {
            return 'http://' + subdomain;
        } else {
            return 'http://' + subdomain + '.force.com';
        }
    }

    private boolean checkSubdomain(String subdomain) {
        if (subdomain == null)
            return false;
        else if (subdomain.contains('developer-edition'))
            return true;
        else
            return false;
    }

    private String setupUrlPrefix(String site) {
        if (site == null || site == 'EMPTY')
            return '';
        else
            return site + '/';
    }

    public Pagereference doSurveyReset() {
        setAllSurveys();
        return null;
    }

    public static webservice String deleteSurvey(String deleteId) {
        ICF_Survey__c s = [Select Id, Name from ICF_Survey__c where Id = :deleteId];
        delete s;

        return 'true';
    }

    public Class miniSurvey {
        public String sName {get; set;}
        public String sId   {get; set;}

        public miniSurvey(String miniName, String miniId) {
            sName = miniName;
            sId = miniId;
        }

    }
}