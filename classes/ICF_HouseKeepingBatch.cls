/*************************************************************************************
Apex Class Name - ICF_HouseKeepingBatch

Version - 1.0

Created Date - 14 DEC 2015

Function - Batch to expire surveys url

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* AA            14/12/2015      Original Version
*************************************************************************************/
global class ICF_HouseKeepingBatch implements Database.Batchable<sObject>  {
    
    global string query;
    global string statusActive =  ICF_AP_Constant.STATUS_Active;
    global string taskStatusSent =  ICF_AP_Constant.TaskStatusSent;
    global string taskStatusExpired =  ICF_AP_Constant.TaskStatusExpired;
    global string taskStatusRemind =  ICF_AP_Constant.TaskStatusRemind;
    global string taskStatusRemindFailLimit =  ICF_AP_Constant.TaskStatusRemind;
    
    global ICF_HouseKeepingBatch() { }//end of constructor
        
    global Database.QueryLocator start(Database.BatchableContext BC) {      
        query = 'SELECT Id, Url_Expiring_Date__c, survey_email_reminder__c, Survey_Status__c ' +
                'FROM ICF_Survey__c ' +
                'Where Survey_Status__c = :statusActive And Expiration_Date__c > today And (Url_Expiring_Date__c > 0 or survey_email_reminder__c > 0)';
        return Database.getQueryLocator(query);     
    }//end of start
    
    global void execute(Database.BatchableContext BC, List<ICF_Survey__c> scope) {
        System.debug('>>> START ICF_HouseKeepingBatch - execute <<<');        
        string queryOnTask = '';
        map<ID, integer> mapSurveyIdExpiringDateValue = new map<ID, integer>();
        map<ID, integer> mapSurveyIdEmailReminderValue = new map<ID, integer>();
        List<Task> listTaskToUpdate = new List<Task>();        
        
        try {               
            for(ICF_Survey__c survey : scope) {
                if(survey.Url_Expiring_Date__c > 0)
                    mapSurveyIdExpiringDateValue.put(survey.Id, Integer.ValueOF(survey.Url_Expiring_Date__c));      
                
                if(survey.survey_email_reminder__c > 0)
                    mapSurveyIdEmailReminderValue.put(survey.Id, Integer.ValueOF(survey.survey_email_reminder__c));
            }
            
            //find and update tasks to expire            
            for(ID survId : mapSurveyIdExpiringDateValue.KeySet()) {
                queryOnTask = 'Select id, status, icf_sent_date__c, icf_surveyId__c From Task Where Recordtype.DeveloperName = \'ICF\' '+
                              'And icf_surveyId__c = : survId And Status = :taskStatusSent ' + 
                              'And icf_sent_date__c <= n_days_ago:'+ mapSurveyIdExpiringDateValue.get(survId); 
                
                System.debug('>>> START ICF_HouseKeepingBatch (Expire) - execute <<<'+queryOnTask);
                
                for(Task t : Database.Query(queryOnTask)) {
                    t.Status = taskStatusExpired;   
                    listTaskToUpdate.add(t);    
                }   
            }           
            if(!listTaskToUpdate.IsEmpty()) {
                update listTaskToUpdate;
            }
            
            //find and update tasks to remind
            listTaskToUpdate = new List<Task>();
            queryOnTask = '';            
            for (ID survId : mapSurveyIdEmailReminderValue.KeySet()) {
                queryOnTask = 'Select id, status, icf_sent_date__c, icf_surveyId__c From Task Where Recordtype.DeveloperName = \'ICF\' '+
                              'And icf_surveyId__c = :survId ' + //And ((Status = :taskStatusSent And ICF_Remind_Date__c = n_days_ago:'+ mapSurveyIdEmailReminderValue.get(survId)+') '+
                              'And (Status = :taskStatusSent And icf_sent_date__c = n_days_ago:' + mapSurveyIdEmailReminderValue.get(survId)+' And ICF_Remind_Date__c = null)'; 
                
                System.debug('>>> START ICF_HouseKeepingBatch (Resend) - execute <<<' + queryOnTask);
                
                for (Task t : Database.Query(queryOnTask)) {
                    t.Status = taskStatusRemind;  
                    listTaskToUpdate.add(t);    
                }   
            }
            if (!listTaskToUpdate.IsEmpty()) {
                update listTaskToUpdate;
            }                      
            
        } 
        catch(Exception e) {
            System.debug('>>> Exception occured in ICF_HouseKeepingBatch - execute <<<');
        }
        
        System.debug('>>> END ICF_HouseKeepingBatch - execute <<<');    
    }//end of execute
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> START ICF_HouseKeepingBatch - finish <<<');        
        System.debug('>>> END ICF_HouseKeepingBatch - finish <<<');          
    }//end of finish

}