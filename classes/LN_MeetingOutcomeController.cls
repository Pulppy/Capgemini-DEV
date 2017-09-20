public with sharing class LN_MeetingOutcomeController{

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
		/////////////add ML-170: Meeting Outcome in Call Task (Banca) 15/05/2017 ////////

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
		////////////////////Field Labels 26-05-2017////////////////////

		@AuraEnabled
        public String subjectLabel { get; set; }

		@AuraEnabled
        public String subjectHelpTextLabel { get; set; }

		@AuraEnabled
        public String adateLabel { get; set; }

		@AuraEnabled
        public String startTimeLabel { get; set; }

		@AuraEnabled
        public String endTimeLabel { get; set; }

		@AuraEnabled
        public String descriptionLabel { get; set; }

		@AuraEnabled
        public String descriptionHelpTextLabel { get; set; }

		@AuraEnabled
        public String locationLabel { get; set; }

		@AuraEnabled
        public String locationHelpTextLabel { get; set; }

		@AuraEnabled
		public String expectedCloseDateLabel { get; set; }

		@AuraEnabled
        public String expectedPVILabel { get; set; }
		
		@AuraEnabled
        public String expectedPVIHelpTextLabel { get; set; }
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

		////////////////////Field Labels 26-05-2017////////////////////

		@AuraEnabled
        public String subjectLabel { get; set; }

		@AuraEnabled
        public String startTimeLabel { get; set; }

		@AuraEnabled
        public String endTimeLabel { get; set; }
	
		@AuraEnabled
        public String descriptionLabel { get; set; }
	
		@AuraEnabled
        public String descriptionHelpTextLabel { get; set; }

		//////////////////////Add 29/6/2017 - ML187 Proposed PVI field and value for agency///////////////////////////
		@AuraEnabled
        public String proposedPVILabel { get; set; }

		@AuraEnabled
        public String proposedPVIHelpTextLabel { get; set; }
    }

    public class S4Data {

		@AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String description { get; set; }

		@AuraEnabled
        public String badLeadReason { get; set; }

		////////////////////Field Labels 26-05-2017////////////////////

		@AuraEnabled
        public String descriptionLabel { get; set; }
	
		@AuraEnabled
        public String descriptionHelpTextLabel { get; set; }

		@AuraEnabled
        public String badLeadReasonLabel { get; set; }
	
		@AuraEnabled
        public String badLeadReasonHelpTextLabel { get; set; }
    }
    
    @AuraEnabled
    public static LN_MeetingOutcomeController.Data prepare(String objId) {
				
        LN_MeetingOutcomeController.Data tag = new LN_MeetingOutcomeController.Data();
		
        tag.timeDiff = getTimeDiff();
		tag.objId = objId;	
      	tag.isAgent = checkAgent();
		tag.isTask = String.ValueOf(objId).startsWithIgnoreCase( Schema.SObjectType.Task.getKeyPrefix() ) ;
		tag.title = Label.LN_MeetingOutcome_Title;			//'Meeting Outcome:';

		tag.s2 = new S2Data();
		tag.s2.name = Label.LN_MeetingOutcome_Option1;		//'Sales Won';
		//tag.s2.expectedCloseDate = Datetime.now();			
		//tag.s2.expectedPVI = 0;
		/////////////
		tag.s2.subject = Label.LN_MeetingOutcome_Option1_Subject; //'1st Appointment';
		tag.s2.startTime = Datetime.now();					
        tag.s2.endTime = Datetime.now().addHours(1);		
		//tag.s2.adate = Datetime.now();
        
        tag.s3 = new S3Data();
		tag.s3.name = Label.LN_MeetingOutcome_Option2;		//'To Follow Up';
		//tag.s3.subject = 'Follow up';
		tag.s3.startTime = Datetime.now();	
		tag.s3.endTime = Datetime.now().addHours(1);				

        tag.s4 = new S4Data();
		tag.s4.name = Label.LN_MeetingOutcome_Option3;		//'Sales Lost';

		if (tag.isTask)
		{	//Task
			tag.title = Label.LN_MeetingOutcome_Title_for_Task;		//'Call Outcome:';
			tag.s2.name = Label.LN_MeetingOutcome_Option1forTask;	//'Interested';
			tag.s3.name = Label.LN_MeetingOutcome_Option2forTask;	//'Follow up Call needed';
			tag.s4.name = Label.LN_MeetingOutcome_Option3forTask;	//'Not Interested';
			tag.s3.subject = Label.LN_MeetingOutcome_Option2forTask_Subject;//'Follow up Call';

			tag.inputId = [select Id from Lead where Id = :[select WhoId from Task where Id = :objId].WhoId].Id;//Get LeadId
			/*
			Lead vlead = [select Id, Expected_Premium_Payment__c, Expected_APE__c, Description from Lead where Id = :[select WhoId from Task where Id = :objId].WhoId];
			tag.inputId = vlead.Id;
			tag.s2.expectedCloseDate = vlead.Expected_Premium_Payment__c;
			tag.s2.expectedPVI = vlead.Expected_APE__c;
			tag.s4.description = vlead.Description;
			*/
		}else 
		{	//Event
			tag.s2.name = Label.LN_MeetingOutcome_Option1forEvent;//'Sales Closed';
			tag.s3.subject = Label.LN_MeetingOutcome_Option2forEvent_Subject;//'Follow up Event';
			if(tag.isAgent) // Agency User Process on Lead.
			{	//tag.inputId = [select Id from Lead where Id = :[select WhoId from Event where Id = :objId].WhoId].Id;//Get LeadId
				Lead vlead = [select Id, Expected_Premium_Payment__c, Expected_APE__c, Description, Proposed_PVI__c from Lead where Id = :[select WhoId from Event where Id = :objId].WhoId];
				tag.inputId = vlead.Id;
				tag.s2.expectedCloseDate = vlead.Expected_Premium_Payment__c;
				tag.s2.expectedPVI = vlead.Expected_APE__c;
				tag.s4.description = vlead.Description;

				tag.s3.proposedPVI = vlead.Proposed_PVI__c;
			}
			else // Banca User Process on Opportunity
			{
				//Opportunity opp =  [select Id, CloseDate, Amount from Opportunity where Id = :objId];
				//tag.inputId = [select Id from Opportunity where Id = :[select WhatId from Event where Id = :objId].WhatId].Id;//Get OppId
				Opportunity opp =  [select Id, CloseDate, Amount, Description from Opportunity where Id = :[select WhatId from Event where Id = :objId].WhatId];
				tag.inputId = opp.Id;
				tag.s2.expectedCloseDate = opp.CloseDate;
				tag.s2.expectedPVI = opp.Amount;
				tag.s4.description = opp.Description;
			}
		}
		//system.debug('## log tag:'+ tag);
		setLabel(tag, tag.isAgent, tag.isTask);
        return tag;
    }

    @AuraEnabled
	public static String goS2(String objId, String inputId, Datetime expectedCloseDate, Decimal expectedPVI, String description, 
							   String subject, DateTime startTime, DateTime endTime, String location, 
							   Boolean isAgent, Boolean isTask)	   	////Sales Won
	{
		String tag = '';
        try {
			if(isTask)
			{
				////////////////////Validation StartDateTime & EndDateTime// 16/6/2017 ML-180/////////////////////
				if(startTime > endTime) return ' End Date cannot be earlier than Start Date';

				///////////////////////////////////////////////////////////////////////////////////////////////////
				if (subject == null || subject == '')   subject = Label.LN_MeetingOutcome_Option1_Subject;
				
				Event ev = new Event();
  				ev.StartDateTime = startTime;//newStartTime;
  				ev.EndDateTime = endTime;//newEndTime;
  				ev.Subject = subject;
  				ev.WhoId = inputId;
				ev.Description = description;
				ev.Location = location;
				//insert ev;
				Database.SaveResult sr = Database.insert(ev, false);

				if (sr.isSuccess())	tag = 'O:' + sr.getId();
				else tag = '' + sr.getErrors();
			}

			if(isAgent)	//Agency User Process
			{	
				if(!isTask) // Event Case
				{
					///////////////update Lead - 19-5-2017 - ML167//////////////
					Lead le = [select Id, Expected_Premium_Payment__c, Expected_APE__c from Lead where Id = :inputId];

					//le.Expected_Premium_Payment__c = Date.newinstance(expectedCloseDate.year(), expectedCloseDate.month(), expectedCloseDate.day());//expectedCloseDate;
					le.Expected_Premium_Payment__c = expectedCloseDate.Date();
					le.Expected_APE__c = expectedPVI;
					update le;

					/////////////////////////End update///////////////////////////////
					tag = getConvertLeadResult(inputId, true);
				}else{
					//if(String.ValueOf(inputId).startsWithIgnoreCase( Schema.SObjectType.Lead.getKeyPrefix() )) // add 16/6/2017 - ML182
					{
						Lead le = [select Id, Status from Lead where Id = :inputId];
    					le.Status = 'Approach';
						update le;
					}
				}
			}
			else // Banca User Process
			{
				if(isTask)// Get Lead, Convert Lead
				{	
					tag = getConvertLeadResult(inputId, false);
				}else// Event, Get Opp, update Opp
				{
 					Opportunity opp =  [select Id, CloseDate, Amount, Description, StageName, RecordType.Name 
										from Opportunity 
										where Id = :inputId];
						
					if(opp.RecordType.Name.contains('Agency'))	opp.StageName = 'Closed Won';
					else 										opp.StageName = 'Application';//--> change from 'Submission' to 'Application' 15/05/2017
	
					opp.Amount = expectedPVI;
					//opp.CloseDate = Date.newinstance(expectedCloseDate.year(), expectedCloseDate.month(), expectedCloseDate.day());    
					opp.CloseDate = expectedCloseDate.Date();
					opp.Description = description; 
         			update opp;
					
					tag = 'O:' + inputId;					
				}
			}

			updateTaskEvent(objId, isTask,'Won');			// add 24/5/2017
        } catch (Exception e) {tag = '' + e.getMessage();}

        return tag;
    }
    
    @AuraEnabled
    public static String goS3(String objId, String inputId, String subject, DateTime startTime, DateTime endTime, String description, Decimal proposedPVI, Boolean isAgent, Boolean isTask) //// To Follow Up
	{
        String tag = '';
        try {
            if (subject == null || subject == '') subject = Label.LN_MeetingOutcome_Option2;//'Follow up';

			if(isTask)
			{
				/////////////////Create Task//////////////////////
				Task t = new Task();
				t.OwnerId = UserInfo.getUserId();
				t.Subject = subject;
				t.Status = 'Open';
				t.Priority = 'Normal';
				t.WhoId = inputId;
				//t.ActivityDate = adate;
				t.ActivityDate = startTime.date();
				t.ReminderDateTime = startTime.addHours(-1);
				t.IsReminderSet = true;
				t.Description = description;
    			insert t;      
			}
			else	
			{
     			///////////////////Create Event//////////////////	  
				////////////////////Validation StartDateTime & EndDateTime// 16/6/2017 ML-180/////////////////////
				if(startTime > endTime) return ' End Date cannot be earlier than Start Date';

				///////////////////////////////////////////////////////////////////////////////////////////////////        
				Event evt = new Event();
				evt.OwnerId = UserInfo.getUserId();
				evt.Subject = subject;
				evt.StartDateTime = startTime;
  				//evt.EndDateTime = adatetime.addHours(3);
				evt.EndDateTime = endTime;

				if(isAgent)			evt.WhoId = inputId;
				else				evt.WhatId = inputId;
          
				evt.ReminderDateTime = startTime.addHours(-1);
				evt.IsReminderSet = true;
				evt.Description = description;
 				insert evt;  
			}
			////////////////////////////////////////////////
			if(String.isNotBlank(inputId))	
				tag = 'O:' + inputId;   
           
		    updateTaskEvent(objId, isTask,'Follow up');			// add 24/5/2017

			if(String.ValueOf(inputId).startsWithIgnoreCase( Schema.SObjectType.Lead.getKeyPrefix() )) // add 16/6/2017 - ML182
			{
				Lead le = [select Id, Status, Proposed_PVI__c from Lead where Id = :inputId];
    			le.Status = 'Approach';
				le.Proposed_PVI__c = proposedPVI; 
				update le;
			}
				
        } catch (Exception e) {
            tag = '' + e.getMessage();
        }
        return tag;
    }

    @AuraEnabled
	public static String goS4(String objId, String inputId, String badLeadReason, String description, Boolean isAgent, Boolean isTask) //Sales Lost
	{
        String tag = '';
        try {
			if(isAgent)
			{
				Lead le = [select Id, Status, Description, Bad_Lead_Reason__c from Lead where Id = :inputId];
				le.Status = 'Bad Lead';
				le.Description = description;
				le.Bad_Lead_Reason__c = badLeadReason;
				//try {
					update le;
				//} catch (DmlException e) {}
				if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
			}
			else
			{
				if(isTask)// Get Lead, update Lead
				{
					Lead le = [select Id, Status from Lead where Id = :inputId];
					le.Status = 'Bad Lead';
					le.Description = description;
					update le;
		
					if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
				}
				else
				{
					Opportunity opp =  [select Id, StageName, Description from Opportunity where Id = :inputId];
					//opp.StageName = 'Not taken Up';
					opp.StageName = 'Sales Lost';
					opp.Description = description;
					//try {
						update opp;
					//} catch (DmlException e) {}
					if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
				}
			}

			 updateTaskEvent(objId, isTask,'Lost');			// add 24/5/2017
        } catch (Exception e) {
            tag = '' + e.getMessage();
        }
        return tag;
    }

	public static String getConvertLeadResult(String leadId, Boolean doNotCreateOpp)
	{
		String tag = '';
		try{
			//String ExtCust = [select Customer_ID__c from Lead where Id = :leadId].Customer_ID__c;
			String ExtCust;

			Lead le = [select Id, ASM_Notice_Date_Time__c, RSM_Notice_Date_Time__c, Customer_ID__c,Last_Activity_Date__c from Lead where Id = :leadId];
			le.ASM_Notice_Date_Time__c = null;
			le.RSM_Notice_Date_Time__c = null;
			le.Last_Activity_Date__c = null;
			ExtCust = le.Customer_ID__c;
			update le;
			/////////////////////Convert function: should turn off "Lead Convert after Qualified" Process Builder ///////////////////
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(leadId);
			lc.setDoNotCreateOpportunity(doNotCreateOpp);

			Id AccId = getExistingAccountId(ExtCust);
			if(AccId!=null)	lc.setAccountId(AccId);

			LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);
			lc.setOwnerId(UserInfo.getUserId());
            
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if (lcr.isSuccess())
			{
				if(!doNotCreateOpp) // create and update Opp
				{		//select Id, CloseDate, Amount, Description, StageName, RecordType.Name from Opportunity
					Opportunity opp =  [select Id, StageName from Opportunity where Id = :lcr.getOpportunityId()];
					opp.StageName = 'Appointment';
	   				update opp;
					tag = 'O:' + lcr.getOpportunityId();
				}else 
					//tag = 'O:' + inputId;
					tag = 'O:' + lcr.getAccountId();
				}
			else
				tag = '' + lcr.getErrors();
		}catch (Exception e) {tag = '' + e.getMessage();}

		return tag;
    }

	public static Id getExistingAccountId(String inputId){
		Id accId = null;
        try{
			if(String.isBlank(inputId)) return null;
			else accId = [Select Id from Account where Customer_ID__c =: inputId].Id;
        }catch(Exception ex){return null;}

        return accId;
    }


	@AuraEnabled
	public static DateTime goTimeChange(DateTime inputTime) 
	{
    	 return inputTime.addHours(1);
    }

	public static Boolean checkAgent(){
        Boolean agent=false;
        String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
        
        for(SF1CustomProfileSetting__c cs : SF1CustomProfileSetting__c.getall().values()){
            if (cs.Name==userProfileName & cs.Active__c==true) return true; 
        }
        
        return agent;
    }

	public static void updateTaskEvent(String inputId, Boolean isTask, String status)
	{
		if(isTask){
			Task ta = [select Id, Status from Task where Id = :inputId];
			ta.Status = 'Completed';
			update ta;
		}else{
			Event ev = [select Id, Meeting_Outcome__c from Event where Id = :inputId];
			ev.Meeting_Outcome__c = status;
			update ev;
	    }
    }

	public static String getLineBreakString(String inputStr)
	{
		String replacedMessage;

		String regex = '(\\r?\\n|\\r)';
		Pattern regexPattern = Pattern.compile(regex);
		Matcher regexMatcher = regexPattern.matcher(inputStr);
	
		if(regexMatcher.find()) {
		   replacedMessage = inputStr.replaceAll(regex, '<br>');
        }else{
            replacedMessage = inputStr;
        }
		/*if(replacedMessage.endsWith('<tspan>')){
			replacedMessage = replacedMessage.substring(0,replacedMessage.length()-7);
		}
		replacedMessage = '<tspan>' + replacedMessage + '</tspan>';*/

		return replacedMessage;
    }

    public static integer getTimeDiff(){
        integer agent=24;
        String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
        
        for(SF1CustomProfileSetting__c cs : SF1CustomProfileSetting__c.getall().values()){
            if (cs.Name==userProfileName & cs.Active__c==true) return (cs.Time_Difference__c != null && cs.Time_Difference__c != 0 ? Integer.ValueOf(cs.Time_Difference__c) : 24); 
        }
        
        return agent;
    }
    
	public static void setLabel(LN_MeetingOutcomeController.Data tag, Boolean isAgent, Boolean isTask)
	{
		String typeEvent= 'Event';  //Object Name
		Map<String, Schema.SObjectType> schemaMapEvent = Schema.getGlobalDescribe();
		Schema.SObjectType eventSchema = schemaMapEvent.get(typeEvent);
		Map<String, Schema.SObjectField> fieldMapEvent = eventSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldMapEvent.keySet()) {  
			//getInlineHelpText()
			//getPicklistValues()
			////////////////////////////////////
			if(fieldName =='Subject')  {
				tag.s2.subjectLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s2.subjectHelpTextLabel = fieldMapEvent.get(fieldName).getDescribe().getInlineHelpText();
				tag.s3.subjectLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			}
			if(fieldName =='StartDateTime') { 
				tag.s2.startTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s3.startTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			}
			if(fieldName =='EndDateTime')  {
				tag.s2.endTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s3.endTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			}
			if(fieldName =='Description')  {
				tag.s2.descriptionLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s2.descriptionHelpTextLabel = fieldMapEvent.get(fieldName).getDescribe().getInlineHelpText();
				tag.s3.descriptionLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			}
			if(fieldName =='Location')  {
				tag.s2.locationLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s2.locationHelpTextLabel = fieldMapEvent.get(fieldName).getDescribe().getInlineHelpText();
			}
		}

		String typeTask= 'Task';  //Object Name
		Map<String, Schema.SObjectType> schemaMapTask = Schema.getGlobalDescribe();
		Schema.SObjectType taskSchema = schemaMapTask.get(typeTask);
		Map<String, Schema.SObjectField> fieldMapTask = taskSchema.getDescribe().fields.getMap();
		if(isTask){
			tag.s3.startTimeLabel = 'Date/Time';
			/*
			for (String fieldName: fieldMapTask.keySet()) {  
				//if(fieldName =='Subject')
				//	tag.s3.subjectLabel = fieldMapTask.get(fieldName).getDescribe().getLabel();
			
				if(fieldName =='ActivityDate')  tag.s3.startTimeLabel = fieldMapTask.get(fieldName).getDescribe().getLabel();
			
			}
			*/
		}
		if(isAgent){
			String typeLead= 'Lead';  //Object Name
			Map<String, Schema.SObjectType> schemaMapLead = Schema.getGlobalDescribe();
			Schema.SObjectType leadSchema = schemaMapLead.get(typeLead);
			Map<String, Schema.SObjectField> fieldMapLead = leadSchema.getDescribe().fields.getMap();
			for (String fieldName: fieldMapLead.keySet()) {  
				//if(fieldName =='Subject')  tag.s3.subjectLabel = fieldMap.get(fieldName).getDescribe().getLabel();
				if(fieldName =='Description')	{  
					tag.s2.descriptionLabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
					tag.s2.descriptionHelpTextLabel = fieldMapLead.get(fieldName).getDescribe().getInlineHelpText();
					tag.s4.descriptionLabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
				}
				if(fieldName =='Expected_APE__c')	{  
					tag.s2.expectedPVILabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
					//tag.s2.expectedPVIHelpTextLabel = fieldMapLead.get(fieldName).getDescribe().getInlineHelpText();
					tag.s2.expectedPVIHelpTextLabel = getLineBreakString(fieldMapLead.get(fieldName).getDescribe().getInlineHelpText());
				}
				if(fieldName =='Expected_Premium_Payment__c') tag.s2.expectedCloseDateLabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
				if(fieldName =='Bad_Lead_Reason__c') tag.s4.badLeadReasonLabel = fieldMapLead.get(fieldName).getDescribe().getLabel();

				if(fieldName =='Proposed_PVI__c')	{  
				tag.s3.proposedPVILabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
				tag.s3.proposedPVIHelpTextLabel = fieldMapLead.get(fieldName).getDescribe().getInlineHelpText();
				}
			}
		}else{
			String typeOpp= 'Opportunity';  //Object Name
			Map<String, Schema.SObjectType> schemaMapOpp = Schema.getGlobalDescribe();
			Schema.SObjectType oppSchema = schemaMapOpp.get(typeOpp);
			Map<String, Schema.SObjectField> fieldMapOpp = oppSchema.getDescribe().fields.getMap();
			for (String fieldName: fieldMapOpp.keySet()) {  
			
				if(fieldName =='Description')	{  
					tag.s2.descriptionLabel = fieldMapOpp.get(fieldName).getDescribe().getLabel();
					tag.s2.descriptionHelpTextLabel = fieldMapOpp.get(fieldName).getDescribe().getInlineHelpText();

					tag.s4.descriptionLabel = fieldMapOpp.get(fieldName).getDescribe().getLabel();
				}
				if(fieldName =='Amount')	{  
					tag.s2.expectedPVILabel = fieldMapOpp.get(fieldName).getDescribe().getLabel();
					//tag.s2.expectedPVIHelpTextLabel = fieldMapOpp.get(fieldName).getDescribe().getInlineHelpText();
					tag.s2.expectedPVIHelpTextLabel = getLineBreakString(fieldMapOpp.get(fieldName).getDescribe().getInlineHelpText());
					
				}
				if(fieldName =='CloseDate')	tag.s2.expectedCloseDateLabel = fieldMapOpp.get(fieldName).getDescribe().getLabel();
			}
		}
    }
}