({
	init: function(component, event, helper) {
		console.log('Init');
		helper.init(component, helper);
	},
	onKeyUpInput: function(component, event, helper) {
		var delimiter 		= component.get('v.delimiter');		
		var currentInput 	= component.get("v.searchField");
		if (currentInput[currentInput.length - 1] === delimiter || event.keyCode !== 13) {
			helper.addNewPills(component, currentInput.split(delimiter));
		}
	},
	onRemovePill: function(component, event, helper) {
		var pillId 			= event.getSource().get('v.name');
		var pills 			= component.get('v.pills');
		var currentInput 	= component.get("v.searchField");
		var sResult 		='';

		for (var i = 0; i < pills.length; i++) {
		  if (pillId === pills[i].id) {
		  	sResult =currentInput.replace(pills[i].label,'');
		    pills.splice(i, 1);
		    break;
		  }
		}
		component.set("v.searchField",sResult.trim());
		component.set('v.pills', pills);
	},
	scriptsLoaded: function(component, event, helper) {
	    component.set('v.scriptsLoaded', true);
	    helper.init(component);
	},
})