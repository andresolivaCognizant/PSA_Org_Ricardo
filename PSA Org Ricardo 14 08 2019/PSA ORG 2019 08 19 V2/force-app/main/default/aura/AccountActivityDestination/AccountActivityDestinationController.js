({
  doInit : function(component, event, helper) {
    helper.clearUserInput(component);
    helper.jsGetVnContractList(component);
  },

  handleSelectChange: function(component, event, helper) {
    var evt_source = event.getSource().get("v.name");
    switch (evt_source) {
      case "_vn_contract_number":
        helper.jsGetAgentContractList(component);
        helper.jsGetUserList(component, null);
        helper.isStepComplete(component);
        break;
      case "_agent_contract_number":
        helper.jsGetUserList(component, null);
        break; 
      case "_user_id":
        helper.isStepComplete(component);
    }
  },

  handleEvent: function(component, event, helper) {
      for (var key in event.getParams().message.source) {
        if (event.getParams().message.source[key] != "") {
          component.set("v.user_input_obj.source", event.getParams().message.source);
          helper.jsGetUserList(component, null);
          return;
        }
      }

      // clear component when source is empty
      component.set("v.user_input_obj.source", false);
      helper.clearUserInput(component);
      return;
  },

  handleClick: function(component, event, helper) {
    if (component.get("v.config_obj.locked")) {
      helper.clearUserInput(component);
    } else {
      component.set("v.config_obj.locked", true);
      component.set(
        "v.config_obj.next_btn",
        {
          "label"     : "Clear Selection",
          "disabled"  : false,
          "variant"   : "destructive"
        }
      );
    }

    var evt = $A.get("e.c:CustomerPortfolioTransferDestination");
      debugger;
      evt.setParams({"message" : component.get("v.user_input_obj")});
    evt.fire();
  }

})