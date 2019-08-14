({
    showMessage : function(component, event, stitle, smessage, stype){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title   : stitle,
            message : smessage,
            type    : stype
        });
        toastEvent.fire();
    },
    getUserPortalRole : function(component, event, helper) {
        var action = component.get("c.getUserPortalRole");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                var userPortalRole = response.getReturnValue();
                if(userPortalRole != 'Manager'){
                     component.set("v.filterByCurrentUser", true);
                     component.set("v.userPortalRole", 'Worker');
                }else{
                    component.set("v.userPortalRole", userPortalRole);
                    component.set("v.filterByCurrentUser", false);
                    component.set("v.showPriorityTabs", "true");
                    component.set("v.showActivityTabs", "false");
                }
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
    handleTabs: function(component, tabsToShow) {	
		if (tabsToShow == "leadsByPriority"){
			component.set("v.showPriorityTabs", "true");
            component.set("v.showActivityTabs", "false");
		}else{
			component.set("v.showPriorityTabs", "false");
			component.set("v.showActivityTabs", "true");
		}
	},
})