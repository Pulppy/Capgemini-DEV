public with sharing class EventMeetingOutcomeController {

	public class Data {
		@AuraEnabled
		public String inputId { get; set; }

		@AuraEnabled
		public Boolean isAgent { get; set; }

		@AuraEnabled
		public Boolean isTask { get; set; } //check Event or Task Detail Page.

		@AuraEnabled
		public S2Data s2 { get; set; }

		@AuraEnabled
		public S3Data s3 { get; set; }

		@AuraEnabled
		public S4Data s4 { get; set; }

		@AuraEnabled
		public String title { get; set; }

		@AuraEnabled
		public String objId { get; set; }
			
		@AuraEnabled
		public Integer timeDiff { get; set; }
	}

	public class S2Data {
		@AuraEnabled
		public String name { get; set; }

		@AuraEnabled
		public DateTime expectedCloseDate { get; set; }

		@AuraEnabled
		public Decimal expectedPVI { get; set; }

		@AuraEnabled
		public String description { get; set; }

		@AuraEnabled
		public String subject { get; set; }

		@AuraEnabled
		public DateTime adate { get; set; }

		@AuraEnabled
		public DateTime startTime { get; set; }

		@AuraEnabled
		public DateTime endTime { get; set; }

		@AuraEnabled
		public String location { get; set; }

	}

	public class S3Data {
		@AuraEnabled
		public String name { get; set; }

		@AuraEnabled
		public String subject { get; set; }

		@AuraEnabled
		public DateTime startTime { get; set; }

		@AuraEnabled
		public DateTime endTime { get; set; }

		@AuraEnabled
		public String description { get; set; }  

		@AuraEnabled
		public Decimal proposedPVI { get; set; }

	}

	public class S4Data {
		@AuraEnabled
		public String name { get; set; }

		@AuraEnabled
		public String description { get; set; }

		@AuraEnabled
		public String badLeadReason { get; set; }

	}

	/* 
	 * prepare
	 * @param: objId
	 * @return: tag
	 * @created: 20/07/2017 Nguyen Hoang Khoi
	 * @modified: 
	 */
	@AuraEnabled
	public static EventMeetingOutcomeController.Data prepare(String objId) {
		EventMeetingOutcomeController.Data tag = new EventMeetingOutcomeController.Data();
		tag.objId = objId;
		tag.isAgent = true;
		tag.isTask = String.ValueOf(objId).startsWithIgnoreCase( Schema.SObjectType.Task.getKeyPrefix() );
		tag.s2 = new S2Data();
		tag.s2.startTime = Datetime.now();
		tag.s2.endTime = Datetime.now().addHours(1);
		tag.s3 = new S3Data();
		tag.s3.startTime = Datetime.now();
		tag.s3.endTime = Datetime.now().addHours(1);

		tag.s4 = new S4Data();

		return tag;
	}

	/* Start Sales Close Function */
	@AuraEnabled
	public static String goS2(String objId, String inputId, Datetime expectedCloseDate, Decimal expectedPVI, String description, 
				 String subject, DateTime startTime, DateTime endTime, String location, 
				 Boolean isAgent, Boolean isTask, Date expectDate){
		String tag = '';
		
		try {
			if(isTask){
				Lead vlead = [select Id,Status from Lead where Id = :[select WhoId from Task where Id = :objId].WhoId limit 1];
				/* Checking Time Duration task*/
				if(startTime > endTime){
					return ' End Date cannot be earlier than Start Date';
				}

				if (subject == null || subject == ''){
					subject = 'New Event Create by MeetingOutcome';
				}

				/* Create Even */
				Event ev = new Event();
				ev.StartDateTime = startTime;
				ev.EndDateTime = endTime;
				ev.Subject = subject;
				ev.WhoId = vlead.Id;
				ev.Description = description;
				ev.Location = location;
				Database.SaveResult sr = Database.insert(ev, false);
				if (sr.isSuccess()){
					tag = 'O:' + sr.getId();
				}else{
					tag = '' + sr.getErrors();
				}
			}else{
				Lead vleadUpdate = [select Id, Status,Description__c,Expected_Premium_Payment_Date__c,Expected_APE__c from Lead where Id = :[select WhoId from Event where Id = :objId].WhoId];
				vleadUpdate.Description__c = description;
				vleadUpdate.Status = 'Qualified';
				vleadUpdate.Expected_Premium_Payment_Date__c = startTime ;
				vleadUpdate.Expected_APE__c = String.valueOf(expectedPVI);
				update vleadUpdate;
			}
		}
		catch(Exception ex){
			tag = 'Error ' + ex; 
		}
		return tag;
	}
	/* End Sales Close Function */

	/* Start To Follow Up */
	@AuraEnabled
	public static String goS3(String objId, String inputId, String subject, DateTime startTime, DateTime endTime, String description, Decimal proposedPVI, Boolean isAgent, Boolean isTask){

		String tag = '';
		try {
			if (subject == null || subject == ''){
				subject = 'Follow up';
			}
			if(isTask){
				/* Create new Task (for Lead) */
				Lead vlead = [select Id,Status from Lead where Id = :[select WhoId from Task where Id = :objId].WhoId limit 1];
				Task t = new Task();
				t.OwnerId = UserInfo.getUserId();
				t.Subject = subject;
				t.Status = 'Open';
				t.Priority = 'Normal';
				t.WhoId = vlead.Id;
				t.ActivityDate = startTime.date();
				t.ReminderDateTime = startTime.addHours(-1);
				t.IsReminderSet = true;
				t.Description = description;
				// insert t;
				Database.SaveResult sr = Database.insert(t, false);
				if (sr.isSuccess()){
					tag = 'O:' + sr.getId();
				}else{
					tag = '' + sr.getErrors();
				}
				/* update current Task ( Status --> Completed) */
				Task updateTask = [Select id, Status from Task where id = :objId];
				updateTask.Status = 'Completed';
				update updateTask;
			}else{
				/* Create new Event (for Lead)*/
				Lead vlead = [select Id, Status from Lead where Id = :[select WhoId from Event where Id = :objId].WhoId limit 1];
				Event evt = new Event();
				evt.OwnerId = UserInfo.getUserId();
				evt.Subject = subject;
				evt.StartDateTime = startTime;
				evt.EndDateTime = startTime.addHours(3);

				if(isAgent){
					evt.WhoId = vlead.Id;
				}
				else{
					evt.WhatId = inputId;
				}
				evt.ReminderDateTime = startTime.addHours(-1);
				evt.IsReminderSet = true;
				evt.Description = description;
				Database.SaveResult sr = Database.insert(evt, false);
				if (sr.isSuccess()){
					tag = 'O:' + sr.getId();
				}else{
					tag = '' + sr.getErrors();
				}
			}
		}catch (Exception ex) {
			tag = '' + ex.getMessage();
		}
		return tag;
	}
	/* End To Follow Up */

	/* Start Sales Lost*/
	@AuraEnabled
	public static String goS4(String objId, String inputId, String badLeadReason, String description, Boolean isAgent, Boolean isTask){
		String tag = '';
		try {
			// Get Lead, update Lead
			if(isTask){
				Lead vlead = [select Id,Status from Lead where Id = :[select WhoId from Task where Id = :objId].WhoId limit 1];
				vlead.Status = 'Bad Lead';
				vlead.Description = description;
				update vlead;
				/*Update Task Status*/
				Task taskUpdate = [select id, Status from Task where Id = :objId];
				taskUpdate.Status = 'Completed';
				update taskUpdate;
				if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
			}
			if(!isTask){
				Lead vlead = [select Id, Status,Description,Bad_Lead_Reason__c from Lead where Id = :[select WhoId from Event where Id = :objId].WhoId limit 1];
				vlead.Status = 'Bad Lead';
				vlead.Description = description;
				vlead.Bad_Lead_Reason__c = badLeadReason;

				update vlead;
				if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
			}

		} catch (Exception e) {
			tag = '' + e.getMessage();
		}
		return tag;
		}
	/* End Sales Lost*/

}