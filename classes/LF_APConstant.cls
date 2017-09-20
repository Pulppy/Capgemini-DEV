public with sharing class LF_APConstant {

/**************************************************************************************
-- - Author        : SC
-- - Description   : Constants variable and common classes are stored in this context
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 03-AUG-2016  VMU    1.0     Initial version
--------------------------------------------------------------------------------------
**************************************************************************************/
    //test  
    // A class definined for use, to store a json response or the generated error if any
    Public class DataResponse{
        @AuraEnabled
        public boolean inError {get;set;}//true if any error in the response
        @AuraEnabled
        public String errorMsg{get;set;}// the error to display
        @AuraEnabled
        public list<object> responseAsList{get;set;}// in case of no error, the response as a list of object        
        @AuraEnabled
        public map<String,object> responseAsMap{get;set;}// in case of no error, the response as a map of object (for complex type)       
        @AuraEnabled
        public String responseAsJSON{get;set;} // in case of no error, the response as an unparsed JSON

        public DataResponse(){
            inError = false;
            errorMsg = '';                      
        }
        public void addError(String s){
            errorMsg = s;
            inError = true;
        }
    }
    // Class defining custom exception
    public class customException extends Exception {}

    //Method to generate a map that contains developer Name and id for a set of ObjectAPINames 
    public static map<String,Id> getDeveloperIdMap(Set<String> ObjectAPINames){
        map <String,Id> developerIdMap = new map <String,Id>();
    
        //returns a map where key is Sobject-RecDevName and value is recordtypeId
        //e.g Account-Customer, XXXXX
        for(RecordType r : [select SobjectType,DeveloperName,Id
                                        from RecordType
                                        where SobjectType IN:ObjectAPINames
                                        order by SobjectType ASC ]){
            developerIdMap.put((r.SobjectType +'-'+ r.DeveloperName),r.Id);
        }
        return developerIdMap;                  
    }

    //Case variables
    public static string sobjCase = 'Case';

    //variables used as reference to delete Documents created by WS RetrieveDocumentDetail/ BAT00_DeleteContentDoc
    public static string ExtDocRef = 'HKWSRetrieveDocumentDetails';
    public static string nameDocError = 'csvWSContentDocumentDeleteFailure';

    //Method to retrieve document folderid by doc developer name
    public static Id getDocFolderIdByDevName(String devName){
        return [Select Id from Folder where DeveloperName = :devName limit 1].Id;                 
    } 
    
    
}