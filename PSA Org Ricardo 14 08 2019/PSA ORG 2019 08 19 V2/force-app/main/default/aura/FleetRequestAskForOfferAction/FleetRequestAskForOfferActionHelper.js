({
  handleSaveRecord : function( component, event, helper ){
    var obj = component.get( "v.oppFleetRequest" );
    
    obj.fields.StageName.value = "FR3";
    obj.fields.TECH_IsBhCallout__c.value = !obj.fields.TECH_IsBHCallout__c.value;

    component.find( "fleetRequest" ).saveRecord(
      $A.getCallback( 
        function( saveResult ){
          if( saveResult.state === "SUCCESS" || saveResult.state === "DRAFT" ){
            $A.get("e.force:closeQuickAction").fire();
            
            helper.showToast( "", $A.get( "$Label.c.FleetRequestAskForOfferSuccessMessage" ), "success", "dismissible" );
            
            $A.get("e.force:refreshView").fire();
            
          }else if ( saveResult.state === "INCOMPLETE" ){
            console.log( "User is offline, device doesn't support drafts." );
            
          }else if ( saveResult.state === "ERROR" ){
            console.log( "Problem saving record, error: " + JSON.stringify( saveResult.error ) );
            
            if( saveResult.error && saveResult.error[0] && saveResult.error[0].message ){
              component.set( "v.recordError", saveResult.error[0].message );
              
            }else if( saveResult.error && saveResult.error[0] && saveResult.error[0].pageErrors && saveResult.error[0].pageErrors[0] && saveResult.error[0].pageErrors[0].message ){
              component.set( "v.recordError", saveResult.error[0].pageErrors[0].message );
            }
            
            component.set( "v.hasError", true );
            
          }else{
            console.log( "Unknown problem, state: " + saveResult.state + ", error: " + JSON.stringify( saveResult.error ) );
          }
        }
       ) 
     );
  },

  handleSubmitRecord : function( component, event, helper ){
    var source = event.getSource().get("v.name");

    switch (source) {
      case '_btn_ws':
        var idOpp = component.get("v.recordId");	
        var action = component.get("c.SendRequestOffer");

        var btn_markup = {
          "name"      : '_btn_exit',
          "label"     : $A.get("$Label.c.FleetRequestAskForOfferFooterButtonClose"),
          "disabled"  : true
        };

        component.set("v.ui_obj.isLoading", true);
        component.set("v.ui_obj.btn", btn_markup);

        action.setParams({
          idOpp: idOpp
        });

        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS"){
            var serverResponse = response.getReturnValue();
            if (serverResponse.indexOf('OK')>=0) {
              //this.handleSaveRecord(component, event, helper);
              $A.get("e.force:closeQuickAction").fire();
              helper.showToast( "", $A.get( "$Label.c.FleetRequestAskForOfferSuccessMessage" ), "success", "dismissible" );
              $A.get("e.force:refreshView").fire();
            } else {
              component.set( "v.hasError", true );
              component.set( "v.recordError", serverResponse );
            }
          } else if (state === 'ERROR') {
            var errors = response.getError();
            if (errors) {
              if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
              }
            component.set( "v.hasError", true );
            } else {
              console.log("Unknown error");
              component.set( "v.hasError", true );
            }
          } else {
            console.log('Something went wrong, Please check with your admin');
            component.set( "v.hasError", true );
          }

          component.set("v.ServiceResponse", response.getReturnValue() );
          component.set("v.ui_obj.btn.disabled", false);
          component.set("v.ui_obj.isLoading", false);
          
        });

        $A.enqueueAction(action);
        break;
      case '_btn_exit':
        var dismiss_action = $A.get("e.force:closeQuickAction");
        dismiss_action.fire();
        break;
    }
  },

  showToast : function( msgTitle, msg, msgType, msgMode ) {
    var toastEvent = $A.get( "e.force:showToast" );
    var availableModes = "dismissible&pester&sticky";
    var availableTypes = "info&success&warning&error";
    
    toastEvent.setParams( {
      title : msgTitle,
      message: msg,
      duration: "5000",
      key: "info_alt",
      type: availableTypes.includes( msgType ) ? msgType : "info",
      mode: availableModes.includes( msgMode ) ? msgMode : "pester"
    } );

    toastEvent.fire();
  }
  
})