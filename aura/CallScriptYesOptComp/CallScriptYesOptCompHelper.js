({
    navigateToEventObject: function(component, recordId){
        var navEvt= $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": recordId});
        navEvt.fire();
   	}
})