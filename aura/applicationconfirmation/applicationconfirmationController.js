({
	doInit : function(component, event, helper) {
	  var baseUrl = (window.location).href;
    var applicationID = baseUrl.substring(baseUrl.lastIndexOf('=') + 1);
		if(applicationID){
      var action = component.get("c.getApplicant");
  		action.setParams({ "IdApplication" : applicationID });
  		action.setCallback(this, function(response) {
  			var state = response.getState();
  			//begin IF
  			if ( state === "SUCCESS") {
  				console.log("ye thanh cong roi "+state);
  				  var app = response.getReturnValue();
            console.log("obj: "+JSON.stringify(app));
            component.set("v.app", response.getReturnValue());
  			}else {
  				console.log("Failed with state: " + state);	
  			}
  			
  		});
  		$A.enqueueAction(action);
    }


	},
	display : function(component, event, helper) {
    helper.toggleHelper(component, event);
  },

  displayOut : function(component, event, helper) {
   helper.toggleHelper(component, event);
  },
  closePopup : function(component, event, helper) {
   	 helper.closePopup(component, event);
    },
  openPopup : function(component, event, helper) {
   	  helper.openPopup(component, event);
    },
  openLoanPage : function(component, event, helper) {
    console.log("aaaaa");
   	helper.openLoanPage(component, event);
    },
  saveEmailPhone : function(component, event, helper) {
      // helper.isValidFormatPhone(component, event);
      helper.validatePhone(component, event);
      helper.validateEmail(component, event);
      helper.saveEmailPhone(component, event);
    },
})