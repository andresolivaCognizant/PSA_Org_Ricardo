({
	isMandatory: function(cmp){
		let stringQuery = "select id from " + cmp.get("v.object") + " where id='" + cmp.get("v.id") + "' ";
		const lfields = cmp.get("v.lFields");
		for(const field of lfields){
			if(field){
				stringQuery = stringQuery + "and " + field + " != null ";
			}
		}
		
		let action = cmp.get("c.isMandatoryComplete");
		action.setParams({  Textquery : stringQuery  });
		action.setCallback(this, function(response){
			let state = response.getState();
			if (state === "SUCCESS") {
				const canNext = cmp.get("v.canNext");
				if(response.getReturnValue() && canNext){
					let navigate = cmp.get('v.navigateFlow');
					navigate("NEXT");
				}
			}
		});
		$A.enqueueAction(action);
	},  
	getAvailableFlowActions: function(cmp){
		let availableActions = cmp.get('v.availableActions');
    	for (var i = 0; i < availableActions.length; i++) {
        	if (availableActions[i] == "PAUSE") {
        	   cmp.set("v.canPause", true);
        	} else if (availableActions[i] == "BACK") {
        	   cmp.set("v.canBack", true);
        	} else if (availableActions[i] == "NEXT") {
        	   cmp.set("v.canNext", true);
        	} else if (availableActions[i] == "FINISH") {
        	   cmp.set("v.canFinish", true);
        	}
    	}
	},
	goToPrevious: function(cmp){
		const canBack = cmp.get("v.canBack");

		if(canBack){
			let navigate = cmp.get('v.navigateFlow');
			navigate("BACK");
		}
	}    
})