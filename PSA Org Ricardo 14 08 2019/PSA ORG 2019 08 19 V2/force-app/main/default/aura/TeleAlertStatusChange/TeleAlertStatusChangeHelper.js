({
  getDataTableColumns : function() {
    var cols = [
      {
        "label"     : "Alert",
        "type"      : "button"
      },
      {
        "label"     : "Status",
        "type"      : "text",
        "fieldName" : "strDate"
      }
    ];
    return cols;
  },

  jsGetData: function(component) {
    var action = component.get("c.getData");
      action.setParams({
        "request": JSON.stringify({
          "record_id": component.get("v.recordId")
        })
      });

      action.setCallback(this, function(response) {
        this.handleResponse(component, response);
      });

      $A.enqueueAction(action);
    },


  handleResponse: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        component.set("v.data", response.getReturnValue().payload_data);
        component.set(
          "v.status",
          Object.values(response.getReturnValue().payload_picklist)
        );
        if (response.getReturnValue().payload_data != null && response.getReturnValue().payload_data != '') {
          component.set("v.defaultValue", response.getReturnValue().payload_data[0].telealertresultcode__c);
          if(response.getReturnValue().payload_data[0].telealertresultcode__c == 'Other'){
            this.getStepProperties(21);
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
        break;
    }
  },

  jsSaveData : function(component) {
    //debugger;
    component.set("v.showLoadingSpinner", true);
    var action = component.get("c.saveData");
    var code = component.get("v.resultCode");
    var label = component.get("v.resultLabel");
    var lstVehicleEvent = component.get("v.data");

    action.setParams({
        "recordId" : component.get("v.recordId"),
        "code" : code,
        "label" : label,
        "dealer" : component.get("v.input_obj.APVDealer__c"),
        "status" : component.get("v.input_obj.Status__c"),
        "lstVehicleEvent" : lstVehicleEvent
      });

    action.setCallback(this, function(response) {
      debugger;
      this.handleJsSaveDataResponse(component, response);
      component.set("v.showLoadingSpinner", false);
    });
  
    $A.enqueueAction(action);
  },

  handleJsSaveDataResponse : function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire()
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

  isValEmpty: function(element, index, array) {
    return element.telealertresultcode__c == "" || !element.telealertresultcode__c;
  },

  mapVehicleEventLabel: function(component) {
    let lst_vehicle_event = component.get("v.data");
    let map_status = component.get("v.status");

    lst_vehicle_event.forEach(e => {
      for (let i = 0; i < map_status.length; i++) {
        if (e.telealertresultcode__c == map_status[i].Code__c) {
          e.telealertresultlabel__c = map_status[i].MasterLabel;
          break;
        }
      }
    });

    //debugger;
    return lst_vehicle_event;
  },

  getStepProperties: function(step) {
    switch (step) {
      case 1: 
        return {
          "step"          : step,
          "btn_label"     : "Submit", 
          "btn_disabled"  : false,
          "progress_bar"  : "width: 100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            }
          ],
        }
      case 2:
        return {
          "step"          : step,
          "btn_label"     : "Next", 
          "btn_disabled"  : true,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ],
        }
      case 20:
        return {
          "step"          : step,
          "btn_label"     : "Submit", 
          "btn_disabled"  : false,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ],
        }
      case 3:
        return {
          "step"          : step,
          "btn_label"     : "Next",
          "btn_disabled"  : false,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ],
        }
      case 21:
        return {
          "step"          : 11,
          "btn_label"     : "Next",
          "btn_disabled"  : false,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ],
        }
      case 10:
        return {
          "step"          : step,
          "btn_label"     : "Submit", 
          "btn_disabled"  : true,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ]
        }
      case 11:
        return {
          "step"          : step,
          "btn_label"     : "Submit", 
          "btn_disabled"  : false,
          "progress_bar"  : "width:100%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            },
            {
              "class"     : "slds-progress__item slds-is-completed",
              "btn_class" : "slds-button slds-button_icon slds-button_icon slds-progress__marker slds-progress__marker_icon",
              "icon"      : true
            }
          ]
        }

      default :
        return {
          "step"          : 0,
          "btn_label"     : "Submit", 
          "btn_disabled"  : true,
          "progress_bar"  : "width: 0%",
          "progress_itm"  : [
            {
              "class"     : "slds-progress__item slds-is-active",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            },
            {
              "class"     : "slds-progress__item",
              "btn_class" : "slds-button slds-progress__marker",
              "icon"      : false
            }
          ],
        }
    }
  }
})