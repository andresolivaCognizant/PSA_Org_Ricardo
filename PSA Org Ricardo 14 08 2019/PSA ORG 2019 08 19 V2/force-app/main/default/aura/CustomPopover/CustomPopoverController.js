({
    doInit: function (component, event, helper) {
        helper.calculatePlacement(component);
        helper.setIconValue(component, event, helper);
    },

    handleChangePlacement: function(component, event, helper) {
        helper.calculatePlacement(component);
        if(component.get('v.withClose') === true && component.get('v.showPopover') === true) {
            helper.showPopover(component, event, helper);
        }
    },
    
    handleChangeTheme: function(component, event, helper) {
        helper.setIconValue(component, event, helper);
    },
    
    handleChangeWithClose: function(component, event, helper) {
        if (component.get('v.withClose') === false) {
            helper.hidePopover(component, event, helper);
        }
    },
    
    handleClick: function(component, event, helper) {
        helper.forceHide(component, event, helper);        
    },
    
    onMouseLeaveElement: function(component, event, helper) {
        helper.hidePopover(component, event, helper);
    },
    
    onMouseLeaveOrBlurElement: function (component, event, helper) {
        helper.hidePopover(component, event, helper);
    },
    
    onMouseLeavePopover: function(component, event, helper) {
        helper.hidePopover(component, event, helper);
    },
    
    onMouseOverOrFocusElement: function (component, event, helper) {
        helper.showPopover(component, event, helper);
    },
    
    onMouseOverPopover: function(component, event, helper) {
        component.set('v.preventHide', true);
    }
})