/*************************************************************************************
Trigger Name - ICF_DetailRuleTrigger
Version - 1.0
Created Date - 16 APR 2015
Function - Class to manage processes on Detail Rule object

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SC(NJO)       16/04/2015  Original Version(Check field validity relative to sObject)
* SC(DUN)       21/04/2015  Added Automatic Increment of number field
* SC(HDU)       15/09/2015  Verify sObject of Master rule fo vaild field of details rule
* AA			25/09/2015  Modify the validateDetails method to check field object according to the process type  
*************************************************************************************/
public without sharing class ICF_DetailRuleTriggerHandler {

	ICF_Bypass__c userBypass = ICF_Bypass__c.getInstance(UserInfo.getUserId());
	public void OnBeforeInsert(ICF_DetailRule__c[] newDetailRules) {
		map <Id, list<ICF_DetailRule__c>> mapMasterIdDetailRule = new map <Id, list<ICF_DetailRule__c>>();
		map <String, Id> dRRecordTypeMap = ICF_AP_Constant.getDeveloperIdMap(ICF_AP_Constant.SOBJECT_CRITERIA); 

		for (integer i = 0; i < newDetailRules.size(); i++) {
			if (userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP06')) {
				if (mapMasterIdDetailRule.containsKey(newDetailRules[i].MasterRule__c))
					mapMasterIdDetailRule.get(newDetailRules[i].MasterRule__c).add(newDetailRules[i]);
				else
					mapMasterIdDetailRule.put(newDetailRules[i].MasterRule__c, new list<ICF_DetailRule__c> {newDetailRules[i]});
			}
		}

		system.debug('## mapMasterIdDetailRule' + mapMasterIdDetailRule);
		if (mapMasterIdDetailRule.size() > 0) {
			incrementFieldNumber(mapMasterIdDetailRule);
			validateDetails(mapMasterIdDetailRule);
		}
	}

	public void OnBeforeUpdate(ICF_DetailRule__c[] oldDetailRules, ICF_DetailRule__c[] newDetailRules) {
		map <Id, list<ICF_DetailRule__c>> mapMasterIdDetailRule = new map <Id, list<ICF_DetailRule__c>>();
		map <Id, list<ICF_DetailRule__c>> mapMasterIdDetailRuleForNumber = new map <Id, list<ICF_DetailRule__c>>();
		map <String, Id> dRRecordTypeMap = ICF_AP_Constant.getDeveloperIdMap(ICF_AP_Constant.SOBJECT_CRITERIA);

		for (integer i = 0; i < newDetailRules.size(); i++) {
			if (userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP06')) {
				if (mapMasterIdDetailRule.containsKey(newDetailRules[i].MasterRule__c))
					mapMasterIdDetailRule.get(newDetailRules[i].MasterRule__c).add(newDetailRules[i]);
				else
					mapMasterIdDetailRule.put(newDetailRules[i].MasterRule__c, new list<ICF_DetailRule__c> {newDetailRules[i]});
			}
			if (userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP07')) {
				if (newDetailRules[i].sObject__c != null && newDetailRules[i].fields__c != null && newDetailRules[i].RecordTypeId != dRRecordTypeMap.get(ICF_AP_Constant.CRITERIA_RT_DeveloperName_CRITERIA) &&
				        (newDetailRules[i].sObject__c != oldDetailRules[i].sObject__c || newDetailRules[i].fields__c != oldDetailRules[i].fields__c || newDetailRules[i].Operator__c != oldDetailRules[i].Operator__c || newDetailRules[i].Operator__c != null)) {
					if (checkSObjectField(newDetailRules[i].sObject__c, newDetailRules[i].fields__c, newDetailRules[i].Operator__c) == 1) { 
						newDetailRules[i].addError(System.Label.LABS_SF_DETAILRULEINVALIDFIELD);
					}
				}
			}
			/*if (userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP08')) {
				if (oldDetailRules[i].TECH_MasterRuleStatus__c) {
					newDetailRules[i].addError(System.Label.LABS_SF_DETAILRULENOTUPDATE);
				}
			}*/
		}
		if (mapMasterIdDetailRule.size() > 0) {
			validateDetails(mapMasterIdDetailRule);
		}
	}

	public void OnBeforeDelete(ICF_DetailRule__c[] oldDetailRule) {
		for (integer i = 0; i < oldDetailRule.size(); i++) {

		}
	}


	public void validateDetails(map <Id, list<ICF_DetailRule__c>> mapMasterIdDetailRule) {
		for (    ICF_MasterRules__c masterRule : [   SELECT  Id, sObject__c, Process__c
		         FROM    ICF_MasterRules__c
		         WHERE   Id IN :mapMasterIdDetailRule.KeySet()  ]) {
			for (ICF_DetailRule__c detailRule : mapMasterIdDetailRule.get(masterRule.Id)   ) {

                system.debug('##test ICF_MasterRules__c' + masterRule);
				if (masterRule.Process__c.equals(ICF_AP_Constant.PROCESS_EVENT)  
						&& masterRule.sObject__c != null
				        && detailRule.fields__c != null
				        && detailRule.Operator__c != null
				        && checkSObjectField(detailRule.sObject__c, detailRule.fields__c, detailRule.Operator__c) == 1) {
							detailRule.addError(System.Label.LABS_SF_DETAILRULEINVALIDFIELD);
				} else if (!masterRule.Process__c.equals(ICF_AP_Constant.PROCESS_EVENT) 
						&& masterRule.sObject__c != null
				        && detailRule.fields__c != null
				        && detailRule.Operator__c != null
				        && checkSObjectField(masterRule.sObject__c, detailRule.fields__c, detailRule.Operator__c) == 1) {
				        	detailRule.addError(System.Label.LABS_SF_DETAILRULEINVALIDFIELD);
				        }
			}//end of loop detail
		}//end of loop master rule
	}//end of method

	public Integer checkSObjectField(String sObjectName, string fieldName , string operator) {
		system.debug('## Start checkSObjectField method');
		SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        system.debug('## sObjectName:' + sObjectName);
        system.debug('## objectType:' + objectType);
		Map<String, Schema.SObjectField> mpObjectFields = objectType.getDescribe().fields.getMap();
		if (fieldName.contains('.')) {
			try {
				String queryToSelect = 'SELECT ' + fieldName + ' FROM ' + sObjectName + ' limit 1';
				system.debug('## queryToSelect ' + queryToSelect);
				list <sObject> obj = new list <sObject> (Database.query(queryToSelect));
				system.debug('## try');
				return 0;
			} catch (Exception e) {
				system.debug('## catch' + e);
				return 1;
			}
		} else {
			if (mpObjectFields.containsKey(fieldName)) {
				Schema.DescribeFieldResult dfr = mpObjectFields.get(fieldName).getDescribe();
				system.debug('## dfr=' + dfr);

				Schema.DisplayType fieldType = dfr.getType();
				system.debug('## fieldType=' + fieldType);
				return 0;
			} else
				return 1;
		}
	}

	private void incrementFieldNumber(map <Id, list<ICF_DetailRule__c>> mapMasterIdDetailRule) {
		system.debug('## Start incrementFieldNumber method');
		system.debug('## mapMasterIdDetailRule ' + mapMasterIdDetailRule);
		system.debug('## mapMasterIdDetailRule key ' + mapMasterIdDetailRule.KeySet());
		map <String, Integer> mapIdNumber = new map <String, Integer>();

		system.debug('## aggrequery' + [select MAX(Number__c)maxNumber, MasterRule__c
		                                from ICF_DetailRule__c
		                                where MasterRule__c in: mapMasterIdDetailRule.KeySet()
		                                group by MasterRule__c]);

		for (aggregateResult aggrRe : [select MAX(Number__c)maxNumber, MasterRule__c
		                               from ICF_DetailRule__c
		                               where MasterRule__c in: mapMasterIdDetailRule.KeySet()
		                               group by MasterRule__c]) {
			system.debug('## maxNumber ' + aggrRe.get('maxNumber'));
			system.debug('## aggrRe.Id ' + aggrRe.get('MasterRule__c'));

			If(aggrRe.get('maxNumber') != null) {
				mapIdNumber.put(string.valueOf(aggrRe.get('MasterRule__c')), Integer.valueOf(aggrRe.get('maxNumber')));
			}

		}
		system.debug('## mapIdNumber ' + mapIdNumber);
		for (Id listdrId : mapMasterIdDetailRule.KeySet()) {
			system.debug('## listdrId ' + listdrId);
			Integer count = 1;
			for (ICF_DetailRule__c dr : mapMasterIdDetailRule.get(listdrId)) {
				if(dr.Number__c == null || dr.Number__c < 0 ) {
					system.debug('## dr.Number__c  ' + dr.Number__c );
					if (mapIdNumber.containsKey(dr.MasterRule__c)) {
						dr.Number__c = mapIdNumber.get(dr.MasterRule__c) + count;
					} else {
						dr.Number__c = count;
					}	
					count ++;
				}
			}
		}

		system.debug('## End incrementFieldNumber method');
	}
}