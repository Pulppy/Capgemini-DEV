public with sharing class LN_TodayTaskAndEventController
{
    
    public class Data 
    {
		 @AuraEnabled
        public Date mytoday { get; set; }

        @AuraEnabled
        public List<Task> todayTasks { get; set; }

        @AuraEnabled
        public List<Event> todayEvents { get; set; }

        @AuraEnabled
        public List<Lead> myLeads { get; set; }

		/*
        @AuraEnabled
        public String urlDashboard { get; set; }

        @AuraEnabled
        public Id idDashboard { get; set; }

        @AuraEnabled
        public String nameDashboard { get; set; }
       */
    }

    @AuraEnabled
    public static List<Task> loadTasks(Id recordId){
        return[SELECT Subject, ActivityDate FROM Task WHERE WhatId=:recordId];
    }

    @AuraEnabled
    public static Task saveTask(Task task){
        upsert task;
        return task;
   }
   
   @AuraEnabled
    public static LN_TodayTaskAndEventController.Data prepare()
    {
        String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
        
        //Id FolderId = [select id from folder where Name =:folderName limit 1].id;
        
        LN_TodayTaskAndEventController.Data tag = new LN_TodayTaskAndEventController.Data();

		tag.mytoday = Date.today();
       
        //tag.todayTasks = new list<Task> ([ SELECT Id, Subject, Priority, Description, Status, ActivityDate FROM Task WHERE ActivityDate=TODAY AND OwnerId=:UserInfo.getUserId() limit 10]);
        tag.todayTasks = new list<Task> ([ SELECT Id, Subject, Priority, Description, Status, Who.Name, ActivityDate FROM Task WHERE ActivityDate=TODAY limit 10]);

        //tag.todayEvents = new list<Event> ([ SELECT Id, Subject, Description,ActivityDate FROM Event WHERE ActivityDate=TODAY AND OwnerId=:UserInfo.getUserId() limit 10]);
        tag.todayEvents = new list<Event> ([ SELECT Id, Subject, Description, StartDateTime, EndDateTime,Who.Name, ActivityDate FROM Event WHERE ActivityDate=TODAY limit 10]);
 
        return tag;
    }
  	
}