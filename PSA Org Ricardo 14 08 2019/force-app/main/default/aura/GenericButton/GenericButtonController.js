({
	doInit : function(component, event, helper) {
		/* BEGIN - Manuel Medina - New logic to allow Custom Labels as a design:attribute - 19102018 */
		helper.manageButtonLabels( component );
		/* END - Manuel Medina - 19102018 */
	
		helper.getCountryType(component);
	},
	
	handleClick1 : function(component, event, helper) {
		var mUpName = component.get("v.mUpName1");
	
		helper.callGenMashUp(component, mUpName);
	},
	
	handleClick2 : function(component, event, helper) {
		var mUpName = component.get("v.mUpName2");
		
		helper.callGenMashUp(component, mUpName);
	},
	
	handleClick3 : function(component, event, helper) {
		var mUpName = component.get("v.mUpName3");
		
		helper.callGenMashUp(component, mUpName);
	},
	
	handleClick4 : function(component, event, helper) {
		var mUpName = component.get("v.mUpName4");
		
		helper.callGenMashUp(component, mUpName);
	}
})