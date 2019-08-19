({
	doInit : function(component,event,helper){
		console.log('doInit');
		component.set("v.searchByAccount",helper.getUrlParameter('searchCLI'));
		component.set("v.searchByAsset",helper.getUrlParameter('searchAST'));
	},
	handleonclick : function(component, event, helper) {
		var appEvent 			= $A.get("e.c:AfterSalesSearchEvent");
        appEvent.setParams({
            "searchByAccount" 	: component.get("v.searchByAccount"),
            "searchByAsset"		: component.get("v.searchByAsset"),
            "refreshData" 		:true
        });
        appEvent.fire();
	},
	doneRendering: function(component, event, helper) {
	    if(!component.get("v.isDoneRendering")){
	    	component.set("v.isDoneRendering", true);
			var s1 = helper.getUrlParameter('searchCLI');
			var s2 = helper.getUrlParameter('searchAST');
			if(s1!=undefined || s2!=undefined){
				helper.sendAction(component,event);
			}
	    }
  	}
})