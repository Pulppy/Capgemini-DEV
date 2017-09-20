({
    doInit : function(component, event, helper) {
        var action = component.get("c.createEventTemplate");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.newEvent", response.getReturnValue());  
                console.log("Successful with state: " + state);
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);      
	},
    
    createNewEvent : function(component, event, helper){
        var action = component.get("c.createEvent");
        var eventObj = component.get("v.newEvent");
     	eventObj.sobjectType='Event';
        eventObj.WhoId = component.get("v.leadId");
		action.setParams({'eventObj' : eventObj});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rs = response.getReturnValue();
                console.log('success' + JSON.stringify(rs));
				helper.navigateToEventObject(component, rs);
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);
    }
})