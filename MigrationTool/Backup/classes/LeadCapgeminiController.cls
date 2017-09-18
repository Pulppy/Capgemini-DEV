/*
	* ClassName:	LeadCapgeminiController
	* Summary: 		Controller for Component
	* @created:		20/07/2017 Nguyen Hoang Khoi
	* @modified:	
	*/
public with sharing class LeadCapgeminiController {

	public class Data {
		@AuraEnabled
		public String inputId { get; set; }

		@AuraEnabled
		public S2Data s2 { get; set; }

		@AuraEnabled
		public S3Data s3 { get; set; }

		@AuraEnabled
		public S4Data s4 { get; set; }

		@AuraEnabled
		public String title { get; set; }
	}

	public class S2Data {
		@AuraEnabled
		public String name { get; set; }
	}

	public class S3Data {
		@AuraEnabled
		public String name { get; set; }
	}

	public class S4Data {
		@AuraEnabled
		public String name { get; set; }
	}

	/*
	 * prepare
	 * @param: objId
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static LeadCapgeminiController.Data prepare(String objId){
		LeadCapgeminiController.Data tag = new LeadCapgeminiController.Data();
		tag.s2 = new S2Data();
		tag.s3 = new S3Data();
		return tag;
	}

	/* 
	 * goS2 (Choose Yes)
	 * @param: inputId,
	 			subject,
	 			startDate,
	 			endDate,
	 			description,
	 			location
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static String goS2(String inputId, String subject,DateTime startDate, Datetime endDate,String description, String location){
		String tag = '';
		try{
			Lead le = [select Id, CurrentGenerators__c,StartDateLead__c,EndDateLead__c,Description__c,Location__c,CurrentDate__c,Expected_Premium_Payment__c from Lead where Id = :inputId];
			if(subject != null || subject != ''){
				le.CurrentGenerators__c = subject;
			}
			if(startDate != null){
				le.StartDateLead__c = startDate;
			}
			le.EndDateLead__c = endDate;
			if(description != null || description != ''){
				le.Description__c = description;
			}
			if(location != null || location != ''){
				le.Location__c = location;
			}			
			le.CurrentDate__c = null;

			/*Convert Datetime to date*/
			Date datePayment = Date.valueOf(startDate);
			le.Expected_Premium_Payment__c = datePayment;
			update le;

			/*Start Create Event*/
			Event ev = new Event();
			ev.StartDateTime = startDate;
			ev.EndDateTime = endDate;
			ev.Subject = subject;
			ev.WhoId = inputId;
			ev.Description = description;
			ev.Location = location;
			ev.OwnerId = '00528000002iuRqAAI';
			Database.SaveResult sr = Database.insert(ev, false);
			tag = 'O:' + sr.getId();

		}catch(Exception ex){
			tag = '1:' + ex;
		}
		/*End Create Event*/
		return tag;
	}

	/* 
	 * goS3 (Choose Unreachable/Not Available)
	 * @param: inputId,
	 			subject,
	 			adatetime,
	 			description
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */

	@AuraEnabled
	public static String goS3(String inputId, String subject, DateTime adatetime, String description){
		String tag = '';
		try{
			Lead le = [select Id, CurrentGenerators__c, CurrentDate__c, Description__c,StartDateLead__c,EndDateLead__c,Location__c from Lead where Id = :inputId];
			le.CurrentGenerators__c = subject;
			le.CurrentDate__c = adatetime;
			le.Description__c = description;
			le.StartDateLead__c = null;
			le.EndDateLead__c = null;
			le.Location__c = null;
			update le;

			/*Start Create Task */
			DateTime dT = adatetime;
			Date adate = Date.newinstance(dT.year(), dT.month(), dT.day());
			Task t = new Task();
			t.OwnerId = UserInfo.getUserId();
			t.Subject = subject;
			t.Status = 'Open';
			t.Priority = 'Normal';
			t.WhoId = inputId;
			t.ActivityDate = adate;
			t.ReminderDateTime = adatetime.addHours(-1);
			t.IsReminderSet = true;
			t.Description = description;
			Database.SaveResult sr = Database.insert(t, false);
			tag = 'O:' + sr.getId();
			/*End Create Task*/

		}catch(Exception ex){
			tag = '1:' + ex;
		}
		
		return tag;
	}

	/* 
	 * goS4 (Choose Not Interested)
	 * @param: inputId,
	 			description
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static String goS4(String inputId, String description){
		String tag = '';
		try{
			Lead le = [select Id, CurrentGenerators__c, CurrentDate__c, Description__c,StartDateLead__c,EndDateLead__c,Location__c from Lead where Id = :inputId];
			le.CurrentGenerators__c = null;
			le.CurrentDate__c = null;
			le.Description__c = description;
			le.StartDateLead__c = null;
			le.EndDateLead__c = null;
			le.Location__c = null;
			le.Status = 'Lost';
			update le;
			tag = 'SUCCESS';
		}catch(Exception ex){
			tag = 'FAIL' + ex;
		}
		return tag;
	}

}