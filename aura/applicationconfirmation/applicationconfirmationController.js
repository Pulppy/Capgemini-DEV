({
	doInit : function(component, event, helper) {
	  var baseUrl = (window.location).href;
    var applicantID = baseUrl.substring(baseUrl.lastIndexOf('=') + 1);
		if(applicantID){
      var action = component.get("c.getApplicant");
  		action.setParams({ "IdApplication" : applicantID });
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
   	  var cmpSection = component.find('section');
   	  var cmpBackdrop = component.find('backdrop');
      $A.util.removeClass(cmpSection, 'slds-fade-in-open');
      $A.util.removeClass(cmpBackdrop, 'slds-backdrop_open');
    },
     openPopup : function(component, event, helper) {
   	  var cmpSection = component.find('section');
   	  var cmpBackdrop = component.find('backdrop');
      $A.util.addClass(cmpSection, 'slds-fade-in-open');
      $A.util.addClass(cmpBackdrop, 'slds-backdrop_open');
    },
    OpenLoanPage : function(component, event, helper) {
   	  window.location.href = "https://www.lightningdesignsystem.com/components/buttons/#content";
    },
    saveEmailPhone : function(component, event, helper) {
      var applicant = component.get("v.app");
      console.log("applicantid   "+applicant);
      var action = component.get("c.saveEmailPhoneApplicant");
      action.setParams({ 
        "applicant" : applicant 
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        //begin IF
        if ( state === "SUCCESS") {
          console.log("Saved "+state);
          var app = response.getReturnValue();
            console.log("saveEmailPhoneAfterSave: "+JSON.stringify(app));
            component.set("v.app", app);
        }else {
          console.log("Failed with saved: " + state); 
        }
        
      });
      $A.enqueueAction(action);
    },
})