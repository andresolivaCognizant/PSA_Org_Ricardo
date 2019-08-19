({
	
	doInit: function(component, event, helper) {
		
		// Prepare the action to load the record 
		helper.getRecordDetails(component,event);
		helper.getUserDetails(component,event);
		
		/* var flow = component.find("flowConsent");
		debugger;
		var inputVariables = [
			{
				name : 'ContactID',
				type : 'String',
				value : ($A.util.isUndefinedOrNull(component.get("v.idCnt")) || $A.util.isEmpty(component.get("v.idCnt"))) ? component.get("v.recordId") : component.get("v.idCnt")
			}
		];
		flow.startFlow("NewConsentWizard", inputVariables); */
		
		//si pais <> de DZ o PL lanzar evento standard para levantar formulario estandar del resto de paises
	},
	clickReimbursed : function(component, event, helper) {
		// console.log('sId :  clickReimbursed');
	},
	handleCancel: function(component, event, helper) {
		window.history.back();
		//$A.get("e.force:closeQuickAction").fire();
		//console.log('sId : ' + sId);
	},
	handlePrint: function(component, event, helper){
		window.print();
		
				   /*var fireEvent = $A.get("e.lightning:openFiles");

					fireEvent.fire({
						recordIds: ['0695E000000aQrrQAE']
					});*/
		
		/*document.getElementById("noprint").style.visibility = "hidden";
		document.getElementById("CPL").style.visibility = "visible";
		window.print();
		
		var divProcesoReg=component.find("noprint");
		$A.util.addClass(divProcesoReg,"slds-hide");
		
		divProcesoReg=component.find("CPL");
		$A.util.addClass(divProcesoReg,"slds-show");
		
		window.print();*/
		//var pc = component.find("CPL");
		//var pt = pc.getElement().innerHTML;
		//window.document.execCommand('print',true,pt);
		/*var pc = component.find("CPL");
		var pt = pc.getElement().innerHTML;
		window.document.execCommand('print',true,pt);
		
		var pc = document.getElementById("CPL");
		helper.printElement(pc);    
		window.print();*/
		//helper.printDiv(component, event);
		

	},
	handleSave: function(component, event, helper) {
		var sId             = event.getSource().getLocalId();
		var sRecord 		= component.get("v.idCnt");
		var country 		= component.get("v.country");
		//console.log('vRecordId: ' + sRecordId);
		// if (sId=='buttonCancelRole') {
		//     //component.set("v.selectedRecordId","");
		// }else if (sId=='buttonCancelRel'){
		//     //component.set("v.selectedRecordId","");
		// } else{
		//     //component.set("v.selectedRecordId","");
		// }
		
		var saveConsentAction = component.get("c.saveConsent");
			saveConsentAction.setParams({
				"consent":    component.get("v.newConsent"),
				//"accountId":  sRecord.PersonContactId,
				"accountId":  sRecord,
				"sCountry":   country, 
				"C1": (country=='DZ')?component.get("v.consentDealerDZD"):false,
				"C2": (country=='DZ')?component.get("v.consentBrandDZD"):false,
				"C3": (country=='PL')?component.get("v.consentC3"):false,
				"C4": (country=='PL')?component.get("v.consentC4"):false,
				"C5": (country=='PL')?component.get("v.consentC5"):false,
				"C6": (country=='PL')?component.get("v.consentC6"):false,
				"C7": (country=='PL')?component.get("v.consentC7"):false,
				"C8": (country=='PL')?component.get("v.consentC8"):false,
				"C9": (country=='PL')?component.get("v.consentC9"):false,
				"C10": (country=='PL')?component.get("v.consentC10"):false,
			});

			// Configure the response handler for the action
			saveConsentAction.setCallback(this, function(response) {
				var state = response.getState();
				if(state === "SUCCESS") {

					// Prepare a toast UI message
					var resultsToast = $A.get("e.force:showToast");
					resultsToast.setParams({
						"title": "Consent Saved",
						"type": "success",
						"duration": 3000,
						"message": "The new Consent was created."
					});

					// Update the UI: close panel, show toast, refresh account page
					//$A.get("e.force:closeQuickAction").fire();
					resultsToast.fire();
					//$A.get("e.force:refreshView").fire();
					setTimeout(function(){
						window.history.back();
					}, 3000);
					
				}
				else if (state === "ERROR") {
					console.log('Problem saving Consent, response state: ' + state);
				}
				else {
					console.log('Unknown problem, response state: ' + state);
				}
			});

			// Send the request to create the new contact
			$A.enqueueAction(saveConsentAction);
	},
	flowStatusChange: function(cmp, event, helper) {
		const status = event.getParam('status');

		if(status === 'FINISHED'){

			helper.handleFlowFinish(cmp, event);
			
		}

		// If flow restarts or changes, and skipFlag is true, go to next Parent flow screen
		if(cmp.get('v.skipFlowFlag')){

			let navigate = cmp.get('v.navigateFlow');
			if(navigate){
				navigate("NEXT");
			}
			
		}
	}
})