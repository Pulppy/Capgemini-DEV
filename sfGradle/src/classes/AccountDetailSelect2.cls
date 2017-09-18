public with sharing class AccountDetailSelect2 {
	
	public List<Account> accObj;
	public AccountDetailSelect2() {
		accObj = getAcc();
	}

	public List<Account> getAcc(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc1(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc2(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	
}