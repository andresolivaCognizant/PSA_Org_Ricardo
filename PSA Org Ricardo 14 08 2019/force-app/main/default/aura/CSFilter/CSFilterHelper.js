({
	getLabelList : function(component, objectName, mapName) {
        var action  = component.get("c.getLabels");
        action.setParams({
            objectName : objectName
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                component.set(mapName, response.getReturnValue());
            }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    setFormFilter : function(component, newValue) {
        component.set("v.ObjectType",newValue);
        var resultsBox = component.find('cmpResultBox');
        $A.util.addClass(resultsBox, "slds-hide");
    }
})