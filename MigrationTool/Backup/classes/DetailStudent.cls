/*
* クラス名:		Detail Student Class
* クラス概要:		新入生を挿入
* @created:		2016/04/11 Ksvc Nguyen Hoang Khoi
* @modified:    
*/
public with sharing class DetailStudent {
	 public HocSinh__c hs {get;set;}
	public HocSinh__c hocsinh {get;set;}
	public String hsId {get; set;}
	public DetailStudent() {
		hs = new HocSinh__c();
         hsId = ApexPages.CurrentPage().getParameters().get('hsId');
		 hocsinh = [select HoHocSinhs__c,TenHocSinh__c,GioiTinh__c,NgaySinh__c,Diem1__c,Diem2__c,Diem3__c,DiemTB__c,LopHoc__c  from HocSinh__c where id =: hsId];
	}

	/*
	 * Return Index Page
	 * 
	 * @param: なし
	 * 
	 * @return: なし
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
	 * Direct to Update Page
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */
     public PageReference updateStudent(){
		try{
			PageReference pgref = new PageReference('/apex/UpdatePage?hsId=' + hsId);
	    	pgref.setRedirect(true);	
			return pgref;
		}catch(Exception e){
			System.debug('=====' +  e.getMessage());
			return null;
		} 
    }

    /*
	 * Delete Student and return IndexPage
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */
      public PageReference deleteHocSinh(){
		try{
			if(hsId!=null){
			List<HocSinh__c> existing = [Select Id From HocSinh__c
			where Id =: hsId];
			delete existing;}
			else{
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Không thể Delete.'));
			}

			PageReference pgref = new PageReference('/apex/IndexPage');
	    	pgref.setRedirect(true);	
			return pgref;
		}catch(Exception e){
			System.debug('=====' +  e.getMessage());
			return null;
		} 
    }
    
}