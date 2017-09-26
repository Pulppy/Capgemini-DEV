({
	doInit : function(component, event, helper) {
		// Get Fucntion to HomePageService Component function: getListAccount
		var service = component.find("service");
		service.getListAccount($A.getCallback(function(error, data) { 
			component.set('v.accList', data);
		}));
	}
})