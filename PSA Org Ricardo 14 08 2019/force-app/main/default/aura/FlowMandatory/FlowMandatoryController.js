({
	doInit : function(cmp, event, helper) { 
		// Retrieve fields info
		let fields = cmp.get("v.fields");
		fields = fields.trim();

		if(fields.endsWith(',')){
			// In case the field list finishes with a comma, remove it
			fields = fields.slice(0, -1);
		}

		let lfields = fields.split(',');
		cmp.set("v.lFields", lfields);

		// If skipComleted=true then svreen should not be shown in case all fields are filled
		let skipCompleted = cmp.get('v.skipCompleted');
		
		// Get flow navigability info before excuting navigation events
		helper.getAvailableFlowActions(cmp);
		
		if(skipCompleted){
			helper.isMandatory(cmp);
		}
		
	},

	isMandatory: function(cmp, evt, helper){
		helper.isMandatory(cmp);
	},

	changeField: function(cmp){
		cmp.set("v.fieldChanged", true);
	},
	goToPrevious: function(cmp, evt, helper){
		helper.goToPrevious(cmp);
	}
})