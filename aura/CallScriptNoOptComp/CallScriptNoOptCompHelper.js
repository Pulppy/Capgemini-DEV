({
    refreshView : function(component, event, helper, leadId){
         //$A.get('e.force:refreshView').fire();
        var navEvt= $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": leadId});
        navEvt.fire();
   	}
})