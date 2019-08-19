({
  jsGetUserData : function(component) {
    var action = component.get("c.getUserData");

      action.setCallback(this, function(response) {
        this.handleGetUserDataResponse(component, response);
      });

    $A.enqueueAction(action);
  },

  handleGetUserDataResponse : function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        var server_res = response.getReturnValue().payload;
        switch (server_res[0].Profile.Name) {
          case 'CEC_Dealer_Ext':
          case 'CEC_Dealer_Int':
            component.set(
              "v.cols_fields",
              "LeadRequestType__c,Name,LeadSource,ProductCustomerInterest__c,TECH_CustomerTypeLabel__c,CECTreatmentPriority__c,CECRemainingTreatmentTime__c,OwnerName__c"
            );
            break;
          default:
            component.set(
              "v.cols_fields",
              "LeadRequestType__c,Name,LeadSource,ProductCustomerInterest__c,TECH_CustomerTypeLabel__c,TreatmentPriority__c,RemainingTreatmentTime__c,OwnerName__c"
            );
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
  }

})