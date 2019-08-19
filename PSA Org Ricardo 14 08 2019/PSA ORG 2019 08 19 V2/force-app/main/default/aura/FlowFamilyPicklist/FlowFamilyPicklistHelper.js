({
	getFamily : function(component, event, brand, sRIds) {
	
		var action = component.get("c.getFamilyData");    
 
        
    	action.setParams({
        	'brand' : brand,
        	'sRId'  : sRIds
    	});

    	action.setCallback(this, function(response) {
    		var state = response.getState();    		
    		
    		if (state === "SUCCESS") {
	    		var famData = JSON.parse(response.getReturnValue());
	    		
	    		if(famData !== null && famData !== undefined && famData.length !== 0){
		    		var items = [];
		    		
		    		for(var i = 0; i < famData.length; i++){
			            var item = {
			                "label": famData[i].FamilyDescription__c,
			                "value": famData[i].FamilyCode__c, 
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