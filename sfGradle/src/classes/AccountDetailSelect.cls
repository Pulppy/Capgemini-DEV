public with sharing class AccountDetailSelect {
	
	public List<Account> accObj;
	public AccountDetailSelect() {
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
	public List<Account> getAcc3(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc4(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc5(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc6(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc7(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
	public List<Account> getAcc8(){
		List<Account> acc = [Select Id, Name from Account];
		return acc;
	}
}