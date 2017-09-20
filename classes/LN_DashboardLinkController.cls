public with sharing class LN_DashboardLinkController
{
    
    public class Data 
    {
       
        @AuraEnabled
        public String urlDashboard { get; set; }

        @AuraEnabled
        public Id idDashboard { get; set; }

        @AuraEnabled
        public String nameDashboard { get; set; }
       
    }
   
   @AuraEnabled
    public static LN_DashboardLinkController.Data prepare()
    {
        LN_DashboardLinkController.Data tag = new LN_DashboardLinkController.Data();
        tag.nameDashboard= getDashBoard();
        tag.idDashboard = [select id from Dashboard where Title =:tag.nameDashboard limit 1].id;
        tag.urlDashboard ='/one/one.app#/sObject/'+tag.idDashboard+'/view';

        return tag;
    }
    
    public static String getDashBoard(){
        String dashboard='Agent Performance Dashboard';
        //String dashboard='';
        String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
        for(SF1CustomProfileSetting__c cs : SF1CustomProfileSetting__c.getall().values()){
            if (cs.Name==userProfileName & cs.Active__c==true) return cs.Default_Dashboard__c; 
        }
        
        return dashboard;
    }

}