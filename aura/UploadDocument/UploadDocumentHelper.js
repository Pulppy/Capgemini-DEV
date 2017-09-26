({
	MAX_FILE_SIZE: 4 500 000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 900 000, /* Use a multiple of 4 */

    save : function(component) {
        var fileInput = component.find("file").getElement();
            var file = fileInput.files[0];
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
              'Selected file size: ' + file.size);
            return;
        }
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            //console.log('@@ fileContents:  '+fileContents);
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            console.log('@@ dataStart:  '+dataStart);
            fileContents = fileContents.substring(dataStart);
            //console.log('@@ fileContents:  '+fileContents);
            self.upload(component, file, fileContents);
        };
        fr.readAsDataURL(file);
    },

    upload: function(component, file, dataURL) {
        console.log('uploading file ...');
        var fromPos = 0;
        var len = dataURL.length
        var toPos = Math.min(dataURL.length, fromPos + this.CHUNK_SIZE);
        console.log('@@ len:  '+len);
        console.log('@@ fromPos:  '+fromPos); 
        console.log('@@ toPos:  '+toPos);  
        this.uploadChunk(component, file, dataURL, fromPos, toPos,'');

    },

    uploadChunk : function(component, file, dataURL, fromPos, toPos,contentDocumentId){
        console.log('@@@@ uploading chunk ');
        var action = component.get("c.saveTheChunkChatterFile");
        var chunk = dataURL.substring(fromPos, toPos);
        //console.log('@@@@@@ chuoi tum lum: ' + chunk);
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            contentDocumentId :contentDocumentId
        });
        var self = this;
        action.setCallback(this, function(a) {
            contentDocumentId = a.getReturnValue();
            console.log('@@@@ return value '+contentDocumentId);
            fromPos = toPos;
            toPos = Math.min(dataURL.length, fromPos + self.CHUNK_SIZE);   
            console.log('@@ fromPos:  '+fromPos);
            console.log('@@ toPos:  '+toPos);
            if (fromPos < toPos) {
                self.uploadChunk(component, file, dataURL, fromPos, toPos, contentDocumentId);  
            }else{
                component.set("v.message", "File Uploaded");
                console.log('@@ uploaded');
            }
        });
        component.set("v.message", "Uploading...");

        $A.enqueueAction(action); 
   }
})