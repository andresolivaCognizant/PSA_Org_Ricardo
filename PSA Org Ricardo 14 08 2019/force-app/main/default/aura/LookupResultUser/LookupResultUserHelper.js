({
    getUserLeadCounts : function(component, event) {
        console.log("Start of LookupResultUserController.getUserLeadCounts...");
        var action = component.get("c.getUserLeadCounts");
        var userRec = component.get("v.oRecord");
        console.log(':::userRec: ' + userRec);
        /*
        action.setParams({
            userId: userRec.Id
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                var userLeadCounts = response.getReturnValue();
                console.log("response.getReturnValue: " + JSON.stringify(response.getReturnValue()));
                component.set("v.uRecord", response.getReturnValue());
            } else if (state === 'ERROR') {
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
*/
    },
})