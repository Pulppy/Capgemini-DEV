public with sharing class VisionAccountController {

	public class Data {
		@AuraEnabled
		public Account objAccount { get; set; }

		@AuraEnabled
		public List<Case> lstCase { get; set; }

		@AuraEnabled
		public Map<String,Map<String,Integer>> mapPolicyAura {get;set;}

		@AuraEnabled
		public Integer traditionalLapsed {get;set;}

		@AuraEnabled
		public Integer traditionalForce {get;set;}

		@AuraEnabled
		public Integer traditionalProgress {get;set;}

		@AuraEnabled
		public Integer traditionalIncomplete {get;set;}

		@AuraEnabled
		public Integer ilpLapsed {get;set;}

		@AuraEnabled
		public Integer ilpForce {get;set;}

		@AuraEnabled
		public Integer ilpProgress {get;set;}

		@AuraEnabled
		public Integer ilpIncomplete {get;set;}

		@AuraEnabled
		public Integer creditLapsed {get;set;}

		@AuraEnabled
		public Integer creditForce {get;set;}

		@AuraEnabled
		public Integer creditProgress {get;set;}

		@AuraEnabled
		public Integer creditIncomplete {get;set;}

		@AuraEnabled
		public Map<String,String> mapTest {get;set;}

		@AuraEnabled
		public Integer litCaseNumber {get;set;}
	}

	/*
	 * prepare
	 * @param: objId
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static VisionAccountController.Data getDataView(String objId){
		VisionAccountController.Data tag = new VisionAccountController.Data();
		try{
			String sqlAccount = '';
			tag.objAccount = Database.query('Select id,email__c,CreatedDate ,Name,Gender__c,MaritalStatus__c,Age__c,Birthdate__c,Phone,AlternativePhone__c,HomeNumbers__c,OfficeNumber__c,DoNotCall__c,VIP__c from Account  where Id =: objId');
			tag.lstCase =  Database.query('select id,SubType__c,CaseOrigin__c,CaseNumber__c,CreatedDate from Case where account.ID =: objId');
			tag.litCaseNumber = tag.lstCase.size();
			List<Policy__c> lstPolicy = Database.query('select id, Account__c, Policy_Status__c, Policy_Type__c from Policy__c Where Account__c =: objId');
			/*Traditional Life*/
			tag.traditionalLapsed = 0;
			tag.traditionalForce = 0;
			tag.traditionalProgress = 0;
			tag.traditionalIncomplete = 0;
			/*ILp*/
			tag.ilpLapsed = 0;
			tag.ilpForce = 0;
			tag.ilpProgress = 0;
			tag.ilpIncomplete = 0;
			/*Credit*/
			tag.creditLapsed = 0;
			tag.creditForce = 0;
			tag.creditProgress = 0;
			tag.creditIncomplete = 0;
			for(Policy__c obj : lstPolicy){
				/*Set number Traditional Life*/
				if(obj.Policy_Type__c != null && obj.Policy_Status__c != null){
					if(obj.Policy_Type__c == 'Traditional Life'){
						if(obj.Policy_Status__c == 'Policy Lapsed'){
							tag.traditionalLapsed = tag.traditionalLapsed + 1;
						}
						if(obj.Policy_Status__c == 'Policy In Force'){
							tag.traditionalForce = tag.traditionalForce + 1;
						}
						if(obj.Policy_Status__c == 'Application In Progress'){
							tag.traditionalProgress = tag.traditionalProgress + 1;
						}
						if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
							tag.traditionalIncomplete = tag.traditionalIncomplete + 1;
						}
					}
					/*Set number ILP*/
					if(obj.Policy_Type__c == 'ILP'){
						System.debug('xxxx ILP');
						if(obj.Policy_Status__c == 'Policy Lapsed'){
							tag.ilpLapsed = tag.ilpLapsed + 1;
						}
						if(obj.Policy_Status__c == 'Policy In Force'){
							tag.ilpForce = tag.ilpForce + 1;
						}
						if(obj.Policy_Status__c == 'Application In Progress'){
							tag.ilpProgress = tag.ilpProgress + 1;
						}
						if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
							tag.ilpIncomplete = tag.ilpIncomplete + 1;
						}
					}
					/*Set number Credit Related*/
					if(obj.Policy_Type__c.equals('Credit Related')){
						System.debug('xxxx Credit');
						if(obj.Policy_Status__c == 'Policy Lapsed'){
							tag.creditLapsed = tag.creditLapsed + 1;
						}
						if(obj.Policy_Status__c == 'Policy In Force'){
							tag.creditForce = tag.creditForce + 1;
						}
						if(obj.Policy_Status__c == 'Application In Progress'){
							tag.creditProgress = tag.creditProgress + 1;
						}
						if(obj.Policy_Status__c == 'Application Declined/Incomplete'){
							tag.creditIncomplete = tag.creditIncomplete + 1;
						}
					}
				}
			}
			/*End Sa*/
			tag.mapTest = new Map<String,String>();
			tag.mapTest.put('key1', 'Value');
			tag.mapTest.put('key2', 'Value');
			tag.mapTest.put('key3', 'Value');
		}catch(Exception ex){
			System.debug('xxxxx ' + ex.getMessage());
		}

		return tag;
	}
}

/*List<Policy__c> lstPolicy = [select id, Account__c, Policy_Status__c, Policy_Type__c from Policy__c Where Account__c='0012800000WAlmLAAT'];
Map<String, Map<String, Integer>> mapPolicy = new Map<String, Map<String, Integer>>();
for(Policy__c p : lstPolicy){
	if(!mapPolicy.containsKey(p.Policy_Type__c)){
		Map<String, Integer> mapByStatus = new Map<String, Integer>();
		mapByStatus.put(p.Policy_Status__c, 1);
		mapPolicy.put(p.Policy_Type__c, mapByStatus);
	}else{
		//mapPolicy.get(p.Policy_Type__c) 
		if(mapPolicy.get(p.Policy_Type__c).containsKey(p.Policy_Status__c)){
			Integer countNuber = mapPolicy.get(p.Policy_Type__c).get(p.Policy_Status__c) + 1;
			mapPolicy.get(p.Policy_Type__c).put(p.Policy_Status__c, countNuber);
		}else{
			mapPolicy.get(p.Policy_Type__c).put(p.Policy_Status__c, 1);
		}
	}
}*/