public with sharing class AP_Constant { 
/*
// AP_Constant
----------------------------------------------------------------------
-- - Name          : AP_Constant 
-- - Author        : Spoon Consulting
-- - Description   : Class for keeping all common constant variables 
--                 : and common methods                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks  
-- -----------  ----  -------  ---------------------------------------
-- 08-MAY-2013  YRA   1.0      Initial version
-- 23-MAY-2013  GDO   2.0      Added Account recordtypes and method getDeveloperIdMap() 
-- 28-MAY-2013  VBA   3.0      Added Feedback recordtypes 
-- 06-JAN-2017  BIN   3.0      Added SubType (Claim form, Garage Network, Hospital Network, Report Claim) for Ticket: Add auto closure for the remaining Claims CT/ST

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
    
    
    public static BusinessHours defaultHours;
/***********************************************************************
* Case
************************************************************************/
    public static string sobjectCas = 'Case';

    //picklist FCRAgent
    public static string caseFCRAgentFCR = 'FCR';
    public static string caseFCRAgentFirstContact = '1stContact';
    public static string caseFCRAgentRepeatedContact = 'RepeatedContact';
    
    //picklist FCRCust
    public static string caseFCRCustFCR = 'FCR';
    public static string caseFCRCustFirstContact = '1stContact';
    public static string caseFCRCustRepeatedContact = 'RepeatedContact';
    
    //picklist FCRPolicy
    public static string caseFCRPolicyFCR = 'FCR';
    public static string caseFCRPolicyFirstContact = '1stContact';
    public static string caseFCRPolicyRepeatedContact = 'RepeatedContact';
    
    //picklist Complainant
    public static string caseComplainantInt = 'Intermediary';
    public static string caseComplainantCustomer = '1';

    //picklist Status
    public static string caseStatusPendingStaff = 'Pending Staff';
    public static string caseStatusClosed = 'Closed';
    public static string caseStatusNew = '1';
    public static string caseSubTypeProductEnquiry = '1.1';
    public static string caseSubTypeProcessEnquiry = '1.3';
    public static string caseSubTypeCsOthers = '10.19';
    public static string caseTypeOutbound = '12';
    public static string caseTypeInbound = '1';
    public static string caseTypeComplaint = '10';
    public static string caseCallerCustomer = '1';
    public static string caseCallerDistributor = '2';
    public static string caseOriginOutbound = '2';
    public static string strCasStatusNew = 'New';
    public static string strCasStatusPendingFinance = 'Pending Finance';
    public static string strCasStatusPendingHealthUW = 'Pending Health UW';
    public static string strCasStatusPendingOtherDepartment = 'Pending Other Department';
    public static string strCasStatusPendingCC = 'Pending CC';
    public static string strCasStatusClosed = 'Closed';
    public static string strCasStatusPendingComplaints = 'Pending Complaints';
    public static string strCasStatusPendingServiceRecovery = 'Pending Service Recovery';

    //field SLA
    public static integer caseSLASevenDays = 7;
    public static integer caseSLAFourteenDays= 14;
    
    //field related team
    public static string caseRelatedTeam1 = 'Group Admin';

    //recordtype developer name
    public static string strCasRTPC_RCC = 'PC_RCC'; 
    public static string strCasRTPC_xRCC1 = 'PC_xRCC1';
    public static string strCasRTPC_xRCC2 = 'PC_xRCC2';

    //type
    public static string casTypeComplaintCS = 'Complaint CS';
    public static string casTypeComplaintDC = 'Complaint DC';
    public static string casTypeNewBusiness = 'New Business';
    public static string casTypePremiumpayment = 'Premium payment';
    public static string casTypePolicyService = 'Policy Service';
    public static string casTypeCoverageTermination = 'Coverage Termination';
    public static string casTypeRenewals = 'Renewals';
    public static string casTypeClaim = 'Claims';

    //subtype
    public static string casSubTypeClaimStatus = 'Claim Status';
    public static string casSubTypeServiceRecovery = 'Service Recovery'; 
    public static string casSubTypeReopenClaim = 'Reopen Claim';
    public static string casSubTypeWithdrawClaim = 'Withdraw Claim';

    public static string casSubTypeReportClaim = 'Report Claim'; //add 06-JAN-2017 
    public static string casSubTypeClaimForm = 'Claim form'; //add 06-JAN-2017 
    public static string casSubTypeGarageNetwork = 'Garage Network';  //-- 06-JAN-2017 
    public static string casSubTypeHospitalNetwork = 'Hospital Network';  //-- 06-JAN-2017 
/***********************************************************************
* Policy
'P01' - PREMIUM PAYING									
'P02' - PAID UP                  
'P03' - MATURED/EXPIRED          
'P04' - LAPSED (NON-CV PLAN)     
'P05' - EXTENDED TERM INSURANCE  
'P06' - REDUCED PAID UP INSURANCE
'P07' - SURRENDERED (BY CLIENT)  
'P08' - INSURED DEAD             
'P09' - AUTO-SURRENDER (BY CO.)  
'PA' - POLICY RESCINDED         
'PB' - PREMIUM WAIVED           
'PC' - POLICY CANCELLED         
'PD' - POLICY CONVERTED         
'PE' - POLICY NON-RENEWAL        
'PF' - EXTENDED PLAN COVERAGE   
'PZ' - COOLING-OFF CANCELLATION     

*Application
'A00' - Pending for underwriting                        
'A01' - Pending for more information                    
'A02' - Awaiting APS                                    
'A03' - Not being taken (Non-taken)
'A04' - Standard, premium not paid or cheque not clear
'A05' - Substandard, pending acceptance
'A06' - Substandard, premium not paid or cheque not clear
'A07' - Not DA form
'A09' - Policy issued
'A10' - Pending for RI arrangement
'A11' - Incomplete
'AX' - Postponed
'AY' - Declined
'AR' - Application reversed
************************************************************************/
        public static string sobjectPolicy = 'Policy__c';

        //recordtype developer name
        public static string strPolicyRTHealth = 'Health'; 
        public static string strPolicyRTMotor = 'Motor'; 
        public static string strPolicyRTOther = 'Other';

		public static string policyTypeTraditionalLife = '1';
        public static string policyTypeInvestmentLinks = '2';
        public static string policyTypeHealthNProtection = '3';

		public static string PolicyStatusPN = 'PN';
        public static string PolicyStatusPR = 'PR';
        public static string PolicyStatusPE = 'PE';
        public static string PolicyStatusPFE = 'PFE';
        public static string PolicyStatusIF = 'IF';
        public static string PolicyStatusCA = 'CA';
        public static string PolicyStatusLA = 'LA';
//////////////////////////////////My Life - 14/03/2017 ////////////////////////////////////////
		public static string strPolicyRTApplication = 'Application'; 
		public static string strPolicyRTTraditionalLife = 'Traditional Life'; 
		public static string strPolicyRTCreditRelated = 'Credit Related'; 
		public static string strPolicyRTILPRegularPremium = 'ILP Regular Premium'; 
		public static string strPolicyRTILPSinglePremium = 'ILP Single Premium'; 

		public static string strPolicyRTILP = 'ILP'; 

		// Status
  		public static string PolicyStatus00 = '00';
		public static string PolicyStatus01 = '01'; 
		public static string PolicyStatus02 = '02'; 
		public static string PolicyStatus03 = '03'; 
		public static string PolicyStatus04 = '04'; 
		public static string PolicyStatus05 = '05'; 
		public static string PolicyStatus06 = '06'; 
		public static string PolicyStatus07 = '07'; 
		
		public static string PolicyStatus1 = '1'; 
		public static string PolicyStatus4 = '4'; 
		public static string PolicyStatusR = 'R'; 
		public static string PolicyStatusY = 'Y';

		// Progress Status (for 360 deg View Lightning Component)
		public static string PolicyProgressStatus1 = 'Application In Progress'; 
		public static string PolicyProgressStatus2 = 'Application Declined/Incomplete'; 
		public static string PolicyProgressStatus3 = 'Policy Inforce'; 
		public static string PolicyProgressStatus4 = 'Policy Lapsed'; 
//////////////////////////////////End My Life - 14/03/2017 ////////////////////////////////////////			

        //transaction code
        public static string polTransCodeT413 = 'T413';
        public static string polTransCodeT928 = 'T928';

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
    
    public static BusinessHours getBusinessHoursDefault(){
        if (defaultHours == null){
            defaultHours = [select Id from BusinessHours where IsDefault=true];
        }
        return defaultHours;
    }//end of getBusinessHoursDefault
    
    public static map<string,list<RecordType>> mapSobjectToListRecordTypes = new map<string,list<RecordType>>();
    public static map<Id,RecordType> getRecordTypeMap(string ObjecType){
        map <Id,RecordType> IdRecordTypeMap = new map <Id,RecordType>();
        
        if (mapSobjectToListRecordTypes.containsKey(ObjecType))
        {
            for(RecordType r :mapSobjectToListRecordTypes.get( ObjecType)){
                IdRecordTypeMap.put(r.Id, r);
            }//end of loop
        }
        else{
            mapSobjectToListRecordTypes.put(ObjecType, new list<RecordType>() );
            //populating developerIdMap
            for(RecordType r : [select DeveloperName,Id,SobjectType,businessprocessid
                                            from RecordType
                                            where SobjectType =: ObjecType ]){
                mapSobjectToListRecordTypes.get(ObjecType).add(r);                                              
                IdRecordTypeMap.put(r.Id, r);
            }
        }
        return IdRecordTypeMap;
    }//end of getRecordTypeMap
    
    
    public static string caseType10 = '10'; 

    public static string caseStatus1 = '1'; 
    public static string caseStatus2 = '2';
    public static string caseStatus3 = '3';
    public static string caseStatus4 = '4'; 
    public static string caseStatus5 = '5';
    public static string caseStatus6 = '6';
    public static string caseStatus7 = '7';
    public static string caseStatus8 = '8'; 
    public static string caseStatus9 = '9';
    public static string caseStatus10 = '10';
    public static string caseStatus11 = '11'; 
    public static string caseStatus12 = '12';
    public static string caseStatus13 = '13';
    public static string caseStatus14 = '14';
    public static string caseStatus15 = '15';
    public static string caseStatus16 = '16'; 
    public static string caseStatus17 = '17';
    public static string caseStatus18 = '18';      
    public static string caseStatus19 = '19';  
    public static string caseStatus20 = '20';      
    public static string caseStatus21 = '21'; 
    public static string caseStatus22 = '22';
    public static string caseStatus23 = '23';
    public static string caseStatus24 = '24';
    public static string caseStatus25 = '25';
    public static string caseStatus26 = '26';
    public static string caseStatus27 = '27';
    public static string caseStatus28 = '28';
    public static string caseStatus29 = '29';
    public static string caseStatus30 = '30';
    public static string caseSubCategoryEndorsement = 'Endorsement';
    public static string Open_Case = 'Open_CAse';  
    
/***********************************************************************
* User constants
************************************************************************/ 
     /*department*/
    public static string dept01 = '01' ;
    public static string dept02 = '02' ;
    public static string dept03 = '03' ;
    public static string dept04 = '04' ;
    public static string dept05 = '05' ;
    public static string dept06 = '06' ;
    public static string dept07 = '07' ;

    /*Team*/
    public static string userTeamFinance = 'Finance'; 
    public static string userTeamDispatch = 'Dispatch';
    public static string userTeamInbound = 'Inbound';
    public static string userTeamPolicyService = 'Policy Service'; 

/***********************************************************************
* Queue constants
************************************************************************/   
  public static string Queue01_Suffix = '_'+dept01;
  public static string Queue02_Suffix = '_'+dept02;
  public static string Queue03_Suffix = '_'+dept03;
  public static string Queue04_Suffix = '_'+dept04;
  public static string Queue05_Suffix = '_'+dept05;
  public static string Queue06_Suffix = '_'+dept06;
  public static string Queue07_Suffix = '_'+dept07;

/***********************************************************************
* CS VIP Calculation constants
************************************************************************/ 
    public static string strParameterPremium = 'Premium';
    public static string strParameterTenureVintage = 'Tenure/Vintage';
    public static string strParameterNoclaim = 'No claim';
    public static string strParameterNumberPolicies = 'Number of Policies';
}