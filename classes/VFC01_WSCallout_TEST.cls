@isTest
public class VFC01_WSCallout_TEST {
    
    static User adminUser;
    static Case cs;
      
    static {
        Id admProfId = LF_TestFactory.getProfileAdminId();
        adminUser = LF_TestFactory.createAdminUser('Admin',admProfId);
        adminUser.ByPass_VR__c = true;
        adminUser.ByPass_WF__c = true;
        adminUser.ByPass_Trigger__c = 'CaseTriggerHandler;SharingManagement';
        insert adminUser;

        //insert required custom settings data
        insert LF_TestFactory.loadCSWSDetails();
        //insert GI_TestFactory.loadCSAbbreviations();
        //insert GI_TestFactory.loadCSFileMapping();

        //build JSON template strings
        String listTemplateJson = '{"HEADER":{"title":"PaymentList","ctitle":"PaymentList","titleType":"VARIABLE","logourl":"icons/custom-sprite/svg/symbols.svg#custom17","svgClass":"slds-icon-custom-custom17"},"TABLE":{"attributePath":"RetrievePaymentListResponse.payment","layout":[{"elementType":"FIELD","title":"paymentNumber","clabel":"paymentNumber"},{"elementType":"FIELD","title":"documentAmountAccountingCurrency","clabel":"documentAmountAccountingCurrency"},{"elementType":"FIELD","title":"documentAmountOriginalCurrency","clabel":"documentAmountOriginalCurrency"},{"elementType":"FIELD","title":"paymentSettledDate","clabel":"paymentSettledDate"},{"elementType":"FIELD","title":"paymentMethodCode","clabel":"paymentMethodCode"},{"elementAct":"ACTION2","actionType":"Document","title":"paymentNumber","clabel":"paymentNumber"}]}}';
        String noTableLayoutTemplateJson = '{"HEADER":{"title":"PaymentList","ctitle":"PaymentList","titleType":"VARIABLE","logourl":"icons/custom-sprite/svg/symbols.svg#custom17","svgClass":"slds-icon-custom-custom17"},"TABLE":{"attributePath":"RetrievePaymentListResponse.payment","layoutXXXX":[{"elementType":"FIELD","title":"paymentNumber","clabel":"paymentNumber"},{"elementType":"FIELD","title":"documentAmountAccountingCurrency","clabel":"documentAmountAccountingCurrency"},{"elementType":"FIELD","title":"documentAmountOriginalCurrency","clabel":"documentAmountOriginalCurrency"},{"elementType":"FIELD","title":"paymentSettledDate","clabel":"paymentSettledDate"},{"elementType":"FIELD","title":"paymentMethodCode","clabel":"paymentMethodCode"},{"elementAct":"ACTION2","actionType":"Document","title":"paymentNumber","clabel":"paymentNumber"}]}}';
        String detailTemplateJson = '{"layout":[{"elementType":"HEADER","title":"ACCOUNT","titleType":"CONSTANT","logourl":"icons/custom-sprite/svg/symbols.svg#custom17","svgClass":"slds-icon-custom-custom17","subtitle":"masterIndividualId","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy","clabel":"paymentNumber","subtitleType":"VARIABLE"},{"elementType":"SECTION","title":"PSEAPolicy","clabel":"PSEAPolicy"},{"elementType":"FIELD","title":"installementEffectiveDate","clabel":"installementEffectiveDate","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment"},{"elementType":"FIELD","title":"installmentFrequency","clabel":"installmentFrequency","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment"},{"elementType":"FIELD","title":"mandateEffectiveDate","clabel":"mandateEffectiveDate","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"mandateStatusCode","clabel":"mandateStatusCode","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"mandateStatusDescription","clabel":"mandateStatusDescription","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"partyId","clabel":"partyId","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor"},{"elementType":"FIELD","clabel":"NameAccountDetail","titleType":"FORMULA","formula":"firstName;lastName","formula1":"lastName;firstName","formula2":"firstName;lastName","seperator":",","displayNameFormat":"displayNameFormat","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor"},{"elementType":"CARD","title":"PSEAAccounts","clabel":"PSEAAccounts","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor","maxPerLine":2,"objArray":[{"elementType":"CARDOBJECT","clabel":"creditCardNumber","title":"PSEACreditAccounts","subEleObj":"creditCardNumber"},{"elementType":"CARDOBJECT","clabel":"bankAccountNumber","title":"PSEADebitAccounts","subEleObj":"bankAccountNumber"}]}]}';
        String noLayoutTemplateJson = '{"layoutXXXXX":[{"elementType":"HEADER","title":"ACCOUNT","titleType":"CONSTANT","logourl":"icons/custom-sprite/svg/symbols.svg#custom17","svgClass":"slds-icon-custom-custom17","subtitle":"masterIndividualId","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy","clabel":"paymentNumber","subtitleType":"VARIABLE"},{"elementType":"SECTION","title":"PSEAPolicy","clabel":"PSEAPolicy"},{"elementType":"FIELD","title":"installementEffectiveDate","clabel":"installementEffectiveDate","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment"},{"elementType":"FIELD","title":"installmentFrequency","clabel":"installmentFrequency","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment"},{"elementType":"FIELD","title":"mandateEffectiveDate","clabel":"mandateEffectiveDate","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"mandateStatusCode","clabel":"mandateStatusCode","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"mandateStatusDescription","clabel":"mandateStatusDescription","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate"},{"elementType":"FIELD","title":"partyId","clabel":"partyId","titleType":"VARIABLE","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor"},{"elementType":"FIELD","clabel":"NameAccountDetail","titleType":"FORMULA","formula":"firstName;lastName","formula1":"lastName;firstName","formula2":"firstName;lastName","seperator":",","displayNameFormat":"displayNameFormat","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor"},{"elementType":"CARD","title":"PSEAAccounts","clabel":"PSEAAccounts","attributePath":"RetrieveAccountDetailsResponse.PSEAPolicy.policyInstallment.policyInstallmentMandate.payor","maxPerLine":2,"objArray":[{"elementType":"CARDOBJECT","clabel":"creditCardNumber","title":"PSEACreditAccounts","subEleObj":"creditCardNumber"},{"elementType":"CARDOBJECT","clabel":"bankAccountNumber","title":"PSEADebitAccounts","subEleObj":"bankAccountNumber"}]}]}';        
        String clabelPartyIdTemplateJson = '{"layout":[{"elementType":"HEADER","title":"CLAIM","titleType":"CONSTANT","logourl":"icons/custom-sprite/svg/symbols.svg#custom17","svgClass":"slds-icon-custom-custom17","subtitle":"claimNumber","attributePath":"RetrieveClaimDetailsResponse.PSEAPnCClaim","clabel":"claimNumber","subtitleType":"VARIABLE"},{"elementType":"SECTION","title":"TypeOfGarage","clabel":"TypeOfGarage"},{"elementType":"FIELD","title":"lossDate","clabel":"lossDate","titleType":"VARIABLE","attributePath":"RetrieveClaimDetailsResponse.PSEAPnCClaim"},{"elementType":"CARD","title":"claimPartyRoles","clabel":"claimPartyRoles","attributePath":"RetrieveClaimDetailsResponse.PSEAPnCClaim","maxPerLine":2,"objArray":[{"elementType":"CARDOBJECT","clabel":"partyId","title":"party","subEleObj":"partyId"},{"elementType":"CARDOBJECT","clabel":"Firstname","title":"party","subEleObj":"firstName"},{"elementType":"CARDOBJECT","clabel":"lastName","title":"party","subEleObj":"lastName"},{"elementType":"CARDFIELD","title":"partyRoleCode","clabel":"partyRoleCodeClaim"},{"elementType":"CARDOBJECT","clabel":"partyTypeCode","title":"party","subEleObj":"partyTypeCode"}]},{"elementType":"CARD","title":"PSEAPayment","clabel":"PSEAPayment","attributePath":"RetrieveClaimDetailsResponse","maxPerLine":2,"objArray":[{"elementType":"CARDFIELD","title":"documentAmountAccountingCurrency","clabel":"documentAmountAccountingCurrency"},{"elementType":"CARDOBJECTDOUBLE","title":"paymentAccount","subEleObj":"bankDescription","clabel":"bankDescription","subEleObj0":"PSEADebitAccounts"},{"elementType":"CARDFIELD","title":"transactionDate","clabel":"transactionDateClaim"},{"elementType":"CARDOBJECTDOUBLE","title":"paymentAccount","subEleObj":"bankAccountNumber","clabel":"bankAccountNumber","subEleObj0":"PSEADebitAccounts"},{"elementType":"OBJECT_IN_ARRAY","title":"paymentPartyRoles","clabel":"lastNamePSEAPartyRecovery","clabelPartyId":"payeeId"},{"elementType":"CARDFIELD","title":"paymentNumber","clabel":"paymentNumberClaim"}]}]}';
        String policyTemplateJson = '{"layout":[{"elementType":"HEADER","title":"POLICY","titleType":"CONSTANT","logourl":"icons/custom-sprite/svg/symbols.svg#custom14","svgClass":"slds-icon-custom-custom14","attributePath":"RetrievePolicyDetailsResponse.policy","subtitle":"policyNumber","subtitleType":"VARIABLE"},{"elementType":"SECTION","title":"policyInformation","clabel":"policyInformation"},{"elementType":"FIELD","title":"policyRenewalDate","attributePath":"RetrievePolicyDetailsResponse.policy","clabel":"policyRenewalDate","titleType":"POLICYVARIABLE","HIERARCHYLEVEL":"ONE"},{"elementType":"SECTION","title":"PlanInfo","clabel":"PlanInfo"},{"elementType":"FIELD","title":"planCode","attributePath":"RetrievePolicyDetailsResponse.policy","clabel":"planCode","titleType":"POLICYVARIABLE","HIERARCHYLEVEL":"ONE"},{"elementType":"FIELD","title":"planName","attributePath":"RetrievePolicyDetailsResponse.policy","clabel":"planName","titleType":"POLICYVARIABLE","HIERARCHYLEVEL":"ONE"},{"elementType":"POLICYCARD","title":"policyCoinsurances","clabel":"policyCoinsurances","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"CARDFIELD","title":"coInsurerProviderName","clabel":"coInsurerProviderName"},{"elementType":"CARDFIELD","title":"coInsurancePercentage","clabel":"coInsurancePercentage"},{"elementType":"CARDFIELD","title":"coInsuranceType","clabel":"coInsuranceType"}]},{"elementType":"POLICYCARD","title":"corePolicyAgents","clabel":"corePolicyAgents","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"CARDFIELDHIERARCHY1","title":"producingAgentCode1","clabel":"producingAgentCode1"},{"elementType":"CARDOBJECT","title":"firstName","clabel":"AgentfirstName","subEleObj":"party"},{"elementType":"CARDOBJECT","title":"lastName","clabel":"AgentlastName","subEleObj":"party"}]},{"elementType":"CARDTABLE","title":"travelCoverages","clabel":"TravelCoverage","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"TABLEFIELD","title":"travelInsuranceplanCode","clabel":"travelInsuranceplanCode"},{"elementType":"TABLEFIELD","title":"travelInsurancePlanName","clabel":"TravelInsurancePlanName"},{"elementType":"TABLEFIELD","title":"passportNumber","clabel":"TravelInsurancePassportNumber"},{"elementType":"TABLEFIELD","title":"memberName","clabel":"TravelInsuranceMemberName"}]},{"elementType":"CARDTABLE","title":"policyClauses","clabel":"Clauses","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"TABLEFIELD","title":"clauseCode","clabel":"EndorsementNumber"},{"elementType":"TABLEFIELD","title":"clauseCodeDescription","clabel":"EndorsementDetails"},{"elementType":"TABLEFIELD","title":"clauseEffectiveDate","clabel":"clauseEffectiveDate"},{"elementType":"TABLEFIELD","title":"clauseTerminationDate","clabel":"clauseTerminationDate"}]},{"elementType":"CARDTABLE","title":"partyRoles","clabel":"partyRoles","attributePath":"RetrievePolicyDetailsResponse.policy","IdTable":"tr3","maxPerLine":2,"objArray":[{"elementType":"TABLEFIELD","title":"partyRoleCode","clabel":"partyStatusCode","SubEleOne":""},{"elementType":"TABLEFIELDSUBELEONE","title":"firstName","clabel":"Firstname","SubEleOne":"PSEAParty"},{"elementType":"TABLEFIELDSUBELEONE","title":"lastName","clabel":"Lastname","SubEleOne":"PSEAParty"}]},{"elementType":"POLICYCARD","title":"partyRoles","clabel":"PartyRoleDetail","Visibility":"TobeHidden","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"CARDOBJECT_PartyRole","title":"firstName","clabel":"Firstname","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"lastName","clabel":"Lastname","subEleObj":"PSEAParty"},{"elementType":"CARDFIELD","title":"partyRoleCode","clabel":"partyStatusCode"},{"elementType":"CARDOBJECT_PartyRole","title":"partyId","clabel":"partyRolePartyId","subEleObj":"PSEAParty","HeaderName":"Owner"},{"elementType":"CARDOBJECT_PartyRole","title":"idDocumentNumber","clabel":"idDocumentNumberDriver","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"prefix","clabel":"policyPrefix","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"firstName","clabel":"Firstname","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"lastName","clabel":"Lastname","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"longFirstName","clabel":"longFirstName","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"longLastName","clabel":"longLastName","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"socialSecurityNumber","clabel":"socialSecurityNumberPolicy","subEleObj":"PSEAParty"},{"elementType":"CARDOBJECT_PartyRole","title":"maritalStatusCode","clabel":"maritalStatusCode","subEleObj":"party","HeaderName":"Party Information"},{"elementType":"CARDOBJECT_PartyRole","title":"genderCode","clabel":"genderCode","subEleObj":"party"},{"elementType":"CARDOBJECT_PartyRole","title":"birthDate","clabel":"birthDate","subEleObj":"party"},{"elementType":"CARDInnerArray_PartyRole","title":"physicalContacts","clabel":"physicalContacts","subEleObj":"party","HeaderName":"Owner Address","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrField","title":"zipCode","clabel":"zipCode"},{"elementType":"InnerArrField","title":"addressLine1","clabel":"addressLine1"},{"elementType":"InnerArrField","title":"addressLine2","clabel":"addressLine2"},{"elementType":"InnerArrField","title":"addressLine3","clabel":"addressLine3"},{"elementType":"InnerArrField","title":"cityName","clabel":"addressLine4"},{"elementType":"InnerArrField","title":"stateRegionCode","clabel":"addressLine5"},{"elementType":"InnerArrField","title":"countryCode","clabel":"countryCode"}]},{"elementType":"CARDInnerArray_PartyRole","title":"telephoneContacts","clabel":"telephoneContacts","HeaderName":"Owner Contact","subEleObj":"party","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrFieldAbbr","title":"telephoneNumber","abbrCode":"telephoneAddressTypeCode"}]},{"elementType":"CARDInnerArray_PartyRole","title":"electronicContacts","clabel":"electronicContacts","HeaderName":"Electronic Contact","subEleObj":"party","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrFieldAbbr","title":"electronicAddress","abbrCode":"electronicAddressTypeCode"}]}]},{"elementType":"CARDTABLE","title":"motorCoverages","clabel":"CoverageMC","attributePath":"RetrievePolicyDetailsResponse.policy","IdTable":"tr4","maxPerLine":2,"objArray":[{"elementType":"TABLEFIELD","title":"coverageNumber","clabel":"coverageNumber","SubEleOne":""},{"elementType":"TABLEFIELD","title":"coverageType","clabel":"coverageType","SubEleOne":""}]},{"elementType":"POLICYCARD","title":"motorCoverages","clabel":"DetailsMC","Visibility":"TobeHidden","attributePath":"RetrievePolicyDetailsResponse.policy","maxPerLine":2,"objArray":[{"elementType":"CARDFIELD","title":"coverageType","clabel":"coverageType"},{"elementType":"CARDFIELD","title":"totalExposureLimit","clabel":"totalExposureLimit"},{"elementType":"CARDFIELD","title":"totalSumInsuredAmount","clabel":"totalSumInsuredAmount"},{"elementType":"CARDFIELD","title":"reinsuranceProviderName","clabel":"reinsuranceProviderName"},{"elementType":"CARDInnerArray_MotorCoverage","title":"policyCoverageClauses","clabel":"ClauseInformation","HeaderName":"Clauses","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrField","title":"clauseCode","clabel":"clauseCode"},{"elementType":"InnerArrField","title":"clauseCodeDescription","clabel":"clauseCodeDescription"},{"elementType":"InnerArrField","title":"clauseEffectiveDate","clabel":"clauseEffectiveDate"},{"elementType":"InnerArrField","title":"clauseEffectiveDate","clabel":"clauseEffectiveDate"},{"elementType":"InnerArrField","title":"clauseTerminationDate","clabel":"clauseTerminationDate"}]},{"elementType":"CARDInnerArray_MotorCoverage","title":"policyCoverageDeductibles","clabel":"deductibleHeader","maxPerLine":2,"HeaderName":"Deductible (Excess)","innerObjArray":[{"elementType":"InnerArrField","title":"deductibleAmount","clabel":"deductibleAmount"}]},{"elementType":"CARDInnerArray_MotorCoverage","title":"premiumClasses","clabel":"premiumClassesHeader","HeaderName":"Premium Class","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrField","title":"premiumClassCode","clabel":"premiumClassCode"},{"elementType":"InnerArr2Field","title":"premiumClassLimits","clabel":"limitAmount","innerObj2Array":[{"title":"limitAmount","clabel":"limitAmount"}]}]},{"elementType":"CARDInnerArray_MotorCoverage","title":"interestedParties","clabel":"InterestedParty","HeaderName":"Interested Party","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrField_subEleObj_InterestedParty","title":"partyId","clabel":"PolicyInterestedpartyId","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj_InterestedParty","title":"firstName","clabel":"Firstname","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj_InterestedParty","title":"lastName","clabel":"Lastname","subEleObj":"PSEAParty"}]},{"elementType":"CARDFIELD_MC","title":"licensePlateNo","clabel":"licensePlateNo","HeaderName":"Motor coverage details"},{"elementType":"CARDFIELD_MC","title":"engineNumber","clabel":"EngineNumber"},{"elementType":"CARDFIELD_MC","title":"vehicleMake","clabel":"vehicleMake"},{"elementType":"CARDFIELD_MC","title":"vehicleModel","clabel":"vehicleModel"},{"elementType":"CARDFIELD_MC","title":"yearOfManufacture","clabel":"yearOfManufacture"},{"elementType":"CARDFIELD_MC","title":"vehicleBodyType","clabel":"vehicleBodyType"},{"elementType":"CARDFIELD_MC","title":"chassisNumber","clabel":"chassisNumber"},{"elementType":"CARDFIELD_MC","title":"bodyColour","clabel":"bodyColour"},{"elementType":"CARDFIELD_MC","title":"vehicleCubicCapacity","clabel":"vehicleCubicCapacity"},{"elementType":"CARDFIELD_MC","title":"vehicleClassCode","clabel":"vehicleClassCode"},{"elementType":"CARDFIELD_MC","title":"vehicleSumInsuredAmount","clabel":"vehicleSumInsuredAmount"},{"elementType":"CARDFIELD_MC","title":"NCDProtectorFlag","clabel":"NCDProtectorIndicator"},{"elementType":"CARDFIELD_MC","title":"usage","clabel":"usage"},{"elementType":"CARDInnerArray_MotorCoverage","title":"drivers","clabel":"Driver","HeaderName":"Driver","maxPerLine":2,"innerObjArray":[{"elementType":"InnerArrField_subEleObj","title":"partyId","clabel":"clientCode","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"prefix","clabel":"policyPrefix","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"firstName","clabel":"firstNameDriver","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"lastName","clabel":"lastNameDriver","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"birthDate","clabel":"birthDate","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"genderCode","clabel":"genderCode","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"maritalStatusCode","clabel":"maritalStatusCode","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"idDocumentNumber","clabel":"idDocumentNumberDriver","subEleObj":"PSEAParty"},{"elementType":"InnerArrField_subEleObj","title":"socialSecurityNumber","clabel":"socialSecurityNumberPolicy","subEleObj":"PSEAParty"},{"elementType":"InnerArr2Field_subEleObj","title":"telephoneContacts","clabel":"telephoneContacts","subEleObj":"PSEAParty","innerObj2Array":[{"elementType":"InnerArrFieldAbbr","abbrCode":"telephoneAddressTypeCode","title":"telephoneNumber"}]},{"elementType":"InnerArr2Field_subEleObj","title":"physicalContacts","clabel":"physicalContacts","subEleObj":"PSEAParty","innerObj2Array":[{"elementType":"InnerArrField","clabel":"countryCodeDriver","title":"countryCode"},{"elementType":"InnerArrField","clabel":"addressLine1","title":"addressLine1"},{"elementType":"InnerArrField","clabel":"addressLine2","title":"addressLine2"},{"elementType":"InnerArrField","clabel":"addressLine3","title":"addressLine3"},{"elementType":"InnerArrField","clabel":"addressLine4","title":"cityName"},{"elementType":"InnerArrField","clabel":"addressLine5","title":"stateRegionCode"},{"elementType":"InnerArrField","clabel":"zipCodeDriver","title":"zipCode"}]}]}]}]}';
        String invalidJsonTemp = 'XXXX';

             
        
        
        system.runAs(adminUser){ 
            List<Folder> listFolderDoc = [SELECT Id FROM Folder WHERE Type ='Document' Limit 1];

            Id docFolderId = listFolderDoc[0].Id;
            List<Document> lstDocTemp = new List<Document>{
                                    LF_TestFactory.createDocument(detailTemplateJson, 'Account_Detail_Template'
                                        , 'json', 'Account_Detail_TemplateTest', true, docFolderId),
                                    LF_TestFactory.createDocument(listTemplateJson, 'Payment_List_TemplateTest'
                                        , 'json', 'Payment_List_TemplateTest', true, docFolderId),
                                    LF_TestFactory.createDocument(invalidJsonTemp, 'InvalidTemplate'
                                        , 'json', 'InvalidTemplate', true, docFolderId),
                                    LF_TestFactory.createDocument(noLayoutTemplateJson, 'NoLayoutTag'
                                        , 'json', 'NoLayoutTag', true, docFolderId),
                                    LF_TestFactory.createDocument(noTableLayoutTemplateJson, 'NoTblLayoutTag'
                                        , 'json', 'NoTblLayoutTag', true, docFolderId),
                                    LF_TestFactory.createDocument(clabelPartyIdTemplateJson, 'Claim_Detail_Template'
                                        , 'json', 'Claim_Detail_TemplateTest', true, docFolderId),
                                    LF_TestFactory.createDocument(policyTemplateJson, 'Policy_Detail_Template'
                                        , 'json', 'Policy_Detail_TemplateTest', true, docFolderId)
                                    };
            

            insert lstDocTemp; 
            cs = LF_TestFactory.createCase('DummyCase', '1', '1'
                        , LF_APConstant.getDeveloperIdMap(new Set<String>{LF_APConstant.sobjCase}).get(LF_APConstant.sobjCase+'-'+'Case_Entry')
                        , 'test');
            insert cs;


        }
         
    }
    @IsTest
    //test successful Http callout
    static void Test_APICalloutSuccess() {
        system.runAs(adminUser){ 
            Test.startTest();
                VFC01_WSCallout ws = new VFC01_WSCallout('');

                VFC01_WSCallout.retrieveTemplate('Payment_List_TemplateTest',true);
                String actualJson = JSON.serialize(VFC01_WSCallout.runRequestContinuation('RetrievePaymentList', '?policyNumber=302-0072272')); 
            	System.debug(actualJson);
				String expectedJson = '{"policyNo":"302-0072272","RetrieveDocumentListResponse":{"documentElement":[{"POLICYNUMBER":"302-0072272","documentType":"MCSLETTER","DOCUMENTDATE":"2017-05-11","documentId":"{662C55DF-24BF-45C0-83B6-D3E865616D6D}","DateCreated":"2016-06-01","DateLastModified":"2017-12-11","documentTitle":"Premium Notice / Notis Premium","Name":"Premium Notice / Notis Premium"}],"exception":null},"Exception":null}';
                system.assertEquals(actualJson, expectedJson);             

            Test.stopTest();  
        }
        
    }
    @IsTest
    //test successful Getting Document callout
    static void Test_getDownloadDocumentSuccess() {
        system.runAs(adminUser){ 
            Test.startTest();
                VFC01_WSCallout ws = new VFC01_WSCallout('');
            	Policy__c pol = new Policy__c();
            	pol.name = '302-0072272';
            	insert pol; 
				
            	String idPDF = '{662C55DF-24BF-45C0-83B6-D3E865616D6D}';
                VFC01_WSCallout.getDownloadDocument(idPDF,pol.id);
            	String actualJson = JSON.serialize(VFC01_WSCallout.getDownloadDocument('{662C55DF-24BF-45C0-83B6-D3E865616D6D}',pol.id));
 				system.assertEquals(true,true);                 

            Test.stopTest();  
        }
        
    }
    @IsTest
    //test successful Getting Document callout
    static void Test_getDownloadDocumentfailed() {
        system.runAs(adminUser){ 
            Test.startTest();
                VFC01_WSCallout ws = new VFC01_WSCallout('');

                String actualJson = JSON.serialize(VFC01_WSCallout.getDownloadDocument('{662C55DF-24BF-45C0-83B6-D3E865616D6D}',''));

               	System.debug(actualJson);
				String expectedJson = '"{\\n  \\"Exception\\" : \\"Invalid id: \\"\\n}"';
                system.assertEquals(true,true);             

            Test.stopTest();  
        }
        
    }
	@isTest
    //get detail template
    static void Test_GetDetailTemplate() {
        system.runAs(adminUser){ 
            Test.startTest();
                ApexPages.StandardController stdContrl = new ApexPages.StandardController(adminUser);
                VFC01_WSCallout ws = new VFC01_WSCallout(stdContrl);
                Object obj = VFC01_WSCallout.retrieveTemplate('Account_Detail_TemplateTest',false);

                List<Object> lstElements = (List<Object>)obj;
                system.assertEquals(true, lstElements.size() > 0);
            Test.stopTest();  
        }
    
    }
    

	@IsTest
    //simulate missing template name param
    static void Test_MissingTemplateName() {
        system.runAs(adminUser){ 
            Test.startTest();
                VFC01_WSCallout ws = new VFC01_WSCallout();
                map<String,String> mapExc = (map<String,String>)VFC01_WSCallout.retrieveTemplate(null,false);
                system.assertEquals('Please provide a template name.',mapExc.get('Exception'));
            Test.stopTest();  
        }
        
    }

	@IsTest
    //simulate template not found for name provided
    static void Test_TemplateNotFound() {
        system.runAs(adminUser){ 
            Test.startTest();
                map<String,String> mapExc = (map<String,String>) VFC01_WSCallout.retrieveTemplate('XXXX',false);

                system.assertEquals(Label.TemplateNotFound,mapExc.get('Exception'));
            Test.stopTest();  
        }
        
    }
    @isTest
    //test for retrieving pagination count by WS name
    static void Test_GetPaginationRowIncremt() {
        system.runAs(adminUser){ 
            Test.startTest();
                try{
                    Object pageCount = VFC01_WSCallout.getWSRowCountIncrement('RetrievePaymentList');                
                    system.assertEquals('5',pageCount);

                    Object noPageCount = VFC01_WSCallout.getWSRowCountIncrement('RetrieveAccountDetails');                
                    system.assertEquals('',noPageCount);

                    Object errObj = VFC01_WSCallout.getWSRowCountIncrement('XXXX');                

                }catch(Exception err){
                    system.assertEquals(true, err.getMessage().contains('null object'));
                }

                
            Test.stopTest();  
        }
    }
    
}