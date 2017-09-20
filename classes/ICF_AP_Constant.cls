public with sharing class ICF_AP_Constant {
/*
// ICF_AP_Constant
----------------------------------------------------------------------
-- - Name          : ICF_AP_Constant
-- - Author        : aazafrar
-- - Description   : Class for keeping all common constant variables 
--                 : and common methods                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 08-SEPTEMBER-2015  AA   1.0      Initial version
---------------------------------------------------------------------
**********************************************************************
*/

/***********************************************************************
* get profile id method 
************************************************************************/
    public static id getProfileAdminId(){
        return ([Select Id From Profile 
                Where name = 'Administrateur système' 
                    OR name = 'System Administrator'
                    OR name = 'Amministratore del sistema'
                    OR name = 'Systemadministrator'
                    OR name = 'Systemadministratör'
                    OR name = 'Administrador do sistema'
                    OR name = 'Systeembeheerder'
                    OR name = 'Systemadministrator'].Id);
    }
    
/***********************************************************************
* Case
************************************************************************/

    //picklist Complainant
    public static string caseComplainantInt = 'Intermediary';
    //picklist Status
    public static string caseStatusPendingStaff = 'Pending Staff';
    //field SLA
    public static integer caseSLASevenDays = 7;
    public static integer caseSLAFourteenDays= 14;
    
/***********************************************************************
* Account constants
************************************************************************/  
    /*sobject*/
        public static string sobjectAcc = 'Account';
        
    /*key prefix*/
        public static string AccKeyPrefix = Schema.SObjectType.Account.getKeyPrefix();

    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtAccIndividualClient = 'Client';
        public static string rtAccEmployee = 'Employee';
        public static string rtAccPersonAccount = 'PersonAccount';
        public static string rtAccCorporateClient = 'Business_Account';
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/

    /*Champ Generique: Champ à valeur unique <ObjetAbb><FieldName><Value> */    
     

/***********************************************************************
* Contact constants
************************************************************************/  
    /*sobject*/ 
        public static string sobjectCon = Schema.sObjectType.Contact.getName(); 
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/ 
        public static string contactPreferredChannelEmail = 'Email';
        public static string contactPreferredChannelSMS = 'SMS';
/***********************************************************************
* Survey Constant
************************************************************************/
    public static final String STATUS_ARCHIVED = System.Label.LABS_SF_Status_Archived;
    public static final String STATUS_DRAFT = System.Label.LABS_SF_Status_Draft;
    public static final String STATUS_CLOSED = System.Label.LABS_SF_Status_Closed;
    public static final String STATUS_Active = 'Active';
    public static final String DEFAULT_LANGUAGE = 'en_US';
    // Name of the general configuration CS
    public static final String SURVEY_CONFIGURATION_EMAIL = 'SURVEY_CONFIGURATION_EMAIL';
    public static final String SURVEY_CONFIGURATION_SMS = 'SURVEY_CONFIGURATION_SMS';
    public static final String SURVEY_DELIVERY_CHANNEL_EMAIL = 'Email';
    public static final String SURVEY_DELIVERY_CHANNEL_SMS = 'SMS';
    //TCF_Feb172017: Added new logic
    public static final String SURVEY_CONFIGURATION_EKOMI = 'SURVEY_CONFIGURATION_EKOMI';
    public static final String SURVEY_DELIVERY_CHANNEL_CONTACT_BASED = 'Based on Contact/PersonAccount preferred contact method';
    // New survey question types values
    public static final String QTYPE_MATRIX_MULTI_SELECT = 'Matrix -- Multi-Select';
    public static final String QTYPE_MATRIX_SINGLE_SELECT = 'Matrix -- Single-Select';

/***********************************************************************
* Master Rule Constant
************************************************************************/
    /*sobject*/ 
        public static string sobjectMasterRule = Schema.sObjectType.ICF_MasterRules__c.getName();   
    /*Record Type */
        public static string rtMasterRuleMasterRule = 'MASTERRULE'; 
        public static string rtMasterRuleRuleSet = 'RULESET';   
        
    public static final String PROCESS_STATUS_Eligibility = 'Eligibility';
    public static final String PROCESS_STATUS_Exclusion = 'Exclusion';


    
    public static final Map <String,String> mapOperatorMapping = new Map<String,String>{'EQUALS'         => '=',
                                                                            'NOT_EQUALS'     => '!=',
                                                                            'GREATER'        => '>',
                                                                            'GREATER_EQUALS' => '>=',
                                                                            'LESS'           => '<',
                                                                            'LESS_EQUALS'    => '<=',
                                                                            'IN'             => 'IN' ,
                                                                            'CONTAINS'       => 'LIKE',
                                                                            'NOT_IN'       => 'NOT IN'
                                                                        };   

        
/***********************************************************************
* Task constants
************************************************************************/  
    /*sobject*/
    public static final String TaskStatusInProgress = 'ICF_Targetted';
    public static final String TaskStatusFailedEmail = 'ICF_Failed';
    public static final String TaskStatusFailedLimitReach = 'ICF_Failed_Limit_Reach';
    public static final String TaskStatusCompleted = 'ICF_Taken';
    public static final String TaskStatusSent = 'ICF_Sent';
    public static final String TaskStatusExpired = 'ICF_Expired';
    public static final String TaskStatusRemind = 'ICF_ToRemind';
    public static final String TaskStatusRemindSendFail = 'ICF_Reminder_Sending_Failed';
    public static final String TaskStatusRemindFailLimit = 'ICF_Reminder_Failed_Limit_Reached';
                                                                            
/***********************************************************************
* Global Function
************************************************************************/

    /*method to map corresponding record Type developper name to its respective record Type id*/
    public static map<String,Id> getDeveloperIdMap(String ObjecType){
    /*
     * Version : 1.0
     * Description : Generate a map that contains developer Name and id for a specific Sobject Type
     */     
        map <String,Id> developerIdMap = new map <String,Id>();
    
        //populating developerIdMap
        for(RecordType r : [select DeveloperName,Id
                                        from RecordType
                                        where SobjectType =: ObjecType ]){
            developerIdMap.put(r.DeveloperName,r.Id);
        }
        return developerIdMap;                  
    }
    
    /***********************************************************************
    * Methods for User creation 
    ************************************************************************/ 
    static Integer counter = 0 ;
    public static String getUniqueUserName(){
        //adding an incremental counter because when inserting multiple users the getTime() method can return same value for 2 user record  
        counter++ ;        
        return UserInfo.getOrganizationId() + System.now().getTime() + counter + 'standarduser@testorg.com';
    }

    public static User createAdminUser(){
        return new User(
            Alias = 'sysadm',
            Email = 'systemadmin@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Testing',
            LocaleSidKey = 'en_US',
            ProfileId = getProfileAdminId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = getUniqueUserName(),
            ICF_ByPassVR__c = true
        );
    }
    
    /*****************************************************************
    *               CRITERIA STATIC VALUES
    ******************************************************************/ 
    public static string SOBJECT_CRITERIA = 'ICF_DetailRule__c';
    public static final String CRITERIA_RT_DeveloperName_CRITERIA = 'CRITERIA';
    
    /*****************************************************************
    *               MASTER RULE STATIC VALUES
    ******************************************************************/ 
    public static string SOBJECT_MASTER_RULE = 'ICF_MasterRules__c';
    
    public static final String MASTERRULE_SOBJECTS_FOR_PROCESS_EVENT = 'Account;Contact';
    public static final Integer MASTERRULE_MAX_CRITERIA_FOR_PROCESS_EVENT = 80;
    
    public static final String MASTER_RULE_RT_DeveloperName_RULESET = 'RULESET';
    public static final String MASTER_RULE_RT_DeveloperName_MASTERRULE = 'MASTERRULE'; 

    public static final String MASTER_RULE_STATUS_ACTIVE = 'ACTIVE';
    public static final String MASTER_RULE_STATUS_ARCHIVED = 'ARCHIVED';
    
    /*****************************************************************
    *               PROCESS STATIC VALUES
    ******************************************************************/
    public static final String PROCESS_ELIGIBILITY  = 'ELIGIBILITY';
    public static final String PROCESS_EVENT        = 'EVENT';
    public static final String PROCESS_EXCLUSION  = 'EXCLUSION';
    
    /*****************************************************************
    *               TCF_Feb282017: Added new logic
    ******************************************************************/
    public static final Map <String,Integer> mapRatingAndInteger = new Map<String,Integer>{'Completely Dissatisfied'     => 1,
                                                                            'Quite Dissatisfied'        => 2,
                                                                            'Neither Satisfied nor Dissatisfied' => 3,
                                                                            'Quite Satisfied'           => 4,
                                                                            'Completely Satisfied'    => 5
                                                                        };
                                                                        
	/*****************************************************************
    *          TCF_Feb282017: REPROCESSING BATCH STATIC VALUES
    ******************************************************************/
    public static final String SENDTOEKOMI_RATING    = 'Rating';
    public static final String SENDTOEKOMI_REVIEW    = 'Review';
    public static final String EKOMI_SUCCESS_STATUS  = 'Success';
}