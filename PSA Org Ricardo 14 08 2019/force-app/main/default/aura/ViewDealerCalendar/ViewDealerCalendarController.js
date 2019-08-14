({
  init : function(component, event, helper) {

  },

  handleRecordUpdate : function(component, event, helper) {
    var event_params = event.getParams();

    switch (event_params.changeType) {
      case "LOADED":
        var lds_record = component.get("v.lds_record");
        debugger;

        if (null == lds_record.fields.CalculatedPOS__c.value) {
          helper.showDealerPrompt(component);
          return;
        }

        helper.showCalendar(component, lds_record.fields.CalculatedPOS__c.value);
        debugger;
        break;

      case "CHANGED":
        break;
      default:
        break;
    }

    return;

  }

})