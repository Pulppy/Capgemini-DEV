({
	saveCallScript : function(component, event, helper) {       
        var option = component.get("v.selectedOption");
        var leadId = component.get("v.recordId");
        if(option == 1){
            var childComponent = component.find('childCallScriptYes');
			childComponent.createNewEvent();
        }else if(option == 0){
            var childComponent = component.find('childCallScriptNA');
			childComponent.createNewTask(leadId);
			//childComponent.createNewTask();
        }else if(option == 2){
            var childComponent = component.find('childCallScriptNo');
			childComponent.updateLeadStatus();
        }
	},
    
    cancelCallScript : function(component, event, helper) {
        var leadId = component.get("v.recordId");
        helper.refreshView(component, leadId);
    },
    
    onChangeCallScriptOption: function(component,event,helper){
        var getWhichRdBtn = event.getSource().get("v.value");
        component.set("v.selectedOption" , getWhichRdBtn); 
        var toggleComp = null;
        //var subComponents = component.getElement().querySelectorAll(".optionGroup .option");
        //alert(subComponents.length);
        //for(var cmp in subComponents) {
        //    $A.util.toggleClass(subComponents[cmp], "toggle");
        //}
        helper.applyCSS(component, "optionCallScriptYes", "toggle");
        helper.applyCSS(component, "optionCallScriptNA", "toggle");
        helper.applyCSS(component, "optionCallScriptNo", "toggle");
        if(getWhichRdBtn == 1){
           helper.removeCSS(component, "optionCallScriptYes", "toggle");
        }else if(getWhichRdBtn == 0){          
           helper.removeCSS(component, "optionCallScriptNA", "toggle");
        }else if(getWhichRdBtn == 2){
           helper.removeCSS(component, "optionCallScriptNo", "toggle");        
        } 
    }
})