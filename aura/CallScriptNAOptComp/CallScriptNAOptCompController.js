({
	doInit : function(component, event, helper) {
		var action = component.get("c.createTaskTemplate");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.newTask", response.getReturnValue());  
                console.log("Successful with state: " + state);
			}else {console.log("Failed with state: " + state);}
        });
        $A.enqueueAction(action); 
	},
    
    createNewTask : function(component, event, helper){
        var params = event.getParam('arguments');
        alert("params" + params.leadId);
        var action = component.get("c.createTask");
        var taskObj = component.get("v.newTask");
     	taskObj.sobjectType='Task';
        taskObj.WhoId = params.leadId;
		action.setParams({'taskObj' : taskObj});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rs = response.getReturnValue();
                console.log('success' + JSON.stringify(rs));
				helper.navigateToTaskObject(component, rs);
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);
    }
})