@isTest
public class QuickSearchCTRL_Test {
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
    @isTest
    static void quickSearchListData(){
        List<sObject> listTest = new List<sObject>();
        listTest = QuickSearch_CTRL.quickSearchListData('2%','account');
        System.assertEquals(2, listTest.size());
    }
}