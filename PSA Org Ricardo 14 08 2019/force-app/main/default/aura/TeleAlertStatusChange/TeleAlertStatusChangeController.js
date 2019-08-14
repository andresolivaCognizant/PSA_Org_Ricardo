({
  doInit : function(component, event, helper) {
    component.set("v.nav", helper.getStepProperties(0));
    component.set("v.columns", helper.getDataTableColumns());
    component.set("v.input_obj", {"APVDealer__c" : null});
    helper.jsGetData(component);
  },

  closeButton : function(cmp, event, helper){
    $A.get("e.force:closeQuickAction").fire(); 
  },

  changeStatus : function(cmp, event, helper){
    event.preventDefault();
    var status = event.getParams().value;

    if (status == cmp.get("v.lds_record").fields.Status__c.value) {
      cmp.set("v.nav", helper.getStepProperties(0));
      return;
    }
    switch (status) {
      // new, taken into account, not reached, send to dealer
      case "1":
      case "2":
      case "4":
      case "6":
        cmp.set("v.nav", helper.getStepProperties(1));
        break;
      // appointment created
      case "3":
        cmp.set("v.input_obj.Status__c", status)
        var rows = cmp.get("v.data");
        var olb_id = cmp.get("v.lds_record").fields.OLBAppointmentID__c.value;
        if (olb_id && rows.length > 0) {
          cmp.set("v.input_obj.Status__c", status);
          cmp.set("v.nav", helper.getStepProperties(3));
          return;
        }
        cmp.set("v.nav", helper.getStepProperties(2));
        break;
      // discarded
      case "5":
        var rows = cmp.get("v.data");
        cmp.set("v.input_obj.Status__c", status);

        if(rows.length > 0) {
          cmp.set("v.nav", helper.getStepProperties(3));
          break;
        }
        cmp.set("v.nav", helper.getStepProperties(1));
        break;
      default: 
        cmp.set("v.nav", helper.getStepProperties(0));
      break;
    }
  },

  changeDealer : function(component, event, helper){
    var dealer = event.getParams().value;
    //debugger;
    if (dealer.length == 0) {
      component.set("v.nav", helper.getStepProperties(5));
      return;
    }
    component.set("v.nav", helper.getStepProperties(6));
    component.set("v.input_obj.APVDealer__c", dealer[0]);
  },

  handleClick : function(cmp, event, helper){
    var step = cmp.get("v.nav").step;

    if (step == 1) {
      // save record if no additional logic should be executed
      cmp.find("ltng_form").submit();
      $A.get("e.force:closeQuickAction").fire();
    }

    if (step == 20) {
      // save record if no additional logic should be executed
      cmp.find("ltng_Coments").submit();
      helper.jsSaveData(cmp);
    }

    if (step == 3) {
      var rows = cmp.get("v.data");
      if (rows.some(helper.isValEmpty)) {
        cmp.set("v.nav", helper.getStepProperties(10));
        return;
      }

      cmp.set("v.nav", helper.getStepProperties(11));
      var value = cmp.find("select").get("v.value");
      if (value == "11") {
        cmp.set("v.nav", helper.getStepProperties(21));
      }
      return;
    }

    if (step == 11) {
      var value = cmp.find("select").get("v.value");
      if (value == "11") {
        cmp.set("v.resultCode", value);
        cmp.set("v.resultLabel", 'Other');
        cmp.set("v.nav", helper.getStepProperties(20));
      } else {
        helper.jsSaveData(cmp);
      }
    }
    return;
  },

  onChange : function(component, event, helper) {
    var step = component.get("v.nav").step;
    var code = event.getSource().get("v.value"); 

    var map_status = component.get("v.status");
    var label;
    for (let i = 0; i <  map_status.length; i++) {
      if(map_status[i].Code__c == code){
        label = map_status[i].MasterLabel;
      }
    }

    component.set("v.resultCode", code);
    component.set("v.resultLabel", label);
    if (code == "11") {
      component.set("v.nav", helper.getStepProperties(21));
      return;
    }else {
      component.set("v.nav", helper.getStepProperties(11));
      return;
    }
  }

})