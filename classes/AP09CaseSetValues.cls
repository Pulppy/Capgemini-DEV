public without sharing class AP09CaseSetValues {


 public static void setNumberOfChildCasesForFilledInParent(Map<Id, Case> parentCaseMap)
    {
        System.debug('---------- START AP44CaseSetValues - setNumberOfChildCasesForFilledInParent ----------');
        

        for (AggregateResult ar : [ SELECT count(Id) ChildCount, ParentId 
                                    FROM Case 
                                    WHERE ParentId IN: parentCaseMap.keyset() 
                                       AND isclosed = false
                                    Group By ParentId])
        {
            if(parentCaseMap.containsKey((Id)ar.get('ParentId'))){

                Case caseParent = parentCaseMap.get((Id)ar.get('ParentId'));
                caseParent.Id = (Id)ar.get('ParentId');
                caseParent.NumberOfChildCases__c = Integer.valueOf(ar.get('ChildCount'));
                caseParent.LastUpdateForNumberOfChildCase__c = System.now();
                parentCaseMap.put(caseParent.Id, caseParent);
            }
            
        }

        System.debug('## Cases to be updated: ' + parentCaseMap.values());
        update parentCaseMap.values();

        System.debug('---------- END AP44CaseSetValues - setNumberOfChildCasesForFilledInParent ----------');
    }
    
}