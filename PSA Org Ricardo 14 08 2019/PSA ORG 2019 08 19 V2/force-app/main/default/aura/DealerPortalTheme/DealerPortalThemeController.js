({  
    doInit : function(component, event, helper) {	
        console.log("Start of DealerPortalThemeController.doInit...");
        helper.getUserDetails(component);
        //helper.getUserPortalRole(component);
        /*
		setTimeout(function() {
	        var userPortalRole = component.get("v.userPortalRole");
	        console.log('DealerPortalThemeController.doInit: userPortalRole: ' + userPortalRole);
	        var appEvent = $A.get("e.c:LMAUserPortalControlEvent");
	        appEvent.setParams({
			            			"userPortalRole" : userPortalRole
								});
		    console.log(':::fired event');
	        appEvent.fire(); 
        },3000); 
*/
    },
    
    openMenu : function(component, event, helper) {
        console.log("Start of DealerPortalThemeController.openMenu...");
        var showMenu = component.get("v.showMenu");
        console.log(":::showMenu: " + showMenu);
        if (showMenu == false) component.set("v.showMenu", true);
        else component.set("v.showMenu", false);
    },
    
    goToSearchPage : function(component, event, helper) {
        console.log("Start of DealerPortalThemeController.goToSearchPage..."); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/advanced-search"
        });
        urlEvent.fire();
    },
    
    goToHomePage : function(component, event, helper) {
        console.log("Start of DealerPortalThemeController.goToHomePage..."); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
})