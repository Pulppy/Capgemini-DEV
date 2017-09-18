public with sharing class InsertStudent {
	public HocSinh__c hocSinh {get;set;}

	public void debugStudent() {
		hocSinh = [Select id from HocSinh__c limit 1];
	}
}