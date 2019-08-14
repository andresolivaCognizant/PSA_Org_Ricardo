({
    previousPage : function(component, event, helper) {
        var myEvent = component.getEvent("PageChange");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
    },
    nextPage : function(component, event, helper) {
       var myEvent = component.getEvent("PageChange");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();
    },
    firstPage : function(component, event, helper) {
        var myEvent = component.getEvent("PageChange");
        myEvent.setParams({ "direction": "first"});
        myEvent.fire();
    },
    lastPage : function(component, event, helper) {
        var myEvent = component.getEvent("PageChange");
        myEvent.setParams({ "direction": "last"});
        myEvent.fire();
    }
})