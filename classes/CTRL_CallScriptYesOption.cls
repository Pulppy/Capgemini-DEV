public class CTRL_CallScriptYesOption {
    @AuraEnabled
    public static Event createEventTemplate(){
       return (Event)Event.sObjectType.newSObject(null, true);
    }
    
    @AuraEnabled
    public static ID createEvent(Event eventObj) {
        system.debug('@@@@@@eventObj=' + eventObj);
       
        String tag = 'SUCCESS';
        try{    
        	 insert eventObj;
			ID leadId = eventObj.WhoId;
            //change Status of Lead
           	Lead le = [select Id, status from Lead where Id = :leadId];
            le.Status = 'Working - Contacted';
            update le;
            
            // convert Lead into Opportunity and Account
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setDoNotCreateOpportunity(false);
            
            LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setOwnerId(UserInfo.getUserId());
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if (lcr.isSuccess())  
                tag = 'SUCCESS' + lcr.getOpportunityId();
            else            	   
                tag = 'FAIL' + lcr.getErrors(); 
        }catch(Exception ex){
            tag = 'FAIL' + ex;
        }
        return eventObj.Id;
    }
}