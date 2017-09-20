/**************************************************************************************
Apex Class Name - ICF_PrepareSurveyDeliveryBatch_TEST
*************************************************************************************/
@isTest
private class ICF_PrepareSurveyDeliveryBatch_TEST {
    
    static User userAdmin = ICF_AP_Constant.createAdminUser();
    static String sObjAcount,sObjContact;
    static String processStatusEligibility;
    static String processStatusExclusion;
    static String rtMasterRuleId,rtRuleSetId;
    static list<Account> listAccounts;
    static list<Contact> listContacts;
    static list<Case> listCases;
    static list<ICF_Survey_Task_Mapping__c> listSetting;
    static list<ICF_Survey__c> listSurveys;
    static list<ICF_MasterRules__c> listMasterRules;    
    static list<ICF_MasterRules__c> listRuleSets;
    static list<ICF_DetailRule__c> listDetailsRules;

    //instatiate all variable
    static{
         SharingManagement__c MySMAccount = new SharingManagement__c();
        MySMAccount.Name = 'Account';
        MySMAccount.Sharing_Field__c = 'OwnerId';
        insert MySMAccount;
        
        SharingManagement__c MySMLead = new SharingManagement__c();
        MySMLead.Name = 'Lead';
        MySMLead.Sharing_Field__c = 'OwnerId';
        insert MySMLead;
        System.runAs( userAdmin ){          
            sObjAcount = ICF_AP_Constant.sobjectAcc;
            sObjContact = ICF_AP_Constant.sobjectCon;
            processStatusEligibility = ICF_AP_Constant.PROCESS_STATUS_Eligibility;
            processStatusExclusion = ICF_AP_Constant.PROCESS_STATUS_Exclusion;
            rtMasterRuleId = ICF_AP_Constant.getDeveloperIdMap( ICF_AP_Constant.sobjectMasterRule ).get( ICF_AP_Constant.rtMasterRuleMasterRule ) ;
            rtRuleSetId = ICF_AP_Constant.getDeveloperIdMap( ICF_AP_Constant.sobjectMasterRule ).get( ICF_AP_Constant.rtMasterRuleRuleSet ) ;

            listSetting = new list<ICF_Survey_Task_Mapping__c>{
                /*new ICF_Survey_Task_Mapping__c(
                    name = 'ActivityDate',
                    ICF_Value__c = 'Today'
                ),*/
                new ICF_Survey_Task_Mapping__c(
                    name = 'Subject',
                    ICF_Value__c = 'Survey issue'
                ),
               /* new ICF_Survey_Task_Mapping__c(
                    name = 'Type__c',
                    ICF_Value__c = 'Other'
                ),*/  
                new ICF_Survey_Task_Mapping__c(
                    name = 'ActivityDate',
                    ICF_Value__c = 'now;1'
                ),
                new ICF_Survey_Task_Mapping__c(
                    name = 'CallDurationInSeconds',
                    ICF_Value__c = '4'
                )
            };
            insert listSetting;

            listAccounts = new list<Account>{
                new Account(
                    Name = 'x1',
                    Gender__c = 'F'
                ),
                new Account(
                    Name = 'x2',
                    Gender__c = 'M'
                )
            };
            insert listAccounts;

            listContacts = new list<Contact>{
                new Contact(
                    lastname = 'xxx',
                    Title = 'x',
                    Department = 'x',
                    accountid = listAccounts[1].id
                ),

                new Contact(
                    lastname = 'x1',
                    Title = 'x1',
                    Department = 'x'
                )
            };
            insert listContacts;


            listCases = new list<Case>{
                new Case(
                    Contactid = listContacts[0].id
                )
            };
            insert listCases;
            System.debug('>>>## listCases:'+listCases);

            listSurveys = new list<ICF_Survey__c>{
                new ICF_Survey__c(
                    name ='S1',
                    Submit_Response__c = 'as',
                    URL__c = 'ul1',
                    Survey_Status__c = ICF_AP_Constant.STATUS_Active,
                    Expiration_Date__c = System.now().addDays(10).date()
                ),
                new ICF_Survey__c(
                    name ='S2',
                    Submit_Response__c = 'as',
                    Survey_Status__c = 'Active',
                    URL__c = 'ul1',
                    Expiration_Date__c = System.now().addDays(1).date()
                )
            }; 
            insert listSurveys;

            listRuleSets = new list<ICF_MasterRules__c>{
                new ICF_MasterRules__c(
                    Active__c = true,
                    Survey__c = listSurveys[0].Id,
                    RecordTypeId = rtRuleSetId
                ),
                new ICF_MasterRules__c(
                    Active__c = true,
                    Survey__c = listSurveys[1].Id,
                    RecordTypeId = rtRuleSetId
                )
            };
            insert listRuleSets;
            
            listMasterRules = new list<ICF_MasterRules__c>{
                new ICF_MasterRules__c(
                    RuleSet__c = listRuleSets[0].id,
                    Active__c = true,
                    ConditionLogic__c = '(1 OR 2)',
                    Process__c = processStatusEligibility,
                    sObject__c = sObjContact,
                    Select__c = 'Id',
                    RecordTypeId = rtMasterRuleId
                ),
                new ICF_MasterRules__c(
                    RuleSet__c = listRuleSets[0].id,
                    Active__c = true,
                    ConditionLogic__c = '',
                    Process__c = processStatusExclusion,
                    ObjectReference__c = 'Id',
                    sObject__c = sObjAcount,
                    Select__c= 'Id',
                    RecordTypeId = rtMasterRuleId
                ),
                new ICF_MasterRules__c(
                    RuleSet__c = listRuleSets[1].id,
                    Active__c = true,
                    ConditionLogic__c = '',
                    Process__c = processStatusEligibility,
                    sObject__c = 'Case',
                    Select__c= 'Contact.id',
                    RecordTypeId = rtMasterRuleId
                ),
                new ICF_MasterRules__c(
                    RuleSet__c = listRuleSets[1].id,
                    Active__c = true,
                    ConditionLogic__c = '',
                    Process__c = processStatusEligibility,
                    Select__c= 'Id',
                    sObject__c = 'Contact',
                    RecordTypeId = rtMasterRuleId
                ),
                new ICF_MasterRules__c(
                    RuleSet__c = listRuleSets[1].id,
                    Active__c = true,
                    ConditionLogic__c = '',
                    Process__c = processStatusEligibility,
                    sObject__c = 'Case',
                    Select__c= 'Contactid',
                    RecordTypeId = rtMasterRuleId
                )
            }; 
            insert listMasterRules;

            listDetailsRules = new list<ICF_DetailRule__c>{
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[0].id,
                    fields__c = 'Title',
                    Operator__c = 'CONTAINS',
                    sObject__c = 'Contact',
                    Value__c = '\'%x%\''
                ),
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[0].id,
                    fields__c = 'Department',
                    sObject__c = 'Contact',
                    Operator__c = 'EQUALS',
                    Value__c = '\'x\''
                ),
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[1].id,
                    fields__c = 'Gender__c',
                    sObject__c = 'Account',
                    Operator__c = 'EQUALS',
                    Value__c = '1'
                ),
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[2].id,
                    fields__c = 'CaseNumber',
                    sObject__c = 'Case',
                    Operator__c = 'EQUALS',
                    Value__c = '\'x1\''
                ),
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[3].id,
                    fields__c = 'Title',
                    sObject__c = 'Contact',
                    Value__c = '\'x1\''
                ),
                new ICF_DetailRule__c(
                    MasterRule__c =listMasterRules[4].id,
                    fields__c = 'CaseNumber',
                    Operator__c = 'EQUALS',
                    sObject__c = 'Case',
                    Value__c = '\'x1\''
                )
            }; 
            insert listDetailsRules;



        }//end of run as
    }//end of static
    
    @isTest 
    static void testScheduleBatch() {
        system.debug('## >>> START testMethod testScheduleBatch <<< run by ' + UserInfo.getUserName());
        String jobId;
        
        System.runAs( userAdmin ){          
            Test.startTest();
                // Schedule the test job
                jobId = ICF_PrepareSurveyDeliveryBatchSche.scheduleIt();
            Test.stopTest();    
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                FROM CronTrigger 
                                WHERE Id = :jobId];
            
            // Verify the expressions are the same
            system.assertEquals('0 0 0 * * ?', ct.CronExpression);
            
            // Verify the job has not run
            system.assertEquals(0, ct.TimesTriggered);

        }//end of run as
        
        system.debug('## >>> END testMethod  testScheduleBatch <<<');
    }//end testMethod   
  
   @isTest 
    static void testCreateTaskBatch() {
        system.debug('## >>> START testMethod testCreateTaskBatch <<< run by ' + UserInfo.getUserName());                                                                         
        System.runAs( userAdmin ){  
            ICF_WrapperSurveySoqls wr1 = new ICF_WrapperSurveySoqls('SELECT accountid,Id FROM Contact WHERE (Title LIKE \'%x%\' OR Department = \'x\')',
                                                                                                                listSurveys[0].id,
                                                                                                                'Id',
                                                                                                                ICF_AP_Constant.PROCESS_STATUS_Eligibility,
                                                                                                                'accountid',
                                                                                                                null);
            Case c = [Select casenumber from case where id  = :listCases[0].id limit 1];
            wr1.addSoql('SELECT Id FROM Account WHERE Gender__c = \'F\'' ,'Id',ICF_AP_Constant.PROCESS_STATUS_Eligibility,null , null);
            wr1.addSoql('SELECT contact.Id,contact.Account.Id FROM Case WHERE CaseNumber = \''+c.casenumber+'\'','contact.Id',ICF_AP_Constant.PROCESS_STATUS_Eligibility,'contact.Account.Id',  null);
            wr1.addSoql('SELECT Id FROM Contact WHERE Title = \'x1\'','Id',ICF_AP_Constant.PROCESS_STATUS_Exclusion,null,    null);

            ICF_WrapperSurveySoqls wr2 = new ICF_WrapperSurveySoqls('SELECT contact.accountid,Contact.id FROM Case WHERE CaseNumber = \'x1\'',
                                                                                                                listSurveys[1].id,
                                                                                                                'Contact.id',
                                                                                                                ICF_AP_Constant.PROCESS_STATUS_Exclusion,
                                                                                                                'contact.accountid',
                                                                                                                null);
            wr2.addSoql('SELECT contact.accountid,Contactid FROM Case WHERE CaseNumber = \'x1\'','Contactid',ICF_AP_Constant.PROCESS_STATUS_Eligibility,'contact.accountid',    null);

            map<String,ICF_WrapperSurveySoqls> maplistWrapperSurveySoqls = new map<String,ICF_WrapperSurveySoqls> { listSurveys[0].id=>wr1
                                                                                                            };
                                            
            Test.startTest();
                ICF_CreateTaskForSurveyDeliveryBatch b = new ICF_CreateTaskForSurveyDeliveryBatch(maplistWrapperSurveySoqls.keyset(), maplistWrapperSurveySoqls );
                String jobID =   Database.executeBatch(b,1) ;
            Test.stopTest();    
            list<Task> listResultTask = new list <Task>([SELECT id,whoid,whatid,ICF_SurveyId__c from Task]);
            System.assertEquals(listContacts[0].id,listResultTask[0].whoid);
            System.assertEquals(listAccounts[1].id,listResultTask[0].whatid);
            System.assertEquals(listAccounts[0].id,listResultTask[1].whatid);
        }//end of run as
        
        system.debug('## >>> END testMethod  testCreateTaskBatch <<<');
    }///end testMethod   
}//end of test class*/