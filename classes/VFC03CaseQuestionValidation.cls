public class VFC03CaseQuestionValidation {
/* 
------------------------------------------------------------
-- - Name          : VFC03CaseQuestionValidation
-- - Author        : Spoon Consulting
-- - Description   : controller used to validate a case
--                   when question are answer correctly
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 23-FEB-2016   HDU    1.0    Initial version
------------------------------------------------------------
*/
    
    private Case caseRecord;
    private integer numberOfValideAnswer = 0;
    public Case caseAnswer{set;get;}
    public boolean refreshParent{set;get;}
    public boolean validateCase{set;get;}
    public boolean hasNid{set;get;}
    public string jsonAnswer{set;get;}
    public string nationalNumber{set;get;}
    public QuestionBySubType__c settingQuestionBySubType;
    public set<String> setQuestions{set;get;}
    public list<wrapper2ColumnQuestions> set2ColumnQuestions{set;get;}
    public map<String,boolean> mapQuestionToAnswers{set;get;}
    public map<String,QuestionDetails__c> mapQuestionToDetails{set;get;}
    public boolean noQuestions { get; set; }
    
    public VFC03CaseQuestionValidation (ApexPages.StandardController stdController) {
        this.caseRecord = [SELECT Answers__c, Validation__c, SR_Sub_Type__c, Type, AccountId,
                            Origin, Complainant__c, RecordTypeId, RecordType.DeveloperName
                            FROM Case
                            WHERE Id = :stdController.getRecord().Id];
        System.debug(caseRecord);
        //this.caseRecord = (Case)stdController.getRecord();

        hasNid = false;
        refreshParent = false;
        jsonAnswer = '';
        nationalNumber='';
        setQuestions = new set<String>();
        set2ColumnQuestions = new list<wrapper2ColumnQuestions>();
        mapQuestionToAnswers = new map<String,boolean>();
        mapQuestionToDetails = new map<String,QuestionDetails__c>();
        getSettings();
        getListQuestions();
        populate2ColumnQues();
        list<String>  listGoodAnswers = desiralizedAnswer(caseRecord.Answers__c);

        System.debug(settingQuestionBySubType);
        System.debug(setQUestions);
        system.debug(set2ColumnQuestions);
        System.debug(mapQuestionToAnswers);
        System.debug(mapQuestionToDetails);
        System.debug(noQuestions);
        
        if( (mapQuestionToAnswers.size() ==0 || settingQuestionBySubType == null) && caseRecord.id != null && !caseRecord.Validation__c){
            validateCase = true;
        }else{
            validateCase = false;
        }
        refreshParent = false;
        if(caseRecord.id != null){
            refreshParent = caseRecord.Validation__c;
        }
    }//end of constructor
    
    public void getSettings(){
        noQuestions = true;
        String delimeter = ';';
        if( String.isNotBlank(caseRecord.SR_Sub_Type__c) 
           && String.isNotBlank(caseRecord.Type ) )
        {
            
            for (QuestionBySubType__c setting : QuestionBySubType__c.getAll().values()){
                if( new set<String>(setting.SubType__c.split(delimeter)).contains(caseRecord.SR_Sub_Type__c)
                    && new set<String>(setting.Origin__c.split(delimeter)).contains(caseRecord.Origin)
                    && new set<String>(setting.CallerType__c.split(delimeter)).contains(caseRecord.Complainant__c)
                    /*&& new set<String>(setting.Record_Type__c.split(delimeter)).contains(caseRecord.RecordType.DeveloperName)*/
                  )
                {
                    settingQuestionBySubType = setting;
                    noQuestions = false;
                }//end of check type & sub type
            }//end of loop   
        }//end of check blank
    }//end of getQuestions
    
    public void getListQuestions(){
        list<String> listQuestionId = new list<String>();
        if( settingQuestionBySubType != null )
        {   
            listQuestionId = settingQuestionBySubType.QuestionName__c.split(';');
            for(String quesId : listQuestionId)
            {
                if(QuestionDetails__c.getInstance(quesId ) != null)
                {
                    mapQuestionToAnswers.put(QuestionDetails__c.getInstance(quesId ).Question__c ,false);
                    mapQuestionToDetails.put(QuestionDetails__c.getInstance(quesId ).Question__c ,QuestionDetails__c.getInstance(quesId ));
                }//end of 
            }//end of loop question
        }//end of check blank
        setQuestions = mapQuestionToAnswers.keySet();
    }//end of getQuestions
    
    public void saveAnswer() { 
        list<String>  listGoodAnswers = desiralizedAnswer(jsonAnswer);
        System.debug('>>> ## saveAnswer - listGoodAnswers:'+listGoodAnswers.size());
        if(listGoodAnswers.size() >= Integer.ValueOf(settingQuestionBySubType.NumberOfValidAnswer__c) ){
            caseRecord.Validation__c = true;
        }else{
            caseRecord.Validation__c = false;           
        }//end of check size
        caseRecord.Answers__c = jsonAnswer;
        
        try{
            update caseRecord; 
            refreshParent = caseRecord.Validation__c;
        }catch(Exception e){
            refreshParent = caseRecord.Validation__c;
            ApexPages.addMessages(e);
        }
    }//end of saveAnswer
    
    public void validatedCase(){
        caseRecord.Validation__c = true;
        caseRecord.Answers__c = null;
        try{
            update caseRecord;
            refreshParent = true;
        }catch(Exception e){
            refreshParent = false;
            ApexPages.addMessages(e);
        }
    }
    
    public void populate2ColumnQues(){
        String fieldlist = '';
        String fieldlist2 = '';
        wrapper2ColumnQuestions wrQues;
        list<String> listQues = new list<String>(setQuestions);
        list<String> listQues2 = new list<String>();
        for(String ques:  listQues){
            wrQues = new wrapper2ColumnQuestions();
                wrQues.question1 =  ques;
                wrQues.answerApiName =  '';
            if(mapQuestionToDetails.containsKey(ques)){
                wrQues.answerApiName =mapQuestionToDetails.get(ques).AnswerField__c;
                if(wrQues.answerApiName.toLowerCase() != 'nationalid')
                fieldlist +=  wrQues.answerApiName+',';
                if (wrQues.answerApiName.indexOf('Policy__r.') == 0) {
                    listQues2.add(ques);
                } else {
                    fieldlist2 +=  wrQues.answerApiName+',';
                }
            }
            set2ColumnQuestions.add(wrQues);
        }//end of loop

        System.debug('>>>>fieldlist<<<<:' + fieldlist);

        if(String.IsNotBlank(fieldlist)){
            fieldlist = fieldlist.removeEnd(',');
            boolean found = false;
            try {
                caseAnswer = Database.query('Select '+fieldlist+' From Case Where Id =\''+caseRecord.id+'\' Limit 1');
                found = true;
            } catch (Exception e) {
            }
            if (!found) {
                try {
                    caseAnswer = Database.query('Select '+fieldlist2+' From Case Where Id =\''+caseRecord.id+'\' Limit 1');
                } catch (Exception e) {
                }
                for (Integer i = set2ColumnQuestions.size() - 1; i >= 0; i--) {
                    wrQues = set2ColumnQuestions[i];
                    for (Integer j = 0; j < listQues2.size(); j++) {
                        if (listQues2[j] == wrQues.question1) {
                            set2ColumnQuestions.remove(i);
                        }
                    }
                }
            }
        }
    }//end of populate2ColumnQues
    
    private list<String> desiralizedAnswer(string jsonAnswer){
        list<String>  listGoodAnswers = new list<String> ();
        if(String.isNotBlank(jsonAnswer)){
            System.debug('>>> ## desiralizedAnswer - jsonAnswer:'+jsonAnswer);
            for(String answers :jsonAnswer.split(';')){
                mapQuestionToAnswers.put(answers.split(':')[0],Boolean.valueOf(answers.split(':')[1]));
                System.debug('>>> ## desiralizedAnswer - answers:'+answers.split(':')[1]);
                if(answers.split(':')[1] == 'true'){
                    listGoodAnswers.add(answers.split(':')[0]);
                }
            }//end of loop
        }
        return listGoodAnswers;
    }//end of desiralizedAnswer
    
     public void loadNationalIDFromEIP(){
        SCRUMCustomerSearchEipCalloutHelper calloutHelper; 
        hasNid = false;
        if(String.isNotBlank(this.caseRecord.accountId)){
            Account a = [select id, name, Customer_ID__c
            				//,IsPersonAccount 
            				from Account where id = :this.caseRecord.accountId];
            Map<String, String> searchParams = new Map<String, String>();
            searchParams.put('messageID', GuidUtil.NewGuid());
            searchParams.put('productCD', 'Life');
            searchParams.put('processNM', 'ENQ');
            searchParams.put('entityCD', 'TH');
            //searchParams.put('phoneNo', phoneNo);
            searchParams.put('genderCD', '');
            searchParams.put('birthDT', '');
            searchParams.put('emailAddress', '');
            searchParams.put('recordsPerPage','50');
            searchParams.put('pageNO','1');
            searchParams.put('customerID',a.Customer_ID__c);
            searchParams.put('orderBy','');
            searchParams.put('ordering','');
            searchParams.put('englishNMWildCardSearchIND','');
            searchParams.put('localNMWildCardSearchIND','');
            searchParams.put('policyNOWildCardSearchIND','');
            searchParams.put('ssnWildCardSearchIND','');
            searchParams.put('socialSecurityNO', '');
            searchParams.put('policyNO', '');
            searchParams.put('chineseNM', '');
            searchParams.put('lastNM', '');//???
            
           try {
                calloutHelper = new SCRUMCustomerSearchEipCalloutHelper(searchParams);
                List<SCRUMEipVo.CustomerVO> sList = calloutHelper.execute();
                if(sList != null && sList.size() > 0){
                    nationalNumber = sList[0].HKID;
                    hasNid = true;
                }
           } catch (Exception e) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
           }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No account found'));
        }
    }
    
    public class wrapper2ColumnQuestions{
        public  string question1{set;get;}
        public  string answerApiName{set;get;}
    }//end of wrapper class
}//end of class