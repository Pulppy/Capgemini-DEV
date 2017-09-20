global class ICF_SMSDeliverySmartComm implements ICF_ISMSDelivery {
  public ICF_SMSDeliverySmartComm() {}
  public static String CRLF = '\r\n';
  public static String FOLDER_LOGS = 'ICF_Survey_Delivery_Logs';

  global Map<Id,Task> sendSMS(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pSMSList, Map<Id,Task> pTaskList, Set<Id> pReminderTasks) {
    return sendSMSSmartComm(pSMSList, pTaskList, pReminderTasks);
  }

  private Class CSVWrapper {
    private Integer nbLines { get; set; }
    private String body { get; set; }
  }

    /*
    * Send SMS SmartComm specific
    */
    private static Map<Id,Task> sendSMSSmartComm(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pSMSList, Map<Id,Task> pTaskList, Set<Id> pReminderTasks) {
        System.debug('########### sendSMSSmartComm START : ' + pSMSList); 
        // Use multipart specification : https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2 
        // create the CSV File
        CSVWrapper vCSVWrapper = createSmartCommCSVFile(pSMSList, 'T'); 
        String vBodyCSV = vCSVWrapper.body; 

        ICF_SurveyConf__c vSurveyConfig = ICF_SurveyConf__c.getValues('SURVEY_CONFIGURATION_SMS');
        String vBoundary = '----------';
        String vAccount = vSurveyConfig.Login__c;
        String vPassword = vSurveyConfig.Password__c;
        String vEndPoint = vSurveyConfig.Endpoint__c;
        if (vAccount != null && vPassword != null && vEndPoint != null) {
            String vReqBody = createSmartCommHTTPBody(vAccount, vPassword, vBoundary, vBodyCSV);

            // Create the form part with boundaries
            HttpRequest vReq = createSmartCommHTTPRequest(vEndPoint, vReqBody, vBoundary);
           
            Http vHttpSender = new Http(); 
            // Send the request and get the response
            HTTPResponse vResponse = vHttpSender.send(vReq); 
            System.debug('###########' + vResponse.getBody()); 
            System.debug('########### STATUS : ' + vResponse.getHeader('STATUS'));  
            Boolean vErrorOccured = false;
            if (vResponse.getStatusCode() == 200) {
                System.debug('################### SMS Server response OK ');
                // If body starts with status = 0 no error else it means error occured
                if (vResponse.getBody().startsWith('STATUS=0')) {
                    System.debug('################### No error returned by server (doesnt mean WS is ok but at least network is) ');
                    vErrorOccured = false;
                } else {
                    vErrorOccured = true;
                }
            } else {
              System.debug('################ ERROR : ' + vResponse);
              vErrorOccured = true;
            }
            // In case of error 
            createLogsAttachments(vBodyCSV, vResponse, vErrorOccured);         
            // task errors
            if (vErrorOccured) {
                String vMessage = (vResponse != null && vResponse.getBody() != null) ? vResponse.getBody() : 'ERROR';
                pTaskList = updateErrorTasks(pTaskList, vMessage, pReminderTasks);
            } else {
                pTaskList = updateSentTasks(pTaskList);
            }
        }
        System.debug('########### sendSMSSmartComm END'); 
        
        return pTaskList;
    }


    /**
    * Success management
    */
    private static Map<Id,Task> updateSentTasks(Map<Id,Task> pTaskList) {
        if (pTaskList == null) {
            return null;
        }
        for (Task vTask : pTaskList.values()) {
            vTask.Status = ICF_AP_Constant.TaskStatusSent; 
            vTask.ICF_Exception__c = null; 
        }

        return pTaskList;      
    }
    
    /**
    * Error management
    */
    private static Map<Id,Task> updateErrorTasks(Map<Id,Task> pTaskList, String pErrorMessage, Set<Id> pReminderTasks) {
        if (pTaskList == null) {
            return null;
        }
        for (Task vTask : pTaskList.values()) {
            vTask.Status = ICF_AP_Constant.TaskStatusFailedEmail;
            vTask.ICF_Exception__c = pErrorMessage;
            if (pReminderTasks.contains(vTask.Id)) {
                vTask.ICF_Remind_Date__c = null;
            } else {
                vTask.ICF_Sent_Date__c = null;
            }
        }

        return pTaskList;      
    }
       
    /**
    * Create Log
    */ 
    private static void createLogsAttachments(String pBodyCSV, HTTPResponse pResponse, Boolean pErrorOccured) {
      List<Folder> vFolders = [SELECT Id FROM Folder WHERE DeveloperName = :FOLDER_LOGS];

      if (vFolders != null && vFolders.size() > 0) {
        Folder vFolder = vFolders[0];
        DateTime vNow = DateTime.now();
        List<Document> vDocumentList = new List<Document>();
        String vErrorOrSuccess = !pErrorOccured ? 'Success' : 'Error';
        // Create the CSV file
        Document vCSVuploaded = new Document();
        vCSVuploaded.Name = 'ICF_' + vErrorOrSuccess + '_CSV_' + vNow + '.csv';
        vCSVuploaded.Body = Blob.valueOf(pBodyCSV);
        vCSVuploaded.folderId = vFolder.Id;
        vDocumentList.add(vCSVuploaded);
        
        // Create the HTTP response document        
        Document vRESTuploaded = new Document();
        vRESTuploaded.Name = 'ICF_' + vErrorOrSuccess + '_Response_' + vNow + '.txt';
        vRESTuploaded.Body = Blob.valueOf(pResponse.getBody());
        vRESTuploaded.folderId = vFolder.Id;
        vDocumentList.add(vRESTuploaded);
        
        insert vDocumentList;        
      }
      
    }
   

    /*
    * Create the CSV file
    */
    private static CSVWrapper createSmartCommCSVFile(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pSMSList, String pLanguage) {
        System.debug('############## createSmartCommCSVFile, pSMSList : ' + pSMSList + ' - pLanguage : ' + pLanguage);
        CSVWrapper vCSVWrapper = new CSVWrapper();

        String vCSVFile = '';
        Integer vIndex = 1;
        Integer vSMSListSize = pSMSList.size();
        for (ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer vSMSWrap : pSMSList) {
            String vLine = '';
            vLine += vSMSWrap.Phone + ',';
            String vSMSBody = vSMSWrap.SmsBody;
            vLine += '"' + vSMSBody + '",';
            vLine += (pLanguage != null) ? pLanguage : 'E'; 
            
            if (vIndex == vSMSListSize) {                
              vCSVFile += vLine;
            } else {
               vCSVFile += vLine + CRLF;
            }
            vIndex++;
        }   
        vCSVWrapper.body = vCSVFile;
        vCSVWrapper.nbLines = pSMSList.size();
        System.debug('############## createSmartCommCSVFile END');

        return vCSVWrapper;
    }

    /*
    * Create SmartComm Http Request
    */
    private static HttpRequest createSmartCommHTTPRequest(String pEndPoint, String pReqBody, String pBoundary) {
        System.debug('############## createSmartCommHTTPRequest, pEndPoint : ' + pEndPoint + '####pReqBody : ' + pReqBody + ' - pBoundary : ' + pBoundary);
        
         // Create the REST request
        HttpRequest vReq = new HttpRequest();
        vReq.setHeader('Content-Type','multipart/form-data; charset=TIS-620; boundary=' + pBoundary); 
        vReq.setMethod('POST'); 
        vReq.setEndpoint(pEndPoint);  
        vReq.setBody(pReqBody); 
        vReq.setTimeout(60000); 
         vReq.setHeader('Content-Length', String.valueof(vReq.getBodyAsBlob().size())); 

        System.debug('############## createSmartCommHTTPRequest, vReq : ' + vReq);

        return vReq;
    }

    /*
    * Create SmartComm Http body (with the csv)
    */
    private static String createSmartCommHTTPBody(String pAccount, String pPassword, String pBoundary, String pBodyCSV) {
        System.debug('############## createSmartCommHTTPBody, account : ' + pAccount + ' - Password : ' + pPassword + ' - pBoundary : ' + pBoundary + ' - pBodyCSV : ' + pBodyCSV);
         
        String vHeaderCSV = CRLF + '--' + pBoundary + CRLF + 'Content-Disposition: form-data; name="ATTACHMENT"; filename="ICF.csv"' + CRLF 
                            + 'Content-Type: application/vnd.ms-excel; charset=TIS-620' + CRLF + CRLF;

        // Create the parameters
        String vHeaderAccount = CRLF + '--' + pBoundary + CRLF + 'Content-Disposition: form-data; name="ACCOUNT"' + CRLF + CRLF; 
        String vBodyAccount = pAccount;  

        String vHeaderPwd = CRLF + '--' + pBoundary + CRLF + 'Content-Disposition: form-data; name="PASSWORD"' + CRLF + CRLF;
        String vBodyPwd = pPassword;  

        String vHeaderVersion = CRLF + '--' + pBoundary + CRLF + 'Content-Disposition: form-data; name="VERSION"' + CRLF + CRLF;
        String vBodyVersion = 'CSV-1.0';  

        String vGenericFooter =  CRLF + '--' + pBoundary + '--';

        // Create the httpRequestBody
        String vReqBody = vHeaderAccount + vBodyAccount + vHeaderPwd + vBodyPwd + vHeaderVersion + vBodyVersion + vHeaderCSV + pBodyCSV + vGenericFooter;
        System.debug('############## createSmartCommHTTPBody END');

        return vReqBody;
    }

}