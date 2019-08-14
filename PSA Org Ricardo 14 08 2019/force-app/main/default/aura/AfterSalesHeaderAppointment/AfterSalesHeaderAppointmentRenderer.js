({
	afterRender : function(component, helper) {
  		this.superAfterRender();
   		//helper.startDMScall(component);
	},
    rerender : function(component, helper) {
   		this.superRerender();
        var bCall = component.get("v.callDMSOnLoad");
        if($A.util.isUndefinedOrNull(bCall) || $A.util.isEmpty(bCall) || bCall){
   			helper.startDMScall(component);
            component.set("v.callDMSOnLoad",false);
        }
	}
})