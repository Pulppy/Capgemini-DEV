({
    doInit : function(component, event, helper) {
        var action = component.get("c.getLead");
        var leadId = component.get("v.leadId");
        action.setParams({'leadId' : leadId});
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.leadObject", response.getReturnValue());  
                console.log("Successful with state: " + state);
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);      
	},
    updateLeadStatus : function(component, event, helper){
        var action = component.get("c.updateLead");
        var leadObject = component.get("v.leadObject");
        //alert("leadObject" + leadObject);
        action.setParams({'leadObject' : leadObject});
        action.setCallback(this, function(response) {
			var state = response.getState();
            var rs = response.getReturnValue();
			if (state === "SUCCESS") {
                console.log("Successful with state:lead " + JSON.stringify(rs));
                alert("leadID" + rs.Id);
                //component.set("v.leadObject", response.getReturnValue());
                helper.refreshView(component, event, helper,rs.Id);      
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);   
    }
})