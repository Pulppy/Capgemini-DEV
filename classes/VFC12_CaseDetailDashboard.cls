public with sharing class VFC12_CaseDetailDashboard {
/*
// VFC12_CaseDetailDashboard
----------------------------------------------------------------------
-- - Name          : VFC12_CaseDetailDashboard
-- - Author        : MRA
-- - Description   : Controller for VFP12_CaseDetailDashboard
--
-- Maintenance History:
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 11-JUNE-2014  MRA    1.0      Intitial version 
-- 15-JUNE-2014  AAM    2.0     Evolutions to manage the display of SLA
----------------------------------------------------------------------
**********************************************************************
*/  
    public Case c{get;set;} 
    public string countdown{get;set;}
    
    public String recordTypeName { get; set; }
    public String recordTypeCode { get; set; }
    
    public VFC12_CaseDetailDashboard(ApexPages.StandardController controller){
        this.c=(Case)controller.getRecord();
        
  
        Case ca = [select accountid, TAT_Due_Date__c, isClosed, Overdue_Age__c,
                            Status,ClosedDate, RecordType.Name, RecordType.DeveloperName
                             from case where id =: c.id];
        
        recordTypeName = ca.RecordType.Name;
        recordTypeCode = ca.RecordType.DeveloperName;
        
        if(ca.TAT_Due_Date__c <> null){
            if(ca.isClosed){
                DateTime processedDate = ca.ClosedDate;
                countdown = describeTime(ca.TAT_Due_Date__c.getTime() - processedDate.getTime());
            }
            else
                countdown = describeTime(ca.TAT_Due_Date__c.getTime() - system.now().getTime());
        } 
            
    }
    
    //to go in milliseconds
    public static String describeTime(long toGo){
        
        string described = '';
        long absToGo = math.abs(toGo);
        if(absToGo > 86400000*2)
            described = absToGo/86400000 + ' days';
        else if(absToGo> 3600000*2)
            described = absToGo/3600000 + ' hours';
        else if(absToGo > 60000*2)
            described = absToGo/60000 + ' minutes';
        else if(absToGo <= 60000*2 && absToGo > 0)
            described = '<1 minute';
        else
            return 'imminent';
            
        if(toGo < 0)
            return described + ' overdue';
        else
            return described;
    }

}