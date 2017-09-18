@isTest
private class AccountDetailSelect2Test
{
	static{
		Account acc = new Account(Name ='Account Test');
		insert acc;
	}

	@isTest static void testGetStudent() {
		Test.startTest();
		AccountDetailSelect2 accTest = new AccountDetailSelect2();
		List<Account> accs = accTest.getAcc();
		
		system.assertEquals(accs.size(),3);
		
		Test.stopTest();
	}
}