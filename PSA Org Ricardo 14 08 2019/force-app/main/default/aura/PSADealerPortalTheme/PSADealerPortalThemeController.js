({  
    doInit : function(component, event, helper) {	
        //console.log("Start of DealerPortalThemeController.doInit...");
        helper.getUserDetails(component);
    },
    
    openMenu : function(component, event, helper) {
        //console.log("Start of DealerPortalThemeController.openMenu...");
        var showMenu = component.get("v.showMenu");
        //console.log(":::showMenu: " + showMenu);
        if (showMenu === false) component.set("v.showMenu", true);
        else component.set("v.showMenu", false);
    },
    
    goToSearchPage : function(component, event, helper) {
        //console.log("Start of DealerPortalThemeController.goToSearchPage..."); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/advanced-search"
        });
        urlEvent.fire();
    },
    goToVehicleSearchPage : function(component, event, helper) {
        //console.log("Start of DealerPortalThemeController.goToSearchPage..."); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/advanceassetsearch"
        });
        urlEvent.fire();
    },
    
    goToHomePage : function(component, event, helper) {
        //console.log("Start of DealerPortalThemeController.goToHomePage..."); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    handleMenuSelect: function(component, event, helper) {
        var selectedMenu = event.detail.menuItem.get("v.value");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        switch(selectedMenu) {
            case $A.get("$Label.c.LeadAssignmentAdvancedSearch"):
                urlEvent.setParams({
                    "url": "/advanced-search"
                });
                break;
            case $A.get("$Label.c.AfterSalesVehicleAdvancedSearch"):
                urlEvent.setParams({
                    "url": "/advanceassetsearch"
                });
                break;
        }
         urlEvent.fire();
    },
    handleToastEvent : function(component, event, helper) {
        console.log('Save/Update --> Toast');
        var sParams             = event.getParams();
        var sType               = sParams.type;
        if (sType.toUpperCase() === 'SUCCESS'){
            helper.startCORScall(component,sType);
        }
    },

})