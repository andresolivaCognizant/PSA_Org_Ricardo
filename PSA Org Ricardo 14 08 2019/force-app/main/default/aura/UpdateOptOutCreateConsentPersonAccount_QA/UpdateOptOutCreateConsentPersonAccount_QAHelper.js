({
    executeInit: function (component, event, helper){

		var accountId = component.get("v.recordId");
		var action = component.get("c.check");
        action.setParams({
            "recordId" : accountId,
            "invocationType" : "personAccount"
		});		
		
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();

            if(state === "SUCCESS"){
                if(result === $A.get("$Label.c.Do_not_contact_success")){
                    component.find('notifLib').showToast({
                        "variant": "success",      
                        "message": result
                    }); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();            						
                }
                else{
                    component.set('v.informativeMessage', result);
                }
            }
            else{
                component.set('v.informativeMessage', $A.get("$Label.c.GenericErrorMessage"));                   
            }
        });
		$A.enqueueAction(action);
	}
})