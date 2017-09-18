@isTest
private class AccountDetailTest
{
	private static Account accTest;
	static{
		accTest = createAccount();
	}

	private static Account createAccount() {
		Account acc = new Account(Name ='Account Test');
		insert acc;
		return acc;
	}

	@isTest
	static void itShould()
	{
		// Given


		// When


		// Then

	}
}