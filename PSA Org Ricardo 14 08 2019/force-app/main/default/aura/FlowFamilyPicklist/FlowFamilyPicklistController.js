({
    doInit : function(component, event, helper) { 
		var brand = component.get("v.brand");
		var sRIds = component.get("v.sRId"); 
        
        helper.getFamily(component, event, brand, sRIds);
        
    },
    
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        
        component.set("v.selectedValue", selectedOptionValue); 
    }
})