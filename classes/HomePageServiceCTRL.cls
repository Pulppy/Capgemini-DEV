public with sharing class HomePageServiceCTRL {
    @AuraEnabled
    public static ApplicantPagerWrapper fetchApplicant(Decimal pageNumber ,Integer recordToDisply) {
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
	    //NTT
        // create a instance of wrapper class.
        ApplicantPagerWrapper obj =  new ApplicantPagerWrapper();
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        obj.total = [SELECT count() FROM Application__c]; 
      	obj.application = [SELECT Id, Name,Applicant__c,LastModifiedBy.name,LastModifieddate,Status__c,Applicant__r.Name,Applicant__r.Email__c,Applicant__r.Phone FROM Application__c ORDER BY Name LIMIT :recordToDisply OFFSET :offset];
        // return the wrapper class instance .
        return obj;
    }
    // create a wrapper class with @AuraEnabled Properties    
    public  class ApplicantPagerWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Application__c> application {get;set;}
    }
    
    @AuraEnabled 
	public static List<RecentlyViewed> getlistAccount(){ 
	 	List<RecentlyViewed> listAccountAplicant = new List<RecentlyViewed>();
		listAccountAplicant = [SELECT Id, Name ,Type
			           			FROM RecentlyViewed 
			           			WHERE Type IN ('Account', 'Application__c') 
			           			ORDER BY LastViewedDate DESC 
			           			LIMIT 6]; 
       	return listAccountAplicant;
	}
}
