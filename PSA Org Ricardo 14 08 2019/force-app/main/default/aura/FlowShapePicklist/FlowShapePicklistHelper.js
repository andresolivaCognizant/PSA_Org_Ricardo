({
	getShape : function(component, event, brand, sRIds, family) {
	
		var action = component.get("c.getShapeData");    
        
    	action.setParams({
        	'brand'  : brand,
        	'sRId'   : sRIds,
        	'family' : family
    	});

    	action.setCallback(this, function(response) {
    		var state = response.getState();    		
    		
    		if (state === "SUCCESS") {
	    		var shaData = JSON.parse(response.getReturnValue());
	    		
	    		if(shaData !== null && shaData !== undefined && shaData.length !== 0){
		    		var items = [];
		    		
		    		for(var i = 0; i < shaData.length; i++){
			            var item = {
			                "label": shaData[i].ShapeDescription__c,
			                "value": shaData[i].ShapeCode__c, 
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