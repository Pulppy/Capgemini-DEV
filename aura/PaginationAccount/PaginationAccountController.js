({
	doInit: function(component, event, helper) {
      // this function call on the component load first time     
      // get the page Number if it's not define, take 1 as default
      var page = component.get("v.page") || 1;
      // get the select option (drop-down) values.   
      var recordToDisply = component.find("recordSize").get("v.value");
      //Use HomepageServer get data to server
      var service = component.find("service");
      service.getListData(page,recordToDisply,$A.getCallback(function(error, data) {
          console.log("AAAAAAAAAAA");
         component.set("v.Accounts", data.accounts);
         component.set("v.Application", data.application); 
         component.set("v.page", data.page);
         component.set("v.total", data.total);
         component.set("v.pages", Math.ceil(data.total / recordToDisply));
      }));
 
   },
 
   previousPage: function(component, event, helper) {
      // this function call on click on the previous page button  
      var page = component.get("v.page") || 1;
      // get the previous button label  
      var direction = event.getSource().get("v.label");
      // get the select option (drop-down) values.  
      var recordToDisply = component.find("recordSize").get("v.value");
      // set the current page,(using ternary operator.)  
      page = direction === "Previous Page" ? (page - 1) : (page + 1);
      /* call the helper function
      helper.getAccounts(component, page, recordToDisply); */
      //Use HomepageServer get data to server
      var service = component.find("service");
      service.getListData(page,recordToDisply,$A.getCallback(function(error, data) {
        component.set("v.Accounts", data.accounts);
         component.set("v.Application", data.application);
         component.set("v.page", data.page);
         component.set("v.total", data.total);
         component.set("v.pages", Math.ceil(data.total / recordToDisply));
      }));
 
   },
 
   nextPage: function(component, event, helper) {
      // this function call on click on the next page button   
      var page = component.get("v.page") || 1;
      // get the next button label 
      var direction = event.getSource().get("v.label");
      // get the select option (drop-down) values.   
      var recordToDisply = component.find("recordSize").get("v.value");
      // set the current page,(using ternary operator.)  "(page + 1)"
      page = direction === "Previous Page" ? (page - 1) : (page + 1);
      /* call the helper function
      helper.getAccounts(component, page, recordToDisply); */
      //Use HomepageServer get data to server
      var service = component.find("service");
      service.getListData(page,recordToDisply,$A.getCallback(function(error, data) {
         component.set("v.Accounts", data.accounts);
       component.set("v.Application", data.application);
         component.set("v.page", data.page);
         component.set("v.total", data.total);
         component.set("v.pages", Math.ceil(data.total / recordToDisply));
      }));
   },
 
   onSelectChange: function(component, event, helper) {
      // this function call on the select opetion change,	 
      var page = 1
      var recordToDisply = component.find("recordSize").get("v.value");
      /* helper.getAccounts(component, page, recordToDisply); */
      //Use HomepageServer get data to server
      var service = component.find("service");
      service.getListData(page,recordToDisply,$A.getCallback(function(error, data) {
         component.set("v.Accounts", data.accounts);
         component.set("v.Application", data.application);
         component.set("v.page", data.page);
         component.set("v.total", data.total);
         component.set("v.pages", Math.ceil(data.total / recordToDisply));
      }));
   },
})