({
	doInit : function(component, event, helper) {  
         var service = component.find("service");
        service.getListAccount($A.getCallback(function(error, data) { 
            component.set('v.accList', data);  
        }));
	}  
})