/**************************************************************************************
Apex Class Name - ICF_PrepareSurveyDeliveryBatch

Version - 1.0

Created Date - 10 SEP 2015

Function - Batch to create query based on masters rule of each survey and launch batch to create activity

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* Spoon (HDU)   10/09/2015      Original Version
* Spoon (HDU)   26/01/2016      Add exclusion of existing task with business record.
*************************************************************************************/
global class ICF_PrepareSurveyDeliveryBatch implements Database.Batchable<sObject>, Database.Stateful {

    String query;
    global String survey_status_Active = ICF_AP_Constant.STATUS_Active;
    global list<string> listProcess = new list<String>{ICF_AP_Constant.PROCESS_STATUS_Eligibility, ICF_AP_Constant.PROCESS_STATUS_Exclusion};
    global map<String,ICF_Survey__c> mapIdToSurvey;//key = survey Id, value = survey
    global map<String,String> mapRuleSetToSurveyId;//key = ruleSetId, value SurveyId
    global map<String,set<String>> mapRuleSetToSetMasterRules;//key = ruleSetId, value = list of Master Rule Id
    global map<String,WrapperRule> mapMasterRuleToRule;//key = Master Rule Id , value = Rule wrapper
    global map<String,ICF_WrapperSurveySoqls> maplistWrapperSurveySoqls = new map<String,ICF_WrapperSurveySoqls>() ;
    global ICF_PrepareSurveyDeliveryBatch() {
        mapIdToSurvey = new  map<String,ICF_Survey__c>();
        mapRuleSetToSurveyId = new  map<String,String>();
        mapRuleSetToSetMasterRules = new  map<String,set<String>>();
        mapMasterRuleToRule = new  map<String,WrapperRule>();
        query = 'SELECT MasterRule__r.RuleSet__r.Survey__r.Id, '+
                '       MasterRule__r.RuleSet__r.Survey__r.Name, '+
                '       MasterRule__r.RuleSet__r.Survey__r.URL__c, '+
                '       MasterRule__r.RuleSet__r.Survey__c, '+
                '       MasterRule__r.ConditionLogic__c, '+
                '       MasterRule__r.RuleSet__c, '+
                '       MasterRule__r.sObject__c, '+
                '       MasterRule__r.Process__c, '+
                '       MasterRule__r.Select__c, '+
                '       MasterRule__r.ObjectReference__c, '+
                '       MasterRule__c, '+
                '       Number__c, '+
                '       fields__c, '+
                '       Value__c, '+
                '       Id, '+
                '       Operator__c '+
                'FROM ICF_DetailRule__c '+
                'WHERE MasterRule__r.Active__c = true '+
                'AND MasterRule__r.RuleSet__r.Survey__r.Survey_Status__c = :survey_status_Active '+
                'AND MasterRule__r.RuleSet__r.Survey__r.Expiration_Date__c > TODAY '+
                'AND MasterRule__r.RuleSet__r.Active__c = true '+
                'AND MasterRule__r.RuleSet__r.Survey__c != null '+
                'AND MasterRule__r.RuleSet__c != null '+
                'AND MasterRule__r.Process__c IN  :listProcess';
    }//end of constructor
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug( '>>> START query - start<<<'+ query);
        return Database.getQueryLocator(query);
    }//end of start

    global void execute(Database.BatchableContext BC, List<ICF_DetailRule__c> scope) {
        System.debug('>>> START ICF_PrepareSurveyDeliveryBatch - execute <<<');
        System.debug('>>>## execute - scope size: '+scope.size());
        WrapperRule rule;
        ICF_Survey__c survey;
        for(ICF_DetailRule__c criteria :scope ){
            survey = criteria.MasterRule__r.RuleSet__r.Survey__r;

            //get WrapperRule is existed else create one
            if(criteria.MasterRule__c != null && survey != null ){
                mapIdToSurvey.put(survey.Id,survey);
                if(mapMasterRuleToRule.containskey(criteria.MasterRule__c)){
                    rule = mapMasterRuleToRule.get(criteria.MasterRule__c);
                }else{
                    rule = new WrapperRule();
                }//end of check containskey
            }//end of check null 

            if(criteria.MasterRule__c != null 
                && criteria.MasterRule__r.sObject__c != null
                && criteria.MasterRule__r.Process__c != null
                && criteria.Number__c != null
                && criteria.MasterRule__r.Select__c != null
                && criteria.Operator__c != null)
            {
                rule.addRulesObject(criteria.MasterRule__r.sObject__c);
                rule.addRulesProcess(criteria.MasterRule__r.Process__c);
                rule.addRulesSelect(criteria.MasterRule__r.Select__c);
                rule.addRulesConditionLogic(criteria.MasterRule__r.ConditionLogic__c);
                rule.addRulesCondition(Integer.ValueOf(criteria.Number__c), criteria.fields__c, criteria.Value__c,criteria.Operator__c );
                if(String.isNotBlank( criteria.MasterRule__r.ObjectReference__c )){
                    rule.addRulesQuerySelection(criteria.MasterRule__r.ObjectReference__c);
                }
                //store WrapperRule in map
                mapMasterRuleToRule.put(criteria.MasterRule__c, rule);
                //store rule set to survey id
                mapRuleSetToSurveyId.put(criteria.MasterRule__r.RuleSet__c  , survey.Id);

                //store mapping of rule set  => masterruleS
                if(mapRuleSetToSetMasterRules.containskey(criteria.MasterRule__r.RuleSet__c)){
                    mapRuleSetToSetMasterRules.get(criteria.MasterRule__r.RuleSet__c).add(criteria.MasterRule__c);
                }else{
                    mapRuleSetToSetMasterRules.put(criteria.MasterRule__r.RuleSet__c ,new set<String>{criteria.MasterRule__c } );
                }
            }else{ 
                String valuesError = 'Values are: sObject__c->' + criteria.MasterRule__r.sObject__c 
                                                                + ' | Process__c->'+criteria.MasterRule__r.Process__c 
                                                                + ' | Number__c->'+criteria.Number__c 
                                                                + ' | Select__c->'+criteria.MasterRule__r.Select__c
                                                                + ' | Operator__c->'+criteria.Operator__c;
                System.debug('>>>## execute - WARNING: missing value to build rule. Rule not taken For criteria:'+criteria.Id +' with Master Rule:'+criteria.MasterRule__c + '.  '+valuesError);   
            }//end of check criteria
        }//end of loop Scope
        System.debug('>>> END ICF_PrepareSurveyDeliveryBatch - execute <<<');    
    }//end of execute
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> START ICF_PrepareSurveyDeliveryBatch - finish <<<');
        System.debug('>>>## finish - mapIdToSurvey size: '+mapIdToSurvey.size());
        System.debug('>>>## finish - mapRuleSetToSurveyId size: '+mapRuleSetToSurveyId.size());
        System.debug('>>>## finish - mapRuleSetToSetMasterRules size: '+mapRuleSetToSetMasterRules.size());
        System.debug('>>>## finish - mapMasterRuleToRule size: '+mapMasterRuleToRule.size());

        WrapperRule wrRule;
        String surveyId = '';
        String soql = '';
        String jobID = ''; 
        String selectPath = ''; 
        String selectPathAccount ='';
        String currentProcess ='';
        //////////////////////////////////////////// 
        // -Build set of soql each survey         //
        // -Schedule batch for surveys            //
        ////////////////////////////////////////////

        ///Build Soqls for each surveys
        if(mapRuleSetToSetMasterRules.size() > 0){
            //loo in rule sets
            for (String ruleSetId:mapRuleSetToSetMasterRules.keyset()){
                if(mapRuleSetToSurveyId.containskey(ruleSetId) &&  mapIdToSurvey.containskey(mapRuleSetToSurveyId.get(ruleSetId)) ){
                    surveyId = mapRuleSetToSurveyId.get(ruleSetId);
                    //loop in master rules of rule set
                    if(mapRuleSetToSetMasterRules.containskey(ruleSetId)){
                        for (String masterRuleId :mapRuleSetToSetMasterRules.get(ruleSetId)){
                            selectPathAccount ='';
                            wrRule = mapMasterRuleToRule.get(masterRuleId);
                            //build soql
                            soql =  'SELECT '+ wrRule.queryClause + ' FROM '+wrRule.sObj+' WHERE '+wrRule.getWhereClause();
                            if(wrRule.sObj.toLowerCase() == Schema.sObjectType.Contact.getName().toLowerCase() 
                                 && !wrRule.queryClause.toLowerCase().contains( 'accountid')  ){
                                selectPathAccount = 'accountid';
                                soql =  'SELECT accountid,'+ wrRule.queryClause + ' FROM '+wrRule.sObj+' WHERE '+wrRule.getWhereClause();
                            }else if(wrRule.queryClause.toLowerCase().contains(Schema.sObjectType.Contact.getName().toLowerCase()) 
                                 && !wrRule.queryClause.toLowerCase().contains( 'accountid')
                                 ){
                                if(wrRule.queryClause.toLowerCase().contains(Schema.sObjectType.Contact.getName().toLowerCase()+'id')){
                                    selectPathAccount =wrRule.selectClause.toLowerCase().replace('contactid','contact.accountid');
                                    soql =  'SELECT '+wrRule.selectClause.toLowerCase().replace('contactid','contact.accountid')+','+ wrRule.queryClause + ' FROM '+wrRule.sObj+' WHERE '+wrRule.getWhereClause();
                                }else if(wrRule.selectClause.toLowerCase().contains(Schema.sObjectType.Contact.getName().toLowerCase()+'.id')){
                                    selectPathAccount =wrRule.selectClause.toLowerCase().replace('contact.id','contact.accountid');
                                    soql =  'SELECT '+wrRule.selectClause.toLowerCase().replace('contact.id','contact.accountid')+','+ wrRule.queryClause + ' FROM '+wrRule.sObj+' WHERE '+wrRule.getWhereClause();
                                }
                            }
                            soql = soql.replaceAll('id,id,', 'id,');
                            currentProcess = wrRule.process;
                            if(wrRule.selectClause.toLowerCase() == 'icf_business_object__c' ){
                                currentProcess = ICF_WrapperSurveySoqls.PROCESS_STATUS_Exclusion_Task;
                                soql = soql+' AND  ICF_SurveyId__c =\'' +surveyId+'\'';
                            }
                            if(maplistWrapperSurveySoqls.containskey(surveyId) ){
                                maplistWrapperSurveySoqls.get(surveyId).addSoql(  soql, wrRule.selectClause, currentProcess ,selectPathAccount, wrRule.objectReference );
                            }else{
                                maplistWrapperSurveySoqls.put(surveyId , new ICF_WrapperSurveySoqls( soql,surveyId, wrRule.selectClause,currentProcess ,selectPathAccount, wrRule.objectReference));     
                            }//end of check containskey
                        }//end of loop masterRuleId 
                    }//end of check if ruleset contain master rule
                }//check if contains survey
            }//end of loop in mapRuleSetToSetMasterRules
        }//end of check size mapRuleSetToSetMasterRules
        System.debug('>>>## finish - maplistWrapperSurveySoqls:'+maplistWrapperSurveySoqls);//.size());
        if( !Test.isRunningTest() ){
            ICF_CreateTaskForSurveyDeliveryBatch b = new ICF_CreateTaskForSurveyDeliveryBatch(maplistWrapperSurveySoqls.keyset(), maplistWrapperSurveySoqls );
            jobID =  System.scheduleBatch( b, 'surveys'+System.now() , 0,1 );
        }
        System.debug('>>>## finish - jobID:'+jobID);
        System.debug('>>> END ICF_PrepareSurveyDeliveryBatch - finish <<<'); 
    }//end of finish

    

    ////////////////////////////////////
    //Wrapper container for Rule      //
    ////////////////////////////////////
    global class WrapperRule{
        global map<Integer,string> mapOrderToCondition{get;set;}
        global String conditionLogic{get;set;}
        global String process{get;set;}
        global String selectClause{get;set;}     
        global String queryClause{get;set;}   
        global String objectReference{get;set;}   
        global String sObj{get;set;}   
        global set<String> setSelectClause = new set<String>();

        global WrapperRule(){
            mapOrderToCondition = new map <Integer,string> ();
            conditionLogic = '';
            process = '';
        }//end of constructor

        global boolean addRulesCondition(Integer order, String fieldName, String fieldValue,String operator){

            String clause;
            if(ICF_AP_Constant.mapOperatorMapping.containskey(operator)){
                clause = fieldName+' '+ICF_AP_Constant.mapOperatorMapping.get(operator)+ ' ' + fieldValue; 
            }else if(operator == 'NOT_CONTAINS' && ICF_AP_Constant.mapOperatorMapping.containskey('CONTAINS')){
                clause = ' ( NOT '+fieldName+' '+ICF_AP_Constant.mapOperatorMapping.get('CONTAINS')+ ' ' + fieldValue+ ' ) '; 
            } 

            if(clause !=  null){
                mapOrderToCondition.put(order, clause);
            }else{
                System.debug('addRulesConditionLogic - WARNING Fail to add Claused:'+sObj+','+fieldName+','+operator+','+fieldValue);
                return false;
            }
            return true;
        }//end method addRulesCondition

        global void addRulesProcess(String processIn){
            if(String.isNOTBlank(process) && process != processIn){
                System.debug('addRulesProcess - WARNING changed in process From ['+process+'] to ['+processIn+']');
            }
            process = processIn.toLowerCase();
        }//end method addRulesProcess

        global void addRulesConditionLogic(String logic){
            if(String.isNOTBlank(conditionLogic) && conditionLogic != logic){
                System.debug('addRulesConditionLogic - WARNING changed in logic conditions From ['+conditionLogic+'] to ['+logic+']');
            }
            conditionLogic = logic;
        }//end method addRulesConditionLogic

        global void addRulesSelect(String selectIn){
            setSelectClause.add(selectIn.toLowerCase() );
            if(String.isNOTBlank(selectClause) && selectClause != selectIn){
                System.debug('addRulesSelect - WARNING changed in select Clause From ['+selectClause+'] to ['+selectIn+']');
            }
            queryClause =  String.join( new list<string>(setSelectClause), ',');
            selectClause = selectIn;
        }//end method addRulesConditionLogic
        
        global void addRulesQuerySelection(String querySelectIn){
            setSelectClause.add(querySelectIn.toLowerCase() );
            objectReference = querySelectIn;
            if(String.isNOTBlank(objectReference) && objectReference != querySelectIn){
                System.debug('addRulesSelect - WARNING changed in select Clause From ['+objectReference+'] to ['+querySelectIn+']');
            }
            queryClause =  String.join( new list<string>(setSelectClause), ',');
        }//end method addRulesConditionLogic
        
        global void addRulesObject(String obj){
            if(String.isNOTBlank(sObj) && sObj != obj){
                System.debug('addRulesSelect - WARNING changed in object From ['+sObj+'] to ['+obj+']');
            }
            sObj = obj;
        }//end method addRulesConditionLogic


        global string getWhereClause(){
            string clause = '';

            validateConditionsLogic();

            if(String.isNotBlank(conditionLogic)){
                list <String> listChunk= new list<String>();
                String character = '';
                Integer last = 0;
                String state = '';
                boolean isLastNumeric = false;
                for (Integer i=0; i<conditionLogic.length() ;i++){
                    character = conditionLogic.substring(i,i+1);
                    if(!character.isNumeric() && i == 0){
                       state +=  character;
                       isLastNumeric = false;
                    }else if(character.isNumeric() && i == 0){
                       state +=  character;
                       isLastNumeric = true;
                    }else if(character.isNumeric() && isLastNumeric){
                       state +=  character;
                    }else if(character.isNumeric() && !isLastNumeric){
                        listChunk.add(state);
                        state = character;
                        isLastNumeric = true;
                    }else if(!character.isNumeric() && isLastNumeric){
                        listChunk.add(state);
                        state = character;
                        isLastNumeric = false;
                    }else if(!character.isNumeric() && !isLastNumeric){
                       state +=  character;
                    }else{
                       state +=  character;
                    }                    
                }//end of for loop
                listChunk.add(state);
                for (String key:listChunk ){
                    if(key.isNumeric()){
                        if( mapOrderToCondition.containskey(Integer.valueOf(key))){
                            clause += mapOrderToCondition.get(Integer.valueOf(key));
                        }else{
                            System.debug('>>>## getWhereClause - WARNING failed to build clause :'+key);
                        }
                    }else{
                        clause += key;
                    }//end of check numeric
                }//end of loop
            }//end of check blank
                System.debug('>>>## getWhereClause - clause :'+clause);

            return clause;
        }// end of getWhereClause

        private void validateConditionsLogic(){
            String whereConcat = ' AND ';
            String logic = '';

            if(String.isBlank(conditionLogic) && mapOrderToCondition.size() > 0 ){
                for(Integer key : mapOrderToCondition.keyset()){
                    logic += key + whereConcat;
                }//end of loop key
                logic = logic.removeEnd(whereConcat);
                conditionLogic = logic;
            }// end of check 
        }//end of method validateCondition
    }//end of wrapper class


}//end of batch