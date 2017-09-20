public class CTRL_CallScriptNoOption {
    @AuraEnabled
    public static Lead getLead(String leadId){
        Lead le = [select Id, status from Lead where Id = :leadId];
        return le;
    }
    @AuraEnabled
    public static Lead updateLead(Lead leadObject){
        leadObject.Status = 'Lost';
        upsert leadObject;
        return leadObject;
    }
	
}