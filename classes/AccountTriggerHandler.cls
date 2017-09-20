public without sharing class AccountTriggerHandler{
    
    public static void OnBeforeInsert(List<Account> accounts) {

    }
    
    public static void OnAfterInsert(List<Account> newAccountList){
        System.debug(PAD.canRun('SharingManagement'));
        if(PAD.canRun('SharingManagement')) {
            SharingManagement.CreateSharing(newAccountList, 'Account');
        }
    }
    
    public static void OnBeforeUpdate(List<Account> newAccountList, Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap ){
        Set<Id> accountShareRemoveSet = new Set<Id>();
        String sharingFields = SharingManagement__c.getValues('Account').Sharing_Field__c;
        List<String> sharingFieldList = sharingFields.split(';');

        for(Id accountId: newAccountMap.keySet()) {
            Account newAccount = newAccountMap.get(accountId);
            Account oldAccount = oldAccountMap.get(accountId);

            for(String s: sharingFieldList) {
                if(oldAccount.get(s) != newAccount.get(s)) {
                    accountShareRemoveSet.add(accountId);
                }
            }
        }

        if(accountShareRemoveSet.size() > 0) {
            delete [SELECT Id FROM AccountShare WHERE AccountId IN :accountShareRemoveSet AND RowCause = 'manual'];
        }
    }
    
    public static void OnAfterUpdate(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap){
        String sharingFields = SharingManagement__c.getValues('Account').Sharing_Field__c;
        List<String> sharingFieldList = sharingFields.split(';');
        Map<Id, Account> pendingAccountUpdate = new Map<Id, Account>();

        for(Id accountId : newAccountMap.keySet()) {
            Account newAccount = newAccountMap.get(accountId);
            Account oldAccount = oldAccountMap.get(accountId);

            for(String s: sharingFieldList) {
                if(oldAccount.get(s) != newAccount.get(s)) {
                    pendingAccountUpdate.put(accountId, newAccount);
                }
            }
        }

        if(pendingAccountUpdate.size() > 0 && PAD.canRun('SharingManagement')) {
            SharingManagement.CreateSharing(pendingAccountUpdate.values(), 'Account');
        }
        
    }
    
}