public with sharing class AccountDetail {
// Phuc
	public class Data {
		@AuraEnabled
		public Account objAccount { get; set; }

		@AuraEnabled
		public List<Case> lstCase { get; set; }	

		@AuraEnabled
		public Map<String, String> policyMap {get;set;}
		
	}
	/* Test Deploy*/
	/* I am Super Man =]]]*/

	/*Phuc LONG*/
	/*
	 * prepare
	 * @param: objId
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static AccountDetail.Data getDataView(String objId){
		AccountDetail.Data tag = new AccountDetail.Data();
		try{
			String sqlAccount = '';
			tag.objAccount = Database.query('Select id,email__c,CreatedDate ,Name,Gender__c,MaritalStatus__c,Age__c,Birthdate__c,Phone,AlternativePhone__c,HomeNumbers__c,OfficeNumber__c,DoNotCall__c,VIP__c from Account  where Id =: objId');
			tag.lstCase =  Database.query('select id,SubType__c,CaseOrigin__c,CaseNumber__c,CreatedDate from Case where account.ID =: objId');
			
			List<Policy__c> lstPolicy = Database.query('select id, Account__c, Policy_Status__c, Policy_Type__c from Policy__c Where Account__c =: objId');
			/*Traditional Life*/
			Integer traditionalLapsed = 0;
			Integer traditionalForce = 0;
			Integer traditionalProgress = 0;
			Integer traditionalIncomplete = 0;
			/*ILp*/
			Integer ilpLapsed = 0;
			Integer ilpForce = 0;
			Integer ilpProgress = 0;
			Integer ilpIncomplete = 0;
			/*Credit*/
			Integer creditLapsed = 0;
			Integer creditForce = 0;
			Integer creditProgress = 0;
			Integer creditIncomplete = 0;
			for(Policy__c obj : lstPolicy){
				/*Set number Traditional Life*/
				if(obj.Policy_Type__c == 'Traditional Life'){
					if(obj.Policy_Status__c == 'Policy Lapsed'){
						traditionalLapsed = traditionalLapsed + 1;
					}
					if(obj.Policy_Status__c == 'Policy In Force'){
						traditionalForce = traditionalForce + 1;
					}
					if(obj.Policy_Status__c == 'Application In Progress'){
						traditionalProgress = traditionalProgress + 1;
					}
					if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
						traditionalIncomplete = traditionalIncomplete + 1;
					}
				}
				/*Set number ILP*/
				if(obj.Policy_Type__c == 'ILP'){
					System.debug('xxxx ILP');
					if(obj.Policy_Status__c == 'Policy Lapsed'){
						ilpLapsed = ilpLapsed + 1;
					}
					if(obj.Policy_Status__c == 'Policy In Force'){
						ilpForce = ilpForce + 1;
					}
					if(obj.Policy_Status__c == 'Application In Progress'){
						ilpProgress = ilpProgress + 1;
					}
					if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
						ilpIncomplete = ilpIncomplete + 1;
					}
				}
				/*Set number Credit Related*/
				if(obj.Policy_Type__c.equals('Credit Related')){
					System.debug('xxxx Credit');
					if(obj.Policy_Status__c == 'Policy Lapsed'){
						creditLapsed = creditLapsed + 1;
					}
					if(obj.Policy_Status__c == 'Policy In Force'){
						creditForce = creditForce + 1;
					}
					if(obj.Policy_Status__c == 'Application In Progress'){
						creditProgress = creditProgress + 1;
					}
					if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
						creditIncomplete = creditIncomplete + 1;
					}
				}
			}

			tag.policyMap = new Map<String, String>();
			tag.policyMap.put('traditionalLapsed', String.valueOf(traditionalLapsed));
			tag.policyMap.put('traditionalForce', String.valueOf(traditionalForce));
			tag.policyMap.put('traditionalProgress', String.valueOf(traditionalProgress));
			tag.policyMap.put('traditionalIncomplete', String.valueOf(traditionalIncomplete));
			
			tag.policyMap.put('ilpLapsed', String.valueOf(ilpLapsed));
			tag.policyMap.put('ilpForce', String.valueOf(ilpForce));
			tag.policyMap.put('ilpProgress', String.valueOf(ilpProgress));
			tag.policyMap.put('ilpIncomplete', String.valueOf(ilpIncomplete));
			
			tag.policyMap.put('creditLapsed', String.valueOf(creditLapsed));
			tag.policyMap.put('creditForce', String.valueOf(creditForce));
			tag.policyMap.put('creditProgress', String.valueOf(creditProgress));
			tag.policyMap.put('creditIncomplete', String.valueOf(creditIncomplete));
		}catch(Exception ex){
			System.debug('xxxxx ' + ex.getMessage());
		}

		return tag;
	}
}