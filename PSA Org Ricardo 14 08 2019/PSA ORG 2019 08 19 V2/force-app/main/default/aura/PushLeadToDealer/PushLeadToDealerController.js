({
  handleRecordUpdate : function(component, event, helper) {
    switch (event.getParams().changeType) {
      case "LOADED":
        var lds_record = component.get("v.lds_record");
        helper.jsAllocateLeads(component);
        break;

      case "CHANGED":
        break;

      default:
        break;
    }

    return;
  }
})