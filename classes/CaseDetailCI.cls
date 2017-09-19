public with sharing class CaseDetailCI {
	public Case objCase;

	public CaseDetailCI() {
		objCase = getCase();
	}

	public Case getCase(){
		Case acc = [Select Id, Status from Case limit 1];
		return acc;
	}
}
