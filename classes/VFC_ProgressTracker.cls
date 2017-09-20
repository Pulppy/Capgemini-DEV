/**
 * This class is generic and can be called from Opportunity or case or any object with a process (business or support)
 */
public with sharing class VFC_ProgressTracker {

	// Progress tracker can be used with all objects with a BusinessProcess that s to say Case, Lead and Opportunity.
	// Even if Lead is lead process and case is support process, everything is stored un BusinessProcess Object
	public static Map<String, String> statusFieldsByObject = new Map<String, String> {
		'Case' => 'Status',
		'Lead' => 'Status',
		'Opportunity' => 'Stage'		
	};
	
    private sObject mSObject { get; set; } // sObject from the controller  
    public List<ProgressTrackerStatus__c> mStatusByProcess { get; set; } // List of CS depending on the support process
    // Id of the salesforce object from the page passed in parameter
    public Id mId { 
    	get; 
    	set {
    		mId = value;
	    	retrieveRecordFromId();
	    	retrieveCSConfiguration();    		
    	}
    }
    private String statusField { get; set; } // Status for case, stage for opportunity
    
    /*
    * Do nothing in constructor because actions must be done when id is set.
    */
    public VFC_ProgressTracker() { }
    
    /**
    * Retrieve the record with the necessary fields
    */ 
    private void retrieveRecordFromId() {
    	System.debug('#################### mId : ' + mId);
    	Schema.SObjectType vsObjectType = mId.getSObjectType();
    	String vsObjectName = vsObjectType.getDescribe().getName();
		statusField = statusFieldsByObject.get(vsObjectName);
        String vQuery = 'SELECT Id, RecordType.DeveloperName, RecordTypeId, ' + statusField + ' FROM ' + vsObjectName + ' WHERE Id = :mId';
		
        try{
            mSObject = database.query(vQuery);
        } catch(Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Technical Error : Impossible to retrieve sObject : ' + mId));
        }
    }
    
    /*
    * Retrieve the custom setting configuration
    */
    public void retrieveCSConfiguration() {
    	if (mSObject != null && mSObject.get('recordTypeId') != null) {
    		Id vRecordTypeId = Id.valueOf(mSObject.get('recordTypeId') + '');
    		// Retrieve business process from record type
	    	List<RecordType> vRT = [SELECT BusinessProcessId FROM RecordType WHERE ID = :vRecordTypeId LIMIT 1];
	    	if (vRT != null && vRT.size() > 0) {
	    		initStatusList(vRT[0].BusinessProcessId);    		
	    	}
    	}
    }
    
    /**
    * Get status list from the custom setting 
    * @param : pProcessId => the business Id from the current record type 
    */
    public void initStatusList(String pProcessId) {
    	mStatusByProcess = [SELECT Name, Process_Id__c, StatusMasterLabel__c, StatusOrder__c, CustomLabelToDisplay__c
    							FROM ProgressTrackerStatus__c 
    							WHERE Process_Id__c = :pProcessId ORDER BY StatusOrder__c];
    	if (mStatusByProcess == null || mStatusByProcess.size() == 0) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Technical Error : No status configured in the CS for the current process'));
    	} else if (mSObject != null && mSObject.get(statusField) != null && getOrderByName(mSObject.get(statusField) + '') == -1) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Technical Error : Status name in CS doesn\'t match with case status'));
    	}
    }
    
    /*
    * Return current status order
    */
    public Integer getCurrentStatusOrder() {
    	return getOrderByName(mSObject.get(statusField) + '');
    }
    
     /*
    * Return current status order
    */
    public Integer getLastStepOrder() {
    	if (mStatusByProcess == null) {
    		return 0;
    	}
    	return mStatusByProcess.size();
    }
    
    /**
    * Return order by status name
    * @param : pName => status label of the searched status 
    */
    public Integer getOrderByName(String pName) {
		if (mStatusByProcess == null) {
			return -1;
		}
		
		for (ProgressTrackerStatus__c vStatusProcessLink : mStatusByProcess) {
			if (vStatusProcessLink.StatusMasterLabel__c == pName) {
				return Integer.ValueOf(vStatusProcessLink.StatusOrder__c + '');
			}
		}
		
		return -1;
    }
    
}