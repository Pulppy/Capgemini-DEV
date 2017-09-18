public with sharing class StudentComponent {

	public class Data {
		@AuraEnabled
		public String inputId { get; set; }

		@AuraEnabled
		public StudentDetail stu { get; set; }
	}

	/* Student OBJ*/
	public class StudentDetail {
		@AuraEnabled
		public String studentName { get; set; }
		@AuraEnabled
		public String studentClass { get; set; }
	}

	/*Data Loader*/
	@AuraEnabled
	public static StudentComponent.Data prepare(String objId) {
		System.debug('xxxxx objId: ' +  objId);
		StudentComponent.Data tag = new StudentComponent.Data();
		tag.stu = new StudentDetail();
		return tag;
	}

	@AuraEnabled
	public static String getStudentName(String objId,String studentName){
		try{
			HocSinh__c stu = [Select Id, HoHocSinhs__c from HocSinh__c where Id = : objId];
			stu.HoHocSinhs__c = studentName;
			update stu;
		}catch (Exception ex){
			return 'Error ' + ex;
		}
		return 'Success:' + studentName + ':' + objId;
		
	}
}