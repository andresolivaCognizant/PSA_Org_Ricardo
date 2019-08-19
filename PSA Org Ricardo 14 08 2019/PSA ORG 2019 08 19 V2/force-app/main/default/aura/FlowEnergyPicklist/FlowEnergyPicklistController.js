({
    doInit : function(component, event, helper) { 
		var brand = component.get("v.brand");
		var sRIds = component.get("v.sRId"); 
		var family = component.get("v.family");
		var shape = component.get("v.shape");
        
        helper.getEnergy(component, event, brand, sRIds, family, shape);
        
    },
    
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        
        component.set("v.selectedValue", selectedOptionValue); 
    }
})