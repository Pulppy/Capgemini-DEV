public without sharing class CTRL_ValidationPage{
    public Account                          applicant                 {get;set;}
    public ErrorMessage__c                  errorMessage              {get;set;}
    public List<showMessageError>           showMessageErrorList      {get;set;} 
    public User                             user                      {get;set;}
    public static final String              STRING_DATE_FORMAT_PATTERN_YYYYYMMDD ='YYYYMMDD';
    public static final String              STRING_DATE_FORMAT_PATTERN_DDMMYYYYY ='DDMMYYYY';
    Public List<Account>                    applicants                {get;set;}    
    public Account objectAcc{get; set;}
    public String localeOfUser{get; set;}
     public String strDefaultCurrency{get;set;}
    //yyyymmdd
    public class showMessageError{
        private String                      id             {get; set;}
        private String                      errorCode      {get; set;}
        private String                      messageError   {get; set;}
    }



    public CTRL_ValidationPage () {  
        this.applicant = new Account();
        applicants = new List<Account>(); 
        this.applicant.City__c = 'city';
        for(Integer i = 0; i < 2; i++){
            applicants.add(new Account());
        }
        
        System.debug('@@@2this.applicant: '+ this.applicants);
        localeOfUser = UserInfo.getLocale();
        strDefaultCurrency = UserInfo.getDefaultCurrency();
    }

    public void saveApplicant(){
        try{
            if(validateApplicant()){
                upsert applicant;
            }
        }catch(Exception ex){
            System.debug('@@@@ex'+ ex);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage());
            //ApexPages.addMessage(myMsg);
        }
        
    }

    /* Define error message on Page
        FullName = '001'
        Address = '002'
        MobilePhone = '003'
        HomePhone = '004'
        Email = '005'
        Birthdate ='006'
        ......

        Emty -- 001
        inValid - 002
     */
    private Boolean validateApplicant(){
        system.debug('@@@@date1: '+this.applicant.TestDate__c);
        Boolean errorOnField = true;
        this.user = [Select id, LocaleSidKey from User where id=: userInfo.getUserId()];
        system.debug('@@@@user: '+this.user);
        this.showMessageErrorList = new List <showMessageError>();
        showMessageError errorMessage = new showMessageError();
        if(!String.isBlank(this.applicant.TestDate__c)){
            if(!isCheckDateFormat(this.applicant.TestDate__c)){
                errorMessage.errorCode = '011';
                errorMessage.messageError = 'inValid Birthdate';
                errorOnField = false;
            }
        }
            

        if(this.applicant.Name == null || this.applicant.Name == '' ){
            errorMessage.errorCode = '001';
            errorMessage.messageError = 'Please put full name';
            errorOnField = false;
        }else if(this.applicant.Address_line_1__c == null || this.applicant.Address_line_1__c == '' ){
            errorMessage.errorCode = '002';
            errorMessage.messageError = 'Please put Address';
            errorOnField = false;
        }/*else if(this.applicant.MobilePhone__c == null || this.applicant.MobilePhone__c == '' ){
            errorMessage.errorCode = '003';
            errorMessage.messageError = 'Please put Mobile Phone';
            errorOnField = false;
        }*/else if(this.applicant.Phone == null || this.applicant.Phone == '' ){
            errorMessage.errorCode = '004';
            errorMessage.messageError = 'Please put Home phone';
            errorOnField = false;
        }else if(this.applicant.Tech_Person_Email__c == null || this.applicant.Tech_Person_Email__c == '' ){
            errorMessage.errorCode = '005';
            errorMessage.messageError = 'Please put Email';
            errorOnField = false;
        }else if(this.applicant.PersonBirthdate__c == null ){
            errorMessage.errorCode = '006';
            errorMessage.messageError = 'Please put Birthdate';
            errorOnField = false;
        }else if(this.applicant.Address_line_1__c.length() > 15){
            errorMessage.errorCode = '007';
            errorMessage.messageError = 'inValid length address';
            errorOnField = false;
        }else if(this.applicant.MobilePhone__c.length() > 20 || !this.applicant.MobilePhone__c.isNumeric()){
            errorMessage.errorCode = '008';
            errorMessage.messageError = 'inValid length Mobile Phone';
            errorOnField = false;
        }else if(this.applicant.Phone.length() > 25){
            errorMessage.errorCode = '009';
            errorMessage.messageError = 'Invalid phone length';
            errorOnField = false;
        }else if(this.applicant.Tech_Person_Email__c.length() > 30 ){
            errorMessage.errorCode = '010';
            errorMessage.messageError = 'Invalid length Email';
            errorOnField = false;
        } 
        
        if(errorMessage != null){
            this.showMessageErrorList.add(errorMessage);
        }
        
        return errorOnField;
    }

    private Boolean isCheckDateFormat(String dateformat){
        Boolean errorOnField = true;
        if(Pattern.matches(Label.TECH_DATE_FORMAT_REGEX, dateformat)){
            Integer day = Integer.valueOf(this.applicant.TestDate__c.substring(0,2));
            Integer month = Integer.valueOf(this.applicant.TestDate__c.substring(3,5));
            Integer year = Integer.valueOf(this.applicant.TestDate__c.substring(6,this.applicant.TestDate__c.length()));
             system.debug('@@@@month: '+month + 'daty:'+ day + 'year: '+ year);
            if(month > 12){
                errorOnField = false;
            }
        }else if(Pattern.matches(Label.TECH_DATE_FORMAT_REGEX1, dateformat)){
            Integer year = Integer.valueOf(this.applicant.TestDate__c.substring(0,4));
            Integer month = Integer.valueOf(this.applicant.TestDate__c.substring(5,7));
            Integer day = Integer.valueOf(this.applicant.TestDate__c.substring(8,this.applicant.TestDate__c.length()));
             system.debug('@@@@month: '+month + 'daty:'+ day + 'year: '+ year);
            if(month > 12){
                errorOnField = false;
            }
        }
        return errorOnField;
    }
}