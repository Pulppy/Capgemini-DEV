public with sharing class StudentClassCI {
	public HocSinh__c student;
	public Map<Id,HocSinh__c> mapHocSinh {get;set;}

	public StudentClassCI() {
		mapHocSinh = new Map<Id,HocSinh__c>();
		student = getStudent();
		mapHocSinh = getMapHocSinh();
	}

	public HocSinh__c getStudent(){
		HocSinh__c stu = [Select Id, Name from HocSinh__c limit 1];
		return stu;
	}

	public Map<Id,HocSinh__c> getMapHocSinh(){
		Map<Id,Hocsinh__c> mapObj = new Map<Id,Hocsinh__c>();
		try{
			List<Hocsinh__c> hocSinh = [Select Id,TenHocSinh__c,GioiTinh__c,DiemTB__c from Hocsinh__c];
			mapObj.putAll(hocSinh);
		}catch(QueryException ex){
			System.debug('xxxxx ' + ex);
		}
		return mapObj;
	}
}