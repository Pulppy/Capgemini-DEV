({
	submitS2 : function(component) {
		var action = component.get("c.goS2");
		action.setParams({'inputId':  component.get("v.recordId")
                          , 'subject' : component.get("v.subject")
                          , 'startDate' : component.get("v.startTime")
						  , 'endDate' : component.get("v.endTime")
                          , 'comments' : component.get("v.comments")
       	});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rs = response.getReturnValue();
                console.log(rs);
			
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);
	}, 
    
    submitS3 : function(component) {
		var action = component.get("c.goS3");
		action.setParams({'inputId':  component.get("v.recordId")
                          , 'subnotvailable' : component.get("v.subnotvailable")
                          , 'datenotvailable' : component.get("v.datenotvailable")
                          , 'commentsnotvailable' : component.get("v.commentsnotvailable")
       	});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rs = response.getReturnValue();
                console.log(rs);
			
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);
	}, 
    
    submitS4 : function(component) {
		var action = component.get("c.goS4");
		action.setParams({'inputId':  component.get("v.recordId")
                          , 'discription' : component.get("v.discription")
       	});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rs = response.getReturnValue();
                console.log(rs);
			
			}else {console.log("Failed with state: " + state);}
		});
		$A.enqueueAction(action);
	}, 
})