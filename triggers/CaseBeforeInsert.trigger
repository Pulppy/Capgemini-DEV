trigger CaseBeforeInsert on Case (before insert) {
    
    if (PAD.canRun('AP02')) {
        AP02CasesSetFlagsTargetDate.setTargetDateOfFlagDisplay(Trigger.New);            
    }

    /*if (PAD.canRun('AP04')) {
        for (Integer i=0; i < trigger.new.size(); i++) {
            if (trigger.new[i].Status == 'Closed') {
                try {
                    String parentId = trigger.new[i].Id + '';
                    AP04LatestClosedDate.calcLatestClosedDate(parentId, trigger.new[i]);
                } catch (Exception e) {
                    System.debug('Trigger.Case.AP04: ' + e.getMessage());
                }
            }
        }    
    }*/
    
}