public with sharing class ICF_AP_Utility {
    public ICF_AP_Utility() {}

    /*
    * Get the standard picklist values
    */
    public static List<SelectOption> getStandardPicklistValues(SObjectField pPicklistField, Boolean pAddEmpty) {
        List<SelectOption> vSOList = new List<SelectOption>();
        // Get field describe
        Schema.DescribeFieldResult vFieldResult = pPicklistField.getDescribe();
        // Get picklist entries   
        List<Schema.PicklistEntry> vPickEntries = vFieldResult.getPicklistValues();

        if (pAddEmpty) {
            vSOList.add(new SelectOption('', ''));
        }
        for (Schema.PicklistEntry vPickEntry : vPickEntries) {
            vSOList.add(new SelectOption(vPickEntry.getLabel(), vPickEntry.getValue()));
        }       
        return vSOList;
    }
    
    //**
    //* Return the list of a pickList values after the applying of a filter  
    //*
    public static List<SelectOption> filterPckList(SObjectField field, set<string> valuesToShow, set<string> valuesToHide, List<SelectOption> opList) { 
        //List<SelectOption> opList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        // Get picklist entries   
        List<Schema.PicklistEntry> pckListEntries = fieldResult.getPicklistValues();
        
        //System.Debug('#####AA - filterPckList valuesToShow:'+valuesToShow);
        for (Schema.PicklistEntry pEntry : pckListEntries) {
            
            if(!valuesToShow.IsEmpty() && valuesToShow.contains(pEntry.getValue())) {
                opList.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
            else if (!valuesToHide.IsEmpty() && !valuesToHide.contains(pEntry.getValue())) {
                opList.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
            else if (valuesToShow.IsEmpty() && valuesToHide.IsEmpty()) {
                opList.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }
        //System.Debug('#####AA - filterPckList opList:'+opList);       
        return opList;
    }
    
    public static Boolean IsFieldExists(string sObjectName, string field) {
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> mpObjectFields = objectType.getDescribe().fields.getMap();
        if (field.contains('.')) {
            try {
                String queryToSelect = 'SELECT ' + field + ' FROM ' + sObjectName + ' limit 1';
                system.debug('## IsFieldExists - queryToSelect ' + queryToSelect);
                list <sObject> obj = new list <sObject> (Database.query(queryToSelect));
                return true;
            } catch (Exception e) {
                system.debug('## IsFieldExists - Exception' + e);
                return false;
            }
        } else {
            if (mpObjectFields.containsKey(field)) {
                Schema.DescribeFieldResult dfr = mpObjectFields.get(field).getDescribe();
                Schema.DisplayType fieldType = dfr.getType();
                return true;
            } else {
                return false;
            }
        }
    }

    /**
     *  Splits up the string as given by the user and adds each option
     *  to a list to be displayed as option on the Visualforce page
     *  param: str String as submitted by the user
     *  returns the List of String for the visualforce page
     */
    public static List<String> stringToStringList(String pString) {
        if (pString == '') {
            return new List<String>();
        }
        List<String> vStrList = pString.split('\n');

        List<String> vListReturn = new List<String>();
        for (String s : vStrList) {
            if (s != '') {
                vListReturn.add(s);
            }
        }
        return vListReturn;
    }
    
    public static string findObjectAPINameById(String recordId){
        if(recordId == null)
            return null;
        String objectAPIName = '';
        string keyPrefix = recordId.substring(0,3);
         for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
           String prefix = obj.getDescribe().getKeyPrefix();
           if(prefix == keyPrefix){
                 objectAPIName = obj.getDescribe().getName();
                  break;
            }
         }
         return objectAPIName;
    }
}