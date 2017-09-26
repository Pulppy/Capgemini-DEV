({
	actionNewApplicant: function(component, event, helper) {
        console.log('Hello World');
    	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": '/applicantsubscription'
        });
        urlEvent.fire();
	},
})