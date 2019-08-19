({
  init: function(component, event, helper) {

    var columns = [
      {
        label:      'Name',
        fieldName:  'Name',
        type:       'text'
      },
      {
        label:      'Type',
        fieldName:  'sObjectType',
        type:       'text'},
      {
        label:      'City',
        fieldName:  'City',
        type:       'text'
      },
      {
        label:      'Postal Code',
        fieldName:  'PostalCode',
        type:       'text'
      },
      {
        label:      'Owner',
        fieldName:  'Owner',
        type:       'text'
      },
      {
        label:      'Customer Type',
        fieldName:  'Type',
        type:       'text'
      },
      {
        label:      'Customer Status',
        fieldName:  'Status',
        type:       'text'
      }
    ];

    component.set("v.config_obj.data_table.cols", columns);
    component.set("v.config_obj.data_table.rows", []);
    component.set("v.user_input_obj.selected_rows", []);
    component.set("v.config_obj.btn_next.disabled", true);
  },

  handleEvent: function(component, event, helper) {
    var mode = event.getParams().message.mode;

    if (mode) {
      component.set("v.config_obj.show", true);
      component.set("v.user_input_obj.source", event.getParams().message.source);
      component.set("v.user_input_obj.destination", event.getParams().message.destination);
      component.set("v.user_input_obj.filter", event.getParams().message.filter);
      helper.jsGetAvailableActivity(component, mode);
    }
  },

  handleRowSelection: function(component, event, helper) {
    if (event.getParam('selectedRows').length > 0) {
      component.set("v.config_obj.btn_next.disabled", false); 
    } else {
      component.set("v.config_obj.btn_next.disabled", true);
    }

    component.set(
      "v.user_input_obj.selected_rows",
      event.getParam('selectedRows')
    );
  },

  handleClick: function(component, event, helper) {
    var s = event.getSource().get("v.name");
    switch (s) {
      case "_btn_next":
        helper.jsInsertTransferRequest(component);
        break;
      case "_btn_close":
      case "_btn_cancel":
        component.set("v.config_obj.show", false);
        component.set("v.config_obj.isLoading",true);
        component.set("v.user_input_obj.selected_rows", []);
        break;
    }
  },
})