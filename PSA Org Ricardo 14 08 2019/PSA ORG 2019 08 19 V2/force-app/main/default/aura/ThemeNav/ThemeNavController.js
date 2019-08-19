({
    onClick : function(component, event, helper) {
        console.log("Start of ThemeNavController.onClick...");
        var id = event.target.dataset.menuItemId;
        if (id) {
            component.getSuper().navigate(id);
        }
        component.set("v.showMenu", false);
    },
    
    handleMenuSelect: function(cmp, event, helper) {
        console.log("Start of ThemeNavController.handleMenuSelect...");
    	//var pageName = event.getParam("value");
        var id = event.target.dataset.menuItemId;
        console.log(":::id: " + id);
        if (id) {
            component.getSuper().navigate(id);
        }
    },
   
    showHideMenu : function(component, event, helper) {
        console.log("Start of ThemeNavController.showMenu...");
        var showMenu = component.get("v.showMenu");
        console.log(":::showMenu: " + showMenu);
        if (showMenu == false) component.set("v.showMenu", true);
        else component.set("v.showMenu", false);
    },
   
    hideMenu : function(component, event, helper) {
        console.log("Start of ThemeNavController.hideMenu...");
        var menu = component.find("menuId");
        $A.util.toggleClass(menu, 'slds-hide');
        component.set("v.showMenu", false);
    },
})