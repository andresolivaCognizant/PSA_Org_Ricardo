({  
    doInit : function(component, event, helper) {	
        //console.log("Start of DealerPortalThemeController.doInit...");
      	var urlForm = (window.location.href).toString();
        if(urlForm.includes("peugeot")){
            component.set("v.brandAtrib","AP");
            component.set("v.backgroundColor","#1E2336");
        }
        else if(urlForm.includes("citroen")){
            component.set("v.brandAtrib","AC");
            component.set("v.backgroundColor","#A09696");
        }
        else if(urlForm.includes("ds")){
            component.set("v.brandAtrib","DS");
            component.set("v.backgroundColor","#AD0040");
        }

        helper.userInfo(component,event);
    },
    
    openMenu : function(component, event, helper) {
        //console.log("Start of DealerPortalThemeController.openMenu...");
        var showMenu = component.get("v.showMenu");
        //console.log(":::showMenu: " + showMenu);
        if (showMenu == false) component.set("v.showMenu", true);
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
    handleIsAlgeria : function(component,event,helper){
        var country = event.getParam("country");
        component.set("v.countryAtrib",country);
    }    
})