public with sharing class ICF_EditSurveyRulesComponentCtrl  {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_EditSurveyRulesComponentCtrl
-- - Author        : aazafrar 
-- - Description   : Class Controller for ICF_EditSurveyRulesComponent
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 24-08-2015   AA    1.0     Initial version
--------------------------------------------------------------------------------------
*/ 
    public string recordId {get; set;}
    public string recordType {get; set;} 
    public static string pageModel {get; set;}
    public static string typeAction {get; set;}
    public static string typeObject {get; set;}    
    public static string processExclusion {get{ return ICF_AP_Constant.PROCESS_STATUS_Exclusion.toLowerCase(); }set;}
    public static string processEligibility {get{ return ICF_AP_Constant.PROCESS_STATUS_Eligibility.toLowerCase(); }set;}
    public string firstValSobject {get; set;}
    public List<SelectOption> opList {get; set;}
  
    public List<SelectOption> ListProcess {
        get {
            return ICF_EditSurveyRulesVFPageCtrl.getProcessList();
        }       
    }
    
    public List<SelectOption> ListMrSObj {
        get {           
            return ICF_EditSurveyRulesVFPageCtrl.getMrSObjList();
        }
    }
    //**
    //* Return the list of recordTypes according to the selected sObject in action edit  
    //*    
    public PageReference setRTSelectList() {
                         
            opList = new List<SelectOption>();
            opList.add(new SelectOption('','--None--'));
            
            if(typeObject == null && typeAction == null) {
                typeObject = firstValSobject;
            }  
            if(typeObject != null) {
                for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType Where SobjectType = :typeObject]) { 
                    opList.add(new SelectOption(rt.DeveloperName, rt.DeveloperName));
                }               
            }        
        return null;
    }
    
    public ApexPages.StandardController MasterRuleCtrl {get; set;}
    public ICF_MasterRules__c  MasterRule {
        get {
            if(recordType != null && recordType.equals('RuleSetsObj')) {
                MasterRule = [Select Id, Process__c, Description__c, Active__c, RuleSet__c
                                From ICF_MasterRules__c Where Id = :recordId limit 1];
            }
            //System.Debug('####AA - recordType:'+recordType + '-' + recordId);
            if(recordType != null && recordId != null && recordType.equals('MasterRuleSobj')) {
                MasterRule = [Select Id, Process__c, Description__c, Active__c, RuleSet__c, sObject__c, ConditionLogic__c,ObjectReference__c,
                             Select__c, version__c From ICF_MasterRules__c Where Id = :recordId limit 1];
            }
            MasterRuleCtrl = new ApexPages.StandardController(MasterRule);
            return MasterRule;
        } 
        set;
    }
    
    public ApexPages.StandardController CriteriaCtrl {get; set;}
    public ICF_DetailRule__c  Criteria {
        get {
            if(recordType != null && recordType.equals('CriteriaSobj')) {
                Criteria = [Select Id, Process__c, MasterRule__c, sObject__c, Description__c, fields__c, value__c, operator__c, Select__c
                              From ICF_DetailRule__c Where Id = :recordId limit 1];
            }
            CriteriaCtrl = new ApexPages.StandardController(Criteria);
            return Criteria;
        } 
        set;
    }
    
    public ApexPages.StandardController ActionCtrl {get; set;}
    public ICF_Action__c  Action {
        get {
            
            if(recordType != null && recordType.equals('ActionSobj')) {
                Action = [Select Id, Name, MasterRule__c, sObject__c, Type__c, message__c, fieldSet__c, RTDevName__c
                              From ICF_Action__c Where Id = :recordId limit 1];
                
                //first load of RT Developer Name list
                if(opList == null) {
                    opList = new List<SelectOption>();
                    opList.add(new SelectOption('','--None--')); 
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType Where SobjectType = :Action.sObject__c]) { 
                        opList.add(new SelectOption(rt.DeveloperName, rt.DeveloperName));
                    }
                }               
            }
            ActionCtrl = new ApexPages.StandardController(Action);
            return Action;
        } 
        set;
    }
        
    public ApexPages.StandardController FieldSetCtrl {get; set;}
    public ICF_Field_Set__c  FieldSet {
        get {
            if(recordType != null && recordType.equals('FieldSetSobj')) {
                FieldSet = [Select Id, Name, sObject__c From ICF_Field_Set__c Where Id = :recordId limit 1];
            }
            FieldSetCtrl = new ApexPages.StandardController(FieldSet);
            return FieldSet;
        } 
        set;
    }
    
    public ApexPages.StandardController FieldTemplateCtrl {get; set;}
    public ICF_FieldTemplate__c  FieldTemplate {
        get {
            if(recordType != null && recordType.equals('FieldTemplateSobj')) {
                FieldTemplate = [Select Id, Name, value__c, fieldSet__c, dynamic__c From ICF_FieldTemplate__c Where Id = :recordId limit 1];
            }
            FieldTemplateCtrl = new ApexPages.StandardController(FieldTemplate);
            return FieldTemplate;
        } 
        set;
    }   
    
    public ICF_EditSurveyRulesComponentCtrl() {
        
    }
        
    public void updateMasterRule() {            
        try {
            MasterRuleCtrl.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    
    public void updateCriteria() {              
        try {
            CriteriaCtrl.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    
    public void updateAction() {            
        try {
            ActionCtrl.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    
    public void updateFieldSet() {              
        try {
            FieldSetCtrl.save();
        } catch(DMLException e) { 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    
    public void updateFieldTemplate() {             
        try {
            FieldTemplateCtrl.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }    
    
}