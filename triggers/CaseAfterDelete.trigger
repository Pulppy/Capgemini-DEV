/*
    NAME: CaseAfterDelete
    Create by: Nga Do 2017/05/17
    Last Modify by: Nga Do 2017/05/17
    Modify: Coppy the logic for NumberOfChildCases__c, LastUpdateForNumberOfChildCase__c from SG org 
*/
trigger CaseAfterDelete on Case (after delete) {
	// Nga Do 2017/05/17: coppy the logic for NumberOfChildCases__c, LastUpdateForNumberOfChildCase__c

   if(PAD.canRun('AP09')){
        Map<Id, Case> parentCaseIds = new Map<Id, Case>();

        Set<Id> parentCaseId = new Set<Id>();

        for(Case objCase : trigger.old){

            if(objCase.ParentId != null ){

                Case caseParent = new Case(  Id = objCase.ParentId,
                                        NumberOfChildCases__c = 0,
                                        LastUpdateForNumberOfChildCase__c = System.now());

                parentCaseIds.put(objCase.ParentId, caseParent);
            }
        }

        if(!parentCaseIds.isEmpty())
        {
            AP09CaseSetValues.setNumberOfChildCasesForFilledInParent(parentCaseIds);
        }
    }  
}