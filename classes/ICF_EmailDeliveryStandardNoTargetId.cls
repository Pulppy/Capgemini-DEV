global class ICF_EmailDeliveryStandardNoTargetId implements ICF_IEmailDelivery {
	public ICF_EmailDeliveryStandardNoTargetId() {}

	global Map<Id, Task> sendEmails(list<ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer> pEmailList, Map<Id, Task> mapTaskUpdates, Set<Id> pRemindTasks) {
 		System.debug('>>> START ICF_EmailDeliveryStandardNoTargetId - sendSTDEmail <<<');
        
        Messaging.singleEmailMessage email ;
        list<Messaging.singleEmailMessage> emails = new list<Messaging.singleEmailMessage>();
        list<OrgWideEmailAddress> listOrgWideEmailAddress = new list<OrgWideEmailAddress>([SELECT Address, DisplayName, Id FROM OrgWideEmailAddress where DisplayName = :system.label.LABS_SF_Org_Wide_Email_Address or id  = :system.label.LABS_SF_Org_Wide_Email_Address limit 1]);
        List<Id> vImpactedTasks = new List<Id>();

        if (listOrgWideEmailAddress.size() == 1) {
            for (ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer wrEmail : pEmailList) {
                if (String.isNotBlank(wrEmail.To)) {
                    email = new Messaging.singleEmailMessage();
                    email.setHtmlBody(wrEmail.HtmlBody);
                    email.setPlainTextBody(wrEmail.TextBody);
                    email.setSubject(wrEmail.Subject);
                    email.setToAddresses(new List<String>{ wrEmail.To });
                    email.setOrgWideEmailAddressId(listOrgWideEmailAddress[0].id);
                    emails.add(email);
                    if (String.isNotBlank(wrEmail.TaskId)) {
                        vImpactedTasks.add(Id.valueOf(wrEmail.TaskId));
                    }
                } else {
                    if (String.isNotBlank(wrEmail.TaskId)) {
                        mapTaskUpdates.get(wrEmail.TaskId).Status = ICF_AP_Constant.TaskStatusFailedEmail;
                        mapTaskUpdates.get(wrEmail.TaskId).ICF_Exception__c += ' Missing contact,lead or user assoiciated to send the email.'  ;
                    } else {
                        System.debug('>>>## sendSTDEmail - blank TaskId:' + wrEmail);
                    }
                }
            }
            System.debug('>>>## ICF_EmailDeliveryStandardNoTargetId - emails:' + emails);
            try {  
                Messaging.sendEmail(emails);                    

                // Everything went right to update the status to 'Sent'
                setStatusToSentInTasksMap(vImpactedTasks, mapTaskUpdates);
                // Add  coverage because it is impossible to have a mock for sendEmail
                if (Test.isRunningTest() && email != null && email.HtmlBody.contains('###Failure from test###')) {
                    Integer vException = 1 / 0;
                } 
            } catch (Exception e) {
                System.debug('############ Exception occured during send ' + e);
                System.debug('############ pEmailList :  ' + pEmailList);
                for (ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer wrEmail : pEmailList) {
                    System.debug('############ Task status : ' + mapTaskUpdates.get(wrEmail.TaskId).Status);
                    Boolean vIsReminder = pRemindTasks != null && pRemindTasks.contains(wrEmail.TaskId);
                    System.debug('############ vIsReminder : ' + vIsReminder);
                    if (e.getMessage().contains('SINGLE_EMAIL_LIMIT_EXCEEDED')) {
                        resetSentDateOrRemindSentDateOfTask(mapTaskUpdates.get(wrEmail.TaskId), vIsReminder);
                        mapTaskUpdates.get(wrEmail.TaskId).Status = vIsReminder ? ICF_AP_Constant.TaskStatusRemindFailLimit : ICF_AP_Constant.TaskStatusFailedLimitReach;
                    } else {
                        resetSentDateOrRemindSentDateOfTask(mapTaskUpdates.get(wrEmail.TaskId), vIsReminder);
                        mapTaskUpdates.get(wrEmail.TaskId).Status = vIsReminder ? ICF_AP_Constant.TaskStatusRemindSendFail : ICF_AP_Constant.TaskStatusFailedEmail;
                    }
                    mapTaskUpdates.get(wrEmail.TaskId).ICF_Exception__c += 'Error :' + e.getMessage();
                }
            }//end of catch
        } else {
            for (ICF_SurveyDeliveryBatch.WrapperEmailSmsContainer wrEmail : pEmailList) {
                Boolean vIsReminder = pRemindTasks != null && pRemindTasks.contains(wrEmail.TaskId);
                resetSentDateOrRemindSentDateOfTask(mapTaskUpdates.get(wrEmail.TaskId), vIsReminder);
                mapTaskUpdates.get(wrEmail.TaskId).Status = vIsReminder ? ICF_AP_Constant.TaskStatusRemindSendFail : ICF_AP_Constant.TaskStatusFailedEmail;
                mapTaskUpdates.get(wrEmail.TaskId).ICF_Exception__c += 'Error : Invalid ORG WIDE EMAIL ADDRESS Id';
            }
        }
        System.debug('>>> START ICF_EmailDeliveryStandardNoTargetId - sendSTDEmail <<<');

        return mapTaskUpdates;
	}


    /*
    * In case of success change the status
    */
    private void setStatusToSentInTasksMap(List<Id> pImpactedTasks, Map<Id, Task> pTaskMap) {
        for (Id vTaskId : pImpactedTasks) { 
            pTaskMap.get(vTaskId).Status = ICF_AP_Constant.TaskStatusSent; 
        }
    }

    /*
    * Incase of send fail, reset the sent date
    */
    private void resetSentDateOrRemindSentDateOfTask(Task pTask, Boolean pIsReminder) {
        if (pTask != null) {
            // If not reminder, reset the sent date
            if (!pIsReminder) {
                pTask.ICF_Sent_Date__c = null;
            } else {
                // if reminder reset the reminder sent date
                pTask.ICF_Remind_Date__c = null;
            }
        }
    }
}