public with sharing class CapgeminiControl {
	public CapgeminiControl() {
		getData(3,5);
	}

	public void getData(Integer limitNo ,Integer offsetNo){
		Map<ID,HocSinh__c> mapHocSinhNam = new Map<ID,HocSinh__c>();
		List<HocSinh__c> lstHocSinh = [Select Id,Gioitinh__c , TenHocSinh__c from HocSinh__c];
		for(HocSinh__c obj : lstHocSinh){
			if(obj.Gioitinh__c == true){
				mapHocSinhNam.put(obj.ID , obj);
			}
		}
		Map<ID,HocSinh__c> mapHocSinh = new Map<Id,HocSinh__c>([Select TenHocSinh__c from HocSinh__c limit :limitNo offset :offsetNo]);
		System.debug('xxxx lst ' + lstHocSinh.size());
		System.debug('xxxx map ' + mapHocSinh.size());
		System.debug('xxxx mapHocSinhNam ' + mapHocSinhNam.size());

		Integer condition1 = 6;
		Integer condition2 = 9;
		// Phép toán điều kiện 3 ngôi
		System.debug(condition1<condition2?'True':'False');

		String text = '          ';
		System.debug('xxxxx ' + String.isEmpty(text) + ' ' + String.isBlank(text));
	}
}