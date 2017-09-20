public with sharing class ICF_EditSurveyRulesVFPageCtrl {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ICF_EditSurveyRulesVFPageCtrl
-- - Author        : aazafrar 
-- - Description   : Class Controller for ICF_EditSurveyRulesVFPage
--
-- Maintenance History:  
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 18-08-2015   AA    1.0     Initial version
-- 28-01-2016   HDU   1.1     Add field ObjectReference__c in master rule
--------------------------------------------------------------------------------------
*/ 
    
    //Region Wrapper Classes
    public class RuleSetWrapper {
        public Id id {get; set;}
        public String name {get; set;}
        public String process {get; set;}
        public String description {get; set;}
        public boolean active {get; set;}        
    }
    public class MasterRuleWrapper {
        public Id id {get; set;}
        public String name {get; set;}
        public String process {get; set;}
        public String sObj {get; set;}
        public String cLogic {get; set;}
        public String description {get; set;}
        public string relationship {get; set;}
        public String ruleSet {get; set;}
        public boolean active {get; set;}   
        public string objectSelect {get; set;}     
    }
    public class CriteriaWrapper {
        public Id id {get; set;}
        public String name {get; set;}
        public String process {get; set;}
        public String sObj {get; set;}
        public String relationship {get; set;}                
        public decimal num {get; set;}
        public String field {get; set;}
        public String value {get; set;} 
        public String operator {get; set;}
        public String description {get; set;}    
        public String masterRule {get; set;} 
        public String MRInfo {get; set;} 
    }
    public class ActionWrapper {
        public Id id {get; set;}
        public String name {get; set;}
        public String type {get; set;}
        public String message {get; set;}        
        public String sObj {get; set;}
        public String fieldSet {get; set;}    
        public String masterRule {get; set;} 
        public String recordType {get; set;}          
    }
     public class FieldSetWrapper {
        public Id id {get; set;}
        public String name {get; set;}       
        public String sObj {get; set;}          
    }
    public class FieldTemplateWrapper {
        public Id id {get; set;}
        public String fieldName {get; set;}
        public String fieldValue {get; set;}
        public String fieldSet {get; set;}
        public String sObj {get; set;}
        public boolean dynamic {get; set;}        
    }
    
    
    //Region class variables
    list<ICF_MasterRules__c> listRuleSet;
    list<ICF_MasterRules__c> listMasterRule;
    list<ICF_DetailRule__c> listCriteria;
    list<ICF_Action__c> listAction;
    list<ICF_Field_Set__c> listFieldSet;
    list<ICF_FieldTemplate__c> listFieldTemplate;
    ICF_MasterRules__c ruleSetToDelete;
    ICF_MasterRules__c masterRuleToDelete;
    ICF_DetailRule__c criteriaToDelete;
    ICF_Action__c actionToDelete;
    ICF_Field_Set__c fieldSetToDelete;
    ICF_FieldTemplate__c fieldTemplateToDelete;
    public static set<string> listProcess; 
    public static set<string> listSobject; 
    public static string processExclusion {get{ return ICF_AP_Constant.PROCESS_STATUS_Exclusion.toLowerCase(); }set;}
    public static string processEligibility {get{ return ICF_AP_Constant.PROCESS_STATUS_Eligibility.toLowerCase(); }set;}
    
    //Region Properties accessible from VF Page
    public string surveyId {get; set;}  
    public static string pageModel {get; set;}        
    public Id ruleSetId {get; set;}
    public Id masterRuleId {get; set;}
    public Id criteriaId {get; set;}
    public Id actionId {get; set;}
    //public Id fieldSetId {get; set;}
    //public Id fieldTemplateId {get; set;}
    public Id recordToEdit {get; set;}
    public String recordTypeToEdit {get; set;}
    public String pageModelComp {get; set;}
    public Boolean isMREvent {get; set;}
    public string actionTypeObject {get; set;}
    
    public list<RuleSetWrapper> listRuleSetWrap {
        get {
            listRuleSetWrap = new list<RuleSetWrapper>();
            listRuleSet = new list<ICF_MasterRules__c>();
            for(ICF_MasterRules__c mr : [Select m.Id, m.Name, m.Active__c, m.Description__c, m.Process__c  From ICF_MasterRules__c m 
                                     Where /*m.Process__c = 'EVENT' And*/ m.Survey__c = :surveyId And m.RecordTypeId in 
                                     (Select Id From RecordType Where DeveloperName  = :ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_RULESET)
                                     Order by CreatedDate desc]) {
                    
                    RuleSetWrapper rsw = new RuleSetWrapper();
                    rsw.Id = mr.Id;
                    rsw.name = mr.Name;
                    rsw.active = mr.Active__c;
                    //rsw.process = mr.Process__c; 
                    rsw.description = mr.Description__c;    
                    listRuleSetWrap.add(rsw);
                    listRuleSet.add(mr);                        
            }
            return listRuleSetWrap; 
        }       
        set;
    }
    
    public list<MasterRuleWrapper> listMasterRuleWrap {
        get {
            listMasterRuleWrap = new list<MasterRuleWrapper>();
            listMasterRule = new list<ICF_MasterRules__c>();
            setlistProcessAndObjects();
                 
            for(ICF_MasterRules__c mr : [Select m.Id, m.Name, m.Active__c, m.Process__c, m.ObjectReference__c, m.RuleSet__r.Name, m.ConditionLogic__c, m.sObject__c, m.Select__c, m.Description__c 
                                        From ICF_MasterRules__c m 
                                     Where /*m.Process__c = 'EVENT' And*/ ruleSet__r.Survey__c = :surveyId And m.RecordTypeId in 
                                     (Select Id From RecordType Where DeveloperName  = :ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_MASTERRULE)
                                     And m.Process__c in :listProcess
                                     Order by CreatedDate desc]) {
                    
                    MasterRuleWrapper mrw = new MasterRuleWrapper();
                    mrw.Id = mr.Id;
                    mrw.name = mr.Name;
                    mrw.active = mr.Active__c;
                    mrw.process = mr.Process__c;
                    mrw.ruleSet = mr.RuleSet__r.Name;
                    mrw.cLogic = mr.ConditionLogic__c;
                    mrw.sObj = mr.sObject__c;
                    mrw.relationship = mr.Select__c;
                    mrw.description = mr.Description__c;    
                    mrw.objectSelect = mr.ObjectReference__c;   
                    listMasterRuleWrap.add(mrw);
                    listMasterRule.add(mr);                     
            }
            return listMasterRuleWrap; 
        }       
        set;
    }
    
    public list<CriteriaWrapper> listCriteriaWrap {
        get {
            listCriteriaWrap = new list<CriteriaWrapper>();
            listCriteria = new list<ICF_DetailRule__c>();
            setlistProcessAndObjects();
            
            for(ICF_DetailRule__c dr : [Select d.Id, d.Name, d.Number__c, d.Process__c, d.sObject__c, d.fields__c, d.Operator__c, d.Value__c, 
                                        d.MasterRule__r.Name, d.Select__c, d.MasterRule__r.Process__c, d.Description__c, 
                                        d.MasterRule__r.ConditionLogic__c, d.MasterRule__r.sObject__c 
                                        From ICF_DetailRule__c d
                                        Where  d.MasterRule__c in (select Id from ICF_MasterRules__c Where RuleSet__r.Survey__c = :surveyId)
                                        And d.MasterRule__r.Process__c in :listProcess
                                        Order by d.MasterRule__r.Name, d.Number__c asc]) {
                    
                    CriteriaWrapper drw = new CriteriaWrapper();
                    drw.Id = dr.Id;
                    drw.name = dr.Name;
                    drw.num = dr.Number__c;
                    drw.process = dr.MasterRule__r.Process__c;
                    drw.sObj = dr.sObject__c;
                    drw.relationship = dr.Select__c;
                    drw.field = dr.fields__c;
                    drw.value = dr.Value__c;
                    drw.operator = dr.Operator__c;
                    drw.description = dr.Description__c;
                    drw.masterRule = dr.MasterRule__r.Name.substringAfter('-');
                    drw.MRInfo = Schema.SObjectType.ICF_MasterRules__c.fields.Process__c.Label + ': ' + dr.MasterRule__r.Process__c +
                                 '\n' + Schema.SObjectType.ICF_MasterRules__c.fields.Sobject__c.Label + ': ' + dr.MasterRule__r.sObject__c +  
                                 '\n' + Schema.SObjectType.ICF_MasterRules__c.fields.ConditionLogic__c.Label + ': ' + dr.MasterRule__r.ConditionLogic__c;      
                    listCriteriaWrap.add(drw);
                    listCriteria.add(dr);                       
            }
            return listCriteriaWrap; 
        }       
        set;
    }
    
    public list<ActionWrapper> listActionWrap {
        get {
            listActionWrap = new list<ActionWrapper>();
            listAction = new list<ICF_Action__c>();
            for(ICF_Action__c ac : [Select a.Id, a.sObject__c, a.Type__c, a.RTDevName__c, a.Name, a.Message__c, a.MasterRule__c, a.FieldSet__r.Name, a.MasterRule__r.Name 
                                From ICF_Action__c a
                                Where a.MasterRule__c in (select Id from ICF_MasterRules__c Where RuleSet__r.Survey__c = :surveyId)
                                Order by a.MasterRule__r.Name, CreatedDate desc]) {
                    
                    ActionWrapper acw = new ActionWrapper();
                    acw.Id = ac.Id;
                    acw.name = ac.Name;
                    acw.type = ac.Type__c;
                    acw.message = ac.Message__c;
                    acw.sObj = ac.sObject__c;
                    acw.fieldSet = ac.FieldSet__r.Name;
                    acw.masterRule = ac.MasterRule__r.Name; 
                    acw.recordType = ac.RTDevName__c;   
                    listActionWrap.add(acw);
                    listAction.add(ac);                     
            }
            return listActionWrap; 
        }       
        set;
    }
    
    public list<FieldSetWrapper> listFieldSetWrap {
        get {
            listFieldSetWrap = new list<FieldSetWrapper>();
            listFieldSet = new list<ICF_Field_Set__c>();
            list<ICF_Field_Set__c> listFS = new list<ICF_Field_Set__c>();
            
            if(!String.IsBlank(Action.FieldSet__c)) {
                listFS = [Select f.Id, f.sObject__c, f.Name, f.CreatedDate From ICF_Field_Set__c f Where Id = :Action.FieldSet__c];
            } else {
                listFS = [Select f.Id, f.sObject__c, f.Name, f.CreatedDate From ICF_Field_Set__c f Order by CreatedDate desc];
            }
            
            for(ICF_Field_Set__c fs : listFS) {
                    
                    FieldSetWrapper fsw = new FieldSetWrapper();
                    fsw.Id = fs.Id;
                    fsw.name = fs.Name;
                    fsw.sObj = fs.sObject__c;   
                    listFieldSetWrap.add(fsw);
                    listFieldSet.add(fs);                       
            }
            return listFieldSetWrap; 
        }       
        set;
    }
    
    public list<FieldTemplateWrapper> listFieldTemplateWrap {
        get {
            listFieldTemplateWrap = new list<FieldTemplateWrapper>();
            listFieldTemplate = new list<ICF_FieldTemplate__c>();
            list<ICF_FieldTemplate__c> listFT = new list<ICF_FieldTemplate__c>();
            
            if(!String.IsBlank(Action.FieldSet__c)) {
                listFT = [Select f.Id, f.Name, f.Value__c, f.Dynamic__c , f.FieldSet__r.Name,  f.FieldSet__r.sObject__c
                            From ICF_FieldTemplate__c f Where f.FieldSet__c = : Action.FieldSet__c
                            Order by FieldSet__c];
            } else {
                listFT = [Select f.Id, f.Name, f.Value__c, f.Dynamic__c , f.FieldSet__r.Name,  f.FieldSet__r.sObject__c
                            From ICF_FieldTemplate__c f
                            Order by FieldSet__c];
            }
            
            for(ICF_FieldTemplate__c ft : listFT) {
                    
                    FieldTemplateWrapper ftw = new FieldTemplateWrapper();
                    ftw.Id = ft.Id;
                    ftw.fieldName = ft.Name;
                    ftw.fieldValue = ft.Value__c;   
                    ftw.dynamic = ft.Dynamic__c;
                    ftw.fieldSet = ft.FieldSet__r.Name;
                    ftw.sObj = ft.FieldSet__r.sObject__c;
                    listFieldTemplateWrap.add(ftw);
                    listFieldTemplate.add(ft);                      
            }
            return listFieldTemplateWrap; 
        }       
        set;
    }
    
    //Region Standard Controllers declaration
    public ApexPages.StandardController MasterRuleCtrl {get; set;}
    public ICF_MasterRules__c MasterRule {get; set;}
    public ApexPages.StandardController CriteriaController {get; set;}  
    public ICF_DetailRule__c Criteria {get; set;}   
    public ApexPages.StandardController ActionController {get; set;}    
    public ICF_Action__c Action {get; set;}
    public ApexPages.StandardController FieldSetController {get; set;}  
    public ICF_Field_Set__c FieldSet {get; set;}
    public ApexPages.StandardController FieldTemplateController {get; set;} 
    public ICF_FieldTemplate__c FieldTemplate {get; set;}
    
    //Region Constructor
    public ICF_EditSurveyRulesVFPageCtrl (ApexPages.Standardcontroller stdCtrl) {
        MasterRuleCtrl = stdCtrl;   
        init();
    }   
    //public ICF_EditSurveyRulesVFPageCtrl () {     
    //}
    
    public void init() {        
        surveyId = Apexpages.currentPage().getParameters().get('surveyId');        
        MasterRule = (ICF_MasterRules__c) MasterRuleCtrl.getRecord();   
        Criteria = new ICF_DetailRule__c();
        CriteriaController = new ApexPages.StandardController(Criteria);
        Action = new ICF_Action__c(); 
        ActionController = new ApexPages.StandardController(Action);
        FieldSet = new ICF_Field_Set__c();
        FieldSetController = new ApexPages.StandardController(FieldSet);
        FieldTemplate = new ICF_FieldTemplate__c();
        FieldTemplateController = new ApexPages.StandardController(FieldTemplate);
        if(Apexpages.currentPage().getParameters().get('pageModel') == 'EVENT')
            isMREvent = true;
        
        setlistProcessAndObjects();                    
    }
    
    static void setlistProcessAndObjects() {
        pageModel = Apexpages.currentPage().getParameters().get('pageModel');
        listProcess = new set<string>();
        listSobject = new set<string>();
        if(pageModel.equals('EVENT')) {
            listProcess.add(ICF_AP_Constant.PROCESS_EVENT);
            if(string.IsNotBlank(ICF_AP_Constant.MASTERRULE_SOBJECTS_FOR_PROCESS_EVENT)) {
                for(string sobj : ICF_AP_Constant.MASTERRULE_SOBJECTS_FOR_PROCESS_EVENT.split(';')) {
                    listSobject.add(sobj);
                }
            }
        } else {
            listProcess.add(ICF_AP_Constant.PROCESS_ELIGIBILITY);
            listProcess.add(ICF_AP_Constant.PROCESS_EXCLUSION);
        }
    }
    
    //Rule Set Methods  
    public PageReference editRuleSet() {        
        MasterRule.RecordTypeId = [Select Id From RecordType Where DeveloperName  = :ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_RULESET].Id;
        MasterRule.Survey__c = surveyId;
        MasterRuleCtrl = new ApexPages.StandardController(MasterRule);      
        try {
            MasterRuleCtrl.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } 
        return null;
    }
    public PageReference deleteRuleSet() {       
        try {
            for(integer i=0; i<listRuleSet.size();i++) {
                if(listRuleSet.get(i).Id == ruleSetId) {
                    ruleSetToDelete = listRuleSet.get(i);
                    break;
                }
            }
            delete ruleSetToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }        
        return null;
    }
    
    //Master Rule Methods
    public PageReference editMasterRule() {     
        MasterRule.RecordTypeId = [Select Id From RecordType Where DeveloperName  = :ICF_AP_Constant.MASTER_RULE_RT_DeveloperName_MASTERRULE].Id;
        MasterRule.Survey__c = surveyId;
        MasterRuleCtrl = new ApexPages.StandardController(MasterRule); 
        try {           
            MasterRuleCtrl.save();           
            
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }       
        return null;
    }
    public PageReference deleteMasterRule() {        
        try {
            for(integer i=0; i<listMasterRule.size();i++) {
                if(listMasterRule.get(i).Id == masterRuleId) {
                    masterRuleToDelete = listMasterRule.get(i);
                    break;
                }
            }
            delete masterRuleToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }       
        return null;
    }
    
    //Criteria Methods
    public PageReference editCriteria() {       
        CriteriaController = new ApexPages.StandardController(Criteria);
        try {           
            CriteriaController.save(); 
            
            integer NumberOfCriteria = listCriteriaWrap.IsEmpty() ? 0 : listCriteriaWrap.size();
            if(NumberOfCriteria > (ICF_AP_Constant.MASTERRULE_MAX_CRITERIA_FOR_PROCESS_EVENT-10) && listCriteriaWrap[0].process.equals('EVENT')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.LABS_SF_MASTERRULE_MAX_CRITERIA + ' ' + string.ValueOf(ICF_AP_Constant.MASTERRULE_MAX_CRITERIA_FOR_PROCESS_EVENT)));
            }  
                          
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }       
        return null;
    }
    public PageReference deleteCriteria() {      
        try {
            for(integer i=0; i<listCriteria.size();i++) {
                if(listCriteria.get(i).Id == criteriaId) {
                    criteriaToDelete = listCriteria.get(i);
                    break;
                }
            }
            delete criteriaToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        } 
        return null;
    }
    
    //Action Methods
    public PageReference editAction() {     
        ActionController = new ApexPages.StandardController(Action);        
        try {            
             ActionController.save();        
                
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } 
        return null;
    }
    public PageReference deleteAction() {        
        try {
            for(integer i=0; i<listAction.size();i++) {
                if(listAction.get(i).Id == actionId) {
                    actionToDelete = listAction.get(i);
                    break;
                }
            }
            delete actionToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        } 
        return null;
    }
    
    //Field Set Methods
    /*public PageReference editFieldSet() {     
        FieldSetController = new ApexPages.StandardController(FieldSet);  
        try {
            FieldSetController.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }       
        return null;
    }
    public PageReference deleteFieldSet() {      
        try {
            for(integer i=0; i<listFieldSet.size();i++) {
                if(listFieldSet.get(i).Id == fieldSetId) {
                    fieldSetToDelete = listFieldSet.get(i);
                    break;
                }
            }
            delete fieldSetToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        } 
        return null;
    }*/
    
    //Field Template Methods
    /*public PageReference editFieldTemplate() {        
        FieldTemplateController = new ApexPages.StandardController(FieldTemplate);  
        try {
            FieldTemplateController.save();
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }       
        return null;
    }
    public PageReference deleteFieldTemplate() {         
        try {
            for(integer i=0; i<listFieldTemplate.size();i++) {
                if(listFieldTemplate.get(i).Id == fieldTemplateId) {
                    fieldTemplateToDelete = listFieldTemplate.get(i);
                    break;
                }
            }
            delete fieldTemplateToDelete;
            recordTypeToEdit = null;
        } catch(DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        return null;
    }*/
     
    //**
    //* Return the list of recordTypes of the selected sObject in action edit  
    //*
    public List<SelectOption> getRtList() { 
        System.Debug('####AA - getRtList -');
        List<SelectOption> opList = new List<SelectOption>();         
        if(Action.Type__c != null && Action.Type__c.equals('Record')) {
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType Where SobjectType = :Action.sObject__c]) { 
                opList.add(new SelectOption(rt.DeveloperName, rt.DeveloperName));
            }
            System.Debug('####AA - getRtList opList:'+opList);
        } else {
            Action.sObject__c = '';
        }      
        return opList;
    }
    
    public static List<SelectOption> getProcessList() {
        setlistProcessAndObjects();
        List<SelectOption> opList = new List<SelectOption>();
        if(!pageModel.equals('EVENT')) {
            opList.add(new SelectOption('', '--None--'));
        }       
        return ICF_AP_Utility.filterPckList(ICF_MasterRules__c.Process__c, listProcess, new set<string>{}, opList);     
    }
    
    public static List<SelectOption> getMrSObjList() {
        setlistProcessAndObjects();
        List<SelectOption> opList = new List<SelectOption>();
        opList.add(new SelectOption('', '--None--'));       
        return ICF_AP_Utility.filterPckList(ICF_MasterRules__c.Sobject__c, listSobject, new set<string>{}, opList);     
    }
        
}