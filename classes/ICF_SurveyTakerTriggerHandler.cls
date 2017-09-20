public without sharing class ICF_SurveyTakerTriggerHandler {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_SurveyTakerTriggerHandler
-- - Author        : aazafrar 
-- - Description   : Trigger Handler Class / called by ICF_SurveyTakerAfterUpdate
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 06-08-2015   AA    1.0     Initial version
--------------------------------------------------------------------------------------
*/ 
    static map<string,string> MapOperators = new map<string,string>(); 
    
    static {
        MapOperators.put('EQUALS', '=');
        MapOperators.put('NOT_EQUALS', '!=');
        MapOperators.put('GREATER', '>');
        MapOperators.put('GREATER_EQUALS', '>=');
        MapOperators.put('LESS', '<');
        MapOperators.put('LESS_EQUALS', '<=');
        MapOperators.put('IN', 'in');
        MapOperators.put('CONTAINS', 'like');
        MapOperators.put('BETWEEN', 'between');
        MapOperators.put('INCLUDES', 'includes'); //for type MultipickList only
        MapOperators.put('NOT_IN', 'not in');
        MapOperators.put('NOT_CONTAINS', 'not_contains');
    }
        
    public static void updateTaskStatus(list<ICF_SurveyTaker__c> newST) {//keep process on Account??
        
        set<ID>    surveyIDs    = new set<ID>();
        set<ID>    contactIDs   = new set<ID>();
        set<ID>    accountIDs   = new set<ID>();
        set<ID>    taskIDs      = new set<ID>();
        list<Task> taskListToUpdate = new list<Task>();
        
        //Get all Survey and Contact Ids/Account Ids, that will allow us to find tasks to process
        for(integer i=0; i<newST.size(); i++) {
            if(newST[i].QRAdded__c == true) {
                surveyIDs.add(newST[i].Survey__c);
                taskIDs.add(newST[i].DeliveryTask_Id__c);
                if(String.isNotBlank(newST[i].Contact__c)) {
                    contactIDs.add(newST[i].Contact__c);
                }
                else if(String.isNotBlank(newST[i].Account__c)) {
                    accountIDs.add(newST[i].Account__c);
                }
            }
        }
        
        //Get tasks to update
        if(!contactIDs.isEmpty()) {
            
            taskListToUpdate = [Select t.Id, t.Status From Task t 
                                Where t.ICF_SurveyId__c in : surveyIDs And t.WhoId in : contactIDs And t.Id in :taskIDs
                                And (Status = :ICF_AP_Constant.TaskStatusSent 
                                    or Status = :ICF_AP_Constant.TaskStatusRemind
                                    or Status = :ICF_AP_Constant.TaskStatusRemindSendFail
                                    or Status = :ICF_AP_Constant.TaskStatusRemindFailLimit
                                    )];
        
        } else if (!accountIDs.isEmpty()) {
            taskListToUpdate = [Select t.Id, t.Status From Task t 
                                Where t.ICF_SurveyId__c in : surveyIDs And t.WhatId in : accountIDs And t.Id in :taskIDs
                                And (Status = :ICF_AP_Constant.TaskStatusSent  
                                    or Status = :ICF_AP_Constant.TaskStatusRemind                                    
                                    or Status = :ICF_AP_Constant.TaskStatusRemindSendFail
                                    or Status = :ICF_AP_Constant.TaskStatusRemindFailLimit
                                    )];
        }
        
        //Update Tasks status
        if(!taskListToUpdate.isEmpty()) {
            for(Task task : taskListToUpdate) {
                    task.Status = ICF_AP_Constant.TaskStatusCompleted;
                    task.ICF_Survey_Taken__c = newST[0].Id;
            }   
                
            try {
                Database.update(taskListToUpdate);          
            } catch(DMLException e) {
                System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.updateTaskStatus - Exception Message:'+ e.getMessage());
            }
        }
        
    }    
    
    public static void processSurveyTakenResults(ICF_SurveyTaker__c newST) {
        //### Comment: take in consideration only one ICF_SurveyTaker__c at a time ###/
        
        //- Check for the given survey the associated active rules with type 'Event'
        ID surveyTakenID = newST.Id;
        ID surveyID = newST.Survey__c;
        ID contactID = newST.Contact__c;
        ID accountID = newST.Account__c;    
        list<ICF_SurveyQuestionResponse__c> listSurvTakAnswers = new list<ICF_SurveyQuestionResponse__c>();
        list<ICF_DetailRule__c> listRuleCriteria = new list<ICF_DetailRule__c>();
        list<ID> ruleSetIds = new list<ID>();
            
        try {
                List<ICF_MasterRules__c>  ruleSet = [Select m.Id From ICF_MasterRules__c m Where m.Survey__c = :surveyID and m.Active__c = true
                                            And m.RecordTypeId in 
                                            (Select Id From RecordType Where DeveloperName  = :ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_RULESET)
                                            limit 1];
                
                if(!ruleSet.IsEmpty()) {                                                         
                    listRuleCriteria = [Select d.sObject__c, d.fields__c, d.Value__c, d.Process__c, d.Operator__c, d.Number__c, d.MasterRule__c, d.Select__c,
                                        d.MasterRule__r.sObject__c, d.MasterRule__r.Process__c, d.MasterRule__r.ConditionLogic__c, d.MasterRule__r.Active__c, 
                                        d.MasterRule__r.Survey__c, d.MasterRule__r.RuleSet__c
                                        From ICF_DetailRule__c d 
                                        Where d.MasterRule__r.Active__c = true 
                                        And d.MasterRule__r.Process__c = 'EVENT'
                                        And d.MasterRule__r.RuleSet__c = :ruleSet[0].Id];                          
                }
                
                if(listRuleCriteria.size() > 0) {
                    
                   //Build a map to group lists of rules by masterRule
                   map<Id,list<ICF_DetailRule__c>> mapMasterRulCriteria = new map<Id,list<ICF_DetailRule__c>>();           
                   for(ICF_DetailRule__c rc : listRuleCriteria) {
                      if(mapMasterRulCriteria.containsKey(rc.MasterRule__c))
                        mapMasterRulCriteria.get(rc.MasterRule__c).add(rc);
                      else
                        mapMasterRulCriteria.put(rc.MasterRule__c, new list<ICF_DetailRule__c>{rc});
                   }
                   
                   //lists of responses for the given surveytaker                                       
                   listSurvTakAnswers = [Select s.Id, s.Survey_Question__c, s.SurveyTaker__c, s.Response__c, s.SurveyTaker__r.Survey__c 
                                         From ICF_SurveyQuestionResponse__c s
                                         Where s.SurveyTaker__c = :surveyTakenID];
                   
                   //call method to check matching data and do next processes          
                   if(!mapMasterRulCriteria.IsEmpty() && !listSurvTakAnswers.IsEmpty() && (string.IsNotBlank(contactID) || string.IsNotBlank(accountID))) {
                        checkRulesMatchingAndDoActions(surveyTakenID, mapMasterRulCriteria, contactID, accountID);
                   }
                }
            } catch(Exception e) {
                System.Debug('An exception has occured in SurveyTakerAfterInsertHandler.processSurveyTakenResults - Exception Message:'+e.getStackTraceString());        
            }
    }
    
    private static  void checkRulesMatchingAndDoActions(ID surveyTakenID, map<Id,list<ICF_DetailRule__c>> mapMasterRulCriteria, ID contactID, ID accountID) {        
        //declare string that are used to build dynamic soql        
        string selectOnSQR      = 'Select  Survey_Question__c, SurveyTaker__c, Response__c, Survey_Question__r.OrderNumber__c, SurveyTaker__r.Id, SurveyTaker__r.Contact__r.Id, SurveyTaker__r.Contact__r.OwnerId, '
                                + 'SurveyTaker__r.Contact__r.Account.Id, SurveyTaker__r.Survey__c, SurveyTaker__r.Account__r.Id, SurveyTaker__r.Account__r.OwnerId '
                                + 'From ICF_SurveyQuestionResponse__c sqr '
                                + 'Where  sqr.SurveyTaker__c = :surveyTakenID And ';     
        
        //this map will contain masterRules with the questions and reponses (corresponding records to rules) linked to the survey taken                   
        map<ID, List<ICF_SurveyQuestionResponse__c>> mapMastrRule_MatchedResp = new map<ID, List<ICF_SurveyQuestionResponse__c>>();
        List<ICF_SurveyQuestionResponse__c> matchingResponses = new List<ICF_SurveyQuestionResponse__c>();
        //this map will contain a list of DetailRules for each object type
        map<string, string> mapObjectCriteria;
        map<string, string> mapCritNumberSubQuery;
        list<ICF_DetailRule__c> criteria;
        list<Sobject> sobj = new list<Sobject>();
        string conditionLogic = '';
        string soqlFinal = '';
        string sObjectTypeOnMR = '';
        String accOrConField = '';
        String accOrConId = '';
        string conditionLogicWithCrit = '';
        String num = '';
        String crit = '';       
        
        try {                        
            //We can have one ICF_MasterRules__c by Object Type, for example: a MR on Contact and a MR on Account
            for(ID masterRuleId : mapMasterRulCriteria.keySet()) { 
                
                mapObjectCriteria = new map<string, string>();
                mapCritNumberSubQuery = new map<string, string>();
                criteria = mapMasterRulCriteria.get(masterRuleId);
                conditionLogic = criteria.get(0).MasterRule__r.ConditionLogic__c;//get the condition logic for each ICF_MasterRules__c                
                sObjectTypeOnMR = criteria[0].MasterRule__r.sObject__c;
                soqlFinal = '';
                
                //first case: sObject field on MasterRule equals contact 
                if(criteria != null && sObjectTypeOnMR.equals('Contact')) {                 
                    mapObjectCriteria = groupCriteriaByObject(criteria, sObjectTypeOnMR, contactID);           
                                    
                } 
                //second case: sObject field on MasterRule equals Account
                else if(criteria != null && sObjectTypeOnMR.equals('Account')) { 
                    mapObjectCriteria = groupCriteriaByObject(criteria, sObjectTypeOnMR, accountID);
                }     
                
                if(!mapObjectCriteria.isEmpty()) {                          
                    for(string so : mapObjectCriteria.keySet()) {
                        
                        if(so.split('-')[1].toLowerCase() == Schema.sObjectType.ICF_SurveyQuestionResponse__c.getName().toLowerCase()
                           || so.split('-')[1].toLowerCase() == Schema.sObjectType.Contact.getName().toLowerCase()
                           || so.split('-')[1].toLowerCase() == Schema.sObjectType.Account.getName().toLowerCase()) {                           
                            
                            mapCritNumberSubQuery.put(so, mapObjectCriteria.get(so));                                                                                 
                        } 
                        else {
                            System.Debug('#### AA - subQuery:'+mapObjectCriteria.get(so));
                            accOrConField = '';
                            accOrConId = '';                            
                            sobj = Database.query(mapObjectCriteria.get(so));
                             
                            if(!sobj.IsEmpty()) {                           
                                accOrConField = mapObjectCriteria.get(so).substringBetween('Select', 'From').replace(' ',''); 
                                accOrConId = (ID) getFieldValue(sobj[0], accOrConField);
                            }                       
                            else {
                                accOrConId = null;
                            }                           
                            
                            //System.Debug('#### AA - accOrConId:'+accOrConId);
                            if(accOrConId != null)
                                mapCritNumberSubQuery.put(so, 'sqr.SurveyTaker__r.' + sObjectTypeOnMR + '__c = \'' + accOrConId+'\'');
                            else
                                mapCritNumberSubQuery.put(so, 'sqr.SurveyTaker__r.' + sObjectTypeOnMR + '__c = ' + accOrConId);//accOrConId = null
                        }                             
                    }                   
                }                
                //System.Debug('#### AA - mapCritNumberSubQuery:'+mapCritNumberSubQuery);
                
                if(!mapCritNumberSubQuery.IsEmpty()) {
                    
                    if(string.IsNotBlank(conditionLogic)) {                    
                        for (Integer i=0; i<conditionLogic.length(); i++) { 
                            num = conditionLogic.substring(i,i+1);
                            if(num.IsNumeric()) {
                                for(string numCrit : mapCritNumberSubQuery.keySet()) {
                                    if(num == numCrit.split('-')[0]) {
                                        conditionLogicWithCrit += mapCritNumberSubQuery.get(numCrit);
                                        break;
                                    }
                                }
                            } else {
                                conditionLogicWithCrit += num;
                            }
                        }
                        
                        if(conditionLogicWithCrit.containsIgnoreCase('or') && !conditionLogicWithCrit.startsWith('('))
                            conditionLogicWithCrit = '('+conditionLogicWithCrit+')';
                            
                    } else {//conditionLogic = blank
                        for(string numCrit : mapCritNumberSubQuery.keySet()) {                          
                            conditionLogicWithCrit += ' And ' + mapCritNumberSubQuery.get(numCrit);                             
                        }
                        conditionLogicWithCrit = conditionLogicWithCrit.substringAfter('And');
                    }                   
              }
                    
              //System.Debug('#### AA - conditionLogicWithCrit:'+conditionLogicWithCrit);                    
              soqlFinal = selectOnSQR + conditionLogicWithCrit;                                      
              System.Debug('#### AA - soqlFinal:'+soqlFinal);
                
              //get main soql results 
              matchingResponses = Database.query(soqlFinal);
              System.Debug('#### AA - matchingResponses:'+matchingResponses);
                    
              if(matchingResponses != null && matchingResponses.size() > 0) {
                  mapMastrRule_MatchedResp.put(masterRuleId, matchingResponses);
              }
            }//end of for loop on ICF_MasterRules__c Object
            
        } catch(Exception e) {
            System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.checkRulesMatchingAndDoActions - Exception Message:'+ e.getMessage());
        }
        
        //If some answers meet the Event rules, execute the associated actions/
        if(!mapMastrRule_MatchedResp.isEmpty()) {
           findAndDoActions(mapMastrRule_MatchedResp);
        }       
    }
    
    private static map<string, string> groupCriteriaByObject(list<ICF_DetailRule__c> criteria, String objTypeOnMR, ID contactOrAccountId) {
        
        map<string, string> mapObjectCriteria = new map<string, string>();
        string crit = '';
        string fieldValue = '';
        string crit2 = '';
        
        try {
            for(Integer i=0; i<criteria.size(); i++) { //ICF_DetailRule__c object list 
                
                //build the criteria                                 
                fieldValue = criteria.get(i).Value__c;
                crit = criteria.get(i).fields__c + ' ' + MapOperators.get(criteria.get(i).Operator__c) + ' ' + fieldValue;              
                //Specific: if operator is "BETWEEN"
                if(criteria.get(i).Operator__c == 'BETWEEN') {
                    
                    string fieldB = crit.replace('(','').replace(')','').split('between')[0];
                    string valueB = crit.replace('(','').replace(')','').split('between')[1];
                    crit = '(' + fieldB + ' <= ' + valueB.split('and')[1] + ' and ' + fieldB + ' >= ' + valueB.split('and')[0]+')';
                }
                //Specific: if operator is "not_contains"
                if(criteria.get(i).Operator__c == 'NOT_CONTAINS') {
                    crit = ' (not ' + criteria.get(i).fields__c + ' ' + MapOperators.get('CONTAINS') + ' ' + fieldValue +')';
                }               
                
                //fill the mapObjectCriteria map    
                if(criteria.get(i).sObject__c.toLowerCase() == Schema.sObjectType.ICF_SurveyQuestionResponse__c.getName().toLowerCase()) {
                    mapObjectCriteria.put(criteria.get(i).Number__c+'-'+criteria.get(i).sObject__c, crit);                  
                } 
                else if(criteria.get(i).sObject__c.toLowerCase() == Schema.sObjectType.Contact.getName().toLowerCase()) {
                            
                     if(objTypeOnMR.toLowerCase().equals(Schema.sObjectType.Contact.getName().toLowerCase())) {
                        if(criteria.get(i).Operator__c == 'BETWEEN' || criteria.get(i).Operator__c == 'NOT_CONTAINS') {
                            crit = crit.replace(criteria.get(i).fields__c, 'SurveyTaker__r.Contact__r.'+criteria.get(i).fields__c);
                        } else {
                            crit = 'SurveyTaker__r.Contact__r.'+crit;
                        }                       
                        mapObjectCriteria.put(criteria.get(i).Number__c+'-'+criteria.get(i).sObject__c, crit);
                     }
                     
                     if(objTypeOnMR.toLowerCase().equals(Schema.sObjectType.Account.getName().toLowerCase())) {
                        //
                     }
                }
                else if(criteria.get(i).sObject__c.toLowerCase() == Schema.sObjectType.Account.getName().toLowerCase()) {
                            
                     if(objTypeOnMR.toLowerCase().equals(Schema.sObjectType.Contact.getName().toLowerCase())) {
                        if(criteria.get(i).Operator__c == 'BETWEEN' || criteria.get(i).Operator__c == 'NOT_CONTAINS') {
                            crit = crit.replace(criteria.get(i).fields__c, 'SurveyTaker__r.Contact__r.Account.'+criteria.get(i).fields__c);
                        } else {
                            crit = 'SurveyTaker__r.Contact__r.Account.'+crit;
                        }
                        mapObjectCriteria.put(criteria.get(i).Number__c+'-'+criteria.get(i).sObject__c,  crit);
                     }
                     
                     if(objTypeOnMR.toLowerCase().equals(Schema.sObjectType.Account.getName().toLowerCase())) {
                        if(criteria.get(i).Operator__c == 'BETWEEN' || criteria.get(i).Operator__c == 'NOT_CONTAINS') {
                            crit = crit.replace(criteria.get(i).fields__c, 'SurveyTaker__r.Account__r.'+criteria.get(i).fields__c);
                        } else {
                            crit = 'SurveyTaker__r.Account__r.'+crit;
                        }
                        mapObjectCriteria.put(criteria.get(i).Number__c+'-'+criteria.get(i).sObject__c, crit);
                     }
                }
                else {
                    mapObjectCriteria.put(criteria.get(i).Number__c+'-'+criteria.get(i).sObject__c, 'Select '+criteria.get(i).Select__c+' From '+criteria.get(i).sObject__c+' Where ' + crit + ' And '+criteria.get(i).Select__c+' = \''+ contactOrAccountId+'\'');
                }                   
            }
                                      
        } catch(Exception e) {
            System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.groupCriteriaByObject - Exception Message:'+e.getMessage());            
        }
        
        System.Debug('####AA groupCriteriaByObject - mapObjectCriteria fin:'+mapObjectCriteria);
        return mapObjectCriteria;
     }
    
    //find actions related to the master rules
    private static void findAndDoActions(map<ID, List<ICF_SurveyQuestionResponse__c>> mapMastrRule_MatchedResp) {
        
        list<ICF_Action__c> actionsOfTypeRecord = new list<ICF_Action__c>();
        map<ID,ICF_Action__c> mapFieldSetAction = new map<ID,ICF_Action__c>();
        set<ID> actionsIdOfTypeRecord = new set<ID>();
        list<ICF_Action__c> actionsOfTypeMessage = new list<ICF_Action__c>();
        set<ID> actionsIdOfTypeMessage = new set<ID>();
        list<ICF_Action__c> actionsOfTypeFeed = new list<ICF_Action__c>();
        set<ID> actionsIdOfTypeFeed = new set<ID>();
        //
        for(ICF_Action__c act : [Select a.sObject__c, a.Type__c, a.FieldSet__c, a.MasterRule__c, a.RTDevName__c, a.Message__c 
                                 From ICF_Action__c a 
                                 Where a.MasterRule__c in : mapMastrRule_MatchedResp.KeySet()]) {
            if(act.Type__c == 'Record') {
                actionsOfTypeRecord.add(act);
                actionsIdOfTypeRecord.add(act.Id);
                mapFieldSetAction.put(act.FieldSet__c, act);
            }
                            
            if(act.Type__c == 'Message') {
                actionsOfTypeMessage.add(act);
                actionsIdOfTypeMessage.add(act.Id);
            }   
            
            if(act.Type__c == 'Feed') {
                actionsOfTypeFeed.add(act);
                actionsIdOfTypeFeed.add(act.Id);
            }        
        }
        
        //Call methods to execute actions
        if(actionsIdOfTypeRecord.size() > 0)
            createRecordAction(actionsIdOfTypeRecord, mapFieldSetAction, mapMastrRule_MatchedResp.values()[0][0]);
        if(actionsIdOfTypeMessage.size() > 0)
            sendMessageAction(actionsOfTypeMessage, mapMastrRule_MatchedResp.values()[0][0]);
        if(actionsIdOfTypeFeed.size() > 0)
            postFeedAction(actionsOfTypeFeed, mapMastrRule_MatchedResp.values()[0][0]);
    }
    
    //create new record method
    private static void createRecordAction(set<ID> actionIds, map<ID,ICF_Action__c> mapFieldSetAction, ICF_SurveyQuestionResponse__c sQR) {
        list<sObject> objsToInsert = new list<sObject>();
        map<string, ID> mapRTIds = new map<string, ID>();
        list<string> listRT = new list<string>();
        string valueFromST = '';
        string ID = '';
        system.debug('#########BCH-SqR:'+sQR);        
        //get the RecordType Ids for create record actions with RT info
        for(ID idFS : mapFieldSetAction.KeySet()) {
            //System.Debug('####AA createRecordAction - idFS:'+idFS);   
            if(!string.IsBlank(mapFieldSetAction.get(idFS).RTDevName__c)) {
                listRT.add(mapFieldSetAction.get(idFS).RTDevName__c);
            }
        }
        for(RecordType rt : [Select Id, DeveloperName, SobjectType From RecordType Where DeveloperName in : listRT]) {
            mapRTIds.put(rt.DeveloperName, rt.Id);
        }
        
        for(ICF_Field_Set__c fs : [Select f.sObject__c, f.Name, (Select Name, Value__c, FieldSet__c, Dynamic__c  From Field_Templates__r) 
                                   From ICF_Field_Set__c f
                                   Where f.Id in (Select FieldSet__c from ICF_Action__c Where Id in :actionIds)]) {            
            sObject sObj = null;            
            //set the RecordType if required
            if(!string.IsBlank(mapFieldSetAction.get(fs.Id).RTDevName__c)) {
                sObj = Schema.getGlobalDescribe().get(fs.sObject__c).newSObject(mapRTIds.get(mapFieldSetAction.get(fs.Id).RTDevName__c), false);
            } else {
                sObj = Schema.getGlobalDescribe().get(fs.sObject__c).newSObject() ;
            }
            //set other fields
            if(string.IsNotBlank(sQR.SurveyTaker__r.Contact__c)) {
                for(ICF_FieldTemplate__c ft : fs.Field_Templates__r) {
                    if(!(ft.Dynamic__c)) {
                        sObj.put(ft.Name, ft.Value__c);                        
                    } else { //lookup fields
                        if (ft.Value__c.startsWithIgnoreCase('Contact.')) {
                            valueFromST = ft.Value__c.replace('Contact.','SurveyTaker__r.Contact__r.');
                        } else if (ft.Value__c.startsWithIgnoreCase('Account.')) {
                            valueFromST = ft.Value__c.replace('Account.','SurveyTaker__r.Contact__r.Account.');
                        } else if(ft.Value__c.startsWithIgnoreCase('ICF_SurveyTaker__c.'))  {
                            valueFromST = ft.Value__c.replace('ICF_SurveyTaker__c.','SurveyTaker__r.');
                        }system.debug('AMA2 ' + ft);
                        ID = (ID) getFieldValue(sQR, valueFromST);                        
                        sObj.put(ft.Name, ID);
                    }
                }
            } else if(string.IsNotBlank(sQR.SurveyTaker__r.Account__c)) {
                for(ICF_FieldTemplate__c ft : fs.Field_Templates__r) {
                    if(!(ft.Dynamic__c)) {
                        sObj.put(ft.Name, ft.Value__c);
                    } else { //lookup fields                        
                        
                        if (ft.Value__c.startsWithIgnoreCase('Account.')) {
                            valueFromST = ft.Value__c.replace('Account.','SurveyTaker__r.Account__r.');
                        } else if(ft.Value__c.startsWithIgnoreCase('ICF_SurveyTaker__c.'))  {
                            valueFromST = ft.Value__c.replace('ICF_SurveyTaker__c.','SurveyTaker__r.');
                        }                        
                        ID = (ID) getFieldValue(sQR, valueFromST);
                        sObj.put(ft.Name, ID);
                    }
                }
            }
            
            if(string.valueOf(sObj.getSObjectType()) == Schema.sObjectType.Case.getName()) {
                //Fetching the assignment rules on case
                list<AssignmentRule> AR = new list<AssignmentRule>();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                
                if(!AR.isEmpty()) {
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR[0].id;
                    //Setting the DMLOption on Case instance
                    sObj.setOptions(dmlOpts); 
                }               
            }            
            //System.Debug('####AA createRecordAction - objToInsert:'+sObj);           
            if(sObj != null) {
                objsToInsert.add(sObj);
            }                                                  
        }        
              
        try {
            insert objsToInsert;
        } catch(DmlException e) {
            System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.createRecordAction - Exception Message:'+ e.getMessage());
        }        
    }
    
    //send a private message to owner of the contact 
    private static void sendMessageAction(list<ICF_Action__c> actions, ICF_SurveyQuestionResponse__c sQR) {
        String recipient = '';
        string message = '';
        for(ICF_Action__c act : actions) {
                        
            if(string.IsNotBlank(sQR.SurveyTaker__r.Contact__c))
                recipient = sQR.SurveyTaker__r.Contact__r.OwnerId;
            else if (string.IsNotBlank(sQR.SurveyTaker__r.Account__c))
                recipient = sQR.SurveyTaker__r.Account__r.OwnerId;
            
            try {
                if(string.IsNotBlank(recipient)) {
                    message = act.Message__c;                           
                    ConnectApi.ChatterMessage  sendMessage = ConnectAPI.ChatterMessages.sendMessage(message, recipient);
                }
            } catch(Exception e) {
                System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.sendMessageAction - Exception Message:'+ e.getMessage());
            }            
        }
    }
    
    //post a feed on contact object
    private static void postFeedAction(list<ICF_Action__c> actions, ICF_SurveyQuestionResponse__c sQR) {
        //System.Debug('####AA postFeedAction - actions:'+actions);
        list<FeedItem> listFeed = new list<FeedItem>();
        for(ICF_Action__c act : actions) {
            FeedItem post = new FeedItem();                     
            post.Body = act.Message__c;
            post.type = 'TextPost';
            //post.Visibility = 'AllUsers';
            //post.LinkUrl = '/'+sQR.SurveyTaker__r.Contact__c;
            post.Title = '';
            if(string.IsNotBlank(sQR.SurveyTaker__r.Contact__c))
                post.ParentId =  sQR.SurveyTaker__r.Contact__c;
            else if (string.IsNotBlank(sQR.SurveyTaker__r.Account__c))
                post.ParentId =  sQR.SurveyTaker__r.Account__c;
            listFeed.add(post);
        }   
        //System.Debug('####AA postFeedAction - listFeed:'+listFeed);   
        try {
            insert listFeed;
        } catch(DmlException e) {
            System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.postFeedAction - Exception Message:'+ e.getMessage());
        }
    }
    
    //get field type according to object name and field name
    /*private static Schema.DisplayType getFieldType(string objectName, string fieldName) {
        Schema.DisplayType FldType  = null;
        try {
            
            //if the field is a relationship
            if(fieldName.contains('__r'))   {
                objectName = fieldName.split('\\.')[0].replace('__r', '__c');
                fieldName = fieldName.split('\\.')[1];
            }           
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
            Schema.SObjectType objectType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult objectDescribeResult = objectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = objectDescribeResult.fields.getMap();
            Schema.SObjectField field = mapFields.get(fieldName);           
            Schema.DescribeFieldResult fieldDescription = field.getDescribe();
            FldType = fieldDescription.getType();       
             
        } catch(Exception e) {
            System.Debug('An Exception has occured in SurveyTakerAfterInsertHandler.getFieldType - Exception Message:'+ e.getMessage());
        }
        return FldType;
    }*/
    
    public static Object getFieldValue(SObject o,String field){
        system.debug('AAM ' + o + ' f: ' + field);
         if(o == null){
            return null;
         }
         
        if(field.contains('.')){
            String nextField = field.substringAfter('.');
            String relation = field.substringBefore('.');
            return getFieldValue((SObject)o.getSObject(relation),nextField);
         } else {
            return o.get(field);
         }      
    }
}