({
  doInit : function(component, event, helper) {
    //component.find("pop_up_modal_container").openModal();
    var action = component.get("c.getAppointmentInfo");
      action.setParams({
        "req": JSON.stringify({
          "ids": []
        })
      });
      action.setCallback(this, function(response) {
        helper.hasChanged(component, response, null);
        var js_action = component.get("c.setPolling");
        $A.enqueueAction(js_action);
      });
    $A.enqueueAction(action);
  },

  setPolling : function(component, event, helper) {
    var t = window.setInterval(
      $A.getCallback(function() { 
        console.log("appointment polling");
        var action = component.get("c.getAppointmentInfo");
          action.setParams({
            "req": JSON.stringify({
              "ids": Object.keys(component.get("v.trackedRecords"))
            })
          });
          action.setCallback(this, function(response) {
            helper.hasChanged(component, response, t);
           });
        $A.enqueueAction(action);
        }),
      10000
    );
  }

})