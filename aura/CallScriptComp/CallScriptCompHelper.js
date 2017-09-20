({
	toggleCSS : function(component, name, cssClass) {
		var cmpTarget = component.find(name);
        $A.util.toggleClass(cmpTarget, cssClass);
	},
    
    applyCSS: function(component, name, cssClass) {
        var cmpTarget = component.find(name);
        $A.util.addClass(cmpTarget, cssClass);
    },
    
    removeCSS: function(component, name, cssClass) {
        var cmpTarget = component.find(name);
        $A.util.removeClass(cmpTarget, cssClass);
    },
    
    refreshView : function(component, leadId){
        //$A.get('e.force:refreshView').fire();
        var navEvt= $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": leadId});
        navEvt.fire();
   	}
})