({
  assignCase : function(component,event,caseId) {
    var action = component.get("c.asignCaseToSelf");
    action.setParams({
      caseId : caseId
    });

    // set call back 
     action.setCallback(this, function(response) {
      // store the response  
      var assigned = response.getReturnValue();
      var state = response.getState();
      if (state === "SUCCESS") {
        if (assigned) {
          component.set("v.showLoadingSpinner", false);
          component.set("v.asigned", true);
        }
      }
    });
    // enqueue the action
    $A.enqueueAction(action);
  }
})