public with sharing class AP02CasesSetFlagsTargetDate {
/*
// AP02CasesSetFlagsTargetDate
----------------------------------------------------------------------
-- - Name          : AP02CasesSetFlagsTargetDate 
-- - Author        : SPOON
-- - Description   : Set Target Date for red and yellow flag 
--                   based on status of case
--                   
-- Maintenance History:
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 05-JUNE-2013  HDU    1.0      Init
-- 27-APR-2015   HDU    2.0      Optimisation
-- 17-DEC-2015	 ABT	3.0		 Added Not ReCalculate SLA for the cases
-- 19-May-2017	 Son			 Adding Query to use 'MY Life SCRM Business Hour' business hour in Calculation.
----------------------------------------------------------------------
**********************************************************************
*/
    //***
    //* use custom setting to set
    //* target date for flag
    //*******
    public static void setTargetDateOfFlagDisplay(list<Case> listOldTrigger, list<Case> listNewTrigger){
        //variable
        Id bh;
        Date targetDate;
        DateTime calDueDateTime;
        BusinessHours defaultHours;
        list<Flag_target_date__c> setupList;
        map<id,RecordType > mapIdToRecordType;
        map<string, list<Flag_target_date__c>> mapRecordTypeToSetup = new map<string, list<Flag_target_date__c>>();
        
      //  System.debug('#############' + Flag_target_date__c.getall().values());
        //search for custom setting
        for (Flag_target_date__c setup :  Flag_target_date__c.getall().values() ){

            //check null
            if(setup.Record_type__c != null && setup.Object_developer_name__c == AP_Constant.sobjectCas){
                for (string recordType : setup.Record_type__c.split(';')){
                    if(recordType != null){
                        if(mapRecordTypeToSetup.get(recordType) == null){
                            mapRecordTypeToSetup.put(recordType , new list<Flag_target_date__c>{setup} );
                        }else{
                            mapRecordTypeToSetup.get(recordType).add(setup );
                        }
                    }//end of check if recordtype null
                }//end of loop in split recordtype field
                //mapRecordTypeToSetup.put(setup.Record_type__c , setup );
            }//end of check null            
        }//end of customSetting
        
        
       // System.debug('############# mapRecordTypeToSetup : ' + mapRecordTypeToSetup);
        
        //check if setup is not null
        if(mapRecordTypeToSetup.size()  > 0 ){
            //Get the default business hours
            List<BusinessHours> bsList = [Select id from BusinessHours where name = 'MY Life SCRM Business Hour'];
            if(bsList.size() == 0){
                defaultHours = AP_Constant.getBusinessHoursDefault();//[select Id from BusinessHours where IsDefault=true];
            } else {
                defaultHours = bsList[0];
            }
            
            //search for record type id
            mapIdToRecordType = AP_Constant.getRecordTypeMap(AP_Constant.sobjectCas);
           /* mapIdToRecordType = new map<id,RecordType >([Select r.Id, r.DeveloperName 
                                                        From    RecordType r
                                                        Where   r.DeveloperName IN :mapRecordTypeToSetup.KeySet()]);
             */                                           
            //check if record type exist
            if( mapIdToRecordType.size()  > 0 ){
                //loop in cases
                for(Integer i=0;i<listNewTrigger.size();i++ ){
                    Case caseRecord = listNewTrigger[i];
                    Case oldCaseRecord = listOldTrigger[i];
                    
                  
                    if(mapIdToRecordType.get(caseRecord.RecordTypeId) !=  null && mapRecordTypeToSetup.get(String.ValueOF(mapIdToRecordType.get(caseRecord.RecordTypeId).DeveloperName)) != null){
        
						setupList = mapRecordTypeToSetup.get(String.ValueOF(mapIdToRecordType.get(caseRecord.RecordTypeId).DeveloperName));
                        
        				//System.debug('############# setupList : ' + setupList);
        				//System.debug('Case record type : ' + caseRecord.RecordTypeId);
        				
                        for(Flag_target_date__c setupRow : setupList)
                        {   
                        	//system.debug('>>>>>>>>>>>#### '+setupRow);
                            if(setupRow.Critical_field__c != null &&
                                caseRecord.get(setupRow.Critical_field__c) != null &&
                                /*oldCaseRecord.get(setupRow.Critical_field__c) != null &&*/
                                (caseRecord.get(setupRow.Critical_field__c) != oldCaseRecord.get(setupRow.Critical_field__c) ||
                                caseRecord.get('Priority') != oldCaseRecord.get('Priority') )&& 
                                caseRecord.get(setupRow.Critical_field__c) == setupRow.Critical_value__c &&
								// ABT - 17-DEC-2015
								!(caseRecord.get(setupRow.Update_field__c) != null && setupRow.Not_Re_execute__c)
								){
                                //targetDate = system.now().addHours(Integer.ValueOf(setupRow.Number_of_hours__c)).date();
                                
                                if(caseRecord.BusinessHoursId!=null){
                                    bh = caseRecord.BusinessHoursId;
                                }
                                else{
                                    bh = defaultHours.Id;
                                }
                                //TAT is from created date
                                if(setupRow.TAT__c) {
                                    if(setupRow.Record_type__c.contains('GI_FormalComplaint') || setupRow.Record_type__c.contains('GI_Complaint') || setupRow.Record_type__c.contains('GI_Closed_Complaint')) {
                                        if(setupRow.Is_Calendar_Hours__c == true) {
                                            if(caseRecord.CCRU_Receipt_Date__c != null) {
                                                calDueDateTime = caseRecord.CCRU_Receipt_Date__c.addDays(Integer.valueOf(Math.ceil(setupRow.Number_of_hours__c / Decimal.valueOf(System.Label.DailyHoursOfWork))));                                            
                                            } else {
                                                calDueDateTime = caseRecord.createdDate.addDays(Integer.valueOf(Math.ceil(setupRow.Number_of_hours__c / Decimal.valueOf(System.Label.DailyHoursOfWork))));
                                            }
                                        } else {
                                            if(caseRecord.CCRU_Receipt_Date__c != null) {
                                                calDueDateTime = BusinessHours.add(bh, caseRecord.CCRU_Receipt_Date__c, integer.valueOf(setupRow.Number_of_hours__c)*60 * 60 * 1000L);                                                                                        
                                            } else {
                                                calDueDateTime = BusinessHours.add(bh, caseRecord.createdDate, integer.valueOf(setupRow.Number_of_hours__c) * 60 * 60 * 1000L);
                                            }
                                        }
                                    } else {
                                        calDueDateTime = BusinessHours.add(bh,caseRecord.createdDate ,integer.valueOf(setupRow.Number_of_hours__c)*60 * 60 * 1000L);                                        
                                    }
                                } else {
                                    calDueDateTime = BusinessHours.add(bh,system.now() ,integer.valueOf(setupRow.Number_of_hours__c)*60 * 60 * 1000L);
                                }
                                //set field
                                caseRecord.put( setupRow.Update_field__c , calDueDateTime.addSeconds(-Integer.valueOf(caseRecord.get('Pending_with_customer_time__c'))));
                                //system.debug('>>>>>>>>>>>#### '+calDueDateTime);
                            }//end check rule
                        }
                    }//end of check recordtype of case
                }//end of loop in cases             
            }//end of check if record type exist            
        }//end of check for setup not null
    }//end of method setTargetDateOfFlagDisplay
    
    public static void setTargetDateOfFlagDisplay(list<Case> listNewTrigger){
        //variable
        Id bh;
        Date targetDate;
        DateTime calDueDateTime;
        BusinessHours defaultHours;
        list<Flag_target_date__c> setupList;
        map<id,RecordType > mapIdToRecordType;
        map<string, list<Flag_target_date__c>> mapRecordTypeToSetup = new map<string, list<Flag_target_date__c>>();
        
        //search for custom setting
        for (Flag_target_date__c setup :   Flag_target_date__c.getall().values()){
        									// [Select f.Update_field__c, f.Record_type__c, f.Object_developer_name__c, 
                                            //        f.Number_of_hours__c, f.Critical_value__c, f.Critical_field__c 
                                            //From    Flag_target_date__c f
                                            //Where   f.Object_developer_name__c = :AP_Constant.sobjectCas ]){
            //check null
            if(setup.Record_type__c != null && setup.Object_developer_name__c == AP_Constant.sobjectCas){
                for (string recordType : setup.Record_type__c.split(';')){
                    if(recordType != null){
                        if(mapRecordTypeToSetup.get(recordType) == null){
                            mapRecordTypeToSetup.put(recordType , new list<Flag_target_date__c>{setup} );
                        }else{
                            mapRecordTypeToSetup.get(recordType).add(setup );
                        }
                    }//end of check if recordtype null
                }//end of loop in split recordtype field
                //mapRecordTypeToSetup.put(setup.Record_type__c , setup );
            }//end of check null            
        }//end of customSetting
        
        //Get the default business hours
        defaultHours = AP_Constant.getBusinessHoursDefault();//[select Id from BusinessHours where IsDefault=true];
        
        //check if setup is not null
        if(mapRecordTypeToSetup.size()  > 0 ){
            //search for record type id
            mapIdToRecordType = AP_Constant.getRecordTypeMap(AP_Constant.sobjectCas); 
            					//new map<id,RecordType >([Select r.Id, r.DeveloperName 
                                //                        From    RecordType r
                                //                        Where   r.DeveloperName IN :mapRecordTypeToSetup.KeySet()]);
            //check if record type exist
            if( mapIdToRecordType.size()  > 0 ){
                //loop in cases
                for(Integer i=0;i<listNewTrigger.size();i++ ){
                    Case caseRecord = listNewTrigger[i];
                    if(mapIdToRecordType.get(caseRecord.RecordTypeId) !=  null && mapRecordTypeToSetup.get(String.ValueOF(mapIdToRecordType.get(caseRecord.RecordTypeId).DeveloperName)) != null){
                        setupList = mapRecordTypeToSetup.get(String.ValueOF(mapIdToRecordType.get(caseRecord.RecordTypeId).DeveloperName));
                        
                        
                        for(Flag_target_date__c setupRow : setupList)
                        {   //system.debug('>>>>>>>>>>>#### '+setupRow);
                            if(setupRow.Critical_field__c != null &&
                                caseRecord.get(setupRow.Critical_field__c) != null &&
                                caseRecord.get(setupRow.Critical_field__c) == setupRow.Critical_value__c ){
                                //targetDate = system.now().addHours(Integer.ValueOf(setupRow.Number_of_hours__c)).date();
                                
                                if(caseRecord.BusinessHoursId!=null){
                                    bh = caseRecord.BusinessHoursId;
                                } else {
                                    bh = defaultHours.Id;
                                }

                                System.debug(caseRecord);
                                System.debug(setupRow);

                                if(setupRow.Record_type__c.contains('GI_FormalComplaint') || setupRow.Record_type__c.contains('GI_Complaint') || setupRow.Record_type__c.contains('GI_Closed_Complaint')) {
                                    if(setupRow.Is_Calendar_Hours__c == true) {
                                        if(caseRecord.CCRU_Receipt_Date__c != null) {
                                            calDueDateTime = caseRecord.CCRU_Receipt_Date__c.addDays(Integer.valueOf(Math.ceil(setupRow.Number_of_hours__c / Decimal.valueOf(System.Label.DailyHoursOfWork))));                                            
                                        } else {
                                            calDueDateTime = System.now().addDays(Integer.valueOf(Math.ceil(setupRow.Number_of_hours__c / Decimal.valueOf(System.Label.DailyHoursOfWork))));
                                        }
                                    } else {
                                        if(caseRecord.CCRU_Receipt_Date__c != null) {
                                            calDueDateTime = BusinessHours.add(bh, caseRecord.CCRU_Receipt_Date__c, integer.valueOf(setupRow.Number_of_hours__c)*60 * 60 * 1000L);                                                                                        
                                        } else {
                                            calDueDateTime = BusinessHours.add(bh, System.now(), integer.valueOf(setupRow.Number_of_hours__c) * 60 * 60 * 1000L);
                                        }
                                    }
                                    calDueDateTime = DateTime.newInstance(calDueDateTime.year(), calDueDateTime.month(), calDueDateTime.day(), 23, 59, 59);
                                } else {
                                    calDueDateTime = BusinessHours.add(bh,system.now() ,integer.valueOf(setupRow.Number_of_hours__c)*60 * 60 * 1000L);                                    
                                }
                                
                                //set field
                                caseRecord.put( setupRow.Update_field__c , calDueDateTime);
                               // system.debug('>>>>>>>>>>>#### '+calDueDateTime);
                            }//end check rule
                        }
                    }//end of check recordtype of case
                }//end of loop in cases
            }//end of check if record type exist
        }//end of check for setup not null
    }//end of method setTargetDateOfFlagDisplay
}//end of class