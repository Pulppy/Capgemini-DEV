@isTest
public class HomePageServiceCTRL_Test {
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
    
     @isTest 
     static void AccountPagerWrapper() 
     {
      	HomePageServiceCTRL testFucntionQuickSearch = new HomePageServiceCTRL();
        HomePageServiceCTRL.ApplicantPagerWrapper test = new HomePageServiceCTRL.ApplicantPagerWrapper();
        test = HomePageServiceCTRL.fetchApplicant(1, 1);
        Integer count = [SELECT count() FROM Application__c];
        System.assertEquals(10, test.total);
         
     }
    @isTest
    static void getlistAccount(){
        List<RecentlyViewed> listTest = new List<RecentlyViewed>();
        listTest = HomePageServiceCTRL.getlistAccount();
        System.assertEquals(6, listTest.size());
    }
  
     
}