@isTest
private class AccountDetailSelectTest
{
	static{
		Account acc = new Account(Name ='Account Test');
		insert acc;
	}

	@isTest static void testGetStudent() {
		Test.startTest();
		AccountDetailSelect accTest = new AccountDetailSelect();
		List<Account> accs = accTest.getAcc();
		
		system.assertEquals(accs.size(),1);
		
		Test.stopTest();
	}
}