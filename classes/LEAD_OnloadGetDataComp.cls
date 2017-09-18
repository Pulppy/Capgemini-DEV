public with sharing class LEAD_OnloadGetDataComp {
	/*
	* ClassName:	LEAD_OnloadGetDataComp
	* Summary: 		Get Event List
	* @created:		20/07/2017 Nguyen Hoang Khoi
	* @modified:	
	*/
	public LEAD_OnloadGetDataComp() {
		
	}

	/*
	 * eventList
	 * @param: EventID
	 * @return: lstEvent
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 20/07/2017 Nguyen Hoang Khoi
	 */
	@AuraEnabled
	public static List<Event> eventList(String eventID){
		System.debug('xxxxx  In List Event' );
		List<Event> lstEvent = new List<Event>();
		if(!String.isEmpty(eventID) || eventID != null){
			lstEvent = [Select id,Location,Subject,Description,StartDateTime,Owner.Name,CreatedById,Who.Name from Event where WhoID =: eventID limit 5];
			return lstEvent;
		}
		else return lstEvent;
	}
}