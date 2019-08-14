({
  doInit : function(component, event, helper) {
    var aId = component.get("v.accountId");
    var action = component.get("c.getConsents");
      action.setParams({
        "aId": aId
      });

      action.setCallback(this, function(response) {
         
          helper.createModal(component, response);
      });

    $A.enqueueAction(action);
  },
    

})