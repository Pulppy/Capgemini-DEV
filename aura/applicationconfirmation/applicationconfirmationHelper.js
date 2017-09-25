({
	toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
   },
  openLoanPage : function(component, event) {
    console.log("ccccccc");
    var baseUrl = (window.location).href;
    var applicationID = baseUrl.substring(baseUrl.lastIndexOf('=') + 1);
     console.log("bbbbbbb"+applicationID);
      window.location.href = "https://capvietnamteam-developer-edition.ap5.force.com/capvietnamteam/s/applicationsubscription?applicationID="+applicationID;
    },
  closePopup : function(component, event) {
      var cmpSection = component.find('section');
      var cmpBackdrop = component.find('backdrop');
      $A.util.removeClass(cmpSection, 'slds-fade-in-open');
      $A.util.removeClass(cmpBackdrop, 'slds-backdrop_open');
    },
  openPopup : function(component, event) {
      var cmpSection = component.find('section');
      var cmpBackdrop = component.find('backdrop');
      $A.util.addClass(cmpSection, 'slds-fade-in-open');
      $A.util.addClass(cmpBackdrop, 'slds-backdrop_open');
    },
  validatePhone : function(component, event){
        //alert("validatePhone");
        console.log("validatePhone");
        var phoneField = component.find("phone").get("v.value");
        var phoneRegular = /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/im;
        if(!$A.util.isEmpty(phoneField)){
            if(phoneField.match(phoneRegular)){
                  component.find("phone").set("v.errors", null);
                  $A.util.removeClass( component.find("phone"), 'slds-has-error');
                  return true;
            }else{
                $A.util.addClass(component.find("phone"), 'slds-has-error');
                component.find("phone").set("v.errors", [{message: "Please enter a valid mobile phone"}]);
               return  false;
            }

        }else{
            $A.util.addClass(component.find("phone"), 'slds-has-error');
            component.find("phone").set("v.errors", [{message: "Please enter mobile phone"}]);
           return  false;
        }
        return true;
    },
   validateEmail : function(component, event){
        //alert("validateEmail");
        var emailField = component.find("email").get("v.value");
        var emailRegular = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if(!$A.util.isEmpty(emailField)){
            if(emailField.match(emailRegular)){
                  component.find("email").set("v.errors",null);
                  $A.util.removeClass( component.find("email"), 'slds-has-error');
                  return true;
            }else{
                $A.util.addClass(component.find("email"), 'slds-has-error');
                component.find("email").set("v.errors", [{message: "Please enter a Valid Email Address correct"}]);
               return  false;
            }

        }else{
            $A.util.addClass(component.find("email"), 'slds-has-error');
            component.find("email").set("v.errors", [{message: "Please enter email Address"}]);
           return  false;
        }
        return true;
    },
    saveEmailPhone : function(component, event) {
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