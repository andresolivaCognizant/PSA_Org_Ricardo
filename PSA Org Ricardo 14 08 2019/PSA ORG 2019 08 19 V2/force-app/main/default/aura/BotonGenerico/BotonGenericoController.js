({
    doInit: function(component, event, helper) {
		helper.loadListBtt(component, event, helper);
    },
	
	handleClick: function(component, event, helper) {
		
		var recId = component.get("v.recordId");
		var list = component.get('v.bttList');       
        var id = event.getSource().get("v.name");
        var isCommunity = component.get("v.isCommunity");
		var i;
		var action;
		var comp;
		var url;
        for (i = 0; i<list.length; i++) {
			if (list[i].id == id) {
				action = list[i].action;
				comp = list[i].component;
				url = list[i].url;
			}
		}
         
        if (action === 'navigateToComponent'){
        	if (isCommunity){
        		 var navEvt = $A.get("e.force:navigateToURL");
        		 
        		 url = url + '?' + recId;
		    
        		 navEvt.setParams({
        			 "url": url
        		 });
        	} else {
        		var compToNavigate = 'c:' + component;
        		var navEvt = $A.get("e.force:navigateToComponent");
			
        		navEvt.setParams({
        			componentDef : compToNavigate,
        			componentAttributes : {
        				"recordId" : recId
        			}
        		});		
			}
			
			navEvt.fire();
        
        } else if (action === 'navigateToSObject'){
        	var navEvt = $A.get("e.force:navigateToSObject");
			
			navEvt.setParams({
				"recordId": "recId",
				"slideDevName": "detail"
			});

			navEvt.fire();
        } else if (action === 'navigateToURL' ){
        	var navEvt = $A.get("e.force:navigateToURL");
		    
		    navEvt.setParams({
		      "url": url
			});

			navEvt.fire();
        } else if (action === 'callDMS'){
			helper.startCORScall(component); 
		}  
	},

})