global class ICF_EmailDeliveryPostMark implements ICF_IEmailDelivery {
	public ICF_EmailDeliveryPostMark() {}

	global Map<Id, Task> sendEmails(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pEmailList, Map<Id, Task> mapTaskUpdates, Set<ID> pRemindTask) {
		System.debug('>>> START ICF_SurveyDeliveryBatch - sendPostmarkEmail <<<');
        Integer count = 0;
        String responseBody;
        Http http;
        HttpRequest req;
        HTTPResponse response;
        JSONGenerator genEmail;
        ICF_SurveyConf__c surveyConfig = ICF_SurveyConf__c.getValues('SURVEY_CONFIGURATION_EMAIL');
        List <String> listBatchEmail =new list<String>();

        if(surveyConfig != null && String.isNotBlank(surveyConfig.Endpoint__c) && String.isNotBlank(surveyConfig.Security_Token__c)){
            for(ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer wrEmail :pEmailList ){
                if(count == 0){
                    //first time enter loop , start json
                    genEmail = JSON.createGenerator(true);
                    genEmail.writeStartArray();
                }else if( count == 500){
                    count = 0;
                    genEmail.writeEndArray();
                    listBatchEmail.add(genEmail.getAsString());
                    genEmail = JSON.createGenerator(true);
                    genEmail.writeStartArray();
                }//end of check count

                genEmail.writeStartObject();
                    genEmail.writeStringField('From' , 'hirikesh.dussoye@sc-mauritius.com' );
                    genEmail.writeStringField('To' , wrEmail.To);
                    genEmail.writeStringField('Subject' , wrEmail.Subject);
                    genEmail.writeStringField('TextBody' , wrEmail.TextBody);
                    genEmail.writeStringField('HtmlBody' , wrEmail.HtmlBody);                
                genEmail.writeEndObject();

                count++;
            }//end of loop WrapperEmailSmsContainer
            genEmail.writeEndArray();
            listBatchEmail.add(genEmail.getAsString());

            //send request for each batch of email
            req = new HttpRequest();
            req.setEndpoint(surveyConfig.Endpoint__c);
            req.setMethod('POST');      
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('X-Postmark-Server-Token', surveyConfig.Security_Token__c);

            System.debug('>>>## sendPostmarkEmail - listBatchEmail size:'+ listBatchEmail.size() );
            for(String batch :listBatchEmail){
                req.setBody(batch);        
                System.debug('>>>## sendPostmarkEmail - req:'+ req.getBody() );
                if (!System.Test.isRunningTest()) {
                    http = new Http();
                    response = http.send(req);
                    if(response.getstatusCode() != 200){
                        System.debug('>>>## sendPostmarkEmail - response:'+ response );
                        System.debug('>>>## sendPostmarkEmail - response boby:'+ response.getBody() );
                        System.debug('>>>## sendPostmarkEmail - ERROR Fail to send email ');
                    }
                }
            }//end of loop in batch
        }
        System.debug('>>> END ICF_SurveyDeliveryBatch - sendPostmarkEmail <<<');

        return mapTaskUpdates;
	}
}