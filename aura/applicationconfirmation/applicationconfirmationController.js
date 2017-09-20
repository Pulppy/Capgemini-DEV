({
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
      var baseUrl = (window.location).href;
      var IdApplication = baseUrl.substring(baseUrl.lastIndexOf('=') + 1);
      console.log(IdApplication);
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
})