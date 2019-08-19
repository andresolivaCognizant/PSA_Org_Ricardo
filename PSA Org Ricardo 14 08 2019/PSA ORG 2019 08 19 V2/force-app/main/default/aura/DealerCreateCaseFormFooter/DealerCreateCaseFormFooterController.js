({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    handleSave : function(component, event, helper) {
        //Fire event to submit the form
        var appEvent = $A.get("e.c:DealerCreateCaseEvent");
        appEvent.fire();
    }
})