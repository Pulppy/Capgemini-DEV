public class AP06FCR {

    public static boolean executeCaseRemoval = true; /* This static boolean variable is being used
                                                        to bypass the removal of existing cases when
                                                        inserting cases from AP03CaseSetFCR_TEST. The value
                                                        of this variable is set to false in the test class.
                                                        The removal of existing cases (line 74) will always 
                                                        be executed for real data. */
    /* 
     * This method is used to set values of 3 FCR flags (Customer, Policy, Agent)
     * of new and existing cases by checking on a match with the following criteria:
     * - All GI record types included in the custom label
     * - Internal flag equals to false
     * - ClosedDate equals to last 30 days
     * FCRCustomer flag is calculated with AccountId, Complainant__c, 
     * and threshold value from custom setting: 
     * - if case/s exist, set value of 3 on new case, 
     *   set value of 2 on existing case if previous value equals 1
     * - if not existing, set value of 1 on new case
     * FCRPolicy flag is calculated with Policy__c, Complainant__c, 
     * and threshold value from custom setting: 
     * - if case/s exist, set value of 3 on new case, 
     *   set value of 2 on existing case if previous value equals 1
     * - if not existing, set value of 1 on new case
     * FCRAgent flag is calculated with Policy__c, Complainant__c, 
     * SR_Sub_Type__c and threshold value from custom setting: 
     * - if case/s exist, set value of 1 on new case, 
     *   set value of 3 on existing case
     * - if not existing, set value of 1 on new case
     */
    public static void setFCR(set <Id>setCaseAccId, set<String> setCallerType,set <Id>setCaseId, map<string,Case> mapWithFCRCustKeyToNewCase, map<string,Case> mapWithFCRAgentKeyToNewCase, map<string,Case> mapWithFCRPolicyKeyToNewCase){
        System.debug('>>> START AP03CaseSetFCR - setFCR <<<');
        String keyCompForFCRCust = '';
        String keyCompForFCRAgent = '';
        String keyCompForFCRPolicy = '';
        set<String> setRepeatedCall = new set<String>();
        set<String> setKeyWithFollowUp = new set<String>();
        map<Id,Case> mapCaseForUpdate = new map<Id,Case>();
        Integer thresholdtocheck = getThreshold();
        set<String> setGIRecTypes = new set<String>();
        list<String> lstGIRecTypes = Label.Servicing_GI_Rec_Types.split(';');
        setGIRecTypes.addAll(lstGIRecTypes);
        string FCRCustValue = '';
        string FCRAgentValue = '';
        string FCRPolicyValue = '';
        system.debug('setGIRecTypes@@@'+setGIRecTypes);
        system.debug('setCaseAccId ###'+setCaseAccId);
        system.debug('setCallerType###'+setCallerType);
        system.debug('setCaseId###'+setCaseId);
        
        Set <Case> existingCases = new Set<Case>([SELECT  RecordType.DeveloperName, Id, policy__c, Complainant__c, createdDate,casenumber,Follow_up__c, AccountId, SR_Sub_Type__c, FCRCustomer__c, FCRPolicy__c, FCRAgent__c
                                    FROM    Case
                                    WHERE   AccountId IN :setCaseAccId 
                                        AND Complainant__c IN :setCallerType
                                        AND internal__c != true
                                        AND ClosedDate = LAST_N_DAYS:30
                                        AND Id Not IN :setCaseId
                                        AND RecordType.developerName in: setGIRecTypes 
                                        AND RecordType.sObjectType='Case' 
                                        AND AccountId != null
                                        AND Policy__c != null LIMIT 50000]);
        
        system.debug('existingCasesBefore>>>'+existingCases);
        
        List <Case> existingCasesforRemoval = new List <Case>();
        List <Case> newCase = [Select Id, Complainant__c, createdDate, policy__c from Case where ID in: setCaseId];

        
       /* for(Case existingCase: existingCases) {
            for(Case c : newCase) {
                if(c.Policy__c == existingCase.Policy__c && c.Complainant__c == existingCase.Complainant__c) {
                    if(Math.abs(c.createdDate.getTime() - existingCase.createdDate.getTime()) / 1000 / 60 < 60) {
                        existingCasesForRemoval.add(existingCase);
                    }
                }
            }
        }*/ // Commented as suggested by Bruno till UAT complete
        
        if(executeCaseRemoval) {
           existingCases.removeAll(existingCasesForRemoval); 
        }
        
        system.debug('existingCasesAfter>>>'+existingCases);
                
        for(Case existingCase : existingCases){
            
            String recordTypeGroup = '';
            if (existingCase.RecordType.DeveloperName.startsWith('Life')) {
                recordTypeGroup = 'Life';
            }
            if (existingCase.RecordType.DeveloperName.startsWith('GI')) {
                recordTypeGroup = 'GI';
            }
            
            keyCompForFCRCust = existingCase.AccountId+';'+existingCase.Complainant__c;
            keyCompForFCRAgent = existingCase.policy__c+';'+existingCase.SR_Sub_Type__c+';'+existingCase.Complainant__c;
            keyCompForFCRPolicy = existingCase.policy__c+';'+existingCase.Complainant__c;       
            
            if(mapWithFCRCustKeyToNewCase.containsKey(keyCompForFCRCust)){

                if( existingCase.createdDate.Date().daysBetween(system.today()) < thresholdtocheck){
                    if(existingCase.Follow_up__c){
                        setKeyWithFollowUp.add(keyCompForFCRCust);
                    }
                    if (existingCase.FCRCustomer__c == 'FCR') {
                        existingCase.FCRCustomer__c = '1stContact';
                    }
                    setRepeatedCall.add(keyCompForFCRCust);                   
                }//end of check                 
            }//end of check for FCR Cust key
            
            if(mapWithFCRAgentKeyToNewCase.containsKey(keyCompForFCRAgent)){

                if( existingCase.createdDate.Date().daysBetween(system.today()) < thresholdtocheck){

                    if(existingCase.Follow_up__c){
                        setKeyWithFollowUp.add(keyCompForFCRAgent);
                    }
                    existingCase.FCRAgent__c = 'RepeatedContact';
                    setRepeatedCall.add(keyCompForFCRAgent);                   
                }//end of check                 
            }//end of check for FCR Agent key
            
            if(mapWithFCRPolicyKeyToNewCase.containsKey(keyCompForFCRPolicy)){

                if( existingCase.createdDate.Date().daysBetween(system.today()) < thresholdtocheck){

                    if(existingCase.Follow_up__c){
                        setKeyWithFollowUp.add(keyCompForFCRPolicy);
                    }
                    if (existingCase.FCRPolicy__c == 'FCR') {
                        existingCase.FCRPolicy__c = '1stContact';
                    }
                    setRepeatedCall.add(keyCompForFCRPolicy);                   
                }//end of check                 
            }//end of check for FCR Policy key
            mapCaseForUpdate.put(existingCase.Id,existingCase );
        }//end of loop Case
        
        system.debug('mapCaseForUpdate from exist case$$$'+mapCaseForUpdate);

        System.debug('>>>## setFCR - :setRepeatedCall size: '+ setRepeatedCall.size() );

       
        //Start of loop for key with FCR customer new cases
        for(String key :mapWithFCRCustKeyToNewCase.keyset()){
            system.debug('mapWithFCRCustKeyToNewCase###'+mapWithFCRCustKeyToNewCase);

            system.debug('FCRCustValue ###'+FCRCustValue);
                if(!setRepeatedCall.contains(key) ){
                    if( mapWithFCRCustKeyToNewCase.get(key).createdDate.Date().daysBetween(system.today()) < thresholdtocheck) { 
                        FCRCustValue = 'FCR';
                    }
                    Case caseObj = new Case();
                    if(!mapCaseForUpdate.containsKey(mapWithFCRCustKeyToNewCase.get(key).id)) {
                        caseObj.id = mapWithFCRCustKeyToNewCase.get(key).id;
                        caseObj.FCRCustomer__c = FCRCustValue;
                    }
                    else {
                        caseObj = mapCaseForUpdate.get(mapWithFCRCustKeyToNewCase.get(key).id);
                        caseObj.FCRCustomer__c = FCRCustValue;
                    }
                    
                    if(setKeyWithFollowUp.contains(key) ){
                         mapCaseForUpdate.get(mapWithFCRCustKeyToNewCase.get(key).id).Follow_up__c = true;
                         //mapCaseForUpdate.get(mapWithFCRCustKeyToNewCase.get(key).id).FCR__c = false;
                    }
                    
                    mapCaseForUpdate.put(mapWithFCRCustKeyToNewCase.get(key).id,caseObj);
      
                } else { //end of check setRepeatedCall contains key
                    system.debug('mapCaseForUpdate from new loop###'+mapCaseForUpdate);
                    if( mapWithFCRCustKeyToNewCase.get(key).createdDate.Date().daysBetween(system.today()) < thresholdtocheck) { 
                        FCRCustValue = 'RepeatedContact';
                    }
                    
                    Case caseObj = new Case();
                    if(!mapCaseForUpdate.containsKey(mapWithFCRCustKeyToNewCase.get(key).id)) {
                        caseObj.id = mapWithFCRCustKeyToNewCase.get(key).id;
                        caseObj.FCRCustomer__c = FCRCustValue;
                        //caseObj.RepeatedCall__c = true;
                    }
                    else {
                        caseObj = mapCaseForUpdate.get(mapWithFCRCustKeyToNewCase.get(key).id);
                        caseObj.FCRCustomer__c = FCRCustValue;
                        //caseObj.RepeatedCall__c = true;
                    }
                    mapCaseForUpdate.put(mapWithFCRCustKeyToNewCase.get(key).id,caseObj);
                    
                }
        } // End of loop for key with FCR Cutomer  New cases
        system.debug('mapCaseForUpdate###'+mapCaseForUpdate);
        
        //Start of loop for key with FCR Agent new cases
        for(String key :mapWithFCRAgentKeyToNewCase.keyset()){

                    if( mapWithFCRAgentKeyToNewCase.get(key).createdDate.Date().daysBetween(system.today()) < thresholdtocheck) { 
                        FCRAgentValue = 'FCR';
                    }
                    
                    Case caseObj = new Case();
                    if(!mapCaseForUpdate.containsKey(mapWithFCRAgentKeyToNewCase.get(key).id)) {
                        caseObj.id = mapWithFCRAgentKeyToNewCase.get(key).id;
                        caseObj.FCRAgent__c = FCRAgentValue;
                    }
                    else {
                        caseObj = mapCaseForUpdate.get(mapWithFCRAgentKeyToNewCase.get(key).id);
                        caseObj.FCRAgent__c = FCRAgentValue;
                    }
                    if(setKeyWithFollowUp.contains(key) ){
                         mapCaseForUpdate.get(mapWithFCRAgentKeyToNewCase.get(key).id).Follow_up__c = true;
                         //mapCaseForUpdate.get(mapWithFCRAgentKeyToNewCase.get(key).id).FCR__c = false;
                    }
                    mapCaseForUpdate.put(mapWithFCRAgentKeyToNewCase.get(key).id,caseObj);
      
        } // End of loop for key with FCR Agent New cases
        
        //Start of loop for key with FCR Policy new cases
        for(String key :mapWithFCRPolicyKeyToNewCase.keyset()){

                if(!setRepeatedCall.contains(key) ){
                    if( mapWithFCRPolicyKeyToNewCase.get(key).createdDate.Date().daysBetween(system.today()) < thresholdtocheck) { 
                        FCRPolicyValue = 'FCR';
                    }
                    Case caseObj = new Case();
                    if(!mapCaseForUpdate.containsKey(mapWithFCRPolicyKeyToNewCase.get(key).id)) {
                        caseObj.id = mapWithFCRCustKeyToNewCase.get(key).id;
                        caseObj.FCRPolicy__c = FCRPolicyValue;
                        //caseObj.RepeatedCall__c = false;
                    }
                    else {
                        caseObj = mapCaseForUpdate.get(mapWithFCRPolicyKeyToNewCase.get(key).id);
                        caseObj.FCRPolicy__c = FCRPolicyValue;
                        //caseObj.RepeatedCall__c = false;
                    }
                    
                    if(setKeyWithFollowUp.contains(key) ){
                         mapCaseForUpdate.get(mapWithFCRPolicyKeyToNewCase.get(key).id).Follow_up__c = true;
                         //mapCaseForUpdate.get(mapWithFCRPolicyKeyToNewCase.get(key).id).FCR__c = false;
                    }
                    mapCaseForUpdate.put(mapWithFCRPolicyKeyToNewCase.get(key).id,caseObj);

      
                } else { //end of check setRepeatedCall contains key
                    if( mapWithFCRPolicyKeyToNewCase.get(key).createdDate.Date().daysBetween(system.today()) < thresholdtocheck) { 
                        FCRPolicyValue = 'RepeatedContact';
                    }
                    Case caseObj = new Case();
                    if(!mapCaseForUpdate.containsKey(mapWithFCRPolicyKeyToNewCase.get(key).id)) {
                        caseObj.id = mapWithFCRCustKeyToNewCase.get(key).id;
                        caseObj.FCRPolicy__c = FCRPolicyValue;
                        //caseObj.RepeatedCall__c = true;
                    }
                    else {
                        caseObj = mapCaseForUpdate.get(mapWithFCRPolicyKeyToNewCase.get(key).id);
                        caseObj.FCRPolicy__c = FCRPolicyValue;
                        //caseObj.RepeatedCall__c = true;
                    }
                    mapCaseForUpdate.put(mapWithFCRPolicyKeyToNewCase.get(key).id,caseObj);

                }
        } // End of loop for key with FCR Policy New cases
        
        if(mapCaseForUpdate.size() > 0){
            update mapCaseForUpdate.values();
        }//end of check size
        System.debug('>>> END AP03CaseSetFCR - setFCR <<<');
    }//end of method setFCR
    
    /* 
     * Method used to get threshold value from custom setting 
     * which used to filter cases closed within number of days
     * to compare with current closed case
     */
    public static Integer getThreshold(){
        Integer threshold;
        for(FSC_Threshold__c cs : FSC_Threshold__c.getall().values()){
            if (cs.SubType__c==null) threshold = Integer.ValueOf(cs.Threshold__c );            
        }//end of loop
        return threshold;
    }//end of getThresholdBySubType

}