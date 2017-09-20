@isTest
private class VFC03CaseQuestionValidation_Test {
	
	static Integer counter=0; 
    static String statusNew;
    static String typeInbound;
    static String subTypeProductEnquiry,subTypeProcessEnquiry,subTypeCsOthers;
    static String callerDistributor,callerCustomer;
    static String originOutbound;
  	static user mainUser;
    static Id profileIdAdmin;
    static list<Case> listCases;  
    static list<QuestionBySubType__c> listQuestionsBySubType;  
    static list<QuestionDetails__c> listQuestionsDetail;  
    
    
    public static String getUniqueUserName(){
        //adding an incremental counter because when inserting multiple users the getTime() method can return same value for 2 user record  
        counter++ ;        
        return UserInfo.getOrganizationId() + System.now().getTime() + counter + 'standarduser@testorg.com';
    }
       
    static{
        SharingManagement__c MySMAccount = new SharingManagement__c();
        MySMAccount.Name = 'Account';
        MySMAccount.Sharing_Field__c = 'OwnerId';
        insert MySMAccount;
        
        SharingManagement__c MySMLead = new SharingManagement__c();
        MySMLead.Name = 'Lead';
        MySMLead.Sharing_Field__c = 'OwnerId';
        insert MySMLead;
        
        profileIdAdmin = AP_Constant.getProfileAdminId();
        // Running test class user creation
         mainUser = new User(Username = getUniqueUserName() ,
                                            LastName = 'testuserInsert',
                                            LanguageLocaleKey = 'en_US',
                                            FirstName = 'test',
                                            Email = 'test@test.com',
                                            Alias = 'XXX',
                                            TimeZoneSidKey = 'Europe/Dublin',
                                            LocaleSidKey = 'en_US',
                                            IsActive=true,
                                            EmailEncodingKey = 'UTF-8',
                                            ProfileId = profileIdAdmin,
                                            ByPass_VR__c = true,
                                            ByPass_WF__c = true
                                            );
        insert mainUser;

        CS01_LF_WebServiceDetail__c ws = new CS01_LF_WebServiceDetail__c(
            Name = 'RetrieveCustomerDetails',
            Accept__c = 'application/json',
            AcceptCharset__c = 'UTF-8',
            ContentType__c = 'application/x-www-form-urlencoded',
            HeaderCustomDataSourceSystem__c = 'SCRM',
            HeaderCustomDataTargetSystem__c = 'COREDB',
            HeaderContextVersion__c = '1.0',
            Request_Method__c = 'GET',
            URL__c = 'https://preprodapwsg.axa-tech.com:10443/customer-api/customer/v2/customers/',
            XAxaApiKey__c = 'TBD',
            XAxaEntity__c = 'HK',
            XAxaEnv__c = 'qa5',
            XAxaLOB__c = 'GI',
            XAxaRequestingChannel__c = 'SFDC'
        );
        insert ws;
    
        System.runAs(mainUser){ 
          statusNew = AP_Constant.caseStatusNew;
            typeInbound = AP_Constant.caseTypeInbound;
            subTypeProductEnquiry = AP_Constant.caseSubTypeProductEnquiry;
            subTypeProcessEnquiry = AP_Constant.caseSubTypeProcessEnquiry;
            subTypeCsOthers = AP_Constant.caseSubTypeCsOthers;
            callerDistributor = AP_Constant.caseCallerDistributor;
            callerCustomer = AP_Constant.caseCallerCustomer;
            originOutbound = AP_Constant.caseOriginOutbound;
            
            listQuestionsBySubType = new list<QuestionBySubType__c>{
              new QuestionBySubType__c(
                name = 'qbysub',
                CallerType__c=callerDistributor,
                NumberOfValidAnswer__c=2,
                Origin__c=originOutbound,
                QuestionName__c='1;2;3',
                SubType__c= subTypeProductEnquiry
              )             
            };
            insert listQuestionsBySubType;
            listQuestionsDetail = new list<QuestionDetails__c>{
              new QuestionDetails__c(
                name='1',
                AnswerField__c = 'Casenumber',
                Question__c ='question 1'
              ),
              new QuestionDetails__c(
                name='2',
                AnswerField__c = 'Origin',
                Question__c ='question 2'
              ) ,
              new QuestionDetails__c(
                name='3',
                AnswerField__c = 'Type',
                Question__c ='question 3'
              )                           
            };                    
            insert listQuestionsDetail;

            Account acc = new Account(name='Customer1', Customer_ID__c='7511215');
            insert acc;
              
          listCases = new list<Case>{
                new Case(
                  status = statusNew,
                  Origin = originOutbound ,
                  Complainant__c= callerDistributor ,
                    Type=typeInbound,
                    SR_Sub_Type__c = subTypeProductEnquiry,
                    accountId = acc.Id
                ),
                new Case(
                  status = statusNew,
                  Origin = originOutbound ,
                  Complainant__c= callerDistributor ,
                    Type=typeInbound,
                    SR_Sub_Type__c = subTypeProcessEnquiry
                ),
                new Case(
                  status = statusNew,
                  Origin = originOutbound ,
                  Complainant__c= callerCustomer ,
                    Type=typeInbound,
                    SR_Sub_Type__c = subTypeCsOthers
                )
            };
            insert listCases;
            
        }//end run as
    }// end of static
    //***************************************************************
    //** Scenario test case with subtype, origin and complain found 
    //** in custom setting
    //******************************************************************
    static testMethod void pageWithQuestionsTest() {
        System.runAs(mainUser){ 
           Test.startTest();
             ApexPages.StandardController sc = new ApexPages.StandardController(listCases[0]);
          VFC03CaseQuestionValidation controller = new VFC03CaseQuestionValidation(sc);
                
            PageReference pageRef = Page.VFP03CaseQuestionValidation;
            Test.setCurrentPage(pageRef);
            
            System.assertEquals(false, controller.validateCase );
            System.assertEquals(false, controller.refreshParent );
            System.assertEquals(listQuestionsDetail[0].AnswerField__c , controller.set2ColumnQuestions[0].answerApiName );
            System.assertEquals(listQuestionsDetail[0].Question__c , controller.set2ColumnQuestions[0].question1 );
            System.assertEquals(listQuestionsDetail[1].AnswerField__c , controller.set2ColumnQuestions[1].answerApiName );
            System.assertEquals(listQuestionsDetail[1].Question__c , controller.set2ColumnQuestions[1].question1 );
            System.assertEquals(false, controller.mapQuestionToAnswers.get(listQuestionsDetail[0].Question__c) );
            System.assertEquals(false, controller.mapQuestionToAnswers.get(listQuestionsDetail[1].Question__c) );  
           Test.stopTest();   
        }//end run as   
    }//end of test
    
    //***************************************************************
    //** Scenario test case with subtype, origin and complain found 
    //** in custom setting and save answers to validate case
    //******************************************************************
    static testMethod void saveAnswersTest() {
        System.runAs(mainUser){ 
           Test.startTest();
             ApexPages.StandardController sc = new ApexPages.StandardController(listCases[0]);
          VFC03CaseQuestionValidation controller = new VFC03CaseQuestionValidation(sc);
                
            PageReference pageRef = Page.VFP03CaseQuestionValidation;
            Test.setCurrentPage(pageRef);
            String ans =listQuestionsDetail[0].Question__c+':'+true+';'+
                  listQuestionsDetail[1].Question__c+':'+true;
            controller.jsonAnswer = ans;
            controller.saveAnswer();
            
            
            List<Case> listCaseResult = new list<Case> ([   SELECT   Validation__c,Answers__c
                                    FROM  Case
                                    WHERE   Id = :listCases[0].id]);
            System.assertEquals(true, listCaseResult[0].Validation__c );
            System.assertEquals(ans, listCaseResult[0].Answers__c );
           Test.stopTest();   
        }//end run as   
    }//end of test
    
    //***************************************************************
    //** Scenario test case with subtype, origin and complain found 
    //** in custom setting and save wrong answers to validate case
    //******************************************************************
    static testMethod void saveWrongAnswersTest() {
        System.runAs(mainUser){ 
           Test.startTest();
             ApexPages.StandardController sc = new ApexPages.StandardController(listCases[0]);
          VFC03CaseQuestionValidation controller = new VFC03CaseQuestionValidation(sc);
                
            PageReference pageRef = Page.VFP03CaseQuestionValidation;
            Test.setCurrentPage(pageRef);
            String ans =listQuestionsDetail[0].Question__c+':'+true;
            controller.jsonAnswer = ans;
            controller.saveAnswer();
            
            
            List<Case> listCaseResult = new list<Case> ([   SELECT   Validation__c,Answers__c
                                    FROM  Case
                                    WHERE   Id = :listCases[0].id]);
            System.assertEquals(false, listCaseResult[0].Validation__c );
            System.assertEquals(ans, listCaseResult[0].Answers__c );
           Test.stopTest();   
        }//end run as   
    }//end of test

    static testMethod void loadNationalIDFromEIP() {
        System.runAs(mainUser) {
            Test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(listCases[0]);
                VFC03CaseQuestionValidation controller = new VFC03CaseQuestionValidation(sc);

                PageReference pageRef = Page.VFP03CaseQuestionValidation;
                Test.setCurrentPage(pageRef);

                controller.loadNationalIDFromEIP();

                HttpResponse response = new HttpResponse();
                response.setBody('{"RetrieveCustomerDetailsResponse":{"coreParty":{"birthDate":"1955-12-31","displayNameFormat":"1","firstName":"LOX YXF","genderCode":"F","idDocumentNumber":"R915464(2)","idDocumentTypeCode":"SECURITYNO","lastName":"YXFU","middleName":null,"partyTypeCode":"P","partyId":null,"socialSecurityNumber":"R915464(2)","localFirstName":null,"localLastName":null,"localDisplayNameFormat":null,"salutationText":"MS","geoDemographicCode":null,"occupationClassCode":"UNKN","alertReceiverName":null,"primaryLanguageCode":"E","companyCode":"1","coreDBPartyId":null,"age":"61","smokingHabitFlag":null,"masterIndividualId":"7511215","marketableFlag":"N","telephoneContacts":[{"telephoneAddressTypeCode":"HOM","telephoneNumber":"49803770"},{"telephoneAddressTypeCode":"MOB","telephoneNumber":"49803770"},{"telephoneAddressTypeCode":"OFF","telephoneNumber":"06352200"}],"physicalContacts":[{"addressLine1":"YSQZ 0 YSGGK 6 WSGEA Y","addressLine2":"LIXF IGFU ILT","addressLine3":"LIXF EIO EGXKZ","countryCode":"HK","physicalAddressTypeCode":"COR","stateRegionCode":"9-98 LIXF EIO LZ","addressLine4":"9-98 LIXF EIO LZ","addressLine5":"AVXF ZGFU AGVSGGF"},{"addressLine1":"YSQZ 0 6/Y","addressLine2":"LIXF IGFU IGXLT","addressLine3":"LIXF EIO EGXKZ","countryCode":"HK","physicalAddressTypeCode":"RES","stateRegionCode":"AVXF ZGFU ASF","addressLine4":"AVXF ZGFU ASF"}],"electronicContacts":[{"electronicAddressTypeCode":"EML","electronicAddress":"EIKOLZOFT9029YXFU@NQIGG.EGD.IA"}]}}}');
                //Test.setContinuationResponse(controller.requestLabel, response);
                //Object result = Test.invokeContinuationMethod(controller, con);
            Test.stopTest();
        }
    }
    
    //***************************************************************
    //** Scenario test case with subtype, origin and complain 
    //**  not found in custom setting
    //******************************************************************
    static testMethod void pageWithNoSettingsTest() {
        System.runAs(mainUser){ 
           Test.startTest();
             ApexPages.StandardController sc = new ApexPages.StandardController(listCases[1]);
          VFC03CaseQuestionValidation controller = new VFC03CaseQuestionValidation(sc);
            
            PageReference pageRef = Page.VFP03CaseQuestionValidation;
            Test.setCurrentPage(pageRef);
            controller.validatedCase(); //validate case since setting is not found
           Test.stopTest();   
            
            List<Case> listCaseResult = new list<Case> ([   SELECT   Validation__c,Answers__c
                                    FROM  Case
                                    WHERE   Id = :listCases[1].id]);
            
            System.assertEquals(true, controller.validateCase ); // because subtype of case does not exist in custom setting
            System.assertEquals(true, controller.refreshParent );  
            System.assertEquals(true, listCaseResult[0].Validation__c );
            System.assertEquals(null, listCaseResult[0].Answers__c );
        }//end run as        
    }//end of test
	
}