public with sharing class CTRL_ApplicationConfirmation {
	@AuraEnabled
	 public static Account getApplicant(Id IdApplication){
	 	System.debug('@@@@@IdApplication: '+  IdApplication);
	 	Account applicant = [Select Id, Name, Email__c, PersonMobilePhone From Account Where Id = :IdApplication Limit 1];
	 	return applicant;
	 }
	 @AuraEnabled
	 public static Account saveEmailPhoneApplicant(Account applicant){
	 		Update applicant;

	 	return applicant;
	 }
}