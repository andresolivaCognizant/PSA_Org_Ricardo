({
    doInit: function(component, event, helper) {
        helper.getLeadRecord(component);
        helper.getLeadActivityCount(component);

    },

    handleEditClick: function(component, event, helper) {
        console.log("Start of LeadCardHeader.handleEditClick...");
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();
    },

    handleLeadConvertClick: function(component, event, helper) {
        console.log("Start of LeadCardHeader.handleLeadConvertClick...");
        var leadId = component.get("v.recordId");
        // GAS This doesn't work for quick actions.  I don't think open quick action is supported in LC yet
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ManualConversionQA",
            componentAttributes: {
                leadName: "lead name"
            }
        });
        evt.fire();
    },
})