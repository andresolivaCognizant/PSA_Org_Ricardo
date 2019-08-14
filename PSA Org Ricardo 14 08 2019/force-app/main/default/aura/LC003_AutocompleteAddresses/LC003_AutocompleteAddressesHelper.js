({
     displayOptionsLocation: function (component, searchKey , Language) {
        var action = component.get("c.getAddressAutoComplete");
        action.setParams({
            "input"		: searchKey,
            "language"	: Language,
            "types"		: ''//'(regions)'
        });
 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                var predictions = options.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc =[];
                        for(var j=0;j<predictions[i].terms.length;j++){                  
                            bc.push(predictions[i].terms[j].offset , predictions[i].terms[j].value );
                        }
                        addresses.push({
                                value: predictions[i].types[0],
                                PlaceId: predictions[i].place_id,
                                locaval: bc,
                                label: predictions[i].description                              
                        });
                    }                    
                    component.set("v.filteredOptions", addresses);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getRouteOptionDetails: function(component,placeid, Language){
        var self = this;       
        var action1 = component.get("c.getAddressDetails");
        action1.setParams({
            "PlaceId"   : placeid,
            "language"  : Language
        });
 
        action1.setCallback(this, function (response) {
            var state = response.getState();
            console.log('State: ' + state);
            if (state === "SUCCESS") {
                var options 	= JSON.parse(response.getReturnValue());
                var Addressdet 	= options.result;
                var o 			= Addressdet["address_components"]; // value2
                // Variables to extract from response
				var street 		= Addressdet.name;
				var city 		= '';
				var state 		= '';
				var postcode 	= '';
				var country 	= '';
 
				// Get each component of the address from the place details
				// and fill the corresponding field on the form.
				var addresses = [];
				for (var prop in o) {
					// The Google address type
					var addressType = o[prop].types[0];
					// Set address variables
					if (addressType == 'street_number') {
                        street = o[prop]['long_name'];
                    }
					else if (addressType == 'route') {
						street =  o[prop]['long_name'] + ' ' + street;
					}
					else if (addressType == 'locality') {
						city = o[prop]['long_name'];
					}
					else if (addressType == 'administrative_area_level_1') {
						state = o[prop]['long_name'];
					}
					else if (addressType == 'administrative_area_level_2') {
						state = o[prop]['long_name'];
					}
					else if (addressType == 'country') {
						country = o[prop]['long_name'];
					}
					else if (addressType == 'postal_code') {
						postcode = o[prop]['long_name'];
					}
				}
            	addresses.push({street:street,city:city,state:state,country:country,postcode:postcode});
            	component.set("v.addressdetails", addresses);
            	self.updateAddress(component);
            }
     
        });
        $A.enqueueAction(action1);
         
    },
    // openListbox: function (component, searchKey) {
    //     var searchLookup = component.find("searchLookup");
 
    //     if (typeof searchKey === 'undefined' || searchKey.length < 3){
    //         $A.util.addClass(searchLookup, 'slds-combobox-lookup');
    //         $A.util.removeClass(searchLookup, 'slds-is-open');
    //         return;
    //     }
    //     $A.util.addClass(searchLookup, 'slds-is-open');
    //     $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
    // },
    clearComponentConfig: function (component) {
        var searchLookup = component.find("searchLookup");
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
 
        component.set("v.selectedOption", null);
        component.set("v.searchKey", null);

        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_right');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_left');
    },
    updateAddress : function (component){
    	var address = component.get("v.addressdetails")
  		var action 	= component.get("c.setAddressDetails");
        action.setParams({
            "RecordId"	 : component.get("v.recordId"),
            "lstAddress" : address
        }); 
        action.setCallback(this, function (response) {
             
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
		        resultsToast.setParams({
		            "title": "Address Updated",
		            "message": "The address was updated."
		        });
		        // Update the UI: close panel, show toast, refresh account page
		        $A.get("e.force:closeQuickAction").fire();
		        resultsToast.fire();
		        $A.get("e.force:refreshView").fire();
            }
     		else{
     			console.log(' Error ');
     		}
        });
        $A.enqueueAction(action);
         
    },
    closeTagClass : function (component, sName){
        var forManage = component.find(sName);
        $A.util.addClass(forManage, 'slds-is-close');
        $A.util.removeClass(forManage, 'slds-is-open'); 
       
    },
    openTagClass : function (component, sName){
        var forManage = component.find(sName);
        $A.util.addClass(forManage, 'slds-is-open');
        $A.util.removeClass(forManage, 'slds-is-close'); 
       
    }
})