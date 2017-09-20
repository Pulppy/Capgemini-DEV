public class AP05PendingWithCustomerTime {

    public static void calcPendingWithCustomerTime(List<Case> triggerOld, List<Case> triggerNew) {

        Id businessHoursId = [select Id from BusinessHours where name = 'MY Life SCRM Business Hour' limit 1][0].id;
    
        for (Integer i = 0; i < trigger.new.size(); i++) {
            try {
                if(triggerNew[i].Status  == Label.PT_Case_Status_13 && triggerOld[i].Status != Label.PT_Case_Status_13){
                    triggerNew[i].Pending_With_Customer_Start__c= DateTime.now();
                }
                if (triggerOld[i].Status == Label.PT_Case_Status_13 && triggerNew[i].Status != Label.PT_Case_Status_13) {
                   Integer pendingtime = Math.abs(BusinessHours.diff(businessHoursId,triggerOld[i].Pending_With_Customer_Start__c,DateTime.now())/1000/60).intvalue();
                    triggerNew[i].TAT_Target_Date_Red__c     = triggerOld[i].TAT_Target_Date_Red__c.addMinutes(pendingTime);
                    triggerNew[i].TAT_Target_Date_Yellow__c  =  triggerOld[i].TAT_Target_Date_Yellow__c.addMinutes(pendingTime);
                    triggerNew[i].TAT_Due_Date__c =  triggerOld[i].TAT_Due_Date__c.addMinutes(pendingTime);
               
                }
            } catch (Exception e) {
                System.debug('AP05PendingWithCustomerTime.calcPendingWithCustomerTime: ' + e.getMessage());
            }
        }    
    }

}