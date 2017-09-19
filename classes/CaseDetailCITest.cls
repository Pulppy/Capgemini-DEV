@isTest
private class CaseDetailCITest
{
	static{
		Case acc = new Case(Status = 'New', Origin = 'Phone');
		// insert acc;
	}

	static testMethod void testGetCase() {
		CaseDetailCI caseTest = new CaseDetailCI();
		caseTest.getCase();
	}
}
