public with sharing class LN_TopSideBarInfo {
    
    public class Data {
    
        @AuraEnabled
        public Account account { get; set; }

        //@AuraEnabled
        //public Contact contact { get; set; }
        
        @AuraEnabled
        public Boolean isVIP { get; set; }

        @AuraEnabled
        public String maritalStatus { get; set; }

        @AuraEnabled
        public Case lastCase { get; set; }
        
        @AuraEnabled
        public ICF_SurveyQuestionResponse__c surveyDetails { get; set; }

        @AuraEnabled
        public String ResponseDisplay { get; set; }

        @AuraEnabled
        public String ResponseIcon { get; set; }
        
		//Traditional Life
		@AuraEnabled
		public Integer TradLifeNumOfApp{set;get;} // Number of Application In Progress  - Traditional Life
		@AuraEnabled
		public Integer TradLifeNumOfDeclinedIncomplete{set;get;} //  Application Declined/Incomplete  - Traditional Life
		@AuraEnabled
		public Integer TradLifeNumOfInforcePolicy{set;get;} //Policy Inforce - Traditional Life
		@AuraEnabled
		public Integer TradLifeNumOfLapsedPolicy{set;get;} //Policy Lapsed - Traditional Life

		//Credit Related
		@AuraEnabled
		public Integer CredRelatedNumOfApp{set;get;} // Number of Application In Progress- Credit Related
		@AuraEnabled
		public Integer CredRelatedNumOfDeclinedIncomplete{set;get;} // Application Declined/Incomplete  - Credit Related
		@AuraEnabled
		public Integer CredRelatedNumOfInforcePolicy{set;get;} //Policy Inforce - Credit Related
		@AuraEnabled
		public Integer CredRelatedNumOfLapsedPolicy{set;get;} //Policy Lapsed- Credit Related

		//ILP Combine
		@AuraEnabled
		public Integer ILPNumOfApp{set;get;} // Number of Application In Progress-
		@AuraEnabled
		public Integer ILPNumOfDeclinedIncomplete{set;get;} // Application Declined/Incomplete  - 
		@AuraEnabled
		public Integer ILPNumOfInforcePolicy{set;get;} //Policy Inforce - 
		@AuraEnabled
		public Integer ILPNumOfLapsedPolicy{set;get;} //Policy Lapsed- 

		/*
		//ILP Regular Premium
		@AuraEnabled
		public Integer ILPReguPremiumNumOfApp{set;get;} // Number of Application In Progress- ILP Regular Premium
		@AuraEnabled
		public Integer ILPReguPremiumNumOfDeclinedIncomplete{set;get;} // Application Declined/Incomplete  - ILP Regular Premium
		@AuraEnabled
		public Integer ILPReguPremiumNumOfInforcePolicy{set;get;} //Policy Inforce - ILP Regular Premium
		@AuraEnabled
		public Integer ILPReguPremiumNumOfLapsedPolicy{set;get;} //Policy Lapsed- ILP Regular Premium

		//ILP Single Premium
		@AuraEnabled
		public Integer ILPSingPremiumNumOfApp{set;get;} // Number of Application In Progress- ILP Single Premium
		@AuraEnabled
		public Integer ILPSingPremiumNumOfDeclinedIncomplete{set;get;} // Application Declined/Incomplete - ILP Single Premium
		@AuraEnabled
		public Integer ILPSingPremiumNumOfInforcePolicy{set;get;} //Policy Inforce - ILP Single Premium
		@AuraEnabled
		public Integer ILPSingPremiumNumOfLapsedPolicy{set;get;} //Policy Lapsed- ILP Single Premium
		*/
        
        @AuraEnabled
        public list<Policy__c> listPolicies { get;set; }
        
        @AuraEnabled
        public boolean checkClosedCase { get; set; }

        @AuraEnabled
        public Integer numClosedCase { get; set; }
        
        @AuraEnabled
        public list<Case> openCases { get; set; }

		@AuraEnabled
        public Boolean caseListRender { get; set; }
        
        @AuraEnabled
        public Map<String, String> caseOT { get; set; }
        
        @AuraEnabled
        public String debug { get; set; }

		@AuraEnabled
        public String caseJSON { get; set; }
    }
    
    //----------------------------------------------------------------------
    // retreive Account for display.
    // 1.when id account is pass as url param, retreive same account.
    // 2.when id case is passed as url param, retireve
    //  account of contact assoicated with the case Case.Contact.Account
    //----------------------------------------------------------------------
    @AuraEnabled
    public static LN_TopSideBarInfo.Data prepare(String objId) {
        String objIdIn = objId;
        
        Account account = new Account();
        
        try {
			/////////////////////////////////////////////////////////////////////////Account Object Id//////////////////////////////////////////////////////////////////////////////////
        	if (String.ValueOf(objIdIn).startsWithIgnoreCase( Schema.SObjectType.Account.getKeyPrefix() ) ){
            
				/*
				SELECT  Id, Age__c, Days_to_Birthday__c, PersonEmail__c, FirstName__c,
                                                                    Gender__c,LastName__c,Marital_status__c,
                                                                    PersonContactId__c, PersonBirthdate__c,Mobile_Number__c,PersonMobilePhone__c,
                                                                    primary_language__c, preferred_Channel__c,PersonHomePhone__c,Office_Number__c
																	//,PersonDoNotCall,
                                                                    //PersonOtherPhone
                                                            FROM    Account
                                                            WHERE   Id = :objIdIn  
				
				*/

            	list<Account> listAccount = new list<Account>( [SELECT  Id, Name, Age__c, Days_to_Birthday__c,
            	 //PersonEmail, FirstName,
            	  //Salutation,
																		Gender__c,Marital_status__c, 
																		//PersonContactId, PersonBirthDate, 
																		Preferred_Channel__c, 
																		//PersonMobilePhone, PersonHomePhone, 
																		Primary_language__c,
										Office_Number__c, 
										//PersonDoNotCall, PersonOtherPhone, IsPersonAccount, 
										Tech_Person_Email__c
																		FROM Account
																		WHERE Id = :objIdIn  ] );
            	if(listAccount.size() >0 )  account = listAccount[0];
            	else  						account = new Account();
            	 //end of check listContact.size()
        	} 
			/////////////////////////////////////////////////////////////////////////Case Object Id//////////////////////////////////////////////////////////////////////////////////
			else if ( String.ValueOf(objIdIn).startsWithIgnoreCase( Schema.SObjectType.Case.getKeyPrefix() ) ){
            	//SCSMO 20160929 updated query to remove ref to Mobile_Formula__c to allow encryption on PersonMobilePhone 
				/*
				SELECT   Contact.Account.Id, Contact.Account.Age__c, Contact.Account.Days_to_Birthday__c, Contact.Account.Tech_Person_Email__c, Contact.Account.FirstName__c, Contact.Account.Gender__c,
				   Contact.Account.LastName__c, Contact.Account.Marital_status__c, 
                                                            Contact.Account.PersonContactId__c ,Contact.Account.PersonBirthdate__c,  Contact.Account.primary_language__c ,Contact.Account.preferred_Channel__c,Contact.Account.Mobile_Number__c,Contact.Account.PersonMobilePhone__c,
															//Contact.Account.PersonOtherPhone,
															Contact.Account.PersonEmail__c,Contact.Account.PersonHomePhone__c,Contact.Account.Office_Number__c,
															//Contact.Account.PersonDoNotCall, 
															CreatedDate FROM Case  WHERE    Id = :objIdIn  
				*/

            	list<Case> listCase = new list<Case>( [SELECT Contact.Account.Id, Contact.Account.Name, Contact.Account.Age__c, Contact.Account.Days_to_Birthday__c,
														Contact.Account.Tech_Person_Email__c,Contact.Account.Gender__c, Contact.Account.Marital_status__c, 
														//Contact.Account.PersonContactId, 
														//Contact.Account.PersonBirthDate, 
														Contact.Account.primary_language__c, Contact.Account.preferred_Channel__c
														//Contact.Account.PersonMobilePhone 
														FROM  Case
														WHERE Id = :objIdIn  ] );
            	if(listCase.size() >0 ){
                	account = listCase[0].Contact.Account;
					/*
                	if (account == null) {
                    	listCase = new list<Case>( [SELECT  Account.Id, Account.Age__c, Account.Days_to_Birthday__c, Account.Tech_Person_Email__c,
                                                            Account.FirstName__c, Account.Gender__c, Account.LastName__c, Account.Marital_status__c, 
                                                            Account.PersonContactId__c, Account.PersonBirthdate__c, Account.primary_language__c , 
															Account.preferred_Channel__c, Account.Mobile_Number__c, Account.PersonMobilePhone__c, 
															//Account.PersonOtherPhone, 
															Account.PersonEmail__c, Account.PersonHomePhone__c, 
															Account.Office_Number__c, 
															//Account.PersonDoNotCall, 
															CreatedDate 
															FROM Case
															WHERE Id = :objIdIn  ] );   
                    	if (listCase.size() > 0) {
                        	account = listCase[0].Account;
                    	}                                                                
                	}
					*/
            	}else 	account = new Account();
            	//end of check listCase.size()
        	} 
			/////////////////////////////////////////////////////////////////////////Contact Object Id//////////////////////////////////////////////////////////////////////////////////
			/*
			else if ( String.ValueOf(objIdIn).startsWithIgnoreCase( Schema.SObjectType.Contact.getKeyPrefix() ) ){
            	//SCSMO 20160929 updated query to remove ref to Mobile_Formula__c to allow encryption on PersonMobilePhone 
            	list<Contact> listContact = new list<Contact>( [SELECT   Account.Id, Account.Age__c, Account.Days_to_Birthday__c, Account.Tech_Person_Email__c,
                                                            Account.Name, Account.Gender__c,Account.Marital_status__c, 
                                                            //Account.PersonContactId , 
															//Account.PersonBirthdate, 
															Account.primary_language__c , 
															Account.preferred_Channel__c, Account.Mobile_Number__c, 
															//Account.PersonMobilePhone, 
															//Account.PersonOtherPhone, Account.PersonEmail, Account.PersonHomePhone, 
															Account.Office_Number__c
															//Account.PersonDoNotCall
														    FROM  Contact
														    WHERE Id = :objIdIn  ] );
            	if(listContact.size() >0 )  account = listContact[0].Account;
            	else                     	account = new Account();
            	
        	}
			*/
						
			else     	account = new Account();
        	//end of check if contact /////////////////////////////////////////////////////////End /////////////////////////////////////////////////////////
        } catch (Exception e) {System.debug('LN_TopSideBarInfo.putObjectId: ' + e);}

       	if (account == null)
           	account = new Account();
         
        LN_TopSideBarInfo.Data tag = new LN_TopSideBarInfo.Data();
        tag.account = account;
        tag.listPolicies = new list<Policy__c>();
		tag.listPolicies = getAccountPolicies(account);
        tag.isVIP = checkVip(account, tag.listPolicies);
        tag.maritalStatus = getMaritalStatus(account);
        //tag.contact = loadContact(account);
        tag.surveyDetails = getSurveyDetails(account, tag);
        tag.checkClosedCase = getCheckClosedCase(account, tag);
        tag.openCases = getOpenCases(account);
		tag.caseListRender = tag.openCases.size()>0;
		tag.caseJSON = getCaseJSON(account);
        tag.caseOT = new Map<String, String>();
		try {
			if(tag.openCases.size()>0){
				Map<String, Schema.SobjectField> fields = (tag.openCases[0]).getSObjectType().getDescribe().fields.getMap();
        
				for (String s : fields.keySet()) {
    				String label = fields.get(s).getDescribe().Label;
        			tag.caseOT.put(s, label);
				} 
			}       
		} catch (Exception e) {
        }
        
		if (account != null && account.Id != null){
			list<Case> listCustomerCases = new list<Case> (
				[ SELECT  Character__c , Mood_of_Customer__c
					FROM    Case
					WHERE   AccountId = :account.Id
					Order By createdDate DESC
					Limit 1
				]
			);

			if (listCustomerCases.size() > 0 ) 	tag.lastCase = listCustomerCases[0];
			    
        }
        if (tag.lastCase == null) tag.lastCase = new Case();
       
        
		map<string,String> mapResponseMapping = new map<string,String>{
        //'1' => 'Very disatisfied',
        //'2' => 'Disatisfied',
        //'3' => 'Normal',
        //'4' => 'Satisfied',
        //'5' => 'Very satisfied'
        'Completely Dissatisfied' => 'Completely Dissatisfied',
        'Quite Dissatisfied' => 'Quite Dissatisfied',
        'Neither Satisfied nor Dissatisfied' => 'Neither Satisfied nor Dissatisfied',
        'Quite Satisfied' => 'Quite Satisfied',
        'Completly Satisfied' => 'Completly Satisfied'
    	};        
            
		if (String.isNotBlank(tag.surveyDetails.Response__c)) {
			tag.ResponseDisplay = tag.surveyDetails.Response__c;
			if (mapResponseMapping.containsKey(tag.surveyDetails.Response__c)) {
				tag.ResponseIcon = tag.surveyDetails.Response__c;
				tag.ResponseDisplay = mapResponseMapping.get(tag.surveyDetails.Response__c);
			}
		}   
        
        countPolicyType(tag);
        //System.debug('Debug Log Tag: ' + tag);
        return tag;
    }

	//----------------------------------------------------------------------
    //retreive Policies of account 
    //---------------------------------------------------------------------- 
    @TestVisible
	private static list<Policy__c> getAccountPolicies(Account account)
    //private void getAccountPolicies(Account account)
	{
        //listPolicies.clear(); 
		list<Policy__c> templistPolicies = new list<Policy__c>();
        for(Policy__c policy : [    SELECT  Id, Insured__c, Customer__c, Policy_Type__c, Policy_status__c , Progress_Status__c
                                    FROM    Policy__c 
                                    where    (Customer__c = :account.Id or Insured__c = :account.Id) 
                                    ])
        {
            templistPolicies.add(policy);
        }
		//system.debug('## Start templistPolicies:'+ templistPolicies);
		return templistPolicies;
    }//end of getAccountPolicies

    private static void countPolicyType(LN_TopSideBarInfo.Data tag) {
		tag.TradLifeNumOfApp = 0;
		tag.TradLifeNumOfDeclinedIncomplete= 0;
		tag.TradLifeNumOfInforcePolicy= 0;
		tag.TradLifeNumOfLapsedPolicy= 0;

		
		tag.CredRelatedNumOfApp= 0;
		tag.CredRelatedNumOfDeclinedIncomplete= 0;
		tag.CredRelatedNumOfInforcePolicy= 0;
		tag.CredRelatedNumOfLapsedPolicy= 0;

		/*
		tag.ILPReguPremiumNumOfApp= 0;
		tag.ILPReguPremiumNumOfDeclinedIncomplete= 0;
		tag.ILPReguPremiumNumOfInforcePolicy= 0;
		tag.ILPReguPremiumNumOfLapsedPolicy= 0;

	    tag.ILPSingPremiumNumOfApp= 0;
		tag.ILPSingPremiumNumOfDeclinedIncomplete= 0;
		tag.ILPSingPremiumNumOfInforcePolicy= 0;
		tag.ILPSingPremiumNumOfLapsedPolicy= 0;
        */

		tag.ILPNumOfApp= 0;
		tag.ILPNumOfDeclinedIncomplete= 0;
		tag.ILPNumOfInforcePolicy= 0;
		tag.ILPNumOfLapsedPolicy= 0;

        for(Policy__c policy : tag.listPolicies){
            if(policy.Policy_Type__c  == AP_Constant.strPolicyRTTraditionalLife){ //Traditional Life
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus1)	 tag.TradLifeNumOfApp++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus2)   tag.TradLifeNumOfDeclinedIncomplete++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus3)	 tag.TradLifeNumOfInforcePolicy++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus4)	 tag.TradLifeNumOfLapsedPolicy++;
            }else if(policy.Policy_Type__c  == AP_Constant.strPolicyRTILP){
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus1)   tag.ILPNumOfApp++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus2)   tag.ILPNumOfDeclinedIncomplete++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus3)	 tag.ILPNumOfInforcePolicy++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus4)	 tag.ILPNumOfLapsedPolicy++;
            }/*
			else if(policy.Policy_Type__c  == AP_Constant.strPolicyRTILPRegularPremium){
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus1)	 tag.ILPReguPremiumNumOfApp++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus2)   tag.ILPReguPremiumNumOfDeclinedIncomplete++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus3)	 tag.ILPReguPremiumNumOfInforcePolicy++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus4)	 tag.ILPReguPremiumNumOfLapsedPolicy++;
            }else{//ILP Single Premium
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus1)   tag.ILPSingPremiumNumOfApp++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus2)   tag.ILPSingPremiumNumOfDeclinedIncomplete++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus3)   tag.ILPSingPremiumNumOfInforcePolicy++;
                if(policy.Progress_Status__c == AP_Constant.PolicyProgressStatus4)   tag.ILPSingPremiumNumOfLapsedPolicy++;
            }*/
        }//end loop policy     
		
    }
    
	/*
    @AuraEnabled
    public static Contact loadContact(Account account) {
        Id contactId = account.PersonContactId__c;
        Contact tag = new Contact();
        List<Contact> rs = [select Id, Name from Contact where Id =: contactId];
        if (rs != null && rs.size() > 0) {
            tag = rs[0];
        }
        return tag;
    }   
	*/
    
    @AuraEnabled
    public static String getMaritalStatus(Account account) {
        if (account.Marital_status__c == 'Single') {
            return Label.C01_Marital_Single;
        } else if (account.Marital_status__c == 'Married') {
            return Label.C01_Marital_Married;
        } else if (account.Marital_status__c == 'Divorced') {
            return Label.C01_Marital_Divorce;
        } else if (account.Marital_status__c == 'Unknown') {
            return Label.C01_Marital_X;
        } else if (account.Marital_status__c == 'Widowed') {
            return Label.C01_Marital_Widowed;
        } else {
            return '-';
        }
        return '';
    }
    
    //----------------------------------------------------------------------
    //retreive and check policy(s) of Account
    // this is used to display VIP icon of customerin block 1
    //----------------------------------------------------------------------
    //AMI 21/10/2016 - new vip calculation
    @AuraEnabled
    public static Boolean checkVip(Account account, list<Policy__c> listPolicies){
        system.debug('## Start getcheckVip');

        listPolicies.clear();
        for(Policy__c policy : [    SELECT  Insured__c, Customer__c,Policy_status__c,Policy_Type__c,
                                            RecordType.DeveloperName,Total_Premium__c,
                                            Effective_date__c,Progress_Status__c//,//Previous_Policy_No__c,Transaction_Code__c,
                                            //(SELECT id,Claim_intimation_date__c,Claim_Settlement_Date__c FROM Claims__r  Order By Claim_intimation_date__c DESC)
                                    FROM    Policy__c
                                    where    (Customer__c = :account.Id or Insured__c = :account.Id)
                                    ])
        {
            listPolicies.add(policy);
        }
        
        map <string,double> mapPremium = new map <string,double>();
        integer tenureRenewalTime = 0;
        integer claimYears = 0;
        integer numPolicies = 0;
        map <string,integer> mapSumPolPerTransCode = new map <string,integer>();
        integer sumPolBAGI = 0;

        //querying cs VIP Calculation
        for(VIPCalculation__c vp : VIPCalculation__c.getAll().values()){
            //Premium
            if(vp.Parameter__c == AP_Constant.strParameterPremium){
                if(string.isNotBlank(vp.PolicyType__c) && vp.Threshold__c != null){
                    mapPremium.put(vp.PolicyType__c,integer.valueOf(vp.Threshold__c));
                }
            }else if(vp.Parameter__c == AP_Constant.strParameterTenureVintage && vp.Threshold__c != null){
                //Tenure/vintage
                tenureRenewalTime = integer.valueOf(vp.Threshold__c);
            }else if(vp.Parameter__c == AP_Constant.strParameterNoclaim && vp.Threshold__c != null){
                 //No claim
                 claimYears = integer.valueOf(vp.Threshold__c);
            }else if(vp.Parameter__c == AP_Constant.strParameterNumberPolicies && vp.Threshold__c != null){
                //Number of Policies
                numPolicies = integer.valueOf(vp.Threshold__c);
            }  
        }

        if(account != null && account.Id != null){
            for(Policy__c policy : listPolicies){
                //check for premium
                if(mapPremium.containsKey(policy.Policy_Type__c) && policy.Total_Premium__c != null){
                    if(integer.valueOf(policy.Total_Premium__c) > mapPremium.get(policy.Policy_Type__c)){
                        return true;
                    }
                }

                //Tenure/Vintage
				/*
                if((policy.Transaction_Code__c == AP_Constant.polTransCodeT413 || 
                    policy.Transaction_Code__c == AP_Constant.polTransCodeT928) &&
                    string.isNotBlank(policy.Previous_Policy_No__c)){
                        if(mapSumPolPerTransCode.containsKey(policy.Previous_Policy_No__c)){
                            integer temp = mapSumPolPerTransCode.get(policy.Previous_Policy_No__c);
                            mapSumPolPerTransCode.put(policy.Previous_Policy_No__c,++temp);
                        }else{
                            mapSumPolPerTransCode.put(policy.Previous_Policy_No__c,1);
                        }  
                }
				

                //No claim
                if(policy.Claims__r.size() > 0){
                    for(Claim__c cl : policy.Claims__r){
                        if(cl.Claim_Settlement_Date__c != null){
                            integer tempVariable = (cl.Claim_Settlement_Date__c.monthsBetween(date.today()))/12;
                            if(tempVariable >= claimYears){
                                return true;
                            }
                        }
                    }
                }else 
				*/
				if(policy.Effective_date__c != null){
                    integer tempVariable1 = (policy.Effective_date__c.monthsBetween(date.today()))/12;
                    if(tempVariable1 >= claimYears){
                        return true;
                    }
                }

                //Number of Policies
                if(policy.Policy_status__c == AP_Constant.PolicyStatusIF){
                    sumPolBAGI ++;
                }
            }//end looping in policy
        }

        //Tenure/Vintage
        if(mapSumPolPerTransCode.size() == 1){
            if(mapSumPolPerTransCode.values()[0] == tenureRenewalTime){
                return true;
            }
        }

        //Number of Policies
        if(sumPolBAGI >= numPolicies){
            return true;
        }

        return false;
    }//end of checkVip
    
    @AuraEnabled
    public static ICF_SurveyQuestionResponse__c getSurveyDetails(Account account, Data tag) {
        ICF_SurveyQuestionResponse__c surveyResponse = new ICF_SurveyQuestionResponse__c();
        if(account != null && account.Id != null){
            list<ICF_SurveyQuestionResponse__c> listResponse = new list<ICF_SurveyQuestionResponse__c>(
                                                                [   SELECT  SurveyTaker__r.Survey__r.Name, SurveyTaker__r.Account__c, SurveyTaker__r.Survey__c,
                                                                                Response__c, SurveyTaker__r.CreatedDate, SurveyTaker__r.Targeted_Case__c,
                                                                                SurveyTaker__r.Targeted_Case__r.CaseNumber, SurveyTaker__r.Targeted_Policy__c,
                                                                                SurveyTaker__r.Targeted_Policy__r.Name
                                                                        FROM    ICF_SurveyQuestionResponse__c
                                                                        WHERE   SurveyTaker__r.Account__c = :account.Id
                                                                        Order by CreatedDate DESC
                                                                        ]
                                                                );
            if(listResponse.size() > 0 )
            {
                surveyResponse = listResponse[0];
                
	            if( String.isNotBlank(surveyResponse.Response__c)){
    	            String ResponseDisplay = surveyResponse.Response__c;
                    String ResponseIcon = '';
    				map<string,String> mapResponseMapping = new map<string,String>{
				        'completely dissatisfied' => 'Completely Dissatisfied',            
        				'quite dissatisfied' => 'Quite Dissatisfied',            
        				'neither satisfied nor dissatisfied' => 'Neither Satisfied nor Dissatisfied',            
        				'quite satisfied' => 'Quite Satisfied',            
        				'completely satisfied' => 'Completely Satisfied'
    				};
        	        if( mapResponseMapping.containsKey(surveyResponse.Response__c.toLowerCase()) ){
            	        ResponseIcon = surveyResponse.Response__c;
                	    ResponseDisplay = mapResponseMapping.get(surveyResponse.Response__c.toLowerCase());
                	}
                    tag.responseIcon = ResponseIcon.toLowerCase();
                    tag.responseDisplay = ResponseDisplay;
            	}
            }
        }//end of check null account
        return surveyResponse;
    }//end of getLastCase

	public static boolean getCheckClosedCase(Account account, Data data){
        data.numClosedCase = 0;
        if (account != null && account.Id != null){
            String complaint = AP_Constant.caseTypeComplaint;
            /*
            Integer numClosedCase = [   SELECT  count()
                                        FROM    Case
                                        WHERE   AccountId = :account.Id
                                        AND     Type = :complaint
                                        AND     createddate > LAST_N_MONTHS:12 ];
			*/
            Integer numClosedCase = [   SELECT  count()
                                        FROM    Case
                                        WHERE   AccountId = :account.Id
												AND (       isClosed = false
                                    				OR  Type = :complaint
                                				)                                     
                                        ];
            data.numClosedCase = numClosedCase;
            if(numClosedCase > 0){
                return true;
            }
        }//end of check account
        return false;
    }//end of getCheckActiveCampaign
    
    public static list<Case> getOpenCases(Account account) {
        String complaint = AP_Constant.caseTypeComplaint;
        list<Case> listOpenCases = new list<Case>();
        if (account != null && account.Id != null) {
            for(Case c: [   SELECT  Id, Casenumber ,  toLabel(Origin),  toLabel(SR_Sub_Type__c), CreatedDate
                            FROM    Case
                            WHERE   AccountId = :account.Id
                            //AND CreatedDate > LAST_YEAR
                            AND (       isClosed = false
                                    OR  Type = :complaint
                                )
                            Order By CreatedDate DESC
                            ])
            {
                listOpenCases.add(c);
            }
        }
		//end of check null account
		//if(listOpenCases.size()==0)	listOpenCases= null;

		return listOpenCases;
    }//end of getLastCase
 
	 
    public static String getCaseJSON(Account account){
		ChartDataWrapper chartData = new ChartDataWrapper();
        if(account != null && account.Id != null){
			List<Case> lstCase = [SELECT Id, Origin FROM Case WHERE AccountId = :account.Id limit 100 ];
			Map<String,Integer> mapCaseSource = new Map<String,Integer>();
        
			for(Case l : lstCase)
			{
				if(mapCaseSource.containsKey(l.Origin))
				{
					mapCaseSource.put(l.Origin, mapCaseSource.get(l.Origin) + 1 ) ;
				}else{
					mapCaseSource.put(l.Origin, 1) ;        
				}
			}
			
			for(String key : mapCaseSource.keySet())
			{
				chartData.chartLabels.add(key);
				chartData.chartData.add(mapCaseSource.get(key));
			}
        }
        return System.json.serialize(chartData);
    }
    
    /**
     * Wrapper class to serialize as JSON as return Value
     * */
    class ChartDataWrapper
    {
       public List<String> chartLabels {get;set;}
       public List<Integer> chartData {get;set;}
        
        public ChartDataWrapper(){
            chartLabels = new List<String>();
            chartData = new List<Integer>();
        }
    }
}