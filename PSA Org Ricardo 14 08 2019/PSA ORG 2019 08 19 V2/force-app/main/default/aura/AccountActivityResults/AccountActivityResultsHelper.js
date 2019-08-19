({
  jsGetAvailableActivity : function(component, mode) {
    var source = component.get("v.user_input_obj.source");
    var source_usr = []

    // source user(s) formatted into an array
    if (typeof source.user_id == "string") {
        source_usr.push(source.user_id);
    } else {
        source.user_id.forEach(function(e) {
            source_usr.push(e.Id);
        });
    }

    // if filter fields are empty or blank space, do not send to server
    var city = this.isStringBlank(component.get("v.user_input_obj.filter.city")) ?
      null : component.get("v.user_input_obj.filter.city").trim();
    var postal_code = this.isStringBlank(component.get("v.user_input_obj.filter.postal_code")) ?
      null : component.get("v.user_input_obj.filter.postal_code").trim();

    debugger;
    var action = component.get("c.getAvailableActivity");

      action.setParams({
        "req": JSON.stringify({
          "vn_contract"     : source.vn_contract,
          "agent_contract"  : source.vn_contract,
          "user_id"         : source_usr,
          "city"            : city,
          "postal_code"     : postal_code
        })
      });

      debugger;
      action.setCallback(this, function(response) {
        this.handleAvailableActivity(component, response, mode);
      });

    $A.enqueueAction(action);
  },

  jsInsertTransferRequest : function(component) {
    component.set("v.config_obj.btn_next.disabled", true);
    component.set("v.config_obj.isLoading",true);

    var rec_ids = new Set();
    var rows = component.get("v.user_input_obj.selected_rows").forEach(
      function(e) {
        rec_ids.add(e.Id)
      }
    );

    debugger;

    var s = component.get("v.user_input_obj.source");
    if (typeof s.user_id != 'string') {
      s.user_id = null;
    }

    var action = component.get("c.insertTransferRequest");
    
      action.setParams({
        "req": JSON.stringify({
          "rows"        : Array.from(rec_ids),
          "source"      : s,
          "destination" : component.get("v.user_input_obj.destination")
        })
      });

      action.setCallback(this, function(response) {
        this.handleInsertTransferRequest(component, response);
      });

    $A.enqueueAction(action);
  },

  handleAvailableActivity: function(component, response, mode) {
    debugger;
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        component.set(
          "v.config_obj.data_table.rows",
          this.filterbyStatus(
            this.filterbyType(
              response.getReturnValue().payload,
              component.get("v.user_input_obj.filter")
            ),
            component.get("v.user_input_obj.filter")
          )
        );

        switch (mode) {
          // show table when manual selection is chosen
          case "manual":
            $A.createComponent( 
              "lightning:datatable",
              {
                "columns"             : component.getReference("v.config_obj.data_table.cols"),
                "data"                : component.getReference("v.config_obj.data_table.rows"),
                "keyField"            : "Id",
                "onrowselection"      : component.getReference("c.handleRowSelection"),
                "showRowNumberColumn" : true
              },
              function(e, status, errorMessage) {
                var body = [];
                switch (status) {
                  case "SUCCESS":
                    body.push(e);
                    component.set("v.config_obj.isLoading",false);
                    component.find("_modal_body").set("v.body", body);
                    break;
  
                  case "INCOMPLETE":
                    console.log("No response from server or client is offline.");
                    break;
      
                  case "ERROR":
                    console.log("Error: " + errorMessage)
                    break;
      
                  default:
                    break;
                }
              }
            );
            break;

          // select all returned records when mass tranfer is chosen
          case "auto":
            component.set(
              "v.user_input_obj.selected_rows",
              response.getReturnValue().payload
            );

            $A.createComponent(
              "aura:html",
              {
                tag             : "div",
                body            : response.getReturnValue().payload.length + " " + $A.get("$Label.c.CptMassTransferConfirmationMessage"),
                HTMLAttributes  : {
                    class       : "slds-align_absolute-center",
                    style       : "height: 33vh;"
                }
              },
              function(e, status, errorMessage) {
                var body = [];
                switch (status) {
                  case "SUCCESS":
                    body.push(e);
                    component.set("v.config_obj.isLoading",false);
                    component.find("_modal_body").set("v.body", body);
                    component.set("v.config_obj.btn_next.disabled", false);
                    break;
      
                  case "INCOMPLETE":
                    console.log("No response from server or client is offline.");
                    break;
      
                  case "ERROR":
                    console.log("Error: " + errorMessage)
                    break;
      
                  default:
                    break;
                }
              }
            );
            break;

          default:
            break;
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

  handleInsertTransferRequest: function(component, response) {
    var state = response.getState();
    debugger;
    switch (state) {
      case "SUCCESS":
        var rec_id = response.getReturnValue().payload;
        var nav_evt = $A.get("e.force:navigateToSObject");
          nav_evt.setParams({
            "recordId"      : rec_id,
            "slideDevName"  : "detail"
          });
        nav_evt.fire();
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

  isStringBlank: function(str) {
    return (!str || 0 === str.length || !str.trim());
  },

  filterbyType: function(lst, filter) {
    switch (filter.customer_type) {
      case '1': 
        return lst.filter(e => e.Type == 'B2C');
      case '2': 
        return lst.filter(e => e.Type == 'B2B');
      default:
        return lst;
    }
  },

  filterbyStatus: function(lst, filter) {
    switch (filter.customer_status) {
      case '1': 
        return lst.filter(e => e.Status == 'Customer');
      case '2': 
        return lst.filter(e => e.Status == 'Prospect');
      default:
        return lst;
    }
  }
})