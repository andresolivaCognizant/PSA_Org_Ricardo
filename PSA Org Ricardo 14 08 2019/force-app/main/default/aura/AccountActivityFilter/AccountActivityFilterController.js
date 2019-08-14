({
  doInit : function(component, event, helper) {
    helper.setDefaults(component);
  },

  handleEvent: function(component, event, helper) {
    // skip actions when event is not intended for
    // this component (activity selection mode is informed)
    if (event.getParams().message.mode) {
      return;
    }

    if (event.getParams().message.destination.user_id) {
      component.set("v.config_obj.source", event.getParams().message.source);
      component.set("v.config_obj.destination", event.getParams().message.destination);
      return;
    }
    
    component.set("v.config_obj.source", false);
    component.set("v.config_obj.destination", false);
    return;
  },

  handleToggleClick: function(component, event, helper) {
    if (event.currentTarget.checked) {
      component.set("v.config_obj.search_btn.disabled", true);
      component.set("v.config_obj.transfer_btn.disabled", false);
      component.set("v.config_obj.transfer_btn.variant", "success");
      return;
    }

    component.set("v.config_obj.search_btn.disabled", false);
    component.set("v.config_obj.transfer_btn.disabled", true);
    component.set("v.config_obj.transfer_btn.variant", "brand");
    return;
  },

  handleClick: function(component, event, helper) {
    var mode = component.get("v.config_obj.search_btn.disabled") ? "auto" : "manual";
    var evt = $A.get("e.c:CustomerPortfolioTransferDestination");
      evt.setParams({
        "message" : {
          "mode"        : mode,
          "source"      : component.get("v.config_obj.source"),
          "destination" : component.get("v.config_obj.destination"),
          "filter"      : component.get("v.user_input_obj.filter")
        }
      });
    evt.fire();
  }

})