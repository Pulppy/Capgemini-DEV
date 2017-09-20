/**************************************************************************************
Apex Class Name - ICF_SurveyDeliveryBatch

Version - 1.0

Created Date - 5 OCT 2015

Function - Batch to send email or sms to each contact/account for each task.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date            Description
* ----------    -----           ------------------------
* Spoon (HDU)   15/10/2015      Original Version
*************************************************************************************/
global class ICF_SurveyDeliveryBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global boolean isSingleEmailLimitReached;
    global string query;
    global string taskStatusInProgress = ICF_AP_Constant.TaskStatusInProgress;
    global string taskStatusFailedLimitReach = ICF_AP_Constant.TaskStatusFailedLimitReach;
    global string taskStatusFailedEmail = ICF_AP_Constant.TaskStatusFailedEmail;
    global string taskStatusSent = ICF_AP_Constant.TaskStatusSent;
    global string taskStatusRemind =  ICF_AP_Constant.TaskStatusRemind;
    global string taskStatusRemindFailLimit = ICF_AP_Constant.TaskStatusRemindFailLimit;

    global ICF_SurveyDeliveryBatch() {
        query = 'SELECT Id, WhatId, WhoId,ICF_SurveyId__c,Description, Status, ICF_Remind_Date__c, ICF_business_object__c, ICF_sent_date__c '+
                'FROM   task '+
                'WHERE  (Status = :taskStatusInProgress Or Status = :taskStatusFailedLimitReach or Status = :taskStatusRemind or Status = :taskStatusRemindFailLimit) '+
                'AND    ICF_SurveyId__c != null '+
                'AND    (WhatId != null '+
                '       OR WhoId != null) '+
                'ORDER BY CreatedDate';  
    }//end of constructor
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('>>> START ICF_SurveyDeliveryBatch - start <<<');
        isSingleEmailLimitReached = false;
        System.debug('>>>## start - query:'+query);
        System.debug('>>> END ICF_SurveyDeliveryBatch - start <<<');
        try {
            List<SObject> sobjList = Database.query(query);
            System.debug('Count: ' + sobjList.size());
            for (Integer i = 0; i < sobjList.size(); i++) {
                System.debug('Task: ' + sobjList[i].get('WhatId'));
            }
        } catch (Exception e) {
            System.debug('Errors: ' + e.getStackTraceString());
        }
        return Database.getQueryLocator(query);
    }//end of start

    global void execute(Database.BatchableContext BC, List<Task> scope) {
        System.debug('>>> START ICF_SurveyDeliveryBatch - execute <<<');
        System.debug('>>>## execute - scope size:'+ scope.size()); 
        if (!isSingleEmailLimitReached) {
            ICF_Survey__c surveyTemp;
            sObject objWhat;
            sObject objWho;
            String soql = '';    
            String recieverWho ='';
            String recieverPhoneWho ='';
            String whoChannel ='';
            String recieverWhat ='';
            String whatChannel ='';
            String emailTextBody = '';
            String emailHtmlBody = '';   
            String emailTemplateName = '';  
            String smsTemplateText = '';
            //string surveyUrl = '';       
            EmailTemplate emailTemplate;
            WrapperEmailSmsContainer wrSMS;
            ICF_SurveyTranslation__c smsTemplate;
            WrapperEmailSmsContainer wrEmail;
            Set<Id> setSurveyIds = new Set<Id>();   
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setContactIds = new Set<Id>();            
            Set<Id> setTaskToRemindIds = new Set<Id>();
            Set<String> setEmailTemplateIds = new Set<String>();
            Set<String> setReminderEmailTemplateIds = new Set<String>();
            Map<Id,Task> mapTaskUpdates = new Map<Id,Task>();
            List<WrapperEmailSmsContainer> listWrapperSMS = new list<WrapperEmailSmsContainer>();
            List<WrapperEmailSmsContainer> listWrapperEmail = new list<WrapperEmailSmsContainer>();
            Map<Id,ICF_Survey__c> mapIdToSurvey = new Map <Id,ICF_Survey__c>(); 
            Map<String,EmailTemplate> mapIdToEmailTemplate = new Map <String,EmailTemplate>(); 
            Map<String,sObject> mapObjIdSobject = new Map <String,sObject>(); 
            Set<String> vSurveysId = new Set<String>();
            /* Used to fill in email templates */
            // Keep all the custom setting corresponding to the correct survey and business object
            List<ICF_EmailTemplateMapping__c> vCSETToKeep  = new  List<ICF_EmailTemplateMapping__c>();
            // Map all the task to the associated BO Id
            Map<Id, Id> vTaskBOMap = new Map<Id, Id>();
            // Map all the sObjectRetrieved to their id
            Map<Id, Sobject> vBusinessObjectMap = new Map<Id, Sobject>();
            // List of all possible merging fields
            Set<String> vAllPossibleMergingFieldsOfCS = new Set<String>();

            //loop scope and store survey,whatid ,whoid of each task in different container. 
            for (Task t :scope) {
                setSurveyIds.add(t.ICF_SurveyId__c);
                
                //Ids of task to remind (will help to use a "reminder email template")
                if (t.Status == taskStatusRemind || t.Status == taskStatusRemindFailLimit) {
                    setTaskToRemindIds.add(t.Id);
                }

                //save account id in list
                if (t.whatId != null && String.valueOf(t.whatId).startsWith(Schema.sObjectType.Account.getKeyPrefix())) {
                    setAccountIds.add(t.whatId);
                }//end of check Account

                //save contact id in list
                if (t.whoId != null && String.valueOf(t.whoId).startsWith(Schema.sObjectType.Contact.getKeyPrefix())) {
                    setContactIds.add(t.whoId);
                }//end of check Contact
                // Set status by default to fail
                if (t.Status == taskStatusRemind) {
                    t.Status = ICF_AP_Constant.TaskStatusRemindSendFail;
                } else {
                    t.Status = taskStatusFailedEmail;
                }
                // Reset exception
                t.ICF_Exception__c = '';
                mapTaskUpdates.put(t.id,t);
                // Add all differents surveys
                vSurveysId.add(t.ICF_SurveyId__c);
            }//end of loop scope
            System.debug('>>>## execute - setSurveyIds size:'+ setSurveyIds.size());
            System.debug('>>>## execute - setAccountIds size:'+ setAccountIds.size());
            System.debug('>>>## execute - setContactIds size:'+ setContactIds.size());   

            //retrieve all CS email template records (the aim is to fill merging fields in email)
            System.debug('########################## Retrieve Custom setting ICF_EmailTemplateMapping__c');
            if (scope != null && scope.size() > 0) {
                // Retrieve Custom settings records
                List<ICF_EmailTemplateMapping__c> vETCSFullConfig = [SELECT Name, EmailTemplateFieldName__c, FieldName__c, SObject__c, SurveyId__c FROM ICF_EmailTemplateMapping__c];
                // Retrieve all the differents objects with fields to retrieve (Map<SObjectType, Field>)
                Map<String, Set<String>> vSObjectsTypesAndFields = new Map<String, Set<String>>();
                // Map all the BusinessObject of the task to the object to retrieve (Map<SObjectType, List<TaskID>>)
                Map<String, List<Id>> vBOIDsByObjectToRetrieve = new Map<String, List<Id>>();

                if (vETCSFullConfig != null) {
                    for (ICF_EmailTemplateMapping__c vEmailTemplateMapping : vETCSFullConfig) {
                        vAllPossibleMergingFieldsOfCS.Add(vEmailTemplateMapping.EmailTemplateFieldName__c);
                    }
                }

                for (Task vTask : scope) {
                     if (vETCSFullConfig != null && vETCSFullConfig.size() > 0 && vTask.ICF_business_object__c != null) {
                        try {
                            Id vId = Id.valueOf(vTask.ICF_business_object__c);
                            String vSObjectName = vId.getSObjectType() + ''; 
                            vTaskBOMap.put(vTask.Id, vId); // Task <-> BO but as real ID now

                            for (ICF_EmailTemplateMapping__c vEmailTemplateMapping : vETCSFullConfig) {
                                if (vEmailTemplateMapping.sObject__c == vSObjectName && vEmailTemplateMapping.SurveyId__c == vTask.ICF_SurveyId__c) {
                                    // Add the current record of CS to the list of custom setting to keep
                                    vCSETToKeep.add(vEmailTemplateMapping);
                                    // Fill in the map (Map<SObjectType, List<BoID>>)
                                     if (vBOIDsByObjectToRetrieve.containsKey(vEmailTemplateMapping.sObject__c)) {
                                        List<Id> vBOTasksId = vBOIDsByObjectToRetrieve.get(vEmailTemplateMapping.sObject__c);
                                        vBOTasksId.add(vId);
                                        vBOIDsByObjectToRetrieve.put(vEmailTemplateMapping.sObject__c, vBOTasksId);
                                    } else {
                                        vBOIDsByObjectToRetrieve.put(vEmailTemplateMapping.sObject__c, new List<Id>{ vId });
                                    }
                                }
                            }
                        } catch (Exception e) {
                            System.debug('##########################' + e.getMessage());
                        }
                    }
                }

                System.debug('################## vBOIDsByObjectToRetrieve : ' + vBOIDsByObjectToRetrieve);
                System.debug('################## vCSETToKeep : ' + vCSETToKeep);
                System.debug('################## vTaskBOMap : ' + vTaskBOMap);

                // Fill in the map (Map<SObjectType, List<fields name to retrieve>>)
                if (vCSETToKeep != null && vCSETToKeep.size() > 0) {
                    for (ICF_EmailTemplateMapping__c vMapping : vCSETToKeep) {
                        if (vSObjectsTypesAndFields.containsKey(vMapping.sObject__c)) {
                            Set<String> vFieldsToRetrieve = vSObjectsTypesAndFields.get(vMapping.sObject__c);
                            vFieldsToRetrieve.add(vMapping.FieldName__c);
                            vSObjectsTypesAndFields.put(vMapping.sObject__c, vFieldsToRetrieve);
                        } else {
                            vSObjectsTypesAndFields.put(vMapping.sObject__c, new Set<String>{ vMapping.FieldName__c });
                        }
                    }
                    System.debug('################## vSObjectsTypesAndFields : ' + vSObjectsTypesAndFields);

                    // Then retrieve business objects fields
                    // First construct SOQL
                    for (String vObject : vSObjectsTypesAndFields.keySet()) {
                        List<Id> vBusinessObjectsIdsOfThisType = vBOIDsByObjectToRetrieve.get(vObject); // List of id of this object type
                        String vQuery = 'SELECT Id ';
                        for (String vField : vSObjectsTypesAndFields.get(vObject)) {
                            vQuery += (', ' + vField);
                        }
                        vQuery += ' FROM ' + vObject + ' WHERE Id IN :vBusinessObjectsIdsOfThisType';
                        System.debug('############## Query executed ' + vQuery);
                        for (SObject vSobject : Database.Query(vQuery)) {
                            vBusinessObjectMap.put(vSobject.Id, vSobject);
                        }
                    }
                    System.debug('################## vBusinessObjectMap : ' + vBusinessObjectMap);
                    System.debug('############## End of business object retrieve ');
                }
            }

            //retrieve all accounts record
            if (setAccountIds.size() > 0) {
                soql = 'SELECT '+ String.join(getFields(Schema.sObjectType.Account.getName()) , ',') + ' FROM ' + Schema.sObjectType.Account.getName() + ' Where Id IN :setAccountIds';
                for (Account acc : Database.query(soql)) {
                    mapObjIdSobject.put(acc.Id,acc);
                }//end of loop for contact
            }//end of check setAccountIds size
            System.debug('>>>## execute - mapObjIdSobject with Account size:'+ mapObjIdSobject.size()); 

            //retrieve all contact record
            if (setContactIds.size() > 0) { 
                String vFieldEmailInLabel = Test.isRunningTest() ? 'Email' : System.label.LABS_SF_Survey_Recipent_Con_Email_Field;
                String vFieldPhoneInLabel = Test.isRunningTest() ? 'Phone' : System.label.LABS_SF_Survey_Recipent_Con_Phone_Field;
                String vFieldWhoChannel = Test.isRunningTest() ? 'Email' : System.label.LABS_SF_Survey_Contact_Channel_Field;
                List<String> vContactFields = getFields(Schema.sObjectType.Contact.getName());
                Boolean vFieldEmailAlreadyIncluded = false;
                Boolean vFieldPhoneAlreadyIncluded = false;
                Boolean vWhoChannelAlreadyIncluded = false; 
                for (String vField : vContactFields) {
                    if (vField == vFieldEmailInLabel) {
                        vFieldEmailAlreadyIncluded = true; 
                    }
                    if (vField == vFieldPhoneInLabel) {
                        vFieldPhoneAlreadyIncluded = true; 
                    }
                    if (vField ==  vFieldWhoChannel) {
                        vWhoChannelAlreadyIncluded = true; 
                    }
                }                 
                if (!vFieldEmailAlreadyIncluded) {
                    vContactFields.add(vFieldEmailInLabel);
                }
                if (!vFieldPhoneAlreadyIncluded) {
                    vContactFields.add(vFieldPhoneInLabel);
                }
                if (!vWhoChannelAlreadyIncluded) {
                    vContactFields.add(vFieldWhoChannel);
                }

                soql = 'SELECT ' + String.join(vContactFields, ',') + ' FROM ' + Schema.sObjectType.Contact.getName() + ' Where Id IN :setContactIds';
                for (Contact con : Database.query(soql)) {
                    mapObjIdSobject.put(con.Id,con);
                }//end of loop for contact
            }//end of check setContactIds size
            System.debug('>>>## execute - mapObjIdSobject with Contact size:'+ mapObjIdSobject);//.size());

            //retrieve all contact Survey
            if (setSurveyIds.size() > 0) {
                for (ICF_Survey__c survey : [SELECT Id, Survey_Language__c , EmailTemplate__c, Reminder_EmailTemplate__c,
                                                    Email_Template__c, SMS_Template__c, Reminder_SMS_Template__c,
                                                    Survey_Delivery_Channel__c
                                             FROM   ICF_Survey__c 
                                             WHERE  Id IN :setSurveyIds]) {

                    mapIdToSurvey.put(survey.id,survey);
                    
                    if (String.isNotBlank(survey.EmailTemplate__c)) {
                        setEmailTemplateIds.add(survey.EmailTemplate__c);
                    }
                    if (!setTaskToRemindIds.IsEmpty() && String.isNotBlank(survey.Reminder_EmailTemplate__c)) {
                        setReminderEmailTemplateIds.add(survey.Reminder_EmailTemplate__c);
                    }
                }//end of loop survey
            }//end of check setSurveyIds size

            System.debug('>>>## execute - setEmailTemplateIds size:'+ setEmailTemplateIds.size());
            //retrieve all email templates
            if (setEmailTemplateIds.size() > 0) {
                for (EmailTemplate emailTem : [SELECT Id,Body,HtmlValue,Name,TemplateType,Subject, DeveloperName  FROM EmailTemplate 
                                               WHERE (DeveloperName IN :setEmailTemplateIds or DeveloperName IN :setReminderEmailTemplateIds) AND IsActive = true]) {
                    mapIdToEmailTemplate.put(emailTem.DeveloperName, emailTem);
                }//end of loop email template
            }//end of check size
            System.debug('>>>## execute - mapIdToEmailTemplate size:'+ mapIdToEmailTemplate.size());
            
            //loop in scope to prepare list mails and list sms
            for (Task t : scope) {
                objWhat = null;
                objWho = null;
                emailTemplate = null;
                smsTemplate = null;
                emailTemplateName = '';                
                smsTemplateText = '';
                Boolean vIsAReminderTask = setTaskToRemindIds.contains(t.Id);
                SObject vBusinessObject = null;

                //get survey, Account and Contact related to this Task
                surveyTemp = mapIdToSurvey.get(t.ICF_SurveyId__c);
                if (surveyTemp != null) {
                    if (t.whoId != null &&  mapObjIdSobject.containskey(t.whoId)) {
                        objWho =  mapObjIdSobject.get(t.whoId);
                        System.debug('############# - objWho:'+ objWho);  
                        System.debug('#############  System.label.LABS_SF_Survey_Recipent_Con_Phone_Field : ' + System.label.LABS_SF_Survey_Recipent_Con_Phone_Field);

                        if (String.valueOf(t.whoId).startsWith(Schema.sObjectType.Contact.getKeyPrefix())) {
                            String vEmailField = Test.isRunningTest() ? 'Email' : System.label.LABS_SF_Survey_Recipent_Con_Email_Field;
                            // If label contains '.' it means there is a relation example Account.Email__c
                            if (vEmailField.contains('.')) {
                                List<String> vEmailFieldSplit = vEmailField.split('\\.', 2);
                                String vSObject = vEmailFieldSplit[0]; 
                                String vSField = vEmailFieldSplit[1]; 
                                recieverWho = String.valueOf(objWho.getSObject(vSObject).get(vSField));
                            } else {
                                recieverWho = String.valueOf(objWho.get(vEmailField));
                            } 
                            String vPhoneField = Test.isRunningTest() ? 'Phone' : System.label.LABS_SF_Survey_Recipent_Con_Phone_Field;
                            // If label contains '.' it means there is a relation example Account.Email__c
                            if (vPhoneField.contains('.')) {
                                List<String> vPhoneFieldSplit = vPhoneField.split('\\.', 2);
                                String vSObject = vPhoneFieldSplit[0]; 
                                String vSField = vPhoneFieldSplit[1]; 
                                recieverPhoneWho = String.valueOf(objWho.getSObject(vSObject).get(vSField));
                            } else {
                                recieverPhoneWho = String.valueOf(objWho.get(vPhoneField));
                            }
                            String vWhoChannel = Test.isRunningTest() ? 'Email' : System.label.LABS_SF_Survey_Contact_Channel_Field;
                            whoChannel = String.valueOf(objWho.get(vWhoChannel));
                        }
                    }
                    // Get business object related to this task
                    if (vTaskBOMap != null && vTaskBOMap.keySet().size() > 0 && vTaskBOMap.containsKey(t.Id)) {
                        vBusinessObject = vBusinessObjectMap.get(vTaskBOMap.get(t.Id));
                    }

                    System.debug('#################### vBusinessObject : ' + vBusinessObject);
                    System.debug('>>>## execute - objWhat:'+ objWhat); 
                    System.debug('>>>## execute - whoChannel:'+ whoChannel);   
                    System.debug('>>>## execute - recieverWho:'+ recieverWho);  
                    System.debug('>>>## execute - recieverPhoneWho:'+ recieverPhoneWho);   

                    //invitation email/sms
                    if (!vIsAReminderTask) {
                        //Email Template
                        if (ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_ET_'+surveyTemp.Survey_Language__c) != null) {
                            emailTemplateName = ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_ET_'+surveyTemp.Survey_Language__c).TranslatedValue__c;
                            if (String.IsNotBlank(emailTemplateName))
                                emailTemplate = mapIdToEmailTemplate.get(emailTemplateName);
                        } else {                        
                            emailTemplate = mapIdToEmailTemplate.get(surveyTemp.EmailTemplate__c);
                        }
                        //Sms Template  
                        if (ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_SMS_'+surveyTemp.Survey_Language__c) != null) {
                            smsTemplate = ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_SMS_'+surveyTemp.Survey_Language__c);
                            if (String.IsNotBlank(smsTemplate.TranslatedValue__c))
                                smsTemplateText = smsTemplate.TranslatedValue__c;                           
                        } else {                        
                            smsTemplateText = surveyTemp.SMS_Template__c;
                        }                       
                                    
                    } else {//reminder email/sms
                        //Reminder Email Template
                        if (ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_REMIND_ET_'+surveyTemp.Survey_Language__c) != null) {
                            emailTemplateName = ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_REMIND_ET_'+surveyTemp.Survey_Language__c).TranslatedValue__c;
                            if (String.IsNotBlank(emailTemplateName))
                                emailTemplate = mapIdToEmailTemplate.get(emailTemplateName);
                        } else {                        
                            emailTemplate = mapIdToEmailTemplate.get(surveyTemp.Reminder_EmailTemplate__c);
                        }
                        
                        //Reminder Sms Template 
                        if (ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_REMIND_SMS_'+surveyTemp.Survey_Language__c) != null) {
                            smsTemplate = ICF_SurveyTranslation__c.getValues(surveyTemp.id+'_REMIND_SMS_'+surveyTemp.Survey_Language__c);
                            if (String.IsNotBlank(smsTemplate.TranslatedValue__c))
                                smsTemplateText = smsTemplate.TranslatedValue__c;                           
                        } else {                        
                            smsTemplateText = surveyTemp.Reminder_SMS_Template__c;
                        }
                    }
                    System.debug('>>>## execute - key:'+ surveyTemp.id+'_SMS_'+surveyTemp.Survey_Language__c);           
                    System.debug('>>>## execute - smsTemplate:'+ smsTemplate);    
                    
                    // Fill in email template html and text
                    if (emailTemplate != null) {
                        emailTextBody = emailTemplate.Body;
                        emailHtmlBody = emailTemplate.HtmlValue;
                        /*if (t.Description != null) {
                            surveyUrl = GoogleUrlShortenerInterface.getShortenedUrl(t.Description+'&tid='+t.id);
                            //surveyUrl = BitlyInterface.getShortenedUrl(t.Description+'&tid='+t.id);
                            System.debug('>>>## AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA - surveyUrl:'+ surveyUrl);
                        }*/ 

                        if (emailTextBody != null) {                            
                            emailTextBody = fillInTemplateBody(t, emailTextBody, vCSETToKeep, vBusinessObject, vAllPossibleMergingFieldsOfCS); 
                        }
                        if (emailHtmlBody != null) {
                            emailHtmlBody = emailHtmlBody.replace('<![CDATA[', '');
                            emailHtmlBody = emailHtmlBody.replace(']]>', '');
                            emailHtmlBody = fillInTemplateBody(t, emailHtmlBody, vCSETToKeep, vBusinessObject, vAllPossibleMergingFieldsOfCS); 
                        }

                        System.debug('>>>## execute - emailHtmlBody:'+ emailHtmlBody);
                        System.debug('>>>## execute - emailTextBody:'+ emailTextBody);
                    }
                    // Fill in SMS template
                    if (smsTemplateText != null) {
                        smsTemplateText = fillInTemplateBody(t, smsTemplateText, vCSETToKeep, vBusinessObject, vAllPossibleMergingFieldsOfCS); 
                    }

                    //check survey Delivery Type
                    if (surveyTemp.Survey_Delivery_Channel__c == ICF_AP_Constant.SURVEY_DELIVERY_CHANNEL_SMS  
                                        || (surveyTemp.Survey_Delivery_Channel__c == ICF_AP_Constant.SURVEY_DELIVERY_CHANNEL_CONTACT_BASED
                                            && whoChannel == ICF_AP_Constant.contactPreferredChannelSMS)) {
                        if (objWho != null && String.isNotBlank(recieverPhoneWho) && String.isNotBlank(smsTemplateText)) {
                            wrSMS = new WrapperEmailSmsContainer();
                            wrSMS.SmsBody = getReplacedText(smsTemplateText , objWho);
                            wrSMS.Phone = recieverPhoneWho;
                            wrSMS.TaskId = t.Id;                
                            listWrapperSMS.add(wrSMS);
                            if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                            else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                            }
                            //mapTaskUpdates.get(t.id).Status = taskStatusSent;     
                        } else if (String.isBlank(smsTemplateText)) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: SMS template Found with blank sms body.'); 
                        } else if (objWho == null) { 
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: No Destination found to send SMS. Blank Field [Name] for task.');
                        } else if (String.isBlank(recieverPhoneWho)) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Blank mobile number for destination. Blank Field [Mobile Phone] on contact.');
                        } else {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Fail.'); 
                        }//end of check for error
                    } else if (surveyTemp.Survey_Delivery_Channel__c == ICF_AP_Constant.SURVEY_DELIVERY_CHANNEL_EMAIL
                                        || (surveyTemp.Survey_Delivery_Channel__c == ICF_AP_Constant.SURVEY_DELIVERY_CHANNEL_CONTACT_BASED
                                            && whoChannel == ICF_AP_Constant.contactPreferredChannelEmail)) {
                        if (emailTemplate != null && objWho != null && String.isNotBlank(recieverWho)) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = getReplacedText(emailTemplate.Subject , objWho);
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = objWho.id;
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = getReplacedText(emailTextBody , objWho);
                                wrEmail.HtmlBody = getReplacedText(emailHtmlBody , objWho);
                                wrEmail.To = recieverWho;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                                //mapTaskUpdates.get(t.id).Status = taskStatusSent;
                        } else if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Case.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Case> vCL = [select Id, Account.Tech_Person_Email__c from Case where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Account.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                        } else if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Policy__c.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Policy__c> vCL = [select Id, Customer__r.Tech_Person_Email__c from Policy__c where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Customer__r.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                        } else if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Transaction__c.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Transaction__c> vCL = [select Id, Policy__r.Customer__r.Tech_Person_Email__c from Transaction__c where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Policy__r.Customer__r.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                        } else if (emailTemplate == null) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Blank email template.');
                        } else if (objWho == null) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: No Destination found to send mail. Blank Field [Name] for task.');
                        } else if (String.isBlank(recieverWho)) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Blank email address for destination. Blank Field [Email] on contact.');
                        } else { 
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Fail.');
                        }//end of check email
                    } else if (surveyTemp.Survey_Delivery_Channel__c == ICF_AP_Constant.SURVEY_DELIVERY_CHANNEL_EMAIL) {
                        if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Case.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Case> vCL = [select Id, Account.Tech_Person_Email__c from Case where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Account.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                        } else if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Policy__c.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Policy__c> vCL = [select Id, Customer__r.Tech_Person_Email__c from Policy__c where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Customer__r.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                        } else if (String.valueOf(t.WhatId).startsWith(Schema.sObjectType.Transaction__c.getKeyPrefix())) {
                                wrEmail = new WrapperEmailSmsContainer();
                                wrEmail.Subject = emailTemplate.Subject;
                                wrEmail.EmailTemplateId = emailTemplate.Id;
                                wrEmail.TargetObjectId = UserInfo.getUserId();
                                wrEmail.TaskId = t.Id;                
                                wrEmail.TextBody = emailTextBody;
                                wrEmail.HtmlBody = emailHtmlBody;
                            	List<Transaction__c> vCL = [select Id, Policy__r.Customer__r.Tech_Person_Email__c from Transaction__c where Id =:t.WhatId];
                                wrEmail.To = vCL[0].Policy__r.Customer__r.Tech_Person_Email__c;
                                listWrapperEmail.add(wrEmail);
                                if (t.ICF_Sent_Date__c == null && t.ICF_Remind_Date__c == null) // TaskStatusInProgress ||TaskStatusFailedLimitReach                             
                                    mapTaskUpdates.get(t.id).ICF_Sent_Date__c = System.now().date();
                                else if (t.ICF_Sent_Date__c != null) { //TaskStatusRemind
                                    mapTaskUpdates.get(t.id).ICF_Remind_Date__c = System.now().date();
                                }
                            
                        } else if (emailTemplate == null) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Blank email template.');
                        } else if (objWho == null) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: No Destination found to send mail. Blank Field [Name] for task.');
                        } else if (String.isBlank(recieverWho)) {
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Blank email address for destination. Blank Field [Email] on contact.');
                        } else { 
                            handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Fail.');
                        }//end of check email
                    } else {
                        handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Delivery mode of survey is not valid.');
                        System.debug('>>>## execute - ERROR survey Survey_Delivery_Channel__c['+ surveyTemp.Survey_Delivery_Channel__c+'] is not valid. Surevy ID:'+surveyTemp.id);
                    }//end of verify channel
                } else {
                    handleErrorOnTask(mapTaskUpdates.get(t.id), vIsAReminderTask, ' Error: Survey sis not active');
                }
            }//end of loop Task


            System.debug('>>>## execute - listWrapperSMS :'+ listWrapperSMS);//.size());
            if (listWrapperSMS.size() > 0) {
               mapTaskUpdates = sendSMS(listWrapperSMS, mapTaskUpdates, setTaskToRemindIds);
            }
            
            System.debug('>>>## execute - listWrapperEmail size:'+ listWrapperEmail.size());

            // Email / SMS Delivery
            if (listWrapperEmail.size() > 0) { 
                mapTaskUpdates = sendEmails(listWrapperEmail, mapTaskUpdates, setTaskToRemindIds);                
            }

            System.debug('>>>## execute - mapTaskUpdates size:'+ mapTaskUpdates);//.size());
            update mapTaskUpdates.Values();
        }//end of check if isSingleEmailLimitReached
        System.debug('>>> END ICF_SurveyDeliveryBatch - execute <<<');  
    }//end of execute
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> START ICF_SurveyDeliveryBatch - finish <<<');
        System.debug('>>> END ICF_SurveyDeliveryBatch - finish <<<');           
    }//end+ of finish

    global Map<Id, Task> sendSMS(list<WrapperEmailSmsContainer> listSms, Map<Id, Task> pTaskList, Set<Id> pReminderTasks) {
        ICF_ISMSDelivery vSMSDelivery = ICF_SurveyDeliveryFactory.getSMSDeliveryInstance();
        return vSMSDelivery.sendSMS(listSms, pTaskList, pReminderTasks);
    }//end of sendSMS

    global Map<Id, Task> sendEmails(list<WrapperEmailSmsContainer> listEmail, Map<Id, Task> mapTaskUpdates, Set<Id> pReminderTasks) {
       ICF_IEmailDelivery vEmailDelivery = ICF_SurveyDeliveryFactory.getEmailDeliveryInstance();
       return vEmailDelivery.sendEmails(listEmail, mapTaskUpdates, pReminderTasks);
    }//end of sendSTDEmail

    /*
    * Fill in merging fields of email template in parameter
    * Returns the template filled in
    */
    private String fillInTemplateBody(Task pTask, String pTemplateBody) {
        if (pTemplateBody == null) { 
            return null;
        }
        // If desctipyion is filled in then replace survey URL
        if (pTask.Description != null) {
            pTemplateBody = pTemplateBody.replace('{!SURVEY_URL}', pTask.Description + '&tid=' + pTask.id);
        } else {
            pTemplateBody = pTemplateBody.replace('{!SURVEY_URL}', '');
        }//end of check null description
    
        return pTemplateBody;
    }

    /*
    * Fill in merging fields of email template in parameter
    * Returns the template filled in
    */
    private String fillInTemplateBody(Task pTask, String pTemplateBody, List<ICF_EmailTemplateMapping__c> pFieldsToMap, SObject pSObject, Set<String> pMergingFields) {
        pTemplateBody = fillInTemplateBody(pTask, pTemplateBody);

        System.debug('############ Business Object  : ' + pSObject);
        if (pFieldsToMap != null && pFieldsToMap.Size() > 0 && pSObject != null) {  
            for (ICF_EmailTemplateMapping__c vField : pFieldsToMap) {
                System.debug('################  pSObject.getSObjectType() : ' + pSObject.getSObjectType());
                if (vField.sObject__c == pSObject.getSObjectType() + '') {
                    System.debug('############ vField to replace : ' + vField);
                    if (pTemplateBody.contains('{!' + vField.EmailTemplateFieldName__c + '}') && pSObject.get(vField.FieldName__c) != null) {
                        System.debug('################ Replace {!' + vField.EmailTemplateFieldName__c + '} by : ' + pSObject.get(vField.FieldName__c) + '');
                        pTemplateBody = pTemplateBody.replace('{!' + vField.EmailTemplateFieldName__c + '}', pSObject.get(vField.FieldName__c) + '');
                    }
                } 
            }
        }
        if (pMergingFields != null && pMergingFields.size() > 0) {
            // Remove all remaining merging fields
            System.debug('################ Merging fields : ' + pMergingFields);
            for (String vField : pMergingFields) {
                if (pTemplateBody.contains('{!' + vField + '}')) {
                    pTemplateBody = pTemplateBody.replace('{!' + vField + '}', '');
                }
            
            }
        }

        return pTemplateBody;
    }

    private void handleErrorOnTask(Task pTask, Boolean pIsAReminderTask, String pErrorMessage) {
        pTask.Status = pIsAReminderTask ? ICF_AP_Constant.TaskStatusRemindSendFail : ICF_AP_Constant.TaskStatusFailedEmail;        
        pTask.ICF_Exception__c += pErrorMessage;
        // Reset sent date or reminder date if sent failed 
        if (pIsAReminderTask) {
            pTask.ICF_Remind_Date__c = null;
        } else {
            pTask.ICF_Sent_Date__c = null;
        }
    }

    global List<String> getFields(String objName) {
        List<string> listFieldsName = new List<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = DescribeSObjectResultObj.fields.getMap();
        if (fieldMap != null)
        {
            for (string fieldAPiName : fieldMap.keyset()) {
                if (fieldMap.get(fieldAPiName).getDescribe().isAccessible()) {
                    listFieldsName.add(fieldAPiName);
                }//end of check field updatable
            }//end of loop in fields map
        } else{
            System.debug('>>>## getFields - ERROR No fields found for '+objName);
        }//end of check if field map = null

        return listFieldsName;
    }//end of getFields


    global String getReplacedText(String body, sObject obj) {
        System.debug('############ getReplacedText for body : ' + body + ' and obj : ' + obj);
        if (String.isBlank(body)) {
            return '';
        }

        String mergeField,field,value;
        String replaceText = body;
        Pattern findUrl = Pattern.compile('\\{\\!(.*?)\\}');
        Matcher matcher = findUrl.matcher(body);
       
        while (matcher.find()) {
          mergeField = matcher.group(1);
          System.debug('################### mergeField : ' + mergeField);
          field = mergeField.split('\\.')[1];
          value = '';
          if (obj.get(field) != null) {
            value =  String.valueOf(obj.get(field));
          }
          replaceText = replaceText.replace('{!'+mergeField+'}' ,value);
        }//end of loop find
        return replaceText;
    }//end of getFields

    global class WrapperEmailSmsContainer{
        global string To              {Set;Get;}
        global string Subject         {Set;Get;}
        global string TextBody        {Set;Get;}
        global string HtmlBody        {Set;Get;}
        global string Phone           {Set;Get;}
        global string SmsBody         {Set;Get;}
        global string EmailTemplateId {Set;Get;}
        global string TargetObjectId  {Set;Get;}
        global string TaskId          {Set;Get;}
    }//end of wrapper




}//end of batch