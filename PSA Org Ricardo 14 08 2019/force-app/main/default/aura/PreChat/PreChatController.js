({
    /**
    * On initialization of this component, set the prechatFields attribute and render
    prechat fields.
    * @param component  - The component for this state.
    * @param event 		- The Aura event.
    * @param helper 	- The helper for this state.
    */
    onInit: function (component, event, helper) {
        // Get prechat fields defined in setup using the prechatAPI component.
        var prechatFields = component.find("prechatAPI").getPrechatFields();
        component.set('v.prechatFieldComponentsCopy', prechatFields);
        
        var currentUrl 			= new URL(window.location.href);
		var languageAttribute 	= currentUrl.searchParams.get("language");
        // If it's in an internal web, we must get the info from the settings.
        let bIsExternal = false;
		if($A.util.isUndefinedOrNull(languageAttribute)){
            bIsExternal = true;
        }
        component.set('v.isExternal', bIsExternal);
        var datesToShow = [];   
        for (var i = 0; i < prechatFields.length;i++){
            // Start change 29/03/2019: Hidde First and Last Name //
            if(prechatFields[i].type === "inputSplitName"){
                prechatFields[i].className 	= prechatFields[i].className + " slds-hidden";
                prechatFields[i].label 		= '';
            }
            // End change 29/03/2019 //
            if (prechatFields[i].name !== "Brand__c" && prechatFields[i].name !== "Subject"
                && prechatFields[i].name !== "Country__c" && prechatFields[i].name !== "Reason" 
                 && prechatFields[i].name !== "Email" && prechatFields[i].name !== "Language__c"){
                datesToShow.push(prechatFields[i]);
            }
        }
        // Get prechat field types and attributes to be rendered.
        var prechatFieldComponentsArray = helper.getPrechatFieldAttributesArray(datesToShow);
        
        // Make asynchronous Aura call to create prechat field components.
        $A.createComponents(
            prechatFieldComponentsArray,
            function (components, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set("v.prechatFieldComponents", components);
                }
            }
        );
    },
    /**
    * Event which fires when start button is clicked in prechat.
    *
    * @param component  - The component for this state.
    * @param event 		- The Aura event.
    * @param helper 	- The helper for this state.
    */
    handleStartButtonClick: function (component, event, helper) {
        helper.onStartButtonClick(component);
    },
});