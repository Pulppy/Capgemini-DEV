/*------------------------------------------------------------
Author:        Hieu NGUYEN
Company:       Capgemini
Description:   control elementrecent linghtning Componenet  
Test Class:    ElementRecent_Test
History
  - 18/8 create class     
------------------------------------------------------------*/

public class ElementRecent_CTRL {
	@AuraEnabled 
	public static List<RecentlyViewed> getlist(){ 
	 	List<RecentlyViewed> listAccountAplicant = new List<RecentlyViewed>();
		listAccountAplicant = [SELECT Id, Name ,Type
			           			FROM RecentlyViewed 
			           			WHERE Type IN ('Account', 'Application__c') 
			           			ORDER BY LastViewedDate DESC 
			           			LIMIT 6]; 
       	return listAccountAplicant;
	}
}