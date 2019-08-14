({
  doInit : function(component, event, helper) {
    helper.clearUserInput(component);
  },

  handleSelectChange: function(component, event, helper) {
    var evt_source = event.getSource().get("v.name");

    debugger;
    switch (evt_source) {
      case "_vn_contract_number":
        helper.jsGetAgentContractList(component);
        helper.jsGetUserList(component, null);
        break;
      case "_agent_contract_number":
        helper.jsGetUserList(component, null);
        break; 
      case "_user_id" :
        helper.isStepComplete(component);
    }
  },

  handleClick: function(component, event, helper) {
    // lock selection when a source is chosen
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

    if (
      component.get("v.user_input_obj.source.user_id") == "" &&
      component.get("v.user_input_obj.source.vn_contract") != ""
    ) {
      // auto select user when no more potential sources found
      if (component.get("v.config_obj.user_id.options").length == 1) {
        component.set(
          "v.user_input_obj.source.user_id",
          component.get("v.config_obj.user_id.options")[0].Id
        );
      } else {
          component.set(
            "v.user_input_obj.source.user_id",
            component.get("v.config_obj.user_id.options")
          );
      }
    }

    var evt = $A.get("e.c:CustomerPortfolioTransferSource");
      debugger;
      evt.setParams({"message" : component.get("v.user_input_obj")});
    evt.fire();

    var evt2 = $A.get("e.c:CustomerPortfolioTransferDestination");
      evt2.setParams({"message" : component.get("v.user_input_obj")});
    evt2.fire();
  }
})