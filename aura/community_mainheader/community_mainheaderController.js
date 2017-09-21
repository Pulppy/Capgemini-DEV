({
    doInit: function(cmp){
    var action = cmp.get("c.getUserName");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            cmp.set("v.userinfo", response.getReturnValue());
            console.log(response.getReturnValue());
         }
      });
       $A.enqueueAction(action);
     }
})