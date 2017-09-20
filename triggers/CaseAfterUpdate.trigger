trigger CaseAfterUpdate on Case (after update) {

    List<Case> updateList = new List<Case>();

    /*if (PAD.canRun('AP04')) {
        Map<String, Case> updateCaseMap04 = new Map<String, Case>();
        
        for (Integer i=0; i < trigger.new.size(); i++) {
            if (trigger.new[i].IsClosed && !trigger.old[i].IsClosed) {
                    try {
                        String parentId = trigger.new[i].Id + '';
                        AP04LatestClosedDate.calcLatestClosedDate(parentId, updateCaseMap04);
                    } catch (Exception e) {
                        System.debug('Trigger.Case.AP04: ' + e.getMessage());
                    }
            }
        }
        for (String key : updateCaseMap04.keySet()) {
            updateList.add(updateCaseMap04.get(key));
        }
    }*/
    if (PAD.canRun('AP04')) {
        try{

            AP04LatestClosedDate.onAfterUpdate(Trigger.newMap);

        }catch(Exception ex){
            
            System.debug('Trigger.Case.AP04: ' + ex.getMessage());
        }
    }

    /*if (PAD.canRun('AP07')) {
        AP07ICF.updateICF(trigger.new);
    }*/

    /*Database.update(updateList, false);*/


    System.Debug('#### >>> START of CaseAfterUpdate <<< ');
    
    //AP03
    String recordTypeName;
    set<String> AP03setPoliciesId = new set<string>();
    set<String> AP03setCallerType = new set<string>();
    set<Id> AP03setCaseIds= new set<Id>();
    set<Id> AP03setCaseAccountIds = new set<Id>();
    map<string,Case> AP03mapKeyToNewCaseForFCRCust = new map<string,Case>();
    map<string,Case> AP03mapKeyToNewCaseForFCRAgent = new map<string,Case>();
    map<string,Case> AP03mapKeyToNewCaseForFCRPolicy = new map<string,Case>();
    
      for(integer i=0;i<trigger.new.size();i++){
        //AP03
        recordTypeName = AP05RecordTypeUtil.getRecordTypeName('Case', trigger.new[i].RecordTypeId);

        System.debug(PAD.canRun('AP06'));
        System.debug(recordTypeName);
        System.debug(trigger.new[i]);
        System.debug(trigger.old[i]);
        if(PAD.canRun('AP06') && (recordTypeName.contains('GI') || recordTypeName.contains('Life'))){
            if((
                    trigger.new[i].isclosed != trigger.old[i].isclosed              
                ||  trigger.new[i].Policy__c != trigger.old[i].Policy__c
                ||  trigger.new[i].Complainant__c != trigger.old[i].Complainant__c
                ) 
                && trigger.new[i].isclosed == true 
                && !trigger.new[i].internal__c
                && trigger.new[i].Policy__c != null
                && trigger.new[i].ParentId == null
            ){
                AP03setPoliciesId.add(trigger.new[i].policy__c);
                AP03setCallerType.add(trigger.new[i].Complainant__c);
                AP03setCaseIds.add(trigger.new[i].Id);
                if(trigger.new[i].AccountId != null) {
                    AP03setCaseAccountIds.add(trigger.new[i].AccountId);
                }
                AP03mapKeyToNewCaseForFCRCust.put(trigger.new[i].AccountId+';'+trigger.new[i].Complainant__c, trigger.new[i]);
                AP03mapKeyToNewCaseForFCRAgent.put(trigger.new[i].policy__c+';'+trigger.new[i].SR_Sub_Type__c+';'+trigger.new[i].Complainant__c, trigger.new[i]);
                AP03mapKeyToNewCaseForFCRPolicy.put(trigger.new[i].policy__c+';'+trigger.new[i].Complainant__c, trigger.new[i]);
            }//end of check isclosed
        }//end of AP03
         
    }//end of loop trigger
    
    System.debug(AP03mapKeyToNewCaseForFCRPolicy);
    System.debug(AP03mapKeyToNewCaseForFCRCust);
    System.debug(AP03mapKeyToNewCaseForFCRAgent);
    if(PAD.canRun('AP06')){
        //if(AP03mapKeyToNewCase.size()>0){
            //AP03CaseSetFCR.setFCR( AP03mapKeyToNewCase, AP03setPoliciesId, AP03setCallerType,AP03setCaseIds);
            if(AP03mapKeyToNewCaseForFCRCust.size() > 0 && AP03mapKeyToNewCaseForFCRAgent.size() > 0 && AP03mapKeyToNewCaseForFCRPolicy.size() > 0) {
                AP06FCR.setFCR( AP03setCaseAccountIds, AP03setCallerType,AP03setCaseIds,AP03mapKeyToNewCaseForFCRCust,AP03mapKeyToNewCaseForFCRAgent,AP03mapKeyToNewCaseForFCRPolicy);
            }
       // }//end if
    }//end if PAD AP03

    System.debug(trigger.new);
    System.Debug('#### >>> END of CaseAfterUpdate <<< ');

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
   
}