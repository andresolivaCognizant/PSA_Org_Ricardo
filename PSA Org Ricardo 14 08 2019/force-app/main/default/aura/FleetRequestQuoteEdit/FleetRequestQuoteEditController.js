({
  handlerRecordUpdate : function(component, event, helper) {
    var changeType = event.getParams().changeType;
    switch (changeType) {
      case 'LOADED' :
        var rec = component.get("v.record");
        var record_type = rec.fields.RecordType.value.fields.DeveloperName.value;
        var opportunity_stage = rec.fields.SBQQ__Opportunity2__r.value.fields.StageName.value;
        var edit_stages = new Set([
          "FR1",
          "FR4"
        ]);

        if (record_type == "FleetRequestQuote" && edit_stages.has(opportunity_stage)) {
          component.set("v.isDisabled", false);
        }
        break;
      default :

    }
  }
})