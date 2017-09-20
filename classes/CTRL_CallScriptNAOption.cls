public class CTRL_CallScriptNAOption {
	@AuraEnabled
    public static Task createTaskTemplate(){
       return (Task)Task.sObjectType.newSObject(null, true);
    }
    
    @AuraEnabled
    public static ID createTask(Task taskObj) {
        system.debug('@@@@@@taskObj=' + taskObj);
       
        String tag = 'SUCCESS';
        try{    
            //create Task
        	insert taskObj;
            //change Status of Lead
            ID leadId = taskObj.WhoId;
           	Lead le = [select Id, status from Lead where Id = :leadId];
            le.Status = 'Working - Contacted';
            update le;     
        }catch(Exception ex){
            tag = 'FAIL' + ex;
        }
        return taskObj.Id;
    }
}