/**************************************************************************************
Apex Class Name - ICF_HouseKeepingBatchSche

Version - 1.0

Created Date - 11 DEC 2015

Function - Schedule ICF_HouseKeepingBatch

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* AA            11/12/2015      Original Version
*************************************************************************************/

global class ICF_HouseKeepingBatchSche implements Schedulable {
    
    global static String scheduleIt() {
        return System.schedule('Batch for expiring and resend surveys', '0 0 0 * * ?', new ICF_HouseKeepingBatchSche());             
    }

    global void execute(SchedulableContext sc) {
        ICF_HouseKeepingBatch b = new ICF_HouseKeepingBatch();
        database.executebatch(b);
    }

}