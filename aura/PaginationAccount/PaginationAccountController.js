({
	/*
	* @method: doInit
	* @author: Khoi Nguyen
	* @date: 17/09/2017
	* @description: contructor component calling
	* @param: component event helper
	* @return: none
	*/
	doInit: function(component, event, helper) {
		// this function call on the component load first time     
		// get the page Number if it's not define, take 1 as default
		var page = component.get("v.page") || 1;
		// get the select option (drop-down) values.   
		var recordToDisply = component.find("recordSize").get("v.value");
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

	/*
	* @method: previousPage
	* @author: Khoi Nguyen
	* @date: 17/09/2017
	* @description: previousPage pagination action
	* @param: component event helper
	* @return: none
	*/
	previousPage: function(component, event, helper) {
		// this function call on click on the previous page button  
		var page = component.get("v.page") || 1;
		// get the previous button label  
		var direction = event.getSource().get("v.label");
		// get the select option (drop-down) values.  
		var recordToDisply = component.find("recordSize").get("v.value");
		// set the current page,(using ternary operator.)  
		page = direction === "Previous Page" ? (page - 1) : (page + 1);
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

	/*
	* @method: nextPage
	* @author: Khoi Nguyen
	* @date: 17/09/2017
	* @description: nextPage pagination action
	* @param: component event helper
	* @return: none
	*/
	nextPage: function(component, event, helper) {
		// this function call on click on the next page button   
		var page = component.get("v.page") || 1;
		// get the next button label 
		var direction = event.getSource().get("v.label");
		// get the select option (drop-down) values.   
		var recordToDisply = component.find("recordSize").get("v.value");
		// set the current page,(using ternary operator.)  "(page + 1)"
		page = direction === "Previous Page" ? (page - 1) : (page + 1);
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

	/*
	* @method: onSelectChange
	* @author: Khoi Nguyen
	* @date: 17/09/2017
	* @description: Select number record display on page
	* @param: component event helper
	* @return: none
	*/
	onSelectChange: function(component, event, helper) {
		// this function call on the select opetion change,	 
		var page = 1
		var recordToDisply = component.find("recordSize").get("v.value");
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

	/*
	* @method: actionEditApplicant
	* @author: Khoi Nguyen
	* @date: 17/09/2017
	* @description: direct to applicantsubscription page with id
	* @param: component event helper
	* @return: none
	*/
	actionEditApplicant: function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": '/applicantsubscription?applicantID='+event.target.id
		});
		urlEvent.fire();
	},
})