({
	doInit : function(component, event, helper) {
        /* start in case: view applicant */
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        var sURLVariables = sPageURL.split('&'); 
        var sParameterName;
        var i;
        var isEditMode = true;
       
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            //alert("sParameterName: "+ sParameterName);
            if (sParameterName[0] === 'applicantID') { 
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
            console.log('Param name: '+ i + 'fgfg'+sParameterName[0]);
            console.log('Param value: '+ i + 'fgfg232' +sParameterName[1]);
        }
        
        if(sParameterName.length >=2 && sParameterName[0] === 'applicantID'){
            isEditMode = false;
            var action = component.get("c.getAccountsByID");
            action.setParams({
                "applicantID": sParameterName[1]
            });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("get account obj: "+  JSON.stringify(response.getReturnValue()));
                    //if(response.getReturnValue().isValid()){
                        component.set("v.applicant", response.getReturnValue());  
                        component.set("v.isEditMode", isEditMode);  
                   // }
                    console.log("Successful with state: " + state);
                }else {console.log("Failed with state: " + state);}
    
            });
            $A.enqueueAction(action); 
        }
       
         /* end in case: view applicant */

        //helper.getUrlParameter(component, event, helper);

        /* get picklist value */
        helper.getAccountSalutation(component);
        helper.getAccountCitizenship(component);
        
	},
	
    saveApplicant: function(component, event, helper) {
        alert("create account: ");
        var isCheckField = true;
        var firstName = component.find("nomApplicant").get("v.value");
        var lastName = component.find("lastApplicant").get("v.value");
        //alert("lastName: "+ lastName);
        var birthDate = component.find("inputBirthdate").get("v.value");
        if($A.util.isEmpty(firstName)){
            isCheckField = false;
            component.find("nomApplicant").set("v.errors",[{message:"FirstName: please enter a value"}]);
        }
        /*else if($A.util.isEmpty(lastName)){
            isCheckField = false;
            component.find("lastApplicant").set("v.errors",[{message:"LastName: please enter a value"}]);
        }
        else if($A.util.isEmpty(birthDate)){
            isCheckField = false;
            component.find("inputBirthdate").set("v.errors",[{message:"BirthDate: please enter a value"}]);
        }*/
        var isValidEmail = helper.validateEmail(component, event, helper);
        console.log("isValidEmail: "+ isValidEmail);
        if(isValidEmail){
            isCheckField = true;
        }

        if(isCheckField){
            alert("sdsjds");
            var applicant = component.get("v.applicant");
            console.log('applicant infor: '+applicant);
            helper.createAccount(component, applicant);
        }

      
    },
    

	saveApplicant1 : function(component, event, helper){
        var action = component.get("c.saveApplicantInformation");
        var anApplicantObj = component.get("v.applicant");
		action.setParams({"anApplicant" : anApplicantObj});
		action.setCallback(this, function(response) {
			var state = response.getState();
			//alert("@@@statesave: "+ state);
			if (state === "SUCCESS") {
				var response = response.getReturnValue();
                //alert('success' + JSON.stringify(response));
				console.log('#####result: '+result);
                var urlEvent = $A.get("e.force:navigateToURL");
                alert('urlEvent' + urlEventS);
                urlEvent.setParams({
                  "url": "/applicationconfirmation" 
                });

                urlEvent.fire();
			}else if (state === "ERROR") {
                var errors = response.getError();
                console.log("errors: "+  JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    	alert("Error message: " + errors[0].message);
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