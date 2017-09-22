public with sharing class CTRL_ApplicantSubScription {

	@AuraEnabled
    public static Account createAccountTemplate(){
       return (Account)Account.sObjectType.newSObject(null, true);
    }

    @AuraEnabled
    public static List<String> getAccountSalutation(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: ple) {
          options.add(value.getLabel());
        }
        System.debug('@@@@@AccountSalutation: '+  options);
        return options;
    }

    @AuraEnabled
    public static List<String> getAccountCitizenships(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Citizenships__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: ple) {
          options.add(value.getLabel());
        }
        System.debug('@@@@@getAccountCitizenships: '+  options);
        return options;
    }
   
     @AuraEnabled
    public static Account saveApplicantInformation(Account anApplicant){
      System.debug('@@@@anApplicant before insert: '+ anApplicant);
      if(anApplicant != null){
        anApplicant.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();     
        Upsert anApplicant;
      }
      return anApplicant;
    }


     @AuraEnabled
    public static Account getAccountsByID(String applicantID){
        if(applicantID != null){
          return [Select Id, FirstName, LastName, Salutation,PersonBirthdate,Citizenships__c, PersonMobilePhone, PersonHomePhone, Email__c From Account Where id=:applicantID];
        }
        return new Account();

    }
   
}