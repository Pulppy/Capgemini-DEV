/*
* クラス名:     Controler Application
* クラス概要:        新入生を挿入
* @created:     2016/04/11 Ksvc Nguyen Hoang Khoi
* @modified:    
*/
public with sharing
class Controller {
 public List<WrapperClass> listWrapper;
	private boolean hasError;
	public String tinTest;
	private String sql = 'SELECT TenHocSinh__c, HoHocSinhs__c,GioiTinh__c,NgaySinh__c,Diem1__c,Diem2__c,Diem3__c,DiemTB__c,TinhTrang__c FROM HocSinh__c hs ';
	private String afterSql = ' ORDER BY Name LIMIT 100';
	private String sqlgetLop = 'SELECT Id, TenLop__c FROM LopHoc__c';
	private String createStuUrl = '/apex/InsertPage';
	private String pageUrl = '/apex/test';
	private String updateStuUrl = '/apex/updatestudent';
	private String detailStuUrl = '/apex/detailstudent';
	private String sqlGetListHsinh = 'SELECT Id FROM HocSinh__c WHERE Id = :stringIdDel';
	private String delSuccMess = 'You Delete Success.';
	private String filterErr = 'Please Select One Field To Filter.';
	private String noResFoundErr = 'No Result Found.';
	private String noChoseStuErr = 'Please Pick One To Delete';
	private String message;    
	private String pageReferenceHeader;
	private List<HocSinh__c> hs;
	public String stringSearch {get;set;}
	public Date startDate {get;set;}
	public Date endDate {get;set;}
	public String lopValue {get;set;}
	public List<SelectOption> lop;
	public Boolean isCheck {get;set;}
	public String stringIdDel {get;set;}
	public SysMsgInfo__c listTestCustSetting {get;set;}
	public String txtTest {get;set;}
	public Account account {get; set;}
	public Controller() {
		if(getMessageFromOrtherPage()) 
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
			system.debug('xxxx' + SysMsgInfo__c.getOrgDefaults());
			listTestCustSetting = new SysMsgInfo__c();
			listTestCustSetting = SysMsgInfo__c.getOrgDefaults();
			system.debug('xxxx' + listTestCustSetting.PageSuccess__c);
	}
	
	/*
	 * doFilter
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public void doFilter() {
		String queryString = '';
		if(stringSearch != null) {
			queryString = '%' + stringSearch + '%';            
		}
		con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 'WHERE hs.HoHocSinhs__c LIKE :queryString' + afterSql));
		con.setPageSize(5);
		getListWrapper();
	}
	
	/*
	 * doDelete
	 * 
	 * @param: なし
	 * 
	 * @return: null
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public PageReference doDelete() {
		hs = DataBase.query(sqlGetListHsinh);
		if(hs.size() > 0 || hs[0].Id != '') {
			delete hs;
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, delSuccMess));
		}
		con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + afterSql));
		con.setPageSize(5);
		getListWrapper();
		return null;
	}
	
	 /*
	 * search
	 * 
	 * @param: なし
	 * 
	 * @return: null
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public PageReference search() {  
		ApexPages.getMessages().clear();   
		if(startDate == null  && endDate == null && lopValue.Equals('None')) {  
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning , filterErr));
			con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + afterSql));
		} 
		/*if(startDate != null && endDate != null && lopValue !=null){
		con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 
			'WHERE hs.NgaySinh__c >= :startDate AND hs.NgaySinh__c <= :endDate AND hs.LopHoc__c =: lopValue' + afterSql));
	   }*/
		if(lopValue !=null){
			 con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 
				'WHERE hs.LopHoc__c =: lopValue'
				 + afterSql));
	   }if(startDate != null && endDate != null){
		con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 
				'WHERE hs.NgaySinh__c >= :startDate AND hs.NgaySinh__c <= :endDate'
				 + afterSql));
	   }
	   
		con.setPageSize(5);
		getListWrapper();
		system.debug('xxxxxxx' + startDate);
		return null;
	}
	
	 /*
	 * doOrder
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public void doOrder() {
		if(isCheck) {
			con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 'ORDER BY hs.TenHocSinh__c ASC LIMIT 100'));
		} else {
			con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + 'ORDER BY hs.TenHocSinh__c DESC LIMIT 100'));        
		}
		con.setPageSize(5);
		getListWrapper();
	}
	
	/*
	 * deleteStu
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public void deleteStu() {
		List<WrapperClass> listTempWrap = new List<WrapperClass>();
		List<HocSinh__c> listHS = new List<HocSinh__c>();
		for(WrapperClass w : listWrapper) {
			if(w.checked) {
				listHS.add(w.hs);
			} else {
				listTempWrap.add(w);
			}
		}
		if(listHS.size() > 0) {
			delete listHS;
			listWrapper = listTempWrap;
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, delSuccMess));
		} else {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, noChoseStuErr));
		}
		con =new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + afterSql));
		con.setPageSize(5);
		getListWrapper();
	}
	
	/*
	 * newPage
	 * 
	 * @param: なし
	 * 
	 * @return: /apex/InsertPage
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public PageReference newPage() {
		return new PageReference(createStuUrl);
	}
	
	/*
	 * goEdit
	 * 
	 * @param: なし
	 * 
	 * @return: /apex/updatestudent
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public PageReference goEdit() {
		return new PageReference(updateStuUrl);
	}
	
	/*
	 * goDetail
	 * 
	 * @param: なし
	 * 
	 * @return: /apex/detailstudent
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public PageReference goDetail() {
		return new PageReference(detailStuUrl);
	}
		
	/*
	 * con
	 * 
	 * @param: なし
	 * 
	 * @return: con
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */    
	private ApexPages.StandardSetController con {
		get {
			if(con == null) {
				con = new ApexPages.StandardSetController(DataBase.getQueryLocator(sql + afterSql));
				con.setPageSize(5);                
			}
			return con;
		}        
		set;
	}
	
	/*
	 * hasNext
	 * 
	 * @param: なし
	 * 
	 * @return: con.getHasNext
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}

	/*
	 * hasPrevious
	 * 
	 * @param: なし
	 * 
	 * @return: con.getHasPrevious()
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */   
	public Boolean hasPrevious {
		get {
			return con.getHasPrevious();
		}
		set;
	}

	// returns the page number of the current page set
	/*
	 * pageNumber
	 * 
	 * @param: なし
	 * 
	 * @return: con.getPageNumber()
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */  
	public Integer pageNumber {
		get {
			return con.getPageNumber();
		}
		set;
	}
	
	/*
	 * resultSize
	 * 
	 * @param: なし
	 * 
	 * @return: con.getResultSize()
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	public Integer resultSize {
		get {
			return con.getResultSize();
		}
		set;
	}
	
	/*
	 * first
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	 public void first() {
		 con.first();
	 }

	 // returns the last page of records
	 /*
	 * last
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	 public void last() {
		 con.last();
	 }

	 // returns the previous page of records
	/*
	 * previous
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	 public void previous() {
		 con.previous();
	 }

	 // returns the next page of records
	 /*
	 * next
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	 public void next() {
		 con.next();
	 }

	 // returns the PageReference of the original page, if known, or the home page.
	 /*
	 * cancel
	 * 
	 * @param: なし
	 * 
	 * @return: なし
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	 public void cancel() {
		 con.cancel();
	 }
	
	/*
	 * getListWrapper
	 * 
	 * @param: なし
	 * 
	 * @return: listWrapper
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */ 
	public List<WrapperClass> getListWrapper() {
		listWrapper = new List<WrapperClass>();
		for(HocSinh__c hs : (List<HocSinh__c>)con.getRecords()) {
			listWrapper.add(new WrapperClass(hs));
		}
		if(listWrapper.size() == 0) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning, noResFoundErr));
		}
		return listWrapper;
	}
	
	/*
	 * getLop
	 * 
	 * @param: なし
	 * 
	 * @return: lop
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	public List<SelectOption> getLop() {
		lop = new List<SelectOption>();
		List<LopHoc__c> listLop = DataBase.query(sqlgetLop);
		lop.add(new SelectOption('None','-----None-----'));
		if(listLop.size() > 0) {
			for (LopHoc__c lop2 : listLop) {
				lop.add(new SelectOption(lop2.Id, lop2.TenLop__c));
			}
		}
		return lop;
	}
	
	/*
	 * getMessageFromOrtherPage
	 * 
	 * @param: なし
	 * 
	 * @return: back
	 * 
	 * @created: 2016/04/11 Nguyen Hoang Khoi
	 * 
	 * @modified: 2016/04/29 Nguyen Hoang Khoi
	 */
	private Boolean getMessageFromOrtherPage() {
		Boolean back = false;
		message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
		pageReferenceHeader = ApexPages.CurrentPage().getHeaders().Get('Referer');
		if(pageReferenceHeader != null && pageReferenceHeader.containsIgnoreCase('test') && message != 'null') {
			back = true;
		}
		return back;
	}

	public void test() {
		system.debug('xxxx 1 ' + hasError + ' ' + tinTest);
		insertHocSinh a = new insertHocSinh();
		a.setError();
		system.debug('xxxx 2 ' + a.hasError + ' ' + a.tinTest);
	}
}