public with sharing class ICF_ReportFinderUtil {

    public ICF_ReportFinderUtil(){}
  
    public String findReportId(String reportAPIName){    
        List<Sobject> myReport = [select Id,Name From Report Where DeveloperName=:reportAPIName];
        if(!myReport.isEmpty())
            return myReport[0].Id;
        else
            return null;    
    }
}