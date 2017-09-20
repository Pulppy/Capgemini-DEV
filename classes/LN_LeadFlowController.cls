public with sharing class LN_LeadFlowController{

    public class Data {
        
		@AuraEnabled
		public String inputId { get; set; }

		@AuraEnabled
        public Boolean isAgent { get; set; }


		@AuraEnabled
        public S2Data s2 { get; set; }

        @AuraEnabled
        public S3Data s3 { get; set; }

        @AuraEnabled
        public S4Data s4 { get; set; }

		@AuraEnabled
		public String title { get; set; }

		//@AuraEnabled
		//public String theme { get; set; }
		
        @AuraEnabled
		public Integer timeDiff { get; set; }
    }
    
    public class S2Data {
      
	    @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String subject { get; set; }

        @AuraEnabled
        public DateTime adate { get; set; }

        @AuraEnabled
        public DateTime startTime { get; set; }

        @AuraEnabled
        public DateTime endTime { get; set; }

        @AuraEnabled
        public String description { get; set; }

        @AuraEnabled
        public String location { get; set; }

		@AuraEnabled
        public Decimal proposedPVI { get; set; }
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

		//////////////////////Add 29/6/2017 - ML187 Proposed PVI field and value for agency///////////////////////////
		
		@AuraEnabled
        public String proposedPVILabel { get; set; }

		@AuraEnabled
        public String proposedPVIHelpTextLabel { get; set; }
    }

    public class S3Data {
    
		@AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String subject { get; set; }

        @AuraEnabled
        public DateTime adatetime { get; set; }

        @AuraEnabled
        public String description { get; set; }	

		////////////////////Field Labels 26-05-2017////////////////////

		@AuraEnabled
        public String subjectLabel { get; set; }
	
		@AuraEnabled
        public String descriptionLabel { get; set; }
	
		@AuraEnabled
        public String descriptionHelpTextLabel { get; set; }
    }

    public class S4Data {
    
		@AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String description { get; set; }

		////////////////////Field Labels 26-05-2017////////////////////

		@AuraEnabled
        public String descriptionLabel { get; set; }
	
		@AuraEnabled
        public String descriptionHelpTextLabel { get; set; }
    }
    
    @AuraEnabled
    public static LN_LeadFlowController.Data prepare(String objId)
	{
        LN_LeadFlowController.Data tag = new LN_LeadFlowController.Data();
 	
        tag.timeDiff = getTimeDiff();
		//tag.isAgent = userProfileName.contains('Agent Partner');
		tag.isAgent = checkAgent();
		//tag.inputId = [select Id from Lead where Id = :objId].Id;//Get LeadId
		Lead vlead = [select Id, Expected_Premium_Payment__c, Expected_APE__c, Proposed_PVI__c, Description from Lead where Id = :objId];
		tag.inputId = vlead.Id;
		tag.title = Label.LN_LeadFlow_Title;
		//tag.theme = UserInfo.getUiThemeDisplayed();

		tag.s2 = new S2Data();
		tag.s2.name = Label.LN_LeadFlow_Option1;				 //'Yes';
		tag.s2.subject = Label.LN_LeadFlow_Option1_Subject;		 //'1st Appointment';
		tag.s2.startTime = Datetime.now();
        tag.s2.endTime = Datetime.now().addHours(1);
		tag.s2.adate = Datetime.now();
		tag.s2.proposedPVI = vlead.Proposed_PVI__c;
		        
        tag.s3 = new S3Data();
		tag.s3.name = Label.LN_LeadFlow_Option2;				 //'Unreachable/Not Available';
		tag.s3.subject = Label.LN_LeadFlow_Option2_Subject;		 //'Follow up call';
		tag.s3.adatetime = Datetime.now();

        tag.s4 = new S4Data();
		tag.s4.name = Label.LN_LeadFlow_Option3;//'Not Interested';

		setLabel(tag);
        return tag;
    }

    @AuraEnabled
   	public static String goS2(String inputId, String subject, DateTime startTime, DateTime endTime, String description, String location, Decimal proposedPVI, Boolean isAgent)	//1st Appointment
	{
		////////////////////Validation StartDateTime & EndDateTime// 16/6/2017 ML-180/////////////////////
		if(startTime > endTime) return ' End Date cannot be earlier than Start Date';

		///////////////////////////////////////////////////////////////////////////////////////////////////
        String tag = '';
        try {
			if (subject == null || subject == '') {
                subject = Label.LN_LeadFlow_Option1_Subject;//'1st Appointment';
            }
  		
  			Event ev = new Event();
  			ev.StartDateTime = startTime;
  			ev.EndDateTime = endTime;
  			ev.Subject = subject;
  			ev.WhoId = inputId;
            ev.Description = description;
            ev.Location = location;
            //insert ev;

			Database.SaveResult sr = Database.insert(ev, false);

			if (sr.isSuccess()){
				if(isAgent){ 	
					tag = 'O:' + sr.getId();
					Lead le = [select Id, Status, Proposed_PVI__c from Lead where Id = :inputId];
    				le.Status = 'Approach';
					le.Proposed_PVI__c = proposedPVI;
					update le;
				}
				else {
					//String ExtCust = [select Customer_ID__c from Lead where Id = :inputId].Customer_ID__c;
					String ExtCust;

					Lead le = [select Id, ASM_Notice_Date_Time__c, RSM_Notice_Date_Time__c, Customer_ID__c, Proposed_PVI__c, Last_Activity_Date__c from Lead where Id = :inputId];
					le.ASM_Notice_Date_Time__c = null;
					le.RSM_Notice_Date_Time__c = null;
					le.Last_Activity_Date__c = null;
					le.Proposed_PVI__c = proposedPVI;
					ExtCust = le.Customer_ID__c;
					update le;
					/////////////////////Convert function: should turn off "Lead Convert after Qualified" Process Builder ///////////////////
					Database.LeadConvert lc = new Database.LeadConvert();
					lc.setLeadId(inputId);
					lc.setDoNotCreateOpportunity(false);

					Id AccId = getExistingAccountId(ExtCust);
					if(AccId!=null)	lc.setAccountId(AccId);
            		LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            		lc.setConvertedStatus(convertStatus.MasterLabel);
					lc.setOwnerId(UserInfo.getUserId());
           
					Database.LeadConvertResult lcr = Database.convertLead(lc);
        			if (lcr.isSuccess())   tag = 'O:' + lcr.getOpportunityId();
					else            	   tag = '' + lcr.getErrors();
				}
			}
			else 	tag = '' + sr.getErrors();

        } catch (Exception e) {tag = '' + e.getMessage();}

        return tag;
    }
    
    @AuraEnabled
    public static String goS3(String inputId, String subject, DateTime adatetime, String description, Boolean isAgent)//Unreachable/Not Available
	{
        String tag = '';
        try {
			
            if (subject == null || subject == '') subject = Label.LN_LeadFlow_Option2_Subject;//'Follow up call';
     		////////////////////////////////////
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
            
			insert t;      
           
			Lead le = [select Id, Status from Lead where Id = :inputId];
    		le.Status = 'Approach';
			//le.Description = description;
			update le;

			if(String.isNotBlank(inputId))	tag = 'O:' + inputId;   
			////////////////////////////////////

        } catch (Exception e) {
            tag = '' + e.getMessage();
        }
        return tag;
    }

    @AuraEnabled
	public static String goS4(String inputId, String description, Boolean isAgent) //Not Interested
	{
        String tag = '';
        try {
		
		Lead le = [select Id, Status from Lead where Id = :inputId];
    	le.Status = 'Lost';
		le.Description = description;
		update le;
		
		if(String.isNotBlank(inputId)) tag = 'O:' + inputId;
	
        } catch (Exception e) {
            tag = '' + e.getMessage();
        }
        return tag;
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
    
    public static integer getTimeDiff(){
        integer agent=24;
        String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
        
        for(SF1CustomProfileSetting__c cs : SF1CustomProfileSetting__c.getall().values()){
            if (cs.Name==userProfileName & cs.Active__c==true) return (cs.Time_Difference__c != null && cs.Time_Difference__c != 0 ? Integer.ValueOf(cs.Time_Difference__c) : 24); 
        }
        
        return agent;
    }

	public static Id getExistingAccountId(String inputId){
		Id accId = null;
        try{
			if(String.isBlank(inputId)) return null;
			else accId = [Select Id from Account where Customer_ID__c =: inputId].Id;
        }catch(Exception ex){return null;}

        return accId;
    }

	public static void setLabel(LN_LeadFlowController.Data tag)
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
			}
			if(fieldName =='StartDateTime')  tag.s2.startTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			if(fieldName =='EndDateTime')  tag.s2.endTimeLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
			if(fieldName =='Description')  {
				tag.s2.descriptionLabel = fieldMapEvent.get(fieldName).getDescribe().getLabel();
				tag.s2.descriptionHelpTextLabel = fieldMapEvent.get(fieldName).getDescribe().getInlineHelpText();
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
		for (String fieldName: fieldMapTask.keySet()) {  
			if(fieldName =='Subject')  tag.s3.subjectLabel = fieldMapTask.get(fieldName).getDescribe().getLabel();
			if(fieldName =='Description')  {
				tag.s3.descriptionLabel = fieldMapTask.get(fieldName).getDescribe().getLabel();
				tag.s3.descriptionHelpTextLabel = fieldMapTask.get(fieldName).getDescribe().getInlineHelpText();
			}
		}

		String typeLead= 'Lead';  //Object Name
		Map<String, Schema.SObjectType> schemaMapLead = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMapLead.get(typeLead);
		Map<String, Schema.SObjectField> fieldMapLead = leadSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldMapLead.keySet()) {  
			//if(fieldName =='Subject')  tag.s3.subjectLabel = fieldMap.get(fieldName).getDescribe().getLabel();
			if(fieldName =='Description')	{  
				tag.s4.descriptionLabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
				tag.s4.descriptionHelpTextLabel = fieldMapLead.get(fieldName).getDescribe().getInlineHelpText();
			}
			if(fieldName =='Proposed_PVI__c')	{  
				tag.s2.proposedPVILabel = fieldMapLead.get(fieldName).getDescribe().getLabel();
				tag.s2.proposedPVIHelpTextLabel = fieldMapLead.get(fieldName).getDescribe().getInlineHelpText();
			}
		}
    }
    
}