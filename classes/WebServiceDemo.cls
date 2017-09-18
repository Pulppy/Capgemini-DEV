@RestResource(urlMapping='/Cases/*')
global with sharing class WebServiceDemo {

	@HttpGet
	global static Case getCaseById() {
		RestRequest request = RestContext.request;
		// grab the caseId from the end of the URL
		String caseId = request.requestURI.substring(
		request.requestURI.lastIndexOf('/')+1);
		Case result =  [SELECT CaseNumber,Subject,Status,Origin,Priority,CaseOrigin__c
						FROM Case
						WHERE Id = :caseId];
		return result;
	}
}