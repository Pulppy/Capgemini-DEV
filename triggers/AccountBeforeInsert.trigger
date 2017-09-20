trigger AccountBeforeInsert on Account (before insert) {
	System.Debug('**** START TRIGGER Account Before INSERT ****');
   /* for(Account acc : Trigger.new){
        if(acc.MobilePhone__c != null){
            acc.MobilePhone__c = '12345678912';
            acc.MobilePhone__c.addError('please input MobilePhone__c');
           
        }
        system.debug('@@@accName '+ acc.Name);
        system.debug('@@@@accMobile: '+ acc.MobilePhone__c);
        system.debug('@@@@accExpected_PVI__c: '+ acc.Expected_PVI__c);
        
        if(acc.Expected_PVI__c == null){
        	acc.Expected_PVI__c.addError('');
        }
    }*/
}