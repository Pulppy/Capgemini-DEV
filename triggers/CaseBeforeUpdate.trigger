trigger CaseBeforeUpdate on Case (before update) {
  
    if (PAD.canRun('AP02')) {

        AP02CasesSetFlagsTargetDate.setTargetDateOfFlagDisplay(Trigger.Old, Trigger.New);
    }
    
    if (PAD.canRun('AP04')) {
        /*for (Integer i=0; i < trigger.new.size(); i++) {
            if (trigger.new[i].Status == 'Closed' && trigger.old[i].Status != 'Closed') {
                try {
                    String parentId = trigger.new[i].Id + '';
                    AP04LatestClosedDate.calcLatestClosedDate(parentId, trigger.new[i]);
                } catch (Exception e) {
                    System.debug('Trigger.Case.AP04: ' + e.getMessage());
                }
            }
            if (trigger.new[i].Status != 'Closed' && trigger.old[i].Status == 'Closed') {
                try {
                    trigger.new[i].Actual_close_date__c = null;
                } catch (Exception e) {
                        System.debug('Trigger.Case.AP04: ' + e.getMessage());
                }
            }
        }*/
        try{

            AP04LatestClosedDate.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);

        }catch(Exception ex){
            
            System.debug('Trigger.Case.AP04: ' + ex.getMessage());
        }
    }

    if (PAD.canRun('AP05')) {
        AP05PendingWithCustomerTime.calcPendingWithCustomerTime(Trigger.Old, Trigger.New);
    }

    if (PAD.canRun('AP11')) {
        AP11CaseValidation.resetCaseValidation(Trigger.oldMap, Trigger.New);
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