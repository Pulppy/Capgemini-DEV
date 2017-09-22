public with sharing class CTRL_ApplicationConfirmation {
	@AuraEnabled
	 public static Account getApplicant(String IdApplication){
	 	 if(IdApplication != null){
          return [Select Id, FirstName, LastName, Salutation,PersonBirthdate,Citizenships__c, PersonMobilePhone, PersonHomePhone, Email__c From Account Where id=: IdApplication];
        }
        return new Account();
	 }
	 @AuraEnabled
	 public static Account saveEmailPhoneApplicant(Account applicant){
	 	System.debug('@@@@@applicant.Id: '+  applicant.Id);
	 	System.debug('@@@@@PersonMobilePhone: '+  applicant.PersonMobilePhone);
	 	try {
	 		Upsert applicant;
	 	} catch(DmlException e) {
    		System.debug('An unexpected error has occurred: ' + e.getMessage());
		}

	 	return applicant;
	 }
}