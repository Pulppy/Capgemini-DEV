public class AP03SiblingCase {

    public static void updateSiblingCase(List<Case> triggerNew, Map<String, Case> updateCaseMap) {
        Set<String> caseIdSet = new Set<String>();
        Map<String, String> caseMap = new Map<String, String>();
    
        for (Integer i = 0; i < triggerNew.size(); i++) {
            Case cs = triggerNew[i];
            if (cs.Sibling_Case__c != null) {
                caseIdSet.add(cs.Sibling_Case__c + '');
                caseMap.put(cs.Sibling_Case__c + '', cs.Id + '');
            }
        }
    
        List<Case> caseList = [select Id, Sibling_Case__c from Case where Id in :caseIdSet];
        if (caseList != null && caseList.size() > 0) {
            for (Integer i = 0; i < caseList.size(); i++) {
                Case cs = caseList[i];
                if (updateCaseMap.containsKey(cs.Id + '')) {
                    cs = updateCaseMap.get(cs.Id + '');
                } else {
                    updateCaseMap.put(cs.Id + '', cs);
                }
                cs.Sibling_Case__c = caseMap.get(cs.Id + '');
            }
        }    
    }

}