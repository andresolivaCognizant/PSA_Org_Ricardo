({ 
	searchHelper : function(component, event, getInputkeyWord, getWhereClause) {
		var action = component.get("c.fetchLookUpValues");
		 
		action.setParams({
			'searchKeyWord': getInputkeyWord,
			'ObjectName' : component.get("v.objectAPIName"),
			'whereClause' : getWhereClause
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				if (storeResponse.length == 0) {
					component.set("v.Message", 'No Result Found...');
				} else {
					component.set("v.Message", '');
				}
				component.set("v.listOfSearchRecords", storeResponse);
			}
		});

		$A.enqueueAction(action);
	},
	
	getUserLeadCounts : function(component, event) {
		var action = component.get("c.getUserLeadCounts");

		action.setParams({
			filterByCurrentUser: false
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS') {
				component.set("v.userMetrics", response.getReturnValue());

			} else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}else{
				console.log('Something went wrong, Please check with your admin');
			}
		});
		$A.enqueueAction(action);	
	},
})