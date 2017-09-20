public class CustomLinksCtrl {

	/*
    @AuraEnabled
    public static List<WebLink> prepare() {
		
        List<WebLink> tag = new List<WebLink>();
        tag = [select Id, LinkType, MasterLabel, Name, OpenType, Url from WebLink where PageOrSobjectType = 'CustomPageItem' limit 100];
        return tag;
    }
	*/
	 @AuraEnabled
    public static List<CustomLinksSetting__c> prepare() {
		String userProfileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;

        List<CustomLinksSetting__c> tag = new List<CustomLinksSetting__c>();
        //tag = [select Id, Name, Available_Profile__c, Link_URL__c from CustomLinksSetting__c];

		for(CustomLinksSetting__c cs : CustomLinksSetting__c.getall().values())
		{
            if (CheckMatchCondition(cs.Available_Profile__c.split(';'),userProfileName) && cs.Active__c==true)
				tag.add(cs);
        }

        return tag;
    }

	public static boolean CheckMatchCondition(String[] cslist,String value){
        for(String s : cslist){
            if(s == value) return true;
        }//end of loop
        return false; 
    }//end of 
}