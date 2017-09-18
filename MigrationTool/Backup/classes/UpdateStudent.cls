/*
* クラス名:		UpdateStudent 
* クラス概要:		更新ホックシン
* @created:		2016/04/11 Nguyen Hoang Khoi
* @modified:    
*/
public with sharing
class UpdateStudent {
	public HocSinh__c hocsinh
	{get;set;}
	public String hsId {get; set;}
	public List<SelectOption> lopSel;

	public updateStudent() {
		 hocsinh = new HocSinh__c();
		 hsId = ApexPages.CurrentPage().getParameters().get('hsId');
		 hocsinh = [select HoHocSinhs__c,
		 TenHocSinh__c,
		 GioiTinh__c,
		 NgaySinh__c,
		 Diem1__c,
		 Diem2__c,
		 Diem3__c,
		 LopHoc__c  
		 from HocSinh__c 
		 where id =: hsId];
	}

	/*
	 * updateStudent 学生更新
	 * 
	 * @param: なし
	 * 
	 * @return: pgref PageReference
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */

	public PageReference backIndexPage(){
		try{
			PageReference pgref = new PageReference('/apex/IndexPage');
			pgref.setRedirect(true);	
			return pgref;
		}catch(Exception e){
			System.debug('=====' +  e.getMessage());
			return null;
		}
	}


/*
	 * themHocSinh 後の新入生を追加ページを検索するダイレクト
	 * 
	 * @param: なし
	 * 
	 * @return: pgref PageReference
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */

	public PageReference updateStudentRecord(){
				try{
					update hocsinh;
					PageReference pgref = new PageReference('/apex/IndexPage');
					pgref.setRedirect(true);
					return pgref;
				}	
				catch(Exception e){
					Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				}
		return null;
	}

	public List<SelectOption> getLop(){
		lopSel = new List<SelectOption>();
		try{
				
				List<LopHoc__c> lopList = [SELECT Id, TenLop__c FROM LopHoc__c];
				for (LopHoc__c lop : lopList ){
					SelectOption option = new SelectOption(lop.Id, lop.TenLop__c);
					lopSel.add(option);
					
				}
			}catch(Exception e){
				e.getMessage();
			}
			return lopSel;
	}
}