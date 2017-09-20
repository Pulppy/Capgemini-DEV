public with sharing class ICF_SurveySitesUtil {


    public static String SandboxName {
        public get {
            if (SandboxName == null) {
                //
                // Possible Scenarios:
                //
                // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
                // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
                // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable

                // Split up the hostname using the period as a delimiter
                List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
                if (parts.size() == 4) {
                    SandboxName = parts[0];
                } else if (parts.size() == 5 && parts[0].split('--').size() > 1) {
                    SandboxName = parts[0].split('--')[1];
                } else {
                    SandboxName = null;
                }
            } 
            return SandboxName;
        } 
        private set;
    }

    public static Boolean hasSites() {
        return Schema.getGlobalDescribe().keySet().contains('site');
    }
    
    public static List<SurveySiteInfo> getSiteList() {      
        List<SurveySiteInfo> ret = new List<SurveySiteInfo>();      
        if (!hasSites()) {
            return ret;
        }       
        List<Sobject> sitesResults = Database.query('Select Id, Name, Subdomain, UrlPathPrefix from Site Where Status = \'Active\' AND Subdomain != \'\'');
                
        for (Sobject current : sitesResults) {
            ret.add(new SurveySiteInfo((String)current.get('Id'), (String)current.get('Name'), (String)current.get('UrlPathPrefix'), (String)current.get('Subdomain')));
        }
        
        return ret;     
    }
    
    public class SurveySiteInfo {
        public String Id { get; set; }
        public String name { get; set; }
        public String prefix { get; set; }
        public String subdomain {get; set; }
        
        public SurveySiteInfo(String id, String name, String prefix, String subdomain) {
            this.Id = id;
            this.name = name;
            this.prefix = prefix;
            this.subdomain = subdomain;
        }
    } 
}