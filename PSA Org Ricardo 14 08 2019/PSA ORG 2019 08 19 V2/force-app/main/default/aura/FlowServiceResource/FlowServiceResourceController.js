({
    doInit: function(component, event, helper) {
        var availableActions = component.get('v.availableActions');
        
        for (var i = 0; i < availableActions.length; i++) {
            if (availableActions[i] == "PAUSE") {
                component.set("v.canPause", true);
            } else if (availableActions[i] == "BACK") {
                component.set("v.canBack", true);
            } else if (availableActions[i] == "NEXT") {
                component.set("v.canNext", true);
            } else if (availableActions[i] == "FINISH") {
                component.set("v.canFinish", true);
            }
        }
        
        var brand = component.get("v.brand");
        var sRIds = component.get("v.sRId");
        var family = component.get("v.family");
        var shape = component.get("v.shape");
        var energy = component.get("v.energy");

        helper.getSResource(component, event, brand, sRIds, family, shape, energy);

    },

    handleChange: function(component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");

        component.set("v.selectedValue", selectedOptionValue);
    },

    onButtonPressed: function(component, event, helper) {
        // Figure out which action was called
        var actionClicked = event.getSource().getLocalId();
        var vSelected = component.get("v.selectedValue");
        
        if (actionClicked === "NEXT" && vSelected === undefined){
        	    var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": $A.get("$Label.c.EmptyResourceError")
                });

                toastEvent.fire();
        } else {
        	// Fire that action
        	var navigate = component.get('v.navigateFlow');
        	navigate(actionClicked);
        }

    }
})