public with sharing class PopupUpdateDataCtrl {
	public List<HocSinh__c> hsinh {get;set;}

	public PopupUpdateDataCtrl() {
		hsinh = new List<HocSinh__c>();
		loadDataDetail();
	}

	public void loadDataDetail(){
		hsinh =  [Select Id,
						TenHocSinh__c,
						HoHocSInhs__c, 
						DiemTB__c,
						TInhTrang__c
						from HocSinh__c 
						];
	}

}