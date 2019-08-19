({
  hasChanged : function(component, response, timer_id) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        var old_map = component.get("v.trackedRecords");
        var new_map = response.getReturnValue();

        // do nothing if no records are returned by the server
        if (Object.keys(new_map).length < 1) {
          break;
        }

        // load atrribute on first run
        if (Object.keys(old_map).length < 1) {
          component.set("v.trackedRecords", new_map);
          break;
        }

        // search for changes in the appointments' status
        for (var rec_id in old_map) {
          if (new_map.hasOwnProperty(rec_id)) {

            if (
              old_map[rec_id].AppointmentStatus__c != new_map[rec_id].AppointmentStatus__c &&
              new_map[rec_id].AppointmentStatus__c == '1'
            ) {
              this.insertModal(component, new_map[rec_id].Driver__c)
                if (timer_id) {
                  clearInterval(timer_id);
                }
              break;
            }
          }
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
    }
  },

  insertModal: function(component, account_id){
    $A.createComponent(
      "c:ConsentsPopUpModal",
      {
        "accountId": account_id
      },
      function(e, status, errorMessage) {
        var body = []; 
        if (status === "SUCCESS") {
          body.push(e);
          component.find("consents_modal_container").set("v.body", body);
        }
        else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.")
          // Show offline error
        }
        else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  }

})