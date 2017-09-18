public with sharing class ContactAndLeadSearch {
	static String hello = 'Hello World';
	public ContactAndLeadSearch() {
		if(!String.isBlank(hello)){
			System.debug('Before Change ' + hello);
			hello = 'Thocon7278';
			System.debug('After Change ' + hello);
		}
	}

	public static void searchContactsAndLeads(){
		
	}
}