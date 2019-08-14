({
    getUserDetails : function(component, event, helper) {
        console.log("Start of DealerPortalThemeController.getUserDetails..."); 
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                console.log("response.getReturnValue: " + JSON.stringify(response.getReturnValue()));
                component.set("v.userRecord", response.getReturnValue());
            } else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);	
    },	
    /*
    getUserPortalRole : function(component, event, helper) {
        console.log("Start of DealerPortalThemeController.getUserPortalRole..."); 
        var action = component.get("c.getUserPortalRole");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
            var userPortalRole = response.getReturnValue();
                console.log("userPortalRole: " + userPortalRole);
                component.set("v.userPortalRole", userPortalRole);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getUserPortalRole:Error message: " + errors[0].message);
                    }
                } else {
                    console.log("getUserPortalRole:Unknown error");
                }
            }else{
                console.log('getUserPortalRole:Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);	
    },
*/
})