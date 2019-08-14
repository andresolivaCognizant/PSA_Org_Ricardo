({
	doInit : function(component, event, helper) {
        helper.getUserPortalRole(component, event);

        setTimeout(function() {
                var userPortalRole = component.get("v.userPortalRole");
                helper.getDataMetrics(component, event);
                helper.getNewLeadTotals(component, event);
                if (userPortalRole == 'Manager') {
                    component.set("v.alignClass","slds-grid--align-right");
                    component.set("v.backgroundClass", "with-background");
                } else {
                    component.set("v.alignClass","slds-grid--align-center");
                    component.set("v.backgroundClass", "without-background");
                }
        },1000);
        var t = window.setInterval(
			$A.getCallback(function() {
                helper.getDataMetrics(component, event);
                helper.getNewLeadTotals(component, event);
			}),
			60000
        );
        component.set( "v.CheckIntervalId", t );
    },
    
    expandLeads : function(component, event, helper) {
        var priorityLevel = event.getSource().get("v.name");
        var appEvent = $A.get("e.c:LeadManualAssignmentTabEvent");
        appEvent.setParams({
            "filterByPriority" : ($A.util.isUndefinedOrNull(priorityLevel) || $A.util.isEmpty(priorityLevel)) ? "Overdue" : priorityLevel,
            "tabsToShow"       : "leadsByActivity",
            "refreshData"       : true });
        appEvent.fire(); 
        
    },

    handleToggleEvent : function(component, event, helper) {
		//console.log('Start of LeadMetricsHeaderController.handleToggleEvent...');
		var filterByCurrentUser = event.getParam("filterByCurrentUser");
		component.set("v.filterByCurrentUser", filterByCurrentUser);
        helper.getDataMetrics(component, event);
        helper.getNewLeadTotals(component, event);
    },
    
    restoreTotalTab : function(component, event, helper) {	
        //console.log("Start of LeadMetricsHeaderController.restoreTabs.......");
        var appEvent = $A.get("e.c:LeadManualAssignmentTabEvent");
        appEvent.setParams({
            "tabsToShow"            : "leadsByPriority" ,
            "filterByCurrentUser"   : true,
            "refreshData"           : true });
        appEvent.fire(); 
        
    },
})