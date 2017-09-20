/**************************************************************************************
Apex Class Name - ICF_CreateTaskForSurveyDeliveryBatch

Version - 1.0

Created Date - 15 SEP 2015

Function - Batch to create task based on soql and survey id passed as parameters.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* Spoon (HDU)   15/09/2015      Original Version
* Spoon (HDU)   26/01/2016      Add exclusion of existing task with business record.
*************************************************************************************/
global class ICF_CreateTaskForSurveyDeliveryBatch implements Database.Batchable<sObject> {
    global string query;
    global set<String> setSurveyId;
    global map<String,ICF_Survey__c> mapIdToSurvey;
    global string taskStatusInProgress = ICF_AP_Constant.TaskStatusInProgress;
    global map<String,ICF_WrapperSurveySoqls> mapSurveyToWrapperSurveySoqls;//survey id to WrapperSurveySoqls
    
    global ICF_CreateTaskForSurveyDeliveryBatch(set<String> setSurveyIdIN,map<String,ICF_WrapperSurveySoqls> mapSurveyToWrapperSurveySoqlsIN) {
        System.debug('>>> START ICF_CreateTaskForSurveyDeliveryBatch - constructor <<<');
        setSurveyId = setSurveyIdIN;
        mapSurveyToWrapperSurveySoqls = mapSurveyToWrapperSurveySoqlsIN;
        mapIdToSurvey = new map<String,ICF_Survey__c>();
        System.debug('>>>## constructor - setSurveyId size:'+setSurveyId.size());
        System.debug('>>>## constructor - setSurveyId size:'+setSurveyId);
        System.debug('>>>## constructor - mapSurveyToWrapperSurveySoqlsIN size:'+mapSurveyToWrapperSurveySoqls);//.size());
        System.debug('>>> END ICF_CreateTaskForSurveyDeliveryBatch - constructor <<<');
    }//end of constructor
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('>>> START ICF_CreateTaskForSurveyDeliveryBatch - start <<<');
        query = 'SELECT Id,URL__c, Survey_Language__c '+
                'FROM ICF_Survey__c ' +
                'WHERE Id IN :setSurveyId';
        System.debug('>>> END ICF_CreateTaskForSurveyDeliveryBatch - start <<<');
        return Database.getQueryLocator(query);
    }//end of start

    global void execute(Database.BatchableContext BC, List<ICF_Survey__c> scope) {
        System.debug('>>> START ICF_CreateTaskForSurveyDeliveryBatch - execute <<<');
        System.debug('>>>## execute - scope size:'+ scope.size() );
        String val ='';
        String objRefId ='';
        Task task;
        ICF_WrapperSurveySoqls wrSurveySoqls;
        list<String> listBusinessRecordExclusions = new list<String>();
        list<String> listIds = new list<String>();
        map<String,Task> mapExtIdToTasks = new map<String,Task>();
        map<String,set<String>> mapSurveyIdTosObjectId = new map<String,set<String>>();
        Map <String,sObject> mapIdToObject= new map<String,sObject>();
        Map <String,String> mapIdToAccPath= new map<String,String>();
        Map <String,String> mapIdToObjectRefPath= new map<String,String>();
        map<String,ICF_Survey_Task_Mapping__c> mapTaskMappingField = ICF_Survey_Task_Mapping__c.getAll();
        System.debug('>>>## execute - mapTaskMappingField size:'+ mapTaskMappingField.size() );
        //loop in survey 
        for(ICF_Survey__c survey : scope){
            mapIdToSurvey.put(survey.Id, survey );
            //get WrapperSurveySoqls for this survey
            if(mapSurveyToWrapperSurveySoqls.containskey(survey.Id) ){
                wrSurveySoqls = mapSurveyToWrapperSurveySoqls.get(survey.Id);
                mapSurveyIdTosObjectId.put( wrSurveySoqls.surveyId, new Set<String>() );
                
                //get all businessrecord of existing Task
                System.debug('>>>## execute - wrSurveySoqls listTaskExclusionSoql size:'+  wrSurveySoqls.listTaskExclusionSoql.size() );
                for(ICF_WrapperSurveySoqls.WrapperSoql wrSoql  : wrSurveySoqls.listTaskExclusionSoql ) {
                    listBusinessRecordExclusions = wrSoql.getListSelectedIds();
                }//end of loop wrSoql
                System.debug('>>>## execute - listBusinessRecordExclusions size:'+ listBusinessRecordExclusions.size() );
                
                System.debug('>>>## execute -eligibilty :');
                //add all eligibilty ids of this survey from mapSurveyIdTosObjectId
                for(ICF_WrapperSurveySoqls.WrapperSoql wrSoql  : wrSurveySoqls.listEligibiltySoql ) {
                    if( listBusinessRecordExclusions.size() > 0 ){
                        wrSoql.listBusinessRecordExclusion = listBusinessRecordExclusions;
                    }
                    
                    listIds = wrSoql.getListSelectedIds();
                    System.debug('>>>## execute -eligibilty-listIds ' + listIds);
                    if( listIds.size() > 0 ){
                        mapSurveyIdTosObjectId.get(wrSurveySoqls.surveyId).addAll(listIds);
                        mapIdToObject.putAll(    wrSoql.mapIdToObject );
                        mapIdToAccPath.putAll(    wrSoql.mapIdToAccPath );
                        mapIdToObjectRefPath.putAll(    wrSoql.mapIdToObjectRefPath );
                    }//end of check size
                }//end of loop wrSoql

                System.debug('>>>## execute -exclusion :');
                //remove all exclusion ids of this survey from mapSurveyIdTosObjectId
                for(ICF_WrapperSurveySoqls.WrapperSoql wrSoql  : wrSurveySoqls.listExclusionSoql ) {
                    listIds = wrSoql.getListSelectedIds();
                    if( listIds.size() > 0 ){
                        mapSurveyIdTosObjectId.get(survey.Id).removeAll(listIds);
                    }//end of check size
                }//end of loop wrSoql
            }//end of check contains key
        }//end of loop scope

        System.debug('>>>## execute - mapSurveyIdTosObjectId size:'+ mapSurveyIdTosObjectId);//.size() );
        if( mapSurveyIdTosObjectId.size() > 0){
            for(String surveyId :mapSurveyIdTosObjectId.keySet()){
                for(String objId :mapSurveyIdTosObjectId.get(surveyId)){
                    task = new Task();
                    task.Subject = 'ICF';
                    task.ICF_SurveyId__c = surveyId;
                    task.ICF_SurveyExtId__c = surveyId;
                    task.Status = taskStatusInProgress;
                   // task.ICF_business_object__c = mapIdToObject.get(objId).Id;//link the task record to the business object (case,policy,claim...)
                    if( String.isBlank(ICF_WrapperSurveySoqls.getValue(mapIdToObject.get(objId), mapIdToObjectRefPath.get(objId)) ) &&  mapIdToObjectRefPath.get(objId) != 'Id' ){
                        objRefId = ICF_WrapperSurveySoqls.getValue(mapIdToObject.get(objId), 'Id');
                    }else if(String.isNotBlank(ICF_WrapperSurveySoqls.getValue(mapIdToObject.get(objId), mapIdToObjectRefPath.get(objId)) )){
                        objRefId = ICF_WrapperSurveySoqls.getValue(mapIdToObject.get(objId), mapIdToObjectRefPath.get(objId));
                    }else{                          
                        System.debug('>>>## execute - Warning Blank Object Ref:'+mapIdToObjectRefPath.get(objId) );
                    }
                    task.ICF_business_object__c = objRefId;//link the task record to the business object (case,policy,claim...)
                    
                    //add survey url to task 
                    task.Description = mapIdToSurvey.get(surveyId).URL__c;
                    if(task.Description != null  && !task.Description.toLowerCase().contains('?id=')){
                        task.Description = task.Description +'?id='+surveyId;
                    }
                    //System.debug('>>>##AAAA execute - objId:'+ objId );
                    //System.debug('>>>##AAAA execute - busObj:'+ mapIdToObject.get(objId) );
                    if( objId.substring(0,3) == Schema.sObjectType.Contact.getKeyPrefix()){                     
                        if ( mapIdToObject.containskey(objId) 
                            && mapIdToAccPath.containskey(objId)  ){

                            if(mapIdToAccPath.get(objId) != null && mapIdToAccPath.get(objId).contains('.')){
                                list<string> listAccPath = mapIdToAccPath.get(objId).split('\\.');
                                //System.debug('>>>## execute - listAccPath:'+ listAccPath );
                                sObject temp ;
                                for( Integer i =0;i<listAccPath.size();i++){
                                    //System.debug('>>>## execute - i:'+ i );
                                    //System.debug('>>>## execute - temp:'+ temp );
                                    if(i == 0){
                                       temp =mapIdToObject.get(objId).getsObject(listAccPath[i]);
                                    }else if(i<(listAccPath.size()-1)){
                                       temp =temp.getsObject(listAccPath[i]);
                                    }else{
                                        task.WhatId = string.ValueOf(temp.get(listAccPath[i]));
                                    }//end check

                                    if(temp == null){
                                        break;
                                    }
                                }//end of loop acc path
                            }else{
                                if(mapIdToObject.get(objId).get( mapIdToAccPath.get(objId)) != null){
                                    task.WhatId = string.ValueOf(mapIdToObject.get(objId).get( mapIdToAccPath.get(objId)));
                                }
                            }//end of checkif contains object and account path
                        }//end of check if contact
                        task.WhoId = objId;
                    }else if(objId.substring(0,3) == Schema.sObjectType.Lead.getKeyPrefix()) {
                        task.WhoId = objId;
                    }else{
                        task.WhatId = objId;
                    }//end of process contact       

                    if(task.WhatId != null){
                        task.ICF_SurveyExtId__c += ';'+task.WhatId;
                        if( String.valueOf(task.WhatId).substring(0,3) == Schema.sObjectType.Account.getKeyPrefix()){
                            task.Description = task.Description +'&accid='+task.WhatId;
                        }//end check account
                        else if(String.valueOf(task.WhatId).substring(0,3) == Schema.sObjectType.Case.getKeyPrefix()){
                            task.Description = task.Description +'&caid='+task.WhatId;
                        }//end of check case
                    }//end of check if what id is null

                    if(task.WhoId != null){
                        task.ICF_SurveyExtId__c += ';'+task.WhoId;
                        if( objId.substring(0,3) == Schema.sObjectType.Contact.getKeyPrefix()){
                            task.Description = task.Description +'&cid='+task.WhoId;
                        }//end of check if contact
                    }//end of check null whoid
                    //task.Description = task.Description +'&lg='+mapIdToSurvey.get(surveyId).Survey_Language__c;

                    mapExtIdToTasks.put(task.ICF_SurveyExtId__c,task);
                }//end of loop in objIds
            }//end of loop in surveys
        }//end of check size of survey      
        System.debug('>>>## execute - mapExtIdToTasks size:'+ mapExtIdToTasks.size() );
        System.debug('>>>## execute - mapExtIdToTasks :'+ mapExtIdToTasks );
        
        //Remove all existing task
        /*for( Task existingTask :[ SELECT ICF_SurveyExtId__c FROM Task WHERE ICF_SurveyExtId__c IN :mapExtIdToTasks.keySet() ] ){
            mapExtIdToTasks.remove(existingTask.ICF_SurveyExtId__c);
        }//end loop slect task
        */

        //populate task
        for(String taskExtId :mapExtIdToTasks.keySet()){
            for(String field: mapTaskMappingField.keySet()){                
                    Schema.DescribeFieldResult f = Schema.sObjectType.Task.fields.getMap().get(field).getDescribe();
                    val = mapTaskMappingField.get(field).ICF_Value__c;
                    if(f.getType() == Schema.DisplayType.Boolean){
                        mapExtIdToTasks.get(taskExtId).put(field, Boolean.valueOf(val));
    
                    }else if( f.getType() == Schema.DisplayType.Integer
                        || f.getType() == Schema.DisplayType.Percent
                    ){
                        mapExtIdToTasks.get(taskExtId).put(field, Integer.valueOf(val));
    
                    }else if( f.getType() == Schema.DisplayType.Double){
                        mapExtIdToTasks.get(taskExtId).put(field, Double.valueOf(val));
    
                    }else if( f.getType() == Schema.DisplayType.Date){
                        if( val.toLowerCase().contains('today') ){
                            mapExtIdToTasks.get(taskExtId).put(field,System.today());
                        }else if(val.toLowerCase().contains('now')){
                            list<String> listChunk = val.replace(' ', '').split(';');
                            if(listChunk.size() == 1){
                               mapExtIdToTasks.get(taskExtId).put(field, system.now().date() ); 
                            }else{
                               mapExtIdToTasks.get(taskExtId).put(field, system.now().addDays(Integer.valueOf(listChunk[1])).date() ); 
                            }
                        }else{
                            mapExtIdToTasks.get(taskExtId).put(field, Date.valueOf(val));
                        }
    
                    }else if( f.getType() == Schema.DisplayType.DateTime){
                        if(val.toLowerCase().contains('now')){
                            list<String> listChunk = val.replace(' ', '').split(';');
                            if(listChunk.size() == 1){
                               mapExtIdToTasks.get(taskExtId).put(field, system.now()); 
                            }else{
                               mapExtIdToTasks.get(taskExtId).put(field, system.now().addDays(Integer.valueOf(listChunk[1])) ); 
                            }
                        }else{
                            mapExtIdToTasks.get(taskExtId).put(field, Date.valueOf(val));
                        }
                    }else{
                        mapExtIdToTasks.get(taskExtId).put(field,val);
                    }                
               
            }//end of loop field
        }//end ofloop task

        System.debug('>>>## execute - mapExtIdToTasks size without existing task:'+ mapExtIdToTasks.size() );
        if(mapExtIdToTasks.size() >0){
            insert mapExtIdToTasks.values();
        }//end of check size
        
        System.debug('>>> END ICF_CreateTaskForSurveyDeliveryBatch - execute <<<'); 
    }//end of execute    
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> START ICF_CreateTaskForSurveyDeliveryBatch - finish <<<');       
        System.debug('>>> END ICF_CreateTaskForSurveyDeliveryBatch - finish <<<');          
    }//end of finish
}//end of batch