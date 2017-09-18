public with sharing class AccountHandler {
	public AccountHandler() {
		Account accTest = new Account();
		accTest = insertNewAccount('Test 1');
	}
	public static Account insertNewAccount(String name){
		Account acc = new Account();
		try{
			if(name != null && name != ''){
				acc.Name = name;
				insert acc;
				return acc;
			}
			else{
				return null;
			}
			return acc;
		}catch(Exception ex){
			return null;
		}
	}
}