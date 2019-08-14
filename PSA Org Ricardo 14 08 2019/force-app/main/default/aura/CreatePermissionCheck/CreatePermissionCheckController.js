({
	doInit : function(component, event, helper) {
        console.log("Object name" + component.get("v.sObjectName"));
var action = component.get("c.isRecInsertable");
       
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				// actions to perform after date is received from server
                if (response.getReturnValue()) {
                        var createRecordEvent = $A.get("e.force:createRecord");
    					createRecordEvent.setParams({
        				"entityApiName": component.get("v.sObjectName")
    				});
    					createRecordEvent.fire();
                } else {
                    component.set("v.isInsertAllowed", true);
                }
				
			}
            
           
        });
                           
                            $A.enqueueAction(action);
        
	}
		
	
})