({
	loadDocument : function(component) 
    {
		var action = component.get("c.getDocument");
    	action.setParams({
        	recordparentid : component.get("v.recordId")
    	});
    	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.document", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
    	});
    	$A.enqueueAction(action);
	}
})