public class GlobalUtility { 
/*
----------------------------------------------------------------------
-- - Name          : GlobalUtility
-- - Author        : 
-- - Description   : Class for keeping all common methods                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 24-JUN-2013  GDO   1.0      Initial version 
----------------------------------------------------------------------
*/

/***********************************************************************
* Organization 
************************************************************************/

    private static List<Holiday> listHoliday = new List<Holiday>([SELECT Id, Name, ActivityDate FROM Holiday]);
    public static User IntegrationUser = [select Id from User where IsActive = true and Integration_User__c = true limit 1];



/***********************************************************************
* Global Function
************************************************************************/

    public static User getIntegrationUser(){
        return IntegrationUser;
    }
    
/*method to calculate if a day is a working day*/
    public static Boolean isHolidays(Date day){
        Boolean isHoliday=false;
        Boolean exist=false ;             
        if( listHoliday != null && listHoliday.size()>0){           
            for (Holiday holiday : listHoliday){
                if (holiday.ActivityDate.isSameDay(day)){
                    exist=true;
                }
            }
        }

        if ((day.toStartOfWeek()).daysBetween(day)==6 || (day.toStartOfWeek()).daysBetween(day)==0 || exist == true){
            isHoliday=true;           
        }
        return isHoliday;       
      }//end method isHolidays
    

/*method to calculate the target date based on a date and a number of work days*/   
    public static DateTime TargetWorkingDay(DateTime day, Integer NbWorkDays){
        Integer Signe = 1;
        
        if(NbWorkDays < 0){
            Signe = -1;
            NbWorkDays = NbWorkDays * Signe;

        }
        Integer NbDays = NbWorkDays;
        
        if(NbWorkDays <> 0){
            for(integer i = 1 ; i <= NbWorkDays ; i++){
    
                if (isHolidays(Date.valueof(day.addDays(i*Signe))) == true){ 
                    NbDays = NbDays + 1;
                }
                
            }
        }
        
        if (isHolidays(Date.valueof(day.addDays(NbDays*Signe))) == true){ 
                NbDays = NbDays + 1;
        }

        if (isHolidays(Date.valueof(day.addDays(NbDays*Signe))) == true){ 
            NbDays = NbDays + 1;
        }

        return day.addDays(NbDays*Signe);
    }//end method TargetWorkingDay


    @future
    public static void ProcessObjects(string JSONString)
    {
        list<sobject> a =(list<sobject>)JSON.deserialize(JSONString, List<sobject>.class);

        insert a;
    }
    
         
}//end class GlobalUtility