({
	getListData : function(component, event, helper) {
        var params = event.getParam("arguments");
        var action = component.get("c.fetchApplicant");
        action.setParams({
             "pageNumber": params.page,
             "recordToDisply": params.recordToDisply
      	});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
    	$A.enqueueAction(action);
    }, 
    getListAccount : function(component, event, helper) {
        var params = event.getParam("arguments");
        var action = component.get("c.getlistAccount");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
    	$A.enqueueAction(action);
    }
})