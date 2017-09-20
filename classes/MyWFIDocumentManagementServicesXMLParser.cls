public class MyWFIDocumentManagementServicesXMLParser{
    public static List<Map<String,String>> parseXMLResponse(String res){
        String xmlDoc = res;
        if(xmlDoc == null || xmlDoc == ''){
            return new List<Map<String, String>>();
        }
        if(xmlDoc.contains('<![CDATA[')){
            xmlDoc = xmlDoc.replace('<![CDATA[','').replace(']]>','');
        }
        try{
        Dom.Document doc = new Dom.Document();
        doc.load(xmlDoc);
        System.debug(xmlDoc);
        DOM.XmlNode node = doc.getRootElement();
        while(node.getName() != 'SearchResult' && node.getChildElements().size()>0){
            node = node.getChildElements()[0];
        }
        if(node.getName() != 'SearchResult')
            return new List<Map<String, String>>();
		System.debug(xmlDoc);
        List<Map<String,String>> listDoc= new List<Map<String, String>>();
        for(DOM.XmlNode docNode : node.getChildElements()){
            Map<String,String> docMap = new Map<String, String>();
            for(DOM.XmlNode att: docNode.getChildElements()){
                //System.Debug(att.getText());
                if(att.getText() != 'There are no Document details for given search criteria'){
                    if(stringparse(att.getName()).toLowerCase().contains('date')){
                        docMap.put(stringparse(att.getName()) , parseDatetime(att.getText()).format('YYYY-MM-dd')  );
                    }else{
                		docMap.put(stringparse(att.getName()) ,att.getText());
                    }
                //System.debug(att.getName() +'-'+att.getText());
                } 
            }
            if(docMap.keySet().size() > 0){
                listDoc.add(docMap);
            }
            
        }
    return listDoc;
        }catch(exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage() +'===='+ex.getStackTraceString());
        }
        return new List<Map<String, String>>();
    } 
    
    public static Map<String, Object> getJsonMap(List<Map<String, String>> listDoc){
        Map<String, Object> mapObj = new Map<String, Object>();
        mapObj.put('Exception', null);
        
        Map<String, Object> miniMap = new Map<String, Object>();
        miniMap.put('exception', null);
        miniMap.put('documentElement', listDoc);
        
        MapObj.put('RetrieveDocumentListResponse', miniMap);
        return mapObj;
    }
    
    private static String stringparse(String input){
        if(input=='Id'){
            return 'documentId';
        }
        else if(input=='DOCUMENTTYPE'){
            return 'documentType';
        }
        else if(input=='DocumentTitle'){
            return 'documentTitle';
        }
        else{
            return input;
        }    
    }
    
    public static integer MonthConvert(String input){
        if(input.equalsIgnoreCase('Jan'))
            return 1;
        if(input.equalsIgnoreCase('Feb'))
            return 2;
        if(input.equalsIgnoreCase('Mar'))
            return 3;
        if(input.equalsIgnoreCase('Apr'))
            return 4;
        if(input.equalsIgnoreCase('May'))
            return 5;
        if(input.equalsIgnoreCase('Jun'))
            return 6;
        if(input.equalsIgnoreCase('Jul'))
            return 7;
        if(input.equalsIgnoreCase('Aug'))
            return 8;
        if(input.equalsIgnoreCase('Sep'))
            return 9;
        if(input.equalsIgnoreCase('Oct'))
            return 10;
        if(input.equalsIgnoreCase('Nov'))
            return 11;
        if(input.equalsIgnoreCase('Dec'))
            return 12;
        return 1;
    }
    
    public Static Datetime parseDatetime(String dt){
        Datetime parsedDT;
        List<String> listDTStr = dt.split(' ');
        integer year = Integer.ValueOf(listDTStr[5]);
        integer month = MonthConvert(listDTStr[1]);
        integer day = Integer.ValueOf(listDTStr[2]);
        //integer hour = Integer.ValueOf(listDTStr[3].split(':')[0]);
        //integer minute = Integer.ValueOf(listDTStr[3].split(':')[1]);
        //integer second = Integer.ValueOf(listDTStr[3].split(':')[2]);
        parsedDt = DateTime.newInstance(year, month, day);//, hour, minute, second);
        
        return parsedDt;
    }
}