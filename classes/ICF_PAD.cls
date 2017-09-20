public with sharing class ICF_PAD {
	public static final string bypassTrigger;
    static{
        // a list is used in order to avoid the following exception 'List has no rows for assignment to SObject'
        // this exception is fired when a license manager user try to update a record
        List<User> users = new List<User>([Select ICF_ByPassTrigger__c from User where Id =:UserInfo.getUserId() limit 1]);
        if(users.size()>0){
            System.Debug('## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName());
            bypassTrigger = ';' + users[0].ICF_ByPassTrigger__c + ';';
            System.Debug('## >>> PAD constructor : END <<<');
        }else{
            bypassTrigger = null;
        }
        
        System.Debug('## bypassTrigger'+ bypassTrigger);
    }
    
    
    public static boolean canTrigger(string ApexName){ //If no bypass
        if(bypassTrigger != null){
            return(bypassTrigger.indexOf(';'+ApexName+';')==-1);    
        }
        else{
            // when the string 'bypassTrigger' is null
            // a false is returned, so that no trigger process is applied on the updated record
            return false;
        }
    }

}