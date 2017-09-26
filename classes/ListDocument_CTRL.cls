public without sharing class ListDocument_CTRL {
	@AuraEnabled
	public static List<ContentDocument> getDocument(Id recordparentid)
    {
        List<ContentDocumentLink> cdlist = [Select id, LinkedEntityId, ContentDocumentID from ContentDocumentLink where LinkedEntityId =: recordparentid];
    	Set<Id> fileId = new Set<Id> ();
		for(ContentDocumentLink cl:cdlist){
			fileId.add(cl.ContentDocumentId);
		}
		List<ContentDocument> cvlist = [Select Id, Title, ContentSize, FileExtension, ContentModifiedDate from ContentDocument where Id in:fileId order by ContentModifiedDate DESC];
    	return cvlist;
    }
}