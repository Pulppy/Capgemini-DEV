public with sharing class VFC01_WSCallout {
/**************************************************************************************
-- - Author        : SC
-- - Description   : class which get response (JSON) of WS depending on url and WS Name
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 02-MAR-2016  DMU    1.0     Initial version                                                                                                                                      
--------------------------------------------------------------------------------------
**************************************************************************************/
    //public String strAbbreviations{get;set;}
    public Static final String ERROR = 'Exception';
    public Static Boolean canInsertContVersion = false;
    public Static string pageCountIncrement {get;set;}
    public Static String caseId {get;set;}
    
    //used in test class
    //public Static HttpResponse testResponse {get;set;}

    public VFC01_WSCallout() {        
        //get the abbreviations that could be used      
        //strAbbreviations = JSON.serialize(getAbbreviations('Default')); 
    }

    public VFC01_WSCallout(ApexPages.StandardController stdCtrl) {        
        //get the abbreviations that could be used      
        //strAbbreviations = JSON.serialize(getAbbreviations('Default')); 
    }

    //dummy constructor to be able to call non-static method from static method
    public VFC01_WSCallout(String dummy) {}

    @RemoteAction
    public static Object retrieveTemplate(String templateName, Boolean isList){
        System.debug('## templateName : ' + templateName);
        if(String.isBlank(templateName)){
            return new Map <String, String> {
                ERROR => 'Please provide a template name.'
            };
        }else{
            Map <String, Object> mapTemplate;
            for(Document doc : [select DeveloperName, Type, Body 
                                    from Document 
                                    where DeveloperName =:templateName
                                    and Type = 'json'
                                    limit 1]){              
                try{
                    mapTemplate = (Map <String, Object>)JSON.deserializeUntyped(doc.Body.toString());                       
                }catch(JSONException jsonExcep){
                    return new Map <String, String> {
                        ERROR => jsonExcep.getMessage()
                    };
                }
            }

            if(mapTemplate == null){
                return new Map <String, String> {
                    ERROR => Label.TemplateNotFound_LF
                };
            }else{
                return isList ? getTemplateForLists(mapTemplate): getTemplate(mapTemplate);
            }
        }
    }

    public static Object getTemplateForLists(map <String, Object> map1){
        system.debug('## Starting method getTemplateForLists()');

        list<Object> lstOfElements = new list<Object>();

        try{
            if(map1.containsKey('HEADER')){
                map<String, Object> mapHeader = (map<String, Object>)map1.get('HEADER');
                if(mapHeader.containsKey('ctitle')){
                    mapHeader.put('ctitle',getLabel(mapHeader.get('ctitle')));
                    map1.put('HEADER',mapHeader);
                }
            }   
            if(map1.containsKey('TABLE')) {
                map<String,Object> mapTable = (map<String,Object>) map1.get('TABLE');
                lstOfElements.addAll((list<Object>) mapTable.get('layout'));
                
                for(Object ele1 : lstOfElements){
                    system.debug('## processing elements');

                    map<String,Object> map2 = (map<String,Object>) ele1;

                    system.debug('## map element is '+ map2);
                    if(map2.containsKey('clabel')){                        
                        map2.put('clabel',getLabel(map2.get('clabel')));
                    }
                }
                mapTable.put('layout',lstOfElements);
                map1.put('TABLE',mapTable);
                
            }
            return map1;                
        }
        catch(exception ex){
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };        
        }
    }

    public static Object getTemplate(map <String, Object> map1){
        system.debug('## Starting method getTemplateAsObj : ' + map1);

        list<Object> lstOfElements;
        System.debug('## getLayout ' + map1.get('layout'));

        try{
            if(map1.get('layout') != null){ 
                lstOfElements = (list<Object>) map1.get('layout');   
            }else {
                throw new LF_APConstant.customException(Label.NoLayoutTag_LF);  
            }

            //system.debug('## list of elements :' + lstOfElements);
            //process the elements to replace the label by the corresponding custom label value
            for(Object ele1 : lstOfElements){
                //system.debug('## processing elements');
                map<String,Object> map2 = (map<String,Object>) ele1;

                //system.debug('## map element is '+ map2);

                if(map2.containsKey('clabel')){                        
                    map2.put('clabel',getLabel(map2.get('clabel')));
                }
                if(map2.containsKey('objArray')){
                    //system.debug('## processing objArray elements');
                    list<object> lstObj = (list<object>)map2.get('objArray');
                    for(object ele2 : lstObj ){
                        //system.debug('## processing inner objArray elements');
                        map<String,Object> map3 = (map<String,Object>) ele2;
                        if(map3.containsKey('clabel')){ 
                            system.debug('## replacing label');                       
                            map3.put('clabel',getLabel(map3.get('clabel')));
                        }
                    }
                }
            }
            return lstOfElements;
        }
        catch(exception ex){
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };         
        }
    }

    // this method return this custom label value
    public static string getLabel(object o){        
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + string.valueOf(o) + '}';
        return String.valueOf(output.value);
    }
    //comment out because of change WS from restapi to soap
    /*
    // this method return a map of abbreviation origin and the corresponding custom label value
    public static map<string,string> getAbbreviations(String strCategory){
        //get the abbreviations that could be used  
        map<string,string> mapAbbrev = new map<string,string>();        
        //for(CS_GI_AbbreviationMapping__c a : [select Name, CustomLabelName__c from CS_GI_AbbreviationMapping__c where Category__c = :strCategory ]){
        //    mapAbbrev.put(a.Name,getLabel(a.CustomLabelName__c));
        //}
        return mapAbbrev;
    }
    */
    //comment out because of change WS from restapi to soap
    /*
    // this method returns a map of file type mapping from a list of mime type
    public static map<string,string> getFileTypeMapping(Set<String> lstMimeType){
        map<string,string> mapFileType = new map<string,string>();      
        //for(CS02_GI_FileTypeMapping__c ftm : [select Name,MimeType__c, FileExtension__c from CS02_GI_FileTypeMapping__c where MimeType__c IN :lstMimeType ]){
        //    mapFileType.put(ftm.MimeType__c,ftm.FileExtension__c);
        //}
        return mapFileType;
    }
    */
    //Son Vu
    //Modify to change from Rest Service to SOAP Service
    @RemoteAction
    public static Object runRequestContinuation(String wsname, String strParam){
        try{ 
            System.debug('###params: '+strParam);
            List<String> params = strParam.split('&');
            System.debug(params);
            String policyNo = '';
            String wsResult = '';
            if(params[0].split('=').size()>1){
                policyNo = params[0].split('=')[1];
            
                MyWFIDocumentManagementServices.DocumentManagementServices ws = new MyWFIDocumentManagementServices.DocumentManagementServices();
                DocumentManagementServicesDetail__c detail = DocumentManagementServicesDetail__c.getInstance();
                System.debug('###objStoreName: ' + detail.objStoreName__c);
                System.debug('###policyNo: ' + policyNo);
                
                wsResult = ws.searchPolicyDocuments(detail.objStoreName__c, policyNo);
            }
            System.debug(wsResult); 
    
            Map<String, Object> m = MyWFIDocumentManagementServicesXMLParser.getJsonMap(MyWFIDocumentManagementServicesXMLParser.parseXMLResponse(wsResult));
            m.put('policyNo', policyNo);
            return m;
        }
        catch(exception ex){
            system.debug('## error encountered :' + ex.getMessage());
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };
        }
        /*
        LF_APConstant.DataResponse result = new LF_APConstant.DataResponse();
        VFC01_WSCallout ws = new VFC01_WSCallout('');
        try{    
            //get HTTP request and launch continuation call
            HttpRequest oRequest = (HttpRequest) ws.buildHttpRequest(wsname, strParam);
            // Create a Continuation for the HTTPRequest with max timeout           
            Continuation con = new Continuation(120);
            //cannot have HttpRequest as stateInfo class variable because of null pointer issue during continuation 
            //passing only needed values from request
            map<String,Object> mapRequest = new map<String,Object>();
            mapRequest.put('contLabel', con.addHttpRequest(oRequest));
            mapRequest.put('X-Axa-MsgId',oRequest.getHeader('X-Axa-MsgId'));
            mapRequest.put('HttpMethod',oRequest.getMethod());
            mapRequest.put('HttpReqBody', oRequest.getBody());
            mapRequest.put('HttpReqSaveAsSTP', oRequest.getHeader('HttpReqSaveAsSTP'));

            StateInfo stateInf = new StateInfo(mapRequest);
            con.state = stateInf;
            system.debug('##stateInf = ' + stateInf);
            con.continuationMethod = 'processResponse'; 
            
            // Return it to the system for processing
            return con;
        }
        catch(exception ex){
            system.debug('## error encountered :' + ex.getMessage());
            result.addError(ex.getMessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };
        }
        */
    }  

    //comment out because of change WS from restapi to soap
    /*
    //common method to build HttpRequest 
    public Object buildHttpRequest(String wsname, String strParam){
        CS01_LF_WebServiceDetail__c wsDetail = CS01_LF_WebServiceDetail__c.getInstance(wsname);
        LF_APConstant.DataResponse result = new LF_APConstant.DataResponse();
        
        Http oHttp = new Http();
        HttpRequest oRequest = new HttpRequest();
        
        try{
            //first of all , if no parameters define generate an error
            if(String.isBlank(strParam)){
                throw new LF_APConstant.customException(Label.WSErrorNoParameter_LF);
            }
            //DMU: 20170213 - added condition to check field ClientCertificateName
            if (wsDetail.ClientCertificateName__c != null){
                oRequest.setClientCertificateName(wsDetail.ClientCertificateName__c);
            }
            oRequest.setHeader('SOAPAction', 'Wololo');
            if (wsDetail.Request_Method__c != null){
                oRequest.setMethod('POST');//wsDetail.Request_Method__c);
            }
            if (wsDetail.Accept__c != null){
                oRequest.setHeader('Accept', wsDetail.Accept__c);
            }
            if (wsDetail.AcceptCharset__c != null){
                oRequest.setHeader('Accept-Charset', wsDetail.AcceptCharset__c);
            }
            if (wsDetail.ContentType__c != null){
                oRequest.setHeader('Content-Type', wsDetail.ContentType__c);
            }
            if (wsDetail.XAxaRequestingChannel__c != null){
                oRequest.setHeader('X-Axa-RequestingChannel', wsDetail.XAxaRequestingChannel__c);
            }

            //String guid = GuidUtil.NewGuid();
            //oRequest.setHeader('X-Axa-MsgId', guid);
            //oRequest.setHeader('X-Axa-InitialMsgId', guid);

            //DMU: 20170306 - Temporary dummy data for MsgId & InitialMsgId  
            oRequest.setHeader('X-Axa-MsgId', 'AXA-MY');
            oRequest.setHeader('X-Axa-InitialMsgId', 'AXA-MY-INIT');
              
            //DMU-22/08/2016 - Added wrt card 30 on trello
            if (wsDetail.xAxaEnv__c != null){
                oRequest.setHeader('X-Axa-Env', wsDetail.xAxaEnv__c);
            }       
            if (wsDetail.XAxaEntity__c != null){
                oRequest.setHeader('X-Axa-Entity', wsDetail.XAxaEntity__c);
            }
            if (wsDetail.XAxaLOB__c != null){
                oRequest.setHeader('X-Axa-LOB', wsDetail.XAxaLOB__c);
            }
            if (wsDetail.HeaderContextVersion__c != null){
                oRequest.setHeader('X-Axa-ContextHeader-ContextVersion', wsDetail.HeaderContextVersion__c);
            }
            if (wsDetail.HeaderCustomDataTargetSystem__c != null){
                oRequest.setHeader('X-Axa-ContextHeader-CustomData-TargetSystem', wsDetail.HeaderCustomDataTargetSystem__c);
            }
            if (wsDetail.HeaderCustomDataSourceSystem__c != null){
                oRequest.setHeader('X-Axa-ContextHeader-CustomData-SourceSystem', wsDetail.HeaderCustomDataSourceSystem__c);
            }
            if(wsDetail.SortParameter__c !=null){
                strParam += wsDetail.SortParameter__c;
            }
            if(wsDetail.PaginationParameter__c !=null){
                strParam += wsDetail.PaginationParameter__c;
            }
            if(wsDetail.PaginationCount__c != null){
                pageCountIncrement = wsDetail.PaginationCount__c;
            }
            //if(wsDetail.SaveRequest__c != null){
            //    oRequest.setHeader('HttpReqSaveAsSTP', (wsDetail.SaveRequest__c ? '1':'0'));
            //}
            oRequest.setHeader('HttpReqSaveAsSTP','0');
            if (wsDetail.URL__c != null){
                oRequest.setEndpoint(wsDetail.URL__c + (strParam.startsWith('?') ? strParam : '?'+ strParam));
                String tempEnpoint = wsDetail.URL__c + '?policyNumber=502-0540430&objStoreName=WFIU1OSD06';
                oRequest.setEndpoint(tempEnpoint);
                system.debug('### string Enpt: '+ (wsDetail.URL__c + (strParam.startsWith('?') ? strParam : '?'+ strParam)));
                system.debug('### string Enpt: '+ tempEnpoint);
                system.debug('## accepttype: '+ oRequest.getHeader('Accept'));
            }
            else 
                throw new LF_APConstant.customException(Label.WSErrorNoEndpoint_LF);          
        }
        catch(exception ex){
            system.debug('## error encountered :' + ex.getMessage());
            result.addError(ex.getMessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };
        }
        return oRequest;
    }  
    */
    @RemoteAction
    public static Object getWSRowCountIncrement(String wsname){
        pageCountIncrement = '';
        CS01_LF_WebServiceDetail__c wsDetail = CS01_LF_WebServiceDetail__c.getInstance(wsname);
        
        try{
            if(wsDetail.PaginationCount__c != null){
                pageCountIncrement = wsDetail.PaginationCount__c;
            }
        }               
        catch(exception ex){
            system.debug('## error encountered :' + ex.getMessage());
            return new Map <String, String> {
                ERROR => ex.getMessage()
            };
        }

        return pageCountIncrement;
    }  

    //comment out because of change WS from restapi to soap
    /*
    // Continuation Callback method invoked from JS remote action
    public static Object processResponse(Object state){
        system.debug('## common processResponse' );
        LF_APConstant.DataResponse result = new LF_APConstant.DataResponse();
        
        StateInfo st = (StateInfo)state;
        system.debug('##StateInfo = ' + st);
        //get calloutResponse by continuation unique label

        HttpResponse oResponse = (Test.isRunningTest() ? testResponse :Continuation.getResponse((String)st.stateContent.get('contLabel')) ); 
        system.debug('##oResponse.getHeaderKeys = ' + oResponse.getHeaderKeys()); 
        //setting custom headers in HttpResponse to process them in analyseResponse method
        oResponse.setHeader('reqMsgId', (String)st.stateContent.get('X-Axa-MsgId'));
        oResponse.setHeader('reqMethod', (String)st.stateContent.get('HttpMethod'));
        oResponse.setHeader('reqBody', (String)st.stateContent.get('HttpReqBody'));
        oResponse.setHeader('reqSaveAsSTP', (String)st.stateContent.get('HttpReqSaveAsSTP'));
        
        VFC01_WSCallout ws = new VFC01_WSCallout('');
        return ws.analyseResponse(oResponse);
    }

    public Object analyseResponse(HttpResponse oResponse){
        LF_APConstant.DataResponse result = new LF_APConstant.DataResponse();
        //STP__c stp = new STP__c(InitMsgID__c = '');
        Integer statusCode = oResponse.getStatusCode();
        String reqMsgId = oResponse.getHeader('reqMsgId');
        String reqBody = oResponse.getHeader('reqBody');
        String reqMethod = oResponse.getHeader('reqMethod');
        String saveAsSTP = oResponse.getHeader('reqSaveAsSTP');
        caseId = oResponse.getHeader('reqCaseId');

        system.debug('## statusCode = ' + statusCode);
        system.debug('## oResponse.reqMsgId = ' + reqMsgId);
        system.debug('## oResponse.reqMethod = ' + reqMethod);
        system.debug('## oResponse.saveAsSTP = ' + saveAsSTP);
        //system.debug('###stp.InitMsgID__c blank = ' + String.isBlank(stp.InitMsgID__c));
        system.debug('###caseId = ' + caseId);      

        //if(saveAsSTP == '1'){           
        //    stp = new STP__c(Case__c = caseId, InitMsgID__c = reqMsgId, JSON__c = reqBody, Status__c = String.valueOf(statusCode));
        //}
        
        if (statusCode > 200) {         
            system.debug('### Error response: ' + oResponse.getBody());
            //build map of json exception response
            Map<String, Object> mapErrorResp = (Map<String, Object>)JSON.deserializeUntyped(oResponse.getBody());
            system.debug('##mapErrorResp.keyset = ' + mapErrorResp.keyset());
            
            //get exception details by map key  
            if(mapErrorResp.keyset().size() > 0){
                //SMO 20170111 - reflecting changes in API exception response, which now contains exception object directly
                //system.debug('##mapErrorResp = ' + mapErrorResp.get(new list<string>(mapErrorResp.keyset())[0]));
                //Map<String, Object> mapExc= (Map<String, Object>)mapErrorResp.get(new list<string>(mapErrorResp.keyset())[0]);
                
                //extract reasoncode and reason message from map
                Map<String, Object> mapExcReason= (Map<String, Object>)mapErrorResp.get(new list<string>(mapErrorResp.keyset())[0]);
                system.debug('##exception = ' +mapExcReason );

                //if(String.isNotBlank(stp.InitMsgID__c)){
                //    stp.Reason__c = mapExcReason.get('reasonCode') + ' - ' + mapExcReason.get('reason');
                //    insert stp;
                //}
                
                throw new LF_APConstant.customException('Error Code: ' + mapExcReason.get('reasonCode')  
                            + ' - ' + mapExcReason.get('reason')
                            + ' - msgId=' + reqMsgId);  
            }
            else{
                //if(String.isNotBlank(stp.InitMsgID__c)){
                //    stp.Reason__c = statusCode + ' - ' + oResponse.getBody();
                //    insert stp;
                //}

                throw new LF_APConstant.customException('Status Code: ' + statusCode  
                            + ' - ' + oResponse.getBody()
                            + ' - msgId=' + reqMsgId);
            }                       
        }else{
            result.responseAsJSON = oResponse.getBody();
        }

        //if(String.isNotBlank(stp.InitMsgID__c)){
        //    insert stp;
        //}

        return JSON.deserializeUntyped(result.responseAsJSON);
    }

    // inner class to hold state info for callout via continuation 
    public class StateInfo {
        public map<String,Object> stateContent { get; set; }

        public StateInfo(map<String,Object> stateContent){
            this.stateContent = stateContent;
        }
    }
    */
    
    //comment of because of "METHOD TO BE DELETED LATER"
    /*
    // launch Test Continuation call 
    //DMU - METHOD TO BE DELETED LATER
    @RemoteAction
    public static Object runTestRequestContinuation(String wsname, String strParam){
        Http oHttp = new Http();
        HttpRequest oRequest = new HttpRequest();
        oRequest.setMethod('GET');
        oRequest.setEndpoint('http://www.mocky.io/v2/58b94ae60f00001c0cf09c57');
        // Create a Continuation for the HTTPRequest with max timeout    
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(oRequest);              
        con.continuationMethod = 'processResponse'; 

        // Return it to the system for processing
        return con;
    }

    //DMU - METHOD TO BE DELETED LATER
    // STATIC RESPONSE FROM HTTP RESPONDER
    @RemoteAction
    public static Object testCallout(String wsname){
        LF_APConstant.DataResponse result = new LF_APConstant.DataResponse();

        Http oHttp = new Http();
        HttpRequest oRequest = new HttpRequest();
        oRequest.setMethod('GET');
        if(wsname == 'RetrieveCustomerDetails'){
            oRequest.setEndpoint('http://www.mocky.io/v2/58bd56f90f0000b21a5c6735');
        } 
        else if(wsname == 'RetrievePolicyDetails'){
            oRequest.setEndpoint('http://www.mocky.io/v2/58bd574a0f0000b91a5c6736');
        }        
        HttpResponse oResponse = null;
        oResponse = oHttp.send(oRequest);
        System.debug(oResponse.getBody());

        result.responseAsJSON = oResponse.getBody();
        System.debug('#### result: ' + result);
        return JSON.deserializeUntyped(result.responseAsJSON);
    }
    */
    //Son Vu
    //Added method support pdf download from SOAP service
    @AuraEnabled
    public static String getDownloadDocument(String idPDF, String policyId){
        try{ 
            DocumentManagementServicesDetail__c detail = DocumentManagementServicesDetail__c.getInstance();
            System.debug('###objStoreName__c: ' + detail.objStoreName__c);
            myWFIDocumentManagementServices.DocumentManagementServices ws = new myWFIDocumentManagementServices.DocumentManagementServices();
            myWFIDocumentManagementBean.RetrieveDocResponse pdf = ws.retrieveDoc(detail.objStoreName__c, idPDF);
            
            System.debug(idPDF);
            Policy__c pol = [Select id, Name from policy__c where id =: policyId limit 1];
            Folder fd = [Select id, name from Folder Where Name = 'Policy Document'];
            String UniqueDescription = pol.name + '-'+idPDF;
            List<Document> tempDoc = [Select id, name, body from Document where description = :UniqueDescription AND FolderId=:fd.id];

            if(tempDoc.size()>0){
                tempDoc[0].body = EncodingUtil.base64Decode( pdf.docContent);
                tempDoc[0].name = pdf.retrievalName;
                update tempDoc;
                pdfDownload pdl = new pdfDownload();
                pdl.id = tempDoc[0].id;
                pdl.fileName = tempDoc[0].name;
                return JSON.serializePretty(pdl);
                //delete temp;
            }else{
                Blob b = EncodingUtil.base64Decode( pdf.docContent);
                Document attachmentPDF = new Document();
                //attachmentPdf.DeveloperName = pdf.retrievalName.replace('.pdf','');
                attachmentPdf.name = pdf.retrievalName;
                attachmentPdf.body = b;
                attachmentPdf.FolderId = fd.id;
                attachmentPdf.description = UniqueDescription;
                insert attachmentPDF;
                
                pdfDownload pdl = new pdfDownload();
                pdl.id = attachmentPDF.id;
                pdl.fileName = attachmentPDF.name;
                return JSON.serializePretty(pdl);
            }
        }
        catch(exception ex){
            System.debug(ex.getMessage());
            return JSON.serializePretty(new Map <String, String> {
                ERROR => ex.getMessage()
            });         
        }
    }
    
    class pdfDownload{
        String id {get;set;}
        String fileName {get;set;}
        Blob body {get;set;}
    }
}