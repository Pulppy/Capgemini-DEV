({
	doInit : function(component, event, helper) {
		console.log('xxxx ');
		var action = component.get("c.getDataView");
		action.setParams({ "objId" : component.get("v.recordId") });
		action.setCallback(this, function(response) {
			var state = response.getState();
			//begin IF
			if (component.isValid() && state === "SUCCESS") {
				var arrayOfMapKeys = [];
				var responseData = response.getReturnValue();
				console.log(responseData.objAccount.Name);
				component.set("v.data", responseData);
				
			}else {
				console.log("Failed with state: " + state);	
			}
			
		});
		$A.enqueueAction(action);
	}
})