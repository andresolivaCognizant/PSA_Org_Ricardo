({
    customHandler1: function(component, calledFrom) {
        console.log('Start of DynamicCardHeaderHelper.customHandler1...');
        // Add custom logic here 
        if (calledFrom == "LMAContainer") {
            var button1         = component.find("button1");
            var button1Value    = button1.get("v.value");
            var button1Label    = button1.get("v.label");
            
            if (button1Value != "My Team") {
                button1.set("v.label", $A.get("$Label.c.LeadAssignmentMyTeam"));
                button1.set("v.value", "My Team");
                var appEvent = $A.get("e.c:LMAToggleFilterByUserEvent");
                appEvent.setParams({
                    "filterByCurrentUser": true
                });
                appEvent.fire();
            } else {
                button1.set("v.label", $A.get("$Label.c.LeadAssignmentMyLeads"));
                button1.set("v.value", "My Leads");
                var appEvent = $A.get("e.c:LMAToggleFilterByUserEvent");
                appEvent.setParams({
                    "filterByCurrentUser": false
                });
                appEvent.fire();
            }
        }
    },
   
})