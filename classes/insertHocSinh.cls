/*
* クラス名:		insert HocSinh Class
* クラス概要:		新入生を挿入
* @created:		2016/04/11 Ksvc Nguyen Hoang Khoi
* @modified:    
*/
public without sharing
class insertHocSinh {
	public HocSinh__c hocSinh
	{get;set;}
	public insertHocSinh() {
		hocSinh = new HocSinh__c();
	}
	 public List<SelectOption> lopSel ;
	public boolean hasError;
	public String tinTest;
	/*
	 * themHocSinh 
	 * 
	 * @param: なし
	 * 
	 * @return: pgref PageReference
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */
	
	public PageReference themHocSinh(){
			//validate();
				
				List<ApexPages.Message> errorList = ApexPages.getMessages();
				if(errorList.isEmpty()){
					try{
						insert hocsinh;
						PageReference pgref = new PageReference('/apex/IndexPage');
						pgref.setRedirect(true);	
						return pgref;
				}
				catch(DmlException ex){
					//return nothing 
					
				}	
				catch(Exception e){
					Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
				}
				}
	return null;				
	}

	/*
	 * Lay danh sach lop hoc
	 * 
	 * @param: なし
	 * 
	 * @return: pgref PageReference
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified:
	 */

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

	/*
	 * Direct to Index Page
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

	public void setError (){
			hasError = true;
			tinTest ='Khoi';
	}
}