({
	doInit : function(component, event, helper) {
        var jsonString = '[{"id":"1","name":"aaa2"},{"id":"12","name":"aaa22"},{"id":"13","name":"aaa23"},{"id":"1","name":"aaa2"},{"id":"12","name":"aaa22"}]';;
		var acctId = JSON.parse(jsonString);
		component.set('v.accList', acctId)	;	
        var accDisplay = component.get('v.accList');
        var pos = component.get('v.pos');
        var offset = component.get('v.offset');
        accDisplay = acctId.slice(pos, pos+offset);
        component.set('v.accDisplay', accDisplay)	;
	}
})