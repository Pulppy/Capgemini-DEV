@isTest
public class TestHomePageService {
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
        // Create common test applicant
        List<Application__c> testApps = new List<Application__c>();
        for(Integer i=0;i<10;i++) {
            Application__c objApp = new Application__c();
        	objApp.Name = '2' +'TestAccount'+i;
            testApps.add(objApp);
        }
        insert testApps;
    }
    
     @isTest 
     static void testMethod1() 
     {
      	HomePageServerCTRL testFucntionQuickSearch = new HomePageServerCTRL();
        HomePageServerCTRL.AccountPagerWrapper test = new HomePageServerCTRL.AccountPagerWrapper();
        test = HomePageServerCTRL.fetchAccount(1, 1);
        Integer count = [SELECT count() FROM Application__c];
        System.assertEquals(10, test.total);
         
     }
    @isTest
    static void testMethod2(){
        List<RecentlyViewed> listTest = new List<RecentlyViewed>();
        listTest = HomePageServerCTRL.getlistAccount();
        System.assertEquals(6, listTest.size());
    }
    @isTest
    static void testMethod3(){
        List<sObject> listTest = new List<sObject>();
        listTest = QuickSearch_CTRL.quickSearchListData('2%','account');
        System.assertEquals(2, listTest.size());
    }
     
}