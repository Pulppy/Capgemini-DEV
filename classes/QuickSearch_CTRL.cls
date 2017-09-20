public with sharing class QuickSearch_CTRL {
	@AuraEnabled
    public static List<sObject> quickSearchListData(String searchKeyWord, String ObjectName){
        // use '%' behind keyword for find dynamic 
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
        
    }
}