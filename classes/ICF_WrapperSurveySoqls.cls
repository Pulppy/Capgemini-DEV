global class ICF_WrapperSurveySoqls{
/**************************************************************************************
Apex Class Name - ICF_WrapperSurveySoqls

Version - 1.0

Created Date - 28 SEP 2015

Function - Wrapper class storing Survey ,soql, select path

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* Spoon (HDU)   28/09/2015      Original Version
* Spoon (HDU)   26/01/2016      Add exclusion of existing task with business record.
*************************************************************************************/
    ////////////////////////////////////
    //Wrapper container for Survey    //
    ////////////////////////////////////
    global String surveyId{get;set;}
    global list<WrapperSoql> listEligibiltySoql{get;set;}
    global list<WrapperSoql> listExclusionSoql{get;set;}
    global list<WrapperSoql> listTaskExclusionSoql{get;set;}
    global static final  String PROCESS_STATUS_Exclusion_Task = 'Task Exclusion';

    global ICF_WrapperSurveySoqls(String soqlIn,String surveyIdIn,String pathIdIn,String processIn,String pathAccountIdIn,String pathObjectReferenceIn){
        surveyId = surveyIdIn;
        listEligibiltySoql = new list<WrapperSoql>();
        listExclusionSoql = new list<WrapperSoql>();
        listTaskExclusionSoql = new list<WrapperSoql>();
        
        if(processIn.toLowerCase() == ICF_AP_Constant.PROCESS_STATUS_Eligibility.toLowerCase()){
            listEligibiltySoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));
        }else if(processIn.toLowerCase() == ICF_AP_Constant.PROCESS_STATUS_Exclusion.toLowerCase()){
            listExclusionSoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));
        }else if(processIn.toLowerCase() == PROCESS_STATUS_Exclusion_Task.toLowerCase()){
            listTaskExclusionSoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));  
        }else{
            System.debug('>>>## ICF_WrapperSurveySoqls - WARNING processIn is not compatible  <<<');
        }
    }//end of constructor

    global void addSoql(String soqlIn,String pathIdIn,String processIn,String pathAccountIdIn,String pathObjectReferenceIn){
        if(processIn.toLowerCase() == ICF_AP_Constant.PROCESS_STATUS_Eligibility.toLowerCase()){
            listEligibiltySoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));
        }else if(processIn.toLowerCase() == ICF_AP_Constant.PROCESS_STATUS_Exclusion.toLowerCase()){
            listExclusionSoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));
        }else if(processIn.toLowerCase() == PROCESS_STATUS_Exclusion_Task.toLowerCase()){
            listTaskExclusionSoql.add (new WrapperSoql(soqlIn,pathIdIn,pathAccountIdIn,pathObjectReferenceIn));
        }else{
            System.debug('>>>## ICF_WrapperSurveySoqls - WARNING processIn is not compatible  <<<');
        }
    }//end of method addSoql
 

    ////////////////////////////////////
    //Wrapper container for Soql    //
    ////////////////////////////////////
    global class WrapperSoql{
        global String soql{get;set;}
        global String pathId{get;set;}
        global String pathAccountId{get;set;}
        global String pathObjectReference{get;set;}
        global list<String> listBusinessRecordExclusion {get;set;}
        global Map <String,sObject> mapIdToObject{get;set;}
        global Map <String,String> mapIdToAccPath{get;set;}
        global Map <String,String> mapIdToObjectRefPath{get;set;}

        global WrapperSoql(String soqlIn,String pathIdIn,String pathAccountIdIn,String pathObjectReferenceIn){
            soql = soqlIn;
            pathId = pathIdIn;
            pathAccountId = pathAccountIdIn;
            pathObjectReference = pathObjectReferenceIn;
        }//end of WrapperSoql

        global list<String> getListSelectedIds(){
            System.debug('>>> START ICF_WrapperSurveySoqls:WrapperSoql - getListSelectedIds <<<'); 
            //System.debug('>>>## getListSelectedIds - surveyId:'+surveyId); 
            System.debug('>>>## getListSelectedIds - pathId:'+pathId); 
            System.debug('>>>## getListSelectedIds - soql:'+soql);
            System.debug('>>>## getListSelectedIds - listBusinessRecordExclusion:'+listBusinessRecordExclusion); 
            //variable
            sObject sObjTemp;
            String resultObjId = '';
            String resultBusinessObjId = '';
            set<String> setIds = new set <String>();
            list<String> listChunkPath = pathId.split('\\.');
            mapIdToObject = new Map <String,sObject>();
            mapIdToAccPath = new Map <String,String>();
            mapIdToObjectRefPath = new Map <String,String>();
            
            if(String.isBlank(pathObjectReference)){
                pathObjectReference='Id';                         
            }
            
            for(sObject objResult : Database.query(soql) ){
                sObjTemp = objResult;
                resultObjId = '';
                for(Integer i =0;i<listChunkPath.size();i++){
                    if((i+1)==listChunkPath.size()){
                        if(sObjTemp == null || sObjTemp.get(listChunkPath[i]) == null){
                            break;
                        }
                        resultObjId = String.valueOf(sObjTemp.get(listChunkPath[i]));
                    }else{
                        sObjTemp = sObjTemp.getSobject(listChunkPath[i]);
                    }
                }//end of loop listChunkPath
                resultBusinessObjId =ICF_WrapperSurveySoqls.getValue(objResult, pathObjectReference );
                if(String.isNotBlank(resultObjId)){   
                    if(listBusinessRecordExclusion == null 
                        ||(listBusinessRecordExclusion != null
                        && String.isNotBlank(resultBusinessObjId)
                        && !new Set<string>(listBusinessRecordExclusion).contains(resultBusinessObjId)
                        )
                    ){  
                        System.debug('>>>## getListSelectedIds - Enter:');
                        setIds.add(resultObjId);
                        mapIdToObject.put(resultObjId,objResult);
                        mapIdToAccPath.put(resultObjId,pathAccountId); 
                        mapIdToObjectRefPath.put(resultObjId,pathObjectReference);                                                      
                    }
                }
            }//end of loo soql results
        System.debug('>>> END ICF_WrapperSurveySoqls:WrapperSoql - getListSelectedIds <<<' + setIds); 
        return new list<string>(setIds);
    }//end of getListId
    }//end of wrapper soql
    
    global static string getValue(sObject sObjTemp, String pathId ){
        String resultObjId = '';
        list<String> listChunkPath = pathId.split('\\.');
        
        for(Integer i =0;i<listChunkPath.size();i++){
            if((i+1)==listChunkPath.size()){
                if(sObjTemp == null || sObjTemp.get(listChunkPath[i]) == null){
                    break;
                }
                resultObjId = String.valueOf(sObjTemp.get(listChunkPath[i]));
            }else{
                sObjTemp = sObjTemp.getSobject(listChunkPath[i]);
            }
        }//end of loop listChunkPath
        
        return resultObjId;
    }//end of method
}//end of wrapper class ICF_WrapperSurveySoqls