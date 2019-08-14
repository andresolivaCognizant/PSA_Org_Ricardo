({
	getSResource : function(component, event, brand, sRIds, family, shape, energy) {
	
		var action = component.get("c.getSRData");    
        
    	action.setParams({
        	'brand'  : brand,
        	'sRId'   : sRIds,
        	'family' : family,
        	'shape'  : shape,
        	'energy' : energy
    	});

    	action.setCallback(this, function(response) {
    		var state = response.getState();    		
    		
    		if (state === "SUCCESS") {
	    		var sRData = JSON.parse(response.getReturnValue());
	    		
	    		if(sRData !== null && sRData !== undefined && sRData.length !== 0){
		    		var items = [];
		    		
		    		for(var i = 0; i < sRData.length; i++){
			            var item = {
			                "label": sRData[i].Name,
			                "value": sRData[i].Id,
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