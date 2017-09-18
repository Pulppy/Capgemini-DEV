public with sharing class ContactSearch {
	public ContactSearch() {

		
	}

	public static List<Contact> searchForContacts(String lastName, String mailPostCode){
		List<Contact> lstContact = new List<Contact>();
		String soql = 'Select id from Contact where LastName =: lastName And MailingPostalCode =: mailPostCode';
		lstContact = Database.query(soql);
		return lstContact;
	}
}