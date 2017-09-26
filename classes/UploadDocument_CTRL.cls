public without sharing class UploadDocument_CTRL {
	@AuraEnabled                            
    public static Id saveTheChunkChatterFile(id parentId,String fileName, String base64Data, String contentType, String contentDocumentId){
        system.debug('saving chatter file');
        if (contentDocumentId == '' || contentDocumentId==null ) {
            system.debug('null id');
            system.debug('@@@ base64Data : ' + base64Data);
            contentDocumentId = saveChatterFiles(parentId, fileName, base64Data, contentType);
            system.debug('@@@@@ IF contentDocumentId: 1 '+contentDocumentId);
        } else {
            system.debug('not null id');
            system.debug('id '+contentDocumentId);
            appendToFileChatter(contentDocumentId, base64Data);
            system.debug('@@@@@ IF contentDocumentId: 2 '+contentDocumentId);
        }
        system.debug('@@@@@ contentDocumentId: 3 '+contentDocumentId);
        return Id.valueOf(contentDocumentId);
    }

    @AuraEnabled
    public static Id saveChatterFiles(Id parentId, String fileName, String base64Data, String contentType)  { 
        system.debug('Saving chatter files '+fileName + ' '+ contentType);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title = fileName; 
        testContentInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient='/' + fileName ;
        testContentInsert.IsMajorVersion = false;
        insert testContentInsert; 
        system.debug('testContentInsert.id '+ testContentInsert.id);
        testContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: testContentInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = testContentInsert.ContentDocumentId;
        cl.LinkedEntityId = parentId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        system.debug('testContentInsert.id');
        return testContentInsert.id;
    }

    @AuraEnabled
    public static void appendToFileChatter(Id contentDocumentId, String base64Data) {
        system.debug('@@@ appendToFileChatter contentDocumentId: '+ contentDocumentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug('appending');
        ContentVersion a = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];
        String existingBody = EncodingUtil.base64Encode(a.VersionData);
        a.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 
        update a;
    }
}