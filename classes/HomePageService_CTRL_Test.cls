/**
* @author 	Phuc Huynh
* @date 	22/09/2017
* @description A class Test use test class apex: HomePageServiceCTRL
* Maintenance History: 
* -- Date         Name   Version  Remarks 
* -- -----------  ----  -------  -----------------------------
* -- 22/09/2017  Phuc    1.0    Initial version
*/
@isTest
public class HomePageService_CTRL_Test {

	/*
	* @author 	Phuc Huynh
	* @date 	22/09/2017
	* @description This function create data for Test
	* @param 
	* @return 
	*/
	@testSetup
	static void setup(){
		// Create common test applicant
		List<Application__c> testApps = new List<Application__c>();
		for(Integer i=0;i<10;i++) {
			Application__c objApp = new Application__c();
			objApp.Name = '2' +'TestAccount'+i;
			testApps.add(objApp);
		}
		insert testApps;
	}

	/*
	* @author 	Phuc Huynh
	* @date 	22/09/2017
	* @description This function test HomePageServiceCTRL with function fetchApplicant(pageNumber, recordDisly).
	Compare number in data and data value total return of function
	* @param 
	* @return 
	*/
	@isTest 
	static void AccountPagerWrapper() 
	{
		HomePageService_CTRL testFucntionQuickSearch = new HomePageService_CTRL();
		HomePageService_CTRL.ApplicantPagerWrapper test = new HomePageService_CTRL.ApplicantPagerWrapper();
		test = HomePageService_CTRL.fetchApplicant(1, 1);
		Integer count = [SELECT count() FROM Application__c];
		System.assertEquals(10, test.total);
	}

	/*
	* @author 	Phuc Huynh
	* @date 	22/09/2017
	* @description This function test QuickSearchCTRL with function getlistAccount().
	Fucntion will return List with size = 6. We compare value return with 6.
	* @param 
	* @return 
	*/
	@isTest
	static void getlistAccount(){
		List<RecentlyViewed> listTest = new List<RecentlyViewed>();
		listTest = HomePageService_CTRL.getlistAccount();
		System.assertEquals(6, listTest.size());
	}
}