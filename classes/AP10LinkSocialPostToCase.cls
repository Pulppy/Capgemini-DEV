/*
Class Name: AP10LinkSocialPostToCase
Created by: Nga Do 2017/05/22
Modified by: Nga Do 2017/05/22
Update New Case Id into Parent field of Scial Post.
*/

public without sharing class AP10LinkSocialPostToCase {

	public static void updateParentSocialPost(List<Case> listCase){

		/*Map<Id, String> caseLinktoSocialPostMap = new Map<Id, String>();
	    for(Case objCase : listCase){
	        if(objCase.Social_Post_Id__c != null){
	            caseLinktoSocialPostMap.put(objCase.Social_Post_Id__c, objCase.Id);
	        }
	    }
	    List<SocialPost> listSocialPostUpdate = [SELECT Id, ParentId from SocialPost where Id in: caseLinktoSocialPostMap.keySet()];
	    
	    for(SocialPost objSp : listSocialPostUpdate){
	        if(caseLinktoSocialPostMap.containsKey(objSp.Id)){
	            objSp.ParentId = caseLinktoSocialPostMap.get(objSp.Id);
	        } 
	    }
	    try{

	    	update listSocialPostUpdate; 

    	}catch(Exception ex){

    		System.debug('>>>Error-AP10LinkSocialPostToCase<<<<' + ex.getMessage());
    	}
*/
	}
}