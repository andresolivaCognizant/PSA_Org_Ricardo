({
   doInit : function(component,event,helper){
	   //helper.getUserLeadCounts(component, event);
   },
   
   selectRecord : function(component, event, helper){ 
		console.log('Start of LookupResultUserController.selectRecord...');     
    	// get the selected record from list  
    	var getSelectRecord = component.get("v.oRecord");
    	console.log(':::getSelectRecord: ' + JSON.stringify(getSelectRecord));
      	var compEvent = component.getEvent("oLookupSelectedRecordEvent");
      	compEvent.setParams({"recordByEvent" : getSelectRecord });  
      	compEvent.fire();
    },
})