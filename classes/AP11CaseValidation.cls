/*
    Name Class: AP11CaseValidation
    Created By: Nga Do
    Created Date: 2017/05/22
    Last Modified Date: 2017/05/22
    Reset validation when Sub type, origin, complainant, record type is changed
*/
public without sharing class AP11CaseValidation {
	public static Boolean isInvokedUpdateValidation = false;

	public static void resetCaseValidation(Map<Id, Case> mapOld, List<Case> listNew){
		if(!isInvokedUpdateValidation){

			for(Case objCase : listNew){
				Case oldCase = mapOld.get(objCase.Id);

				String osig = oldCase.SR_Sub_Type__c + '||' + oldCase.Origin + '||' + oldCase.Complainant__c + '||' + oldCase.RecordTypeId + '||';
	        	String nsig = objCase.SR_Sub_Type__c + '||' + objCase.Origin + '||' + objCase.Complainant__c + '||' + objCase.RecordTypeId + '||';

	        	if (osig != nsig) {
		            objCase.Validation__c = false;
		            objCase.Answers__c = '';
		        }
			}

			isInvokedUpdateValidation = true;

			}else{

				isInvokedUpdateValidation = false;
			}

		
		/*for (Integer i = 0; i < trigger.new.size(); i++) {
	        Case oc = trigger.old[i];
	        Case nc = trigger.new[i];
	        String osig = oc.SR_Sub_Type__c + '||' + oc.Origin + '||' + oc.Complainant__c + '||' + oc.RecordTypeId + '||';
	        String nsig = nc.SR_Sub_Type__c + '||' + nc.Origin + '||' + nc.Complainant__c + '||' + nc.RecordTypeId + '||';
	        String oa = trigger.old[i].Answers__c;
	        String na = trigger.new[i].Answers__c;
	        if (osig != nsig) {
	            nc.Validation__c = false;
	            nc.Answers__c = '';
	        }
	    }*/

	}
}