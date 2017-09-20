public class AP05RecordTypeUtil {

    //Method to get the  recordTypeId 
    public static Id getRecordTypeId(String obj, String recName){
       Id recTypeId;
       if(obj!= null && recName != null){
           recTypeId= Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().get(recName).getRecordTypeId();
       }  
       return recTypeId;  
    }

    public static String getRecordTypeName(String obj, Id recordTypeId) {
      if(obj != null) {
        for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()) {
          if(recInfo.getRecordTypeId() == recordTypeId) {
            return recInfo.getName();
          }
        }
      }

      return null;
    }
}