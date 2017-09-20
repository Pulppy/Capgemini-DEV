/**
 * @description Implements SCRUMEipCalloutHelperInf interface and instantiates the Custom Settings used in concrete classes
 */
public abstract class SCRUMEipCalloutHelperAbstract implements SCRUMEipCalloutHelperInf {
    
    public String url = '';
    public CR32_EIP_Endpoint__c endpointSetting;
    public final boolean STUB_WS{get;set;}{if(Test.isRunningTest()){STUB_WS=true;}else{STUB_WS=false;}}
    public String sslCertificateName = '';
    
    public SCRUMEipCalloutHelperAbstract() {
        initCustomSetting();
    }
    
    private void initCustomSetting() {
        List<CR32_EIP_Endpoint__c> tempList = [ SELECT  Name, ESG_Policy_List__c, ESG_Customer_List__c, 
                                                        ESG_Customer_Comm_List__c 
                                                FROM    CR32_EIP_Endpoint__c 
                                                WHERE   Name = 'Default' 
                                                limit   1];
        
        if(tempList != null && !tempList.isEmpty()) {
            endpointSetting = tempList[0];
            
        } else {
            System.debug('>>>>> SCRUMEipCalloutHelperAbstract >>>>> System cannot find EIP endpoints');
            throw new SCRUMCalloutException('System cannot find EIP endpoints. Please contact your administrator.');
        }
        
        List<Filenet_Integration__c> fiList = [SELECT Certificate_Name__c
                                               FROM Filenet_Integration__c
                                               WHERE Name = 'Default' 
                                               LIMIT 1];
        if(fiList != null && !fiList.isEmpty()) {
            sslCertificateName = fiList[0].Certificate_Name__c;
        } else {
            System.debug('>>>>> SCRUMEipCalloutHelperAbstract >>>>> System cannot find the security certificate name');
            throw new SCRUMCalloutException('System cannot find the security certificate name. Please contact your administrator.');
        }                   
    }
    
    public String getXmlNodeChildTextIfNotEmpty(String elementName, Dom.XmlNode node) {
        String result = '';
        if(node != null && node.getChildElement(elementName, null) != null) {
            result = node.getChildElement(elementName, null).getText();
        }
        
        return result;
    }
    
    public void processErrorFromResponse(Dom.document doc) {
        if(doc != null) {
            Dom.XmlNode root = doc.getRootElement(); 
            
            if(root.getChildElements() != null && !root.getChildElements().isEmpty()) {
                //Dom.XmlNode webServiceElement = root.getChildElements()[0];// <ns:NameOfWebService>
                
                List<Dom.XmlNode> exceptions = root.getChildElements(); // <customer> <policy>
                for(Dom.XmlNode ex : exceptions) {
                    if(ex.getName() == 'exception'){
                        String reasonCd = getXmlNodeChildTextIfNotEmpty('reasonCD', ex);
                        String reasonText = getXmlNodeChildTextIfNotEmpty('reasonTXT', ex);
                        String responseCd = getXmlNodeChildTextIfNotEmpty('responseCD', ex);
                        System.debug('>>>>> SCRUMEipCalloutHelperAbstract: processErrorFromResponse >>>>> EIP returned an exception');
                        System.debug('>>>>> SCRUMEipCalloutHelperAbstract: processErrorFromResponse >>>>> reasonCd = ' + reasonCd);
                        System.debug('>>>>> SCRUMEipCalloutHelperAbstract: processErrorFromResponse >>>>> reasonText = ' + reasonText);
                        System.debug('>>>>> SCRUMEipCalloutHelperAbstract: processErrorFromResponse >>>>> reasonCd = ' + responseCd);
                        
                        if(reasonCd == '456') {
                            throw new SCRUMCalloutException('System Error. Data/Validation Error occurred in EIP-Input Parameters blank.');
                        } else if(reasonCd == '457') {
                            throw new SCRUMCalloutException('System Error. Data/Validation Error occurred in EIP-No Output Parameters Returned with the provided Input.');
                        } else if(reasonCd == '102') {
                            throw new SCRUMCalloutException('System Error. Connection Error in ODS.');
                        } else if(reasonCd == '400') {
                            //no result should not be an error
                            //throw new SCRUMCalloutException('System Error. No Result.');
                        } else if(reasonCd == '500') {
                            throw new SCRUMCalloutException('System Error. Error occurred in EIP-Internal Server Errors.');
                        } else { 
                            throw new SCRUMCalloutException(SCRUMCalloutException.genericException + ' [' + reasonCd + ': ' + reasonText + ']');
                        }
                    }
                }
            }
        } else {
            throw new SCRUMCalloutException(SCRUMCalloutException.genericException + ' [No Response]');
            System.debug('>>>>> SCRUMEipCalloutHelperAbstract: processErrorFromResponse >>>>> EIP returned an empty response');
        }
    }
}