({
  showCalendar : function(component, dealer_id) {
    $A.createComponent(
      "c:DealerSalesmenCalendars",
      {
        "dealer_id" : dealer_id
      },
      function(element, status, error_msg) {
        switch (status) {
          case "SUCCESS":
            var body = [];
            body.push(element);
            component.set("v.ui_obj.isLoading", false);
            component.find("body_container").set("v.body", body);
            break;
        
          default:
            break;
        }
      }
    );
  },

  showDealerPrompt : function(component){
    $A.createComponent(
      "aura:html",
      {
        tag             : "div",
        body            : "Please select a Dealer to be able to see Salesmen calendars.",
        HTMLAttributes  : {
          class : "slds-align_absolute-center",
          style : "height: 300px;"
        }
      },
      function(element, status, error_msg) {
        switch (status) {
          case "SUCCESS":
            var body = [];
            body.push(element);
            debugger;
            component.set("v.ui_obj.isLoading", false);
            component.find("body_container").set("v.body", body);
            break;

          default:
            break;
        }
      }
    );
  }
})