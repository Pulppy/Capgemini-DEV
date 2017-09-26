/**
* @author 	Phuc Huynh
* @date 	15/09/2017
* @description A class Service for HomePage include compoent: PaginationAccount Component, ElementRecent Component 
* Maintenance History: 
* -- Date         Name   Version  Remarks 
* -- -----------  ----  -------  -----------------------------
* -- 15/09/2017  Phuc    1.0    Initial version
* -- 17/09/2017  Phuc    1.1    Create class ApplicantPagerWrapper and  function ApplicantPagerWrapper 
*/
public without sharing class HomePageService_CTRL {

	/*
	* @author Phuc Huynh
	* @date 17/09/2017
	* @description This functon return class ApplicantPagerWrapper include propertys
	* @param pageNumber with type Decimal 
	* @param recordToDisply with type Integer
	* @return class ApplicantPagerWrapper
	*/
	@AuraEnabled
	public static ApplicantPagerWrapper fetchApplicant(Decimal pageNumber, Integer recordToDisply) {
		try{
			Integer pageSize = recordToDisply;
			Integer offset = ((Integer)pageNumber - 1) * pageSize;
			String strRecordTypeid = Label.PersonalAccount; 
			// Create a instance of wrapper class.
			ApplicantPagerWrapper obj =  new ApplicantPagerWrapper();
			// Set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
			obj.pageSize = pageSize;
			obj.page = (Integer) pageNumber;
			obj.total = [SELECT count() FROM Application__c  WHERE Applicant__r.RecordTypeid =:strRecordTypeid]; 
			obj.application = [SELECT Id, Name, Applicant__c, LastModifiedBy.name, LastModifieddate, Status__c, Applicant__r.Name, Applicant__r.Email__c, Applicant__r.Phone 
								FROM Application__c 
								WHERE Applicant__r.RecordTypeid =:strRecordTypeid 
								ORDER BY Name 
								LIMIT :recordToDisply OFFSET :offset];
		// Return the wrapper class instance
			return obj;
		}catch(Exception ex){
			System.debug(ex.getMessage());
			return new ApplicantPagerWrapper();
		}
	}

	/**
	* @author 	Phuc Huynh
	* @date 	17/09/2017
	* @description A class include many property: pageSize with type Integer, page with type Integer, total with type Integer and applicant with type List<Applicant__c>
	*			value of class will use fetchApplicant function 
	* Maintenance History: 
	* -- Date         Name   Version  Remarks 
	* -- -----------  ----  -------  -----------------------------
	* -- 
	*/
	public  class ApplicantPagerWrapper {
		@AuraEnabled public Integer pageSize {get;set;}
		@AuraEnabled public Integer page {get;set;}
		@AuraEnabled public Integer total {get;set;}
		@AuraEnabled public List<Application__c> application {get;set;}
	}

	/*
	* @author Hieu Nguyen
	* @date 
	* @description This functon return List<RecentlyViewed> for ElementRecent Component use
	* @param 
	* @return List<RecentlyViewed>
	*/
	@AuraEnabled 
	public static List<RecentlyViewed> getlistAccount(){ 
		try{
			List<RecentlyViewed> listAccountAplicant = new List<RecentlyViewed>();
			listAccountAplicant = [SELECT Id, Name , Type
								FROM RecentlyViewed 
								WHERE Type IN ('Account', 'Application__c') 
								ORDER BY LastViewedDate DESC 
								LIMIT 6]; 
			return listAccountAplicant;
		}catch(Exception ex){
			System.debug(ex.getMessage());
			return   new List<RecentlyViewed>();
		}
	}
}