({
	 onGroup: function(cmp, evt) {
		 var selected = evt.getSource().getLocalId(); 
		 cmp.set('v.step', selected);
         console.log(selected);
         //radio yes
         if(selected == 'ryes'){
             document.getElementById('wp-display-yes').style.display = 'block';
         }else document.getElementById('wp-display-yes').style.display = 'none'; 
         //radio unvariable
         if(selected == 'ravai'){
             document.getElementById('wp-display-notavailable').style.display = 'block';
         }else document.getElementById('wp-display-notavailable').style.display = 'none';  
         //radio no
         if(selected == 'rnot'){
             document.getElementById('wp-display-not').style.display = 'block';
         }else document.getElementById('wp-display-not').style.display = 'none';  
        
	 },
    submit : function(component, event, helper) {
		var submitS = component.get("v.step");
        if(submitS ==="ryes"){
            console.log('#someButton was clicked');
			helper.submitS2(component);
        }
        if(submitS ==="ravai"){
			helper.submitS3(component);
			console.log('#someButton was clicked2');
        }
        if(submitS ==="rnot"){
			console.log('#someButton was clicked3');
            helper.submitS4(component);
        }
	},
    
})