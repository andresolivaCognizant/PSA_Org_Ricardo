({
    handleOnClick1: function(component, event, helper) {        
        var customHandler1          = component.get("v.customHandler1");     
        if (customHandler1) {
            var calledFrom          = component.get("v.calledFrom");
        	helper.customHandler1(component, calledFrom);
        } else {
            var navigateToRecord    = component.get("v.navigateToRecord1");
            var navigateToURL       = component.get("v.navigateToURL1");
            if (navigateToURL != null) {
                var urlEvent        = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": navigateToURL,
                    "isredirect": true
                });
                urlEvent.fire();
            } else if (navigateToRecord != null) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": navigateToRecord,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        }
    },
    customHandle1: function(component, event, helper) {
        var navigateToRecord    = component.get("v.navigateToRecord1");
        var navigateToURL       = component.get("v.navigateToURL1");

        if (navigateToURL != null) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": navigateToURL,
                "isredirect": true
            });
            urlEvent.fire();
        } else if (navigateToRecord != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": navigateToRecord,
                "slideDevName": "detail"
            });
            navEvt.fire();
        }
    },
})