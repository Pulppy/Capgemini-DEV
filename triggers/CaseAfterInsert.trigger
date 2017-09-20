/*
    NAME: CaseAfterInsert
    Create by: 
    Last Modify by: Nga Do 2017/05/17
    Modify: Coppy the logic for NumberOfChildCases__c, LastUpdateForNumberOfChildCase__c from SG org 
*/
trigger CaseAfterInsert on Case (after insert) {

    List<Case> updateList = new List<Case>();


    if (PAD.canRun('AP03')) {
        Map<String, Case> updateCaseMap03 = new Map<String, Case>();
        AP03SiblingCase.updateSiblingCase(trigger.new, updateCaseMap03);
        for (String key : updateCaseMap03.keySet()) {
            updateList.add(updateCaseMap03.get(key));
        }
    }

    if (PAD.canRun('AP04')) {
        
        try{

            AP04LatestClosedDate.onAfterUpdate(Trigger.newMap);

        }catch(Exception ex){
            
            System.debug('Trigger.Case.AP04: ' + ex.getMessage());
        }
    }
    /*
    if (PAD.canRun('AP06')) {
        for (Integer i = 0; i < trigger.new.size(); i++) {
            AP06FCR.setFCRInsert(trigger.new[i], updateList);
        }    
    }
    */
    
   /* if (PAD.canRun('AP07')) {
        AP07ICF.updateICF(trigger.new);
    }*/

    if (PAD.canRun('AP08')) {
        AP08ComplaintCloseParent.closeParent(trigger.new);
    }
    
    Database.update(updateList, false);



    set<String> AP03setPoliciesId = new set<string>();
    set<String> AP03setCallerType = new set<string>();
    set<Id> AP03setCaseIds= new set<Id>();
    set<Id> AP03setCaseAccountIds = new set<Id>();
    map<string,Case> AP03mapKeyToNewCaseForFCRCust = new map<string,Case>();
    map<string,Case> AP03mapKeyToNewCaseForFCRAgent = new map<string,Case>();
    map<string,Case> AP03mapKeyToNewCaseForFCRPolicy = new map<string,Case>();
    List<Case> caseList = new List<Case>();
    Set<Id> parentIds = new Set<Id>();
    String recordTypeName;
    
    for(integer i=0;i<trigger.new.size();i++){
        recordTypeName = AP05RecordTypeUtil.getRecordTypeName('Case', trigger.new[i].RecordTypeId);
        //AP03
        if(PAD.canRun('AP06') && (recordTypeName.contains('GI') || recordTypeName.contains('Life'))) {
            
            if(trigger.new[i].isclosed == true
                && !trigger.new[i].internal__c
                && trigger.new[i].Policy__c != null
                && trigger.new[i].ParentId == null)
                
            {
                AP03setPoliciesId.add(trigger.new[i].policy__c);
                AP03setCallerType.add(trigger.new[i].Complainant__c);
                AP03setCaseIds.add(trigger.new[i].id);
                if(trigger.new[i].AccountId != null) {
                    AP03setCaseAccountIds.add(trigger.new[i].AccountId);
                }    
                AP03mapKeyToNewCaseForFCRCust.put(trigger.new[i].AccountId+';'+trigger.new[i].Complainant__c, trigger.new[i]);
                AP03mapKeyToNewCaseForFCRAgent.put(trigger.new[i].policy__c+';'+trigger.new[i].SR_Sub_Type__c+';'+trigger.new[i].Complainant__c, trigger.new[i]);
                AP03mapKeyToNewCaseForFCRPolicy.put(trigger.new[i].policy__c+';'+trigger.new[i].Complainant__c, trigger.new[i]);
            }//end of check isclosed
        }//end of AP03

        caseList.add(trigger.new[i]);

        if(trigger.new[i].Internal__c == false && trigger.new[i].ParentId != null && trigger.new[i].Sibling_Case__c == null &&
           ( recordTypeName.contains('GI') || recordTypeName.contains('Life'))) {
            
            parentIds.add(trigger.new[i].ParentId);
        }
         
    }//end of loop trigger
    
    if(PAD.canRun('AP06')){
           if(AP03mapKeyToNewCaseForFCRCust.size() > 0 && AP03mapKeyToNewCaseForFCRAgent.size() > 0 && AP03mapKeyToNewCaseForFCRPolicy.size() > 0) {
               AP06FCR.setFCR(AP03setCaseAccountIds, AP03setCallerType,AP03setCaseIds,AP03mapKeyToNewCaseForFCRCust,AP03mapKeyToNewCaseForFCRAgent,AP03mapKeyToNewCaseForFCRPolicy);
           }    
    }//end if PAD AP03
    
   // Nga Do 2017/05/17: coppy the logic for NumberOfChildCases__c, LastUpdateForNumberOfChildCase__c

   if(PAD.canRun('AP09')){
            Map<Id, Case> parentCaseIds = new Map<Id, Case>();

            for(Case objCase : trigger.new){

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
    // Nga Do 2017/05/22 add function Link Social Post & Case 

    if(PAD.canRun('AP10')){

        AP10LinkSocialPostToCase.updateParentSocialPost(trigger.new);

    }
    
}