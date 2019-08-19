({
	doInit : function(component, event, helper) {	
        helper.getUserPortalRole(component, event);
    },
	handleTabEvent: function(component, event, helper) {
		var tabsToShow 		= event.getParam("tabsToShow");
        var tabsToFilter 	= event.getParam("filterByPriority");
        helper.handleTabs(component,tabsToShow);
        component.set("v.filterByPriority",tabsToFilter);
	},
    handleToggleEvent : function(component, event, helper) {
		var filterByCurrentUser = event.getParam("filterByCurrentUser");
		component.set("v.filterByCurrentUser", filterByCurrentUser);
        helper.handleTabs(component,(filterByCurrentUser)?"leadsByActivity":"leadsByPriority");
    },
})