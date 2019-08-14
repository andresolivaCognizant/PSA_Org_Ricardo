({
	init: function(component) {
		var pillList 			= []; 
		pillList.push('');
		component.find("ObjectField").set("v.value", pillList[pillList.length-1]);
  },
	addNewPills: function(component,values) {
		var pills = [];
		for (var i = 0; i < values.length; i++) {
		  var trimmedVal = values[i].trim();
		  if (trimmedVal !== "") {
		    pills.push({
		      id 		: this.guidGenerator(component),
		      label		: trimmedVal,
		      isValid 	: this.isInputValid(component, trimmedVal)
		    });
		  }
		}
		component.set('v.pills', pills);
	},
	isInputValid: function(component, value) {
		return true;
	},
	parsePillsToField: function(component) {
		var pills 				= component.get('v.pills');
		var delimiterInDatabase = component.get('v.delimiterInDatabase');
		var fieldStr 			= '';
		for (var i = 0; i < pills.length; i++) {
		  fieldStr += pills[i].label + delimiterInDatabase;
		}
		try {
		  component.set('v.fieldvalue', fieldStr);
		} catch (e) {
		  //ignore issue that occurs when trying to set unbinded value
		}
	},
	parseFieldToPills: function(component) {
		var fieldStr 					= component.get('v.fieldvalue');
		var delimiterInDatabase = component.get('v.delimiterInDatabase');
		var pills 						= [];
		var splitFieldStr 		= [];
		if (fieldStr != null) {
		  splitFieldStr = fieldStr.split(delimiterInDatabase);
		}
		for (var i = 0; i < splitFieldStr.length; i++) {
		  if (splitFieldStr[i] != "") {
		    pills.push({
		      id 		: this.guidGenerator(component),
		      label 	: splitFieldStr[i],
		      isValid 	: this.isInputValid(component, splitFieldStr[i])
		    });
		  }
		}
		component.set('v.pills', pills);
	},
	guidGenerator: function(component) {
	  var S4 = function() {
	    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
	  };
	  return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
	},

})