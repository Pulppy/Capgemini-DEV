global class ICF_PrepareSurveyDeliveryBatchSche implements Schedulable {
/**************************************************************************************
Apex Class Name - ICF_PrepareSurveyDeliveryBatchSche

Version - 1.0

Created Date - 22 SEP 2015

Function - Schedule ICF_PrepareSurveyDeliveryBatch

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* Spoon (HDU)   22/09/2015      Original Version
*************************************************************************************/

	global static String scheduleIt() {
        return System.schedule('Batch for Lead to calculate Score', 
        						'0 0 0 * * ?', //Syntax: Minutes, Hours, Day of month, Month, Day of week, optional Year
        						new ICF_PrepareSurveyDeliveryBatchSche());
    }//end method scheduleIt()

	global void execute(SchedulableContext sc) {
		ICF_PrepareSurveyDeliveryBatch b = new ICF_PrepareSurveyDeliveryBatch();
		database.executebatch(b);
	} 
}