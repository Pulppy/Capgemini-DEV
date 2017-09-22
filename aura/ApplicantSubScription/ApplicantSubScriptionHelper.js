({
    doInitData : function(component){
    	var action = component.get("c.createAccountTemplate");
        action.setCallback(this, function(response) {
			var state = response.getState();
            alert("doInitData: ");
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
            console.log("getAccountSalutation: ");
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
        console.log("getAccountCitizenship: ");
        action.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            console.log("@@@opts: "+ opts);
            inputsel.set("v.options", opts);

        });
        $A.enqueueAction(action); 
    },

    validateEmail : function(component, event, helper){
        console.log("email");
        var emailField = component.find("emailApplicant").get("v.value");
        var emailRegular = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if(!$A.util.isEmpty(emailField)){
            if(emailField.match(emailRegular)){
                  component.find("emailApplicant").set("v.errors", [{message: null}]);
                  $A.util.removeClass( component.find("emailApplicant"), 'slds-has-error');
                  return true;
            }else{
                $A.util.addClass(emailField, 'slds-has-error');
                component.find("emailApplicant").set("v.errors", [{message: "Please enter a Valid Email Address"}]);
               return  false;
            }

        }else{
            $A.util.addClass(emailField, 'slds-has-error');
            component.find("emailApplicant").set("v.errors", [{message: "Please enter email Address"}]);
           return  false;
        }
        return true;
    },

    validateEmptyField : function(component, event, helper){

    },


    createAccount: function(component, applicant) {
        var action = component.get("c.saveApplicantInformation");
        action.setParams({
            "anApplicant": applicant
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('testhandleCreateAccount state: '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('#####result: '+result);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/applicationsubscription"
                });
                urlEvent.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //alert("Error message: " + errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
})