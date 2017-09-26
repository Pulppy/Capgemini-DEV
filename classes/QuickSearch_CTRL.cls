/**
* @author 	Phuc Huynh
* @date 	20/09/2017
* @description A class use get value for customeQuickSearchResult component with value input to UI.
* Maintenance History: 
* -- Date         Name   Version  Remarks 
* -- -----------  ----  -------  -----------------------------
* -- 20/09/2017  Phuc    1.0    Initial version
* -- 20/09/2017  Phuc    1.1    Create function QuickSearch_CTRL
*/
public without sharing class QuickSearch_CTRL {

	/*
	* @author 	Phuc Huynh
	* @date 	20/09/2017
	* @description This function return  list value sObject follow input searchKeyWord to UI
	* @param searchKeyWord with type String
	* @param ObjectName with type String
	* @return List<sObject>
	*/
	@AuraEnabled
	public static List<sObject> quickSearchListData(String searchKeyWord, String ObjectName){
		try{
			// Use '%' behind keyword for find dynamic 
			String searchKey = searchKeyWord + '%';
			String strRecordTypeid = Label.PersonalAccount;
			List < sObject > returnList = new List < sObject > ();
			// Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
			String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND RecordTypeid   = ' +'\''+strRecordTypeid+'\''+ 'order by createdDate DESC limit 5';
			List < sObject > lstOfRecords = Database.query(sQuery);
			for (sObject obj: lstOfRecords) {
				returnList.add(obj);
			}
			return returnList;
		}catch(Exception ex){
			System.debug(ex.getMessage());
			return new List<sObject>();
		}
	}
}