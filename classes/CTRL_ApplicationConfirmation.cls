public with sharing class CTRL_ApplicationConfirmation {
	@AuraEnabled
	 public static Account getApplicant(String IdApplication){
	 	 if(IdApplication != null){
	 	 	Application__c Application = [Select Applicant__r.id From Application__c Where id=: IdApplication]; 
          return [Select Id,Name, FirstName, LastName, Salutation,PersonBirthdate,Citizenships__c, PersonMobilePhone, PersonHomePhone, Email__c From Account Where id=: Application.Applicant__r.Id];
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