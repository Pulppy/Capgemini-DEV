({
	doInit : function(component, event, helper) {
        helper.doInitData(component);
        /*helper.getAccountSalutation(component);
        helper.getAccountCitizenship(component);*/
    },
    
    handleCreateAccount: function(component, event, helper) {
        console.log('testhandleCreateAccount');
        var applicant = component.get("v.applicant");
        console.log('testhandleCreateAccountapplicant: '+applicant);
        helper.createAccount(component, applicant);
    },
    
    preview : function(component, event, helper) {
       $A.get('e.lightning:openFiles').fire({
        	recordIds: [component.get("v.contentId")]
       });
    }
    
})