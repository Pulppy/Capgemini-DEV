@isTest
private class StudentClassCITest
{
	private static HocSinh__c hosSinhObj;
	private static LopHoc__c lopTest;

	static{
		lopTest = createLop();
		hosSinhObj = createStudent(lopTest.Id);
	}

	private static HocSinh__c createStudent(String lopID) {
		HocSinh__c acc = new HocSinh__c(HoHocSinhs__c ='Account Test',LopHoc__c = lopID);
		insert acc;
		return acc;
	}

	private static LopHoc__c createLop(){
		LopHoc__c lopCreate = new LopHoc__c(Name ='Test Class');
		insert lopCreate;
		return lopCreate;
	}

	static testMethod void testGetStudent() {
		StudentClassCI stuCI = new StudentClassCI();
		stuCI.getStudent();
	}
}