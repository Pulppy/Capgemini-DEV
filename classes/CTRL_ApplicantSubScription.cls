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
      try{
          System.debug('@@@@anApplicant before insert: '+ anApplicant);
          if(anApplicant != null){
            anApplicant.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();     
            Upsert anApplicant;
          }
        }catch(Exception ex){
          System.debug('@@@@ex '+ ex);
        }
        return anApplicant;
    }


     @AuraEnabled
    public static Account getAccountsByID(String applicantID){
      try{
        System.debug('@@@@applicantID: '+ applicantID);
        Account result = new Account();
        if(applicantID != null){
            result = [Select Id, FirstName, LastName, Salutation,PersonBirthdate,Citizenships__c, PersonMobilePhone, PersonHomePhone, Email__c From Account Where id=:applicantID];
           
        }
        return result;
      }catch(Exception ex){
        System.debug('@@@@ex: '+ ex);
         return new Account();
      }
       
    }
   
}