({
	doInit : function(component, event, helper) {
		helper.loadDocument(component);
	},
    
    openSingleFile: function(component, event, helper) {
    	var ind = event.target.getAttribute("data-recId")
        $A.get('e.lightning:openFiles').fire({
        	recordIds: [ind]
   		});
	}
})