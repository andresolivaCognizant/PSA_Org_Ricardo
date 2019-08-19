({
	getEnergy : function(component, event, brand, sRIds, family, shape) {
	
		var action = component.get("c.getEnergyData");    
        
    	action.setParams({
        	'brand'  : brand,
        	'sRId'   : sRIds,
        	'family' : family,
        	'shape'  : shape
    	});

    	action.setCallback(this, function(response) {
    		var state = response.getState();    		
    		
    		if (state === "SUCCESS") {
	    		var eneData = JSON.parse(response.getReturnValue());
	    		
	    		if(eneData !== null && eneData !== undefined && eneData.length !== 0){
		    		var items = [];
		    		
		    		for(var i = 0; i < eneData.length; i++){
			            var item = {
			                "label": eneData[i].EnergyDescription__c,
			                "value": eneData[i].EnergyCode__c, 
			            };
			            
			            items.push(item);
			        }
		    		
		    		component.set("v.options", items);
		    	}
	    		
	    	} else {
	    		var errors = response.getError();
                  
                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
	    	}
    		    		
    	});
    	$A.enqueueAction(action); 
		
	}
})