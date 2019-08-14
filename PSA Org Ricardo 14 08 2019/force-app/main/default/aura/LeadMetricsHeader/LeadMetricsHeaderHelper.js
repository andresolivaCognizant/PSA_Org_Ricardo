({
	getDataMetrics : function(component, event) {
        //console.log("Start of LeadMetricsHeaderHelper.getDataMetrics...")
        var userPortalRole      = component.get("v.userPortalRole");
        var filterByCurrentUser = component.get("v.filterByCurrentUser");
        var action              = component.get("c.getLeadMetrics");
        action.setParams({
                         "filterByCurrentUser" : filterByCurrentUser,
                         "filterByStatus" : component.get("v.filterByStatus"),
                         "whereClause" : component.get("v.whereClause")
                         });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                //console.log("response.getReturnValue: " + JSON.stringify(response.getReturnValue()));
                component.set("v.metricsData", response.getReturnValue());
            } else if (state === 'ERROR'){
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
    
    getNewLeadTotals : function(component, event) {
        //console.log("Start of LeadMetricsHeaderHelper.getNewLeadTotals...")
        var action = component.get("c.getLeadTotals");
        action.setParams({
                         //"filterByCurrentUser" : component.get("v.filterByCurrentUser"),
                         "filterByCurrentUser" : true,
                         "filterByStatus" : component.get("v.filterByStatus"),
                         "whereClause" : component.get("v.whereClause")
                         });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                //console.log("response.getReturnValue: " + JSON.stringify(response.getReturnValue()));
                component.set("v.newLeadTotals", response.getReturnValue());
            } else if (state === 'ERROR'){
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
        
    getUserPortalRole : function(component, event) {
        //console.log("Start of LeadMetricsHeaderHelper.getUserPortalRole..."); 
        var action = component.get("c.getUserPortalRole");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
            var userPortalRole = response.getReturnValue();
                //console.log("userPortalRole: " + userPortalRole);
                component.set("v.userPortalRole", userPortalRole);
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