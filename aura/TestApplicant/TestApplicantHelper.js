({
    doInitData : function(component){
        var action = component.get("c.createAccountTemplate");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert("state: "+ state);
            if (state === "SUCCESS") {
                component.set("v.applicant", response.getReturnValue());  
                console.log("Successful with state: " + state);
            }else {console.log("Failed with state: " + state);}
        });
        $A.enqueueAction(action); 
    },
    
    getAccountSalutation: function(component) { 
        var action = component.get("c.getAccountSalutation");
        var inputsel = component.find("inputSalutations");
        var opts=[];
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert("state: "+ state);
            if (state === "SUCCESS") {
               for(var i=0;i< response.getReturnValue().length;i++){
                    opts.push({label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                //alert("@@@opts: "+ opts);
                console.log('@@@opts:' + JSON.stringify(opts));
                inputsel.set("v.options", opts);
            }else {console.log("Failed with state: " + state);}
            
        });
        $A.enqueueAction(action); 
    },
    

    getAccountCitizenship: function(component){
        var action = component.get("c.getAccountCitizenships");
        var inputsel = component.find("inputNations");
        var opts=[];
        action.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            console.log("@@@opts: "+ opts);
            inputsel.set("v.options", opts);

        });
        $A.enqueueAction(action); 
    },


	createAccount: function(component, applicant) {
        var action = component.get("c.saveApplicantInformation");
        action.setParams({
            "anApplicant": applicant
        });
        alert("@@@applicant: "+ JSON.stringify(applicant));
        action.setCallback(this, function(response){
            
            var state = response.getState();
            alert('testhandleCreateAccount state: '+state);
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('#####result: '+result);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/application"
                });
                urlEvent.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
                        //console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})