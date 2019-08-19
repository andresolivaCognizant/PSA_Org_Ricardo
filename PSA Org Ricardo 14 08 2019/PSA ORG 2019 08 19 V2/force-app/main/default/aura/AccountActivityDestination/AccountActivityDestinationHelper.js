({
  jsGetVnContractList: function(component) {
    var action = component.get("c.getVnContractList");
      action.setParams({
        "req": JSON.stringify({
          "rec_id": []
        })
      });

      action.setCallback(this, function(response) {
        this.handleVnContractList(component, response);
      });

    $A.enqueueAction(action);
  },

  jsGetAgentContractList: function(component) {
    var action = component.get("c.getAgentContractList");
      action.setParams({
        "req": JSON.stringify({
          "vn_contract": component.get("v.user_input_obj").destination.vn_contract
        })
      });

      action.setCallback(this, function(response) {
        this.handleAgentContractList(component, response);
      });

    $A.enqueueAction(action);
  },

  jsGetUserList: function(component, vn_contract) {
    if (
      vn_contract == null &&
      component.get("v.user_input_obj").destination.vn_contract == "" &&
      component.get("v.user_input_obj").destination.agent_contract == ""
    ) {
      component.set("v.config_obj.user_id.options", []);
      component.get("v.user_input_obj").detination.user_id = "";
      this.isStepComplete(component);
      return;
    }

    var action = component.get("c.getUserList");
      action.setParams({
        "req": JSON.stringify({
          "vn_contract": vn_contract == null ? component.get("v.user_input_obj").destination.vn_contract : vn_contract
        })
      });

      action.setCallback(this, function(response) {
        this.handleUserList(component, response);
      });

    $A.enqueueAction(action);
  },

  clearUserInput: function(component) {
    var o = {
      "destination" : {
        "vn_contract"     : "",
        "agent_contract"  : "",
        "user_id"         : ""
      }
    };

    var btn = {
      "label"     : "Select",
      "disabled"  : true
    };

    component.set("v.config_obj.vn_contract.disabled", true);
    component.set("v.config_obj.agent_contract.disabled", true);
    component.set("v.config_obj.user_id.disabled", true);

    component.set("v.user_input_obj.destination", o.destination);
    component.set("v.config_obj.next_btn", btn);
    component.set("v.config_obj.locked", false);

    this.jsGetVnContractList(component);
    return;
  },

  isStepComplete : function(component) {
    var d = component.get("v.user_input_obj").destination.user_id;
    if (d) {
      component.set("v.config_obj.next_btn.disabled", false);
        return;
      }
    component.set("v.config_obj.next_btn.disabled", true);
  },

  getAccessPermission : function(component) {
    var u = component.get("v.config_obj.running_user");

    var FULL_ACCESS_PROFILES = new Set([
      "System Administrator",
      "Subsidiary_MKT_Sales_Manager"
    ]);

    var PARTIAL_ACCESS_PROFILES = new Set([
      "Sales_Manager",
      "Sales_Manager_Agent",
      "Aftersales_Manager"
    ]);

    if (FULL_ACCESS_PROFILES.has(u.Profile.Name)) {
      return "FULL";
    }

    if (PARTIAL_ACCESS_PROFILES.has(u.Profile.Name)) {
      return "PARTIAL";
    }

    return "NONE"
  },

  handleVnContractList: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":

        var vn_contract_val = new Set();
        var agent_contract_val = new Set();

        var u = response.getReturnValue().payload.user;
        component.set("v.config_obj.running_user", u);
        var p = this.getAccessPermission(component);

        switch (p) {
          case "FULL" :
          for (var a of response.getReturnValue().payload.data) {
            vn_contract_val.add(a.VNContractNumber__c)
          }

            component.set("v.config_obj.vn_contract.options", Array.from(vn_contract_val));
            component.set("v.config_obj.vn_contract.disabled", false);
            component.set("v.config_obj.agent_contract.disabled", false);
            component.set("v.config_obj.user_id.disabled", false);
            break;

          case "PARTIAL" :
            component.set("v.config_obj.vn_contract.disabled", true);
            component.set("v.config_obj.agent_contract.disabled", true);
            component.set("v.config_obj.user_id.disabled", false);

            var vn_contract = "";
            var agent_contract = "";

            if (null != u.VNRRDICode__c) {
              vn_contract = u.VNRRDICode__c;
              vn_contract_val.add(u.VNRRDICode__c);
              component.set("v.config_obj.vn_contract.options", Array.from(vn_contract_val));
            }

            if (null != u.RAorAgentRRDICode__c) {
              agent_contract = u.RAorAgentRRDICode__c;
              agent_contract_val.add(u.RAorAgentRRDICode__c);
              component.set("v.config_obj.agent_contract.options", Array.from(agent_contract_val));
            }

            this.jsGetUserList(component, u.VNRRDICode__c);

            window.setTimeout($A.getCallback(function() {
              component.set("v.user_input_obj.destination.vn_contract", vn_contract)
              component.set("v.user_input_obj.destination.agent_contract", agent_contract);
            }));

            break;

          default :
            component.set("v.config_obj.vn_contract.disabled", true);
            component.set("v.config_obj.agent_contract.disabled", true);
            component.set("v.config_obj.user_id.disabled", true);
        }

        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  },

  handleAgentContractList: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        var agent_contract_val = new Set();

        for (var a of response.getReturnValue().payload) {
          agent_contract_val.add(a.SubscriberId__r.AgentContractNumber__c)
        }
        
        component.set(
          "v.config_obj.agent_contract.options",
          Array.from(agent_contract_val)
        )

        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  },

  handleUserList: function(component, response) {
    var state = response.getState();

    switch (state) {
      case "SUCCESS" :
        // filter users returned by the server when an agent contract has been chosen
        var lst = [];

        if (
          component.get("v.user_input_obj.destination.agent_contract") &&
          "" != component.get("v.user_input_obj.destination.agent_contract")
        ) {
          lst = response.getReturnValue().payload.filter(function(u) {
            return u.RAorAgentRRDICode__c == component.get("v.user_input_obj.destination.agent_contract");
          });
        } else {
          lst = response.getReturnValue().payload;
        }

        var usr = component.get("v.user_input_obj.source.user_id");

        // available destination user list excluding source (if only one selected)
        var lst_usr = [];

        if (usr && typeof usr === "string") {
          lst_usr = lst.filter(function(e) {
            return e.Id != usr;
          });
        } else {
          lst_usr = lst;
        }

        component.set("v.config_obj.user_id.options", lst_usr);
        this.isStepComplete(component);
        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  }
})