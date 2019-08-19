({
  jsAllocateLeads: function(component) {
    var action = component.get("c.allocateLeads");
      action.setParams({
        "request": JSON.stringify({
          "lst_ids": [component.get("v.recordId")]
        })
      });

      action.setCallback(this, function(apex_response) {
        this.handleAllocateLeads(apex_response, component);
      });

      $A.enqueueAction(action);
  },

  jsUpdateLeads: function(component, lst_leads) {
    var action = component.get("c.updateLeads");
      action.setParams({
        "request": JSON.stringify({
          "lst_leads": lst_leads
        })
      });

      action.setCallback(this, function(apex_response) {
        this.handleUpdateLeads(apex_response, component);
      });

      $A.enqueueAction(action);
  },

  handleAllocateLeads: function(apex_response, component) {
    switch (apex_response.getState()) {
      case "SUCCESS":
        if (apex_response.getReturnValue().hasError) {
          this.showErrorMessage(component);
          return;
        }

        var old_o = component.get("v.lds_record.fields.OwnerId.value");
        var new_o = apex_response.getReturnValue().payload[component.get("v.recordId")].OwnerId;

        if (old_o == new_o) {
          this.showErrorMessage(component);
          return;
        }

        this.jsUpdateLeads(
          component,
          Object.values(apex_response.getReturnValue().payload)
        );
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get("e.force:refreshView").fire()
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
        this.showErrorMessage(component);
        break;
    }
  },

  handleUpdateLeads: function(apex_response, component) {
    switch (apex_response.getState()) {
      case "SUCCESS":
        if (apex_response.getReturnValue().hasError) {
          this.showErrorMessage(component);
          return;
        }

        debugger;
        // show success message
        console.log('Lead Updated');
        this.showSuccessMessage(
          component,
          apex_response.getReturnValue().payload.map_owner[
            apex_response.getReturnValue().payload.map_lead[component.get("v.recordId")].OwnerId
          ]
        )
        // $A.get("e.force:closeQuickAction").fire();
        // $A.get("e.force:refreshView").fire()
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
        // show error
        break;
    }
  },

  showErrorMessage: function(component) {
    component.set(
      "v.ui_obj", 
      {
        "isLoading" : false,
        "msg"       : $A.get("$Label.c.PushToDealerError")
      }
    );
  },

  showSuccessMessage: function(component, owner_obj) {
    component.set(
      "v.ui_obj", 
      {
        "isLoading" : false,
        "msg"       : $A.get("$Label.c.PushToDealerSuccess") + ' ' + owner_obj.Name + '.'
      }
    );
  }
  
})