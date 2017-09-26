/**
* @author 	Phuc Huynh
* @date 	22/09/2017
* @description A class Test use test class apex: QuickSearchCTRL
* Maintenance History: 
* -- Date         Name   Version  Remarks 
* -- -----------  ----  -------  -----------------------------
* -- 22/09/2017  Phuc    1.0    Initial version
*/
@isTest
public class QuickSearch_CTRL_Test {
	/*
	* @author 	Phuc Huynh
	* @date 	22/09/2017
	* @description This function create data for Test
	* @param 
	* @return 
	*/
	@testSetup
	static void setup(){
		// Create common test accounts
		List<Account> testAccts = new List<Account>();
		for(Integer i=0;i<2;i++) {
			Account objAccount = new Account();
			objAccount.Name = '2' +'TestAccount'+i;
			testAccts.add(objAccount);
		}
		insert testAccts;
	}
	/*
	* @author 	Phuc Huynh
	* @date 	22/09/2017
	* @description This function test QuickSearchCTRL with function quickSearchListData(searchKeyWord,nameObject).
	 We will check size list<sObject> return with keySearch '2' compare size in data with name begin '2'
	* @param 
	* @return 
	*/
	@isTest
	static void quickSearchListData(){
		List<sObject> listTest = new List<sObject>();
		listTest = QuickSearch_CTRL.quickSearchListData('2%','account');
		System.assertEquals(2, listTest.size());
	}
}