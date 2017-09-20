public class lightningexample_controller {
	@AuraEnabled
	public static String goS2(String inputId, String subject, DateTime startDate, Datetime endDate, String comments){
		//String tag = 'Thach' + inputId + subject + startDate + endDate;
		//System.debug('xxxxx ' + inputId);
		//return tag;
		String tag = '';
		try{
            Lead le = [select Id, status from Lead where Id = :inputId];
            le.Status = 'Working - Contacted';
            update le;
            
			//convert lead =>            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(le.id);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            //
            
            System.debug('xxxxx ' + lcr);
            //create new EV
            Event ev = new Event();
			ev.StartDateTime = startDate;
			ev.EndDateTime = endDate;
			ev.Subject = subject;
			ev.WhoId = inputId;
			ev.Description = comments;
			//ev.OwnerId = '00Q7F0000020vbSUAQ';
			upsert(ev);
            //Database.SaveResult sr = Database.insert(ev, true);
			tag = 'SUCCESS';
		}catch(Exception ex){
			tag = 'FAIL' + ex;
		}
		return tag;
	}
    @AuraEnabled
    public static String goS4(String inputId, String discription){
		String tag = '';
		try{
            Lead le = [select Id, Description, status from Lead where Id = :inputId];
            le.Description = discription;
            le.Status = 'Lost';
            update le;
			tag = 'SUCCESS';
		}catch(Exception ex){
			tag = 'FAIL' + ex;
		}
		return tag;
	}
    
    @AuraEnabled
    public static String goS3(String inputId, String subnotvailable, DateTime datenotvailable, String commentsnotvailable){
		//String tag = 'Thach' + inputId + subnotvailable + datenotvailable + commentsnotvailable;
		//System.debug('xxxxx ' + inputId);
		//return tag;
		String tag = '';
		try{
            //call lead and update
            Lead le = [select Id, Description, status from Lead where Id = :inputId];
            le.Description = commentsnotvailable;
            le.Status = 'Working - Contacted';
            update le;
            //new task
            DateTime dT = datenotvailable;
			Date adate = Date.newinstance(dT.year(), dT.month(), dT.day());
            Task t = new Task();
			t.OwnerId = UserInfo.getUserId();
			t.Subject = subnotvailable;
			t.Status = 'Open';
			t.WhoId = inputId;
			t.ActivityDate = adate;
			t.IsReminderSet = true;
			t.Description = commentsnotvailable;
            upsert(t);
			tag = 'SUCCESS';
		}catch(Exception ex){
			tag = 'FAIL' + ex;
		}
		return tag;
	}

}