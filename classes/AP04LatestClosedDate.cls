/*
    Name Class: AP04LatestClosedDate
    Created By: Nga Do
    Created Date: 2017/05/09
    Last Modified Date: 2017/05/09
*/

public class AP04LatestClosedDate {

    /*
    Name: onAfterUpdate
    Action: Update Actual Closed Date for Case Parent (Trigger is Parent or none of parent or child)
    Created By: Nga Do
    Created Date: 2017/05/09
    Last Modified Date: 2017/05/10
    */
    public static Boolean isCaseTrigerBeforeUpadateInvoked = false;
    public static Boolean isCaseTrigerAfterUpadateInvoked = false;

    public static void onBeforeUpdate(Map<Id, Case> mapNewCases, Map<Id, Case> mapCaseTriggerOld){

        if(!isCaseTrigerBeforeUpadateInvoked){

            // check trigger update is called or not
            // set key of triger is parent
            Set<Id> idCaseParentSet = new Set<Id>();
            // map child Case with lasted closed date or Status is not 'Closed'
            Map<Id, Case> caseLatestMap = new Map<Id, Case>();
            
            for(Case objCase : mapNewCases.values()){
                // check case trigger is parent
                if(objCase.ParentId == null){
                    idCaseParentSet.add(objCase.Id);
                }
                
            }
            // get list all Chils of Case Trigger
            List<Case> listCaseChilds = [SELECT Id, Actual_close_date__c, ClosedDate, Status, ParentId, Parent.Status FROM Case  WHERE ParentId IN: idCaseParentSet];

            System.debug('@@@@@@mapCaseTriggerOld: ' + mapCaseTriggerOld);
            System.debug('@@@@@@listCaseChilds: ' + listCaseChilds);
            // add child Case with lasted closed date or Status is not 'Closed' in to Map
            for( Case objCase : listCaseChilds){

                if(!caseLatestMap.containsKey(objCase.ParentId)){

                    caseLatestMap.put(objCase.ParentId, objCase);

                }else{
                    // check if Case child is NOT Closed
                    // Or Case Child is Closed but  Closed date is laster will be added into map
                    if(objCase.Status != 'Closed'
                        ||(objCase.Status == 'Closed'
                            && ((caseLatestMap.get(objCase.ParentId).ClosedDate < objCase.ClosedDate)
                                || caseLatestMap.get(objCase.ParentId).ClosedDate == null))){

                        caseLatestMap.put(objCase.ParentId, objCase);
                    }
                }

            }
            // Check Update Actual Closed Date for Case Trigger.
            for(Id idCase : mapNewCases.keySet()){

                if(mapNewCases.get(idCase).Status == mapCaseTriggerOld.get(idCase).Status){

                    continue;
                }

                if(mapCaseTriggerOld.get(idCase).Status != 'Closed'
                    && mapNewCases.get(idCase).Status == 'Closed'
                    && (mapNewCases.get(idCase).ParentId == null
                        &&(!caseLatestMap.containsKey(idCase)
                           ||(caseLatestMap.containsKey(idCase)
                            && caseLatestMap.get(idCase).Status == 'Closed')))){

                     mapNewCases.get(idCase).Actual_close_date__c = Datetime.now();
                     continue;

                }
                // if trigger is not parent and status is not closed, Actual Closed Date will be set to null
                // if trigger is child, Actual Closed Date will be set to null
                if((mapCaseTriggerOld.get(idCase).Status == 'Closed'
                    && mapNewCases.get(idCase).Status != 'Closed')
                || mapNewCases.get(idCase).ParentId != null
                || (!caseLatestMap.containsKey(idCase)
                    && mapNewCases.get(idCase).ParentId == null
                    && mapNewCases.get(idCase).Status != 'Closed')){

                     mapNewCases.get(idCase).Actual_close_date__c = null;
                     continue;

                }
                if(!caseLatestMap.containsKey(idCase)){
                    continue;
                }
                // trigger is parent, and is reopened or has at least once case child is still opened
                // Actual Closed Date will be set to null
                if(caseLatestMap.get(idCase).Status != 'Closed'){

                    mapNewCases.get(idCase).Actual_close_date__c = null;

                    continue;
                }

                // if trigger is parrent and all of child are closed
                //  Actual Closed Date will be set to Latest close date of childs
                if( mapNewCases.get(idCase).Actual_close_date__c == null
                    || ( caseLatestMap.get(idCase).ClosedDate!= null 
                        && mapNewCases.get(idCase).Actual_close_date__c != null
                         && caseLatestMap.get(idCase).ClosedDate > mapNewCases.get(idCase).Actual_close_date__c)){

                     mapNewCases.get(idCase).Actual_close_date__c = caseLatestMap.get(idCase).ClosedDate;

                }

            }

             isCaseTrigerBeforeUpadateInvoked = true;

        }else{

             isCaseTrigerBeforeUpadateInvoked = false;
        }
        
    }

    /*
    Name: onAfterUpdate
    Action: Update Actual Closed Date for Case Parent(Trigger is child)
    Created By: Nga Do
    Created Date: 2017/05/09
    Last Modified Date: 2017/05/10
    */

    public static void onAfterUpdate(Map<Id,Case> mapNewCases){

        if(!isCaseTrigerAfterUpadateInvoked){

            // set key of triger is parent
            Set<Id> idCaseParentSet = new Set<Id>();
            // map child Case with lasted closed date or Status is not 'Closed'
            Map<Id, Case> caseLatestMap = new Map<Id, Case>();
            // list parents need to update Actual Closed Date
            List<Case> listCaseParentUpdate = new List<Case>();

            for(Case objCase : mapNewCases.values()){
                // check case trigger is child
                if(objCase.ParentId != null){
                    IdCaseParentSet.add(objCase.ParentId);
                    // add child Case Status is not 'Closed' in to Map
                    if(objCase.Status != 'Closed'){
                        caseLatestMap.put(objCase.ParentId, objCase);
                    }
                }

                
            }
            // get list all childs have the same parent with trigger
            List<Case> listCaseChilds= [SELECT Id, Actual_close_date__c, Status, ClosedDate, ParentId FROM Case  WHERE ParentId IN: idCaseParentSet];

            // get list all parents of trigger
            List<Case> listCaseParent = [SELECT Id, Actual_close_date__c, ClosedDate, Status FROM Case  WHERE Id IN: idCaseParentSet];

            // add child Case with lasted closed date or Status is not 'Closed' in to Map
            for(Case objCase : listCaseChilds){

                if(!caseLatestMap.containsKey(objCase.ParentId)){

                    caseLatestMap.put(objCase.ParentId, objCase);

                }else{
                    // check if Case child is NOT Closed
                    // Or Case Child is Closed but  Closed date is laster will be added into map
                    if(objCase.Status != 'Closed' 
                        ||(caseLatestMap.get(objCase.ParentId).Status == 'Closed'
                            &&(caseLatestMap.get(objCase.ParentId).ClosedDate == null
                                || ( caseLatestMap.get(objCase.ParentId).ClosedDate != null
                                    && objCase.ClosedDate != null
                                    &&caseLatestMap.get(objCase.ParentId).ClosedDate < objCase.ClosedDate)))){

                            caseLatestMap.put(objCase.ParentId, objCase);
                    }
                }
                
            }
            // add parents need to update Actual close date into list update
            for(Case objCase: listCaseParent){

                if(objCase.Status != 'Closed'){

                    objCase.Actual_close_date__c = null;

                    listCaseParentUpdate.add(objCase);
                    continue;
                }

                if(!caseLatestMap.containsKey(objCase.Id)){

                    continue;
                }

                // if has at least one of child is not close.
                if(caseLatestMap.get(objCase.Id).Status != 'Closed'){

                    objCase.Actual_close_date__c = null;

                    listCaseParentUpdate.add(objCase);

                    continue;
                }
                // if all of childs are closed,
                // Actual Closed Date will be set to Latest close date of childs 
                if(objCase.Actual_close_date__c == null
                    || (objCase.Actual_close_date__c != null
                        && objCase.Actual_close_date__c < caseLatestMap.get(objCase.Id).ClosedDate)){

                    objCase.Actual_close_date__c = caseLatestMap.get(objCase.Id).ClosedDate;

                    listCaseParentUpdate.add(objCase);
                }
            }
            // update list of parent
            if(!listCaseParentUpdate.isEmpty()){

                update listCaseParentUpdate;
            }
            isCaseTrigerAfterUpadateInvoked = true;

        }else{

            isCaseTrigerAfterUpadateInvoked = false;

        }
        
    }


    

}