/**
 * @description Helper class to make outbound calls to EIP for Customer Search
 */
public class SCRUMCustomerSearchEipCalloutHelper extends SCRUMEipCalloutHelperAbstract {

    public SCRUMCustomerSearchEipCalloutHelper(Map<String, String> parameters) {
        super();
        setEndpoint(parameters);
    }
    
    public void setEndpoint(Map<String, String> parameters) {
        if(!String.isBlank(endpointSetting.ESG_Customer_List__c)) {
            url = endpointSetting.ESG_Customer_List__c;
            
            // Set parameters
            for(String key : parameters.keySet()) {
                if(String.isBlank(parameters.get(key))) {
                    parameters.remove(key);
                } else {
                    parameters.put(key, key + '=' + EncodingUtil.urlEncode(parameters.get(key), 'UTF-8'));
                }
            }
            
            String queryString = String.join(parameters.values(), '&');
            
            if(!String.isBlank(url)) {
                url += '?' + queryString;
            }
            
        } else {
            System.debug('>>>>> SCRUMCustomerSearchEipCalloutHelper >>>>> System cannot find EIP endpoints');
            throw new SCRUMCalloutException('System cannot find EIP endpoints. Please contact your administrator.');
        }        
    }
    
    public List<SCRUMEipVO.CustomerVO> execute() {
        Dom.document resultDoc = getResponse();
        processErrorFromResponse(resultDoc); // First check if there were any errors
        List<SCRUMEipVO.CustomerVO> resultList = processResultFromResponse(resultDoc);
        
        System.debug('SCRUMCustomerSearchEipCalloutHelper.execute() resultList = ' + resultList);
        
        return resultList;
    }
    
    
    public boolean readyForCallout() {
        boolean result = true;
        
        if(String.isBlank(url)) {
            throw new SCRUMCalloutException('URL endpoint is null, callout cannot be completed');
        }
        
        return result;
    }
    
    public Dom.document getResponse() {
        if(STUB_WS) {
            return getResponseStub();
        }
        
        Dom.Document doc = null;
        
        if(readyForCallout()) {
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(120000);
            
            if(!String.isBlank(sslCertificateName)) {
                req.setClientCertificateName(sslCertificateName);
            }

            try{
                System.debug('>>>>> SCRUMCustomerSearchEipCalloutHelper >>>>> getResponse >>>>> request = ' + req.toString());
                
                HttpResponse res = http.send(req);
                
                System.debug('>>>>> SCRUMCustomerSearchEipCalloutHelper >>>>> getResponse >>>>> response = ' + res.toString());
                Integer statusCode = res.getStatusCode();
                
                if(statusCode == 456) {
                    throw new SCRUMCalloutException('System Error. Data/Validation Error occurred in EIP-Input Parameters blank.');
                } else if(statusCode == 457) {
                    throw new SCRUMCalloutException('System Error. Data/Validation Error occurred in EIP-No Output Parameters Returned with the provided Input.');
                } else if(statusCode == 102) {
                    throw new SCRUMCalloutException('System Error. Connection Error in ODS.');
                } else if(statusCode == 400) {
                    //no result should not be an error
                    //throw new SCRUMCalloutException('System Error. No Result.');
                } else if(statusCode == 500) {
                    throw new SCRUMCalloutException('System Error. Error occurred in EIP-Internal Server Errors.');
                } else if(statusCode != 200) {
                    throw new SCRUMCalloutException('System Error. Status Code: ' + res.getStatusCode()  + ' ' + res.getStatus() + '. Please contact the administrator.');
                }
                
                doc = res.getBodyDocument();
                
            } catch(System.CalloutException e){
                
                if(e.getMessage().contains('Read timed out')){
                    throw new SCRUMCalloutException(SCRUMCalloutException.genericException);
                } else {
                    throw new SCRUMCalloutException(SCRUMCalloutException.timeoutException);
                }
            }        
        }
        
        return doc;
    }
    
    public List<SCRUMEipVO.CustomerVO> processResultFromResponse(Dom.document doc) {
        //Special Care
        Map<String, String> specialCareMap = new Map<String, String>();
        /*
        for (Schema.PicklistEntry pe : Account.AML_Indicator__c.getDescribe().getPicklistValues()) {
            specialCareMap.put(pe.getValue(), pe.getLabel());
        }
        for (Schema.PicklistEntry pe : Account.Bankruptcy_Flag__c.getDescribe().getPicklistValues()) {
            specialCareMap.put(pe.getValue(), pe.getLabel());
        }
        for (Schema.PicklistEntry pe : Account.Court_Case_Indicator__c.getDescribe().getPicklistValues()) {
            specialCareMap.put(pe.getValue(), pe.getLabel());
        }
        for (Schema.PicklistEntry pe : Account.Serious_Complaint_Case_Indicator__c.getDescribe().getPicklistValues()) {
            specialCareMap.put(pe.getValue(), pe.getLabel());
        }
        for (Schema.PicklistEntry pe : Account.Fraud_Indicator__c.getDescribe().getPicklistValues()) {
            specialCareMap.put(pe.getValue(), pe.getLabel());
        }
        
        */
        //Special Care
        
        List<SCRUMEipVO.CustomerVO> result = new List<SCRUMEipVO.CustomerVO>();
        List<String> idList = new List<String>();
        Map<String, SCRUMEipVO.CustomerVO> custMap = new Map<String, SCRUMEipVO.CustomerVO>(); 
        
        if(doc != null) {
            Dom.XmlNode root = doc.getRootElement();
            if(root.getChildElements() != null && !root.getChildElements().isEmpty()){
                Dom.XmlNode retrieveCustomerListResponseElement = root.getChildElements()[0];// <ns:RetrieveCustomerListResponse>
            
                List<Dom.XmlNode> customerElements = retrieveCustomerListResponseElement.getChildElements(); // <customer> <policy>
                
                for(Dom.XmlNode customerElement : customerElements) {
                    SCRUMEipVO.CustomerVO custVO = new SCRUMEipVO.CustomerVO();
                    if(customerElement.getName()=='customer'){
                        custVO.CustomerId = getXmlNodeChildTextIfNotEmpty('customerID', customerElement);
                        Dom.XmlNode canBeIndividualElement = customerElement.getChildElement('canBeIndividual', null);
                        Dom.XmlNode hasCustomerAccountInformation = customerElement.getChildElement('hasCustomerAccountInformationIn', null);
                        
                        if(canBeIndividualElement != null) {
                            custVO.HKID = getXmlNodeChildTextIfNotEmpty('socialSecurityNO', canBeIndividualElement);
                            custVO.ChineseName = getXmlNodeChildTextIfNotEmpty('chineseNM', canBeIndividualElement);
                            custVO.EnglishName = getXmlNodeChildTextIfNotEmpty('lastNM', canBeIndividualElement);
                            custVO.Gender = getXmlNodeChildTextIfNotEmpty('genderCD', canBeIndividualElement);
                            custVO.DateOfBirth = getXmlNodeChildTextIfNotEmpty('birthDT', canBeIndividualElement);
                            custVO.MaritalStatus = getXmlNodeChildTextIfNotEmpty('maritalStatusCD', canBeIndividualElement);
                            
                            SCRUMEipVO.AddressVO addressVO = new SCRUMEipVO.AddressVO();
                            custVO.Address = addressVO;
                            Dom.XmlNode hasAddressesInElement = canBeIndividualElement.getChildElement('hasAddressesIn', null);
                            
                            if(hasAddressesInElement != null){
                                addressVO.Mobile = getXmlNodeChildTextIfNotEmpty('mobilePhoneNO', hasAddressesInElement);
                                addressVO.OfficePhone = getXmlNodeChildTextIfNotEmpty('officeTelNo', hasAddressesInElement);
                                addressVO.HomePhone = getXmlNodeChildTextIfNotEmpty('telephoneNO', hasAddressesInElement);
                                addressVO.Email = getXmlNodeChildTextIfNotEmpty('emailAddress', hasAddressesInElement);
                                addressVO.Line1 = getXmlNodeChildTextIfNotEmpty('addressLine1', hasAddressesInElement);
                                addressVO.Line2 = getXmlNodeChildTextIfNotEmpty('addressLine2', hasAddressesInElement);
                                addressVO.Line3 = getXmlNodeChildTextIfNotEmpty('addressLine3', hasAddressesInElement);
                                addressVO.Line4 = getXmlNodeChildTextIfNotEmpty('addressLine4', hasAddressesInElement);
                                addressVO.TypeCd = getXmlNodeChildTextIfNotEmpty('addressTypeCD', hasAddressesInElement);
                                addressVO.CityNm = getXmlNodeChildTextIfNotEmpty('cityNM', hasAddressesInElement);
                                
                                Dom.XmlNode hasAddressExtnDetailsInElement = hasAddressesInElement.getChildElement('hasAddressExtnDetailsIn', null);
                                if(hasAddressExtnDetailsInElement!= null){
                                    addressVO.ExtLine1 = getXmlNodeChildTextIfNotEmpty('addressLine1', hasAddressExtnDetailsInElement);
                                    addressVO.ExtLine2 = getXmlNodeChildTextIfNotEmpty('addressLine2', hasAddressExtnDetailsInElement);
                                    addressVO.ExtLine3 = getXmlNodeChildTextIfNotEmpty('addressLine3', hasAddressExtnDetailsInElement);
                                    addressVO.ExtLine4 = getXmlNodeChildTextIfNotEmpty('addressLine4', hasAddressExtnDetailsInElement);
                                }
                            }
                        }
                        
                        if(hasCustomerAccountInformation != null){
                            custVO.CustomerValue = getXmlNodeChildTextIfNotEmpty('customerValue', hasCustomerAccountInformation);
                            custVO.OccupationClassCd = getXmlNodeChildTextIfNotEmpty('occupationClassCd', hasCustomerAccountInformation);
                        }
                        
                        custMap.put(custVO.CustomerId, custVO);
                        
                    } else if(customerElement.getName()=='policy'){
                    
                        SCRUMEipVO.policyVO policyVO = new SCRUMEipVO.policyVO();
                    
                        Dom.XmlNode customerInformationInElement = customerElement.getChildElement('hasCustomerInformationIn', null);
                        Dom.XmlNode fraudCaseTransDetailsInElement = customerElement.getChildElement('hasFraudCaseTransDetailsIn', null);
                        Dom.XmlNode policySpecialCaseDetailsInElement = customerElement.getChildElement('hasPolicySpecialCaseDetailsIn', null);
                        
                        if(customerInformationInElement!=null){
                            policyVO.CustomerId = getXmlNodeChildTextIfNotEmpty('customerID', customerInformationInElement);
                        }
                        
                        if(fraudCaseTransDetailsInElement!=null){
                            policyVO.FraudIND = getXmlNodeChildTextIfNotEmpty('fraudIND', fraudCaseTransDetailsInElement);
                            
                            policyVO.FraudIND = (policyVO.FraudIND == 'N' || policyVO.FraudIND == '' || policyVO.FraudIND == null) ? '' : 'Fraud';
                        }
                        
                        if(policySpecialCaseDetailsInElement!=null){
                            List<String> brList = new List<String>();
                            for(Dom.XmlNode brElement : policySpecialCaseDetailsInElement.getChildElements()){
                                String v = specialCareMap.get(brElement.getText()) == null ? brElement.getText() : specialCareMap.get(brElement.getText());
                                brList.add(v);
                            }
                            policyVO.BankruptyIND = brList;
                        }
                        
                        policyVO.Section = getXmlNodeChildTextIfNotEmpty('section', customerElement);
                        
                        policyVO.Section = (policyVO.Section == 'N' || policyVO.Section == '' || policyVO.Section == null) ? '' : 'Serious Complaint';

                        
                        if(custMap.size() > 0 && String.isNotEmpty(policyVO.CustomerId) && custMap.containsKey(policyVO.CustomerId)){
                           SCRUMEipVO.CustomerVO targetVO = custMap.get(policyVO.CustomerId);
                           targetVO.Policy = policyVO;
                           idList.add(policyVO.CustomerId);
                           result.add(targetVO);
                        }
                    }
                   
                }
            }
            if(idList.size()>0){
                setAccountId(idList, custMap);
            }
        }
        
        System.debug('>>>>> SCRUMCustomerSearchEipCalloutHelper >>>>> processResultFromResponse >>>>> result = ' + result);
        
        return result;
    }
    
   private void setAccountId(List<String> ids, Map<String, SCRUMEipVO.CustomerVO> cusMap){
        List<Account> result = [Select customer_Id__C, name from Account where customer_Id__C in :ids ];
        for(Account acc : result){
            if(cusMap.containsKey(acc.customer_Id__C)){
                cusMap.get(acc.customer_Id__C).accountId = acc.Id;
                cusMap.get(acc.customer_Id__C).accountName = acc.name;
            }
        }
    }
    
    private Dom.document getResponseStub() {
        String responseStr =  '<retrieveCustomerListResponse xmlns:ns="http://schemas.axa.asia/canonical/1">'
                +'<ns:RetrieveCustomerListResponse> '
                +'    <customer> '
                +'        <customerID>88840</customerID> '
                +'        <canBeIndividual> '
                +'            <birthDT>1962-11-18</birthDT> '
                +'            <genderCD>F</genderCD> '
                +'            <lastNM>VBPZ FHPZ KAA</lastNM> '
                +'            <maritalStatusCD>S</maritalStatusCD> '
                +'            <socialSecurityNO>Q589298</socialSecurityNO> '
                +'            <hasAddressesIn> '
                +'                <addressLine1>ADD1</addressLine1> '
                +'                <addressLine2>ADD2</addressLine2> '
                +'                <addressLine3>ADD3</addressLine3> '
                +'                <addressLine4>ADD4</addressLine4> '
                +'                <addressTypeCD>COR</addressTypeCD> '
                +'                <cityNM>011200</cityNM> '
                +'                <emailAddress>HSGD@GMAIL.COM</emailAddress> '
                +'                <mobilePhoneNO>76565765</mobilePhoneNO> '
                +'                <telephoneNO>8767868</telephoneNO> '
                +'                <hasAddressExtnDetailsIn> '
                +'                    <addressLine1>????????</addressLine1> '
                +'                    <addressLine2>?????????M?</addressLine2> '
                +'                    <addressLine3>59??5295?</addressLine3> '
                +'                    <addressLine4>?????M?</addressLine4> '
                +'                </hasAddressExtnDetailsIn> '
                +'                <officeTelNo>7868789</officeTelNo> '
                +'            </hasAddressesIn> '
                +'            <chineseNM>陳大文</chineseNM> '
                +'        </canBeIndividual> '
                +'        <hasCustomerAccountInformationIn> '
                +'            <customerValue>2274.91</customerValue> '
                +'            <occupationClassCd>???</occupationClassCd> '
                +'        </hasCustomerAccountInformationIn> '
                +'    </customer> '
                +'    <policy> '
                +'        <hasCustomerInformationIn> '
                +'            <customerID>88840</customerID> '
                +'        </hasCustomerInformationIn> '
                +'        <hasFraudCaseTransDetailsIn> '
                +'            <fraudIND>Y</fraudIND> '
                +'        </hasFraudCaseTransDetailsIn> '
                +'        <hasPolicySpecialCaseDetailsIn> '
                +'            <bankruptyIND>A1</bankruptyIND> '
                +'            <bankruptyIND>B2</bankruptyIND> '
                +'            <bankruptyIND>D2</bankruptyIND> '
                +'        </hasPolicySpecialCaseDetailsIn> '
                +'        <section>UW</section> '
                +'    </policy> '
                +'</ns:RetrieveCustomerListResponse>'
            + '</retrieveCustomerListResponse>';
        
        Dom.Document stubDoc = new Dom.Document();
        stubDoc.load(responseStr);
        return stubDoc;
    }
   
}