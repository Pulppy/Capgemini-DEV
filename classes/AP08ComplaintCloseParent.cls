public class AP08ComplaintCloseParent {

    public static void closeParent(List<Case> triggerNew) {
        System.debug('AP08ComplaintCloseParent.closeParent(): ');
        
        Set<String> idSet = new Set<String>();
        Set<String> parentIdSet = new Set<String>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            Case cs = triggerNew[i];
            if (cs.ParentId != null) {
                idSet.add(cs.Id + '');
            }
        }
        List<Case> newCaseList = [select Id, ParentId, RecordType.DeveloperName from Case where Id in :idSet];
        for (Integer i = 0; i < newCaseList.size(); i++) {
            Case cs = newCaseList[i];
            if (cs.ParentId != null) {
                if (cs.RecordType.DeveloperName == 'GI_Formal_Complaint' || cs.RecordType.DeveloperName == 'Life_Formal_Complaint') {
                    parentIdSet.add(cs.ParentId + '');
                }
            }
        }
        List<Case> parentCaseList = [select Id, Status, RecordType.DeveloperName from Case where Id in :parentIdSet];
        List<Case> updateList = new List<Case>();
        for (Integer i = 0; i < parentCaseList.size(); i++) {
            Case cs = parentCaseList[i];
            if (cs.RecordType.DeveloperName == 'Life_Case' || cs.RecordType.DeveloperName == 'GI_Case') {
                cs.Status = 'Closed';
                updateList.add(cs);
            }
        }
        if (updateList.size() > 0) {
            Database.update(updateList, false);
        }
    }

}