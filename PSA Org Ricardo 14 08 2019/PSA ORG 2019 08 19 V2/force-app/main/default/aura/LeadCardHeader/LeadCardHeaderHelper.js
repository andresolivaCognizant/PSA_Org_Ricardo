({
	getLeadRecord: function(component) {
        console.log('Start of LeadCardHeaderHelper.getLeadRecord...');
        var action = component.get("c.getLeadRecord");
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(':::response.getReturnValue: ' + response.getReturnValue());
                component.set('v.leadRecord', response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('Error getsObjectRecords (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    
    getLeadActivityCount: function(component) {
        console.log('Start of LeadCardHeaderHelper.getLeadActivityCount...');
        var action = component.get("c.getLeadActivityCount");
        var leadActivityCount = 0;
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            leadActivityCount = response.getReturnValue();
                console.log(':::response.getReturnValue: ' + leadActivityCount);
                component.set('v.leadActivityCount', leadActivityCount);
            } else if (state === "ERROR") {
                console.log('Error getLeadActivityCount (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
})