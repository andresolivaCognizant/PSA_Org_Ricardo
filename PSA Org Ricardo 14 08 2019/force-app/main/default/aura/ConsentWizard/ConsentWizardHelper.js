({
	getRecordDetails : function(component, objName, event){
		var recId = component.get("v.recordId");
		
		if (recId === null || recId === undefined || recId === ""){
			var urlRecordId				= window.location.search.substring( 1 );

			if( urlRecordId != undefined && urlRecordId != "" ){
				/* BEGIN - Manuel Medina - C1STAGILE-9666 - New logic to allow get record id from url from "?value" or "?key=value?" - 10052019 */
				//component.set( "v.recordId", urlRecordId.split( "=" )[ 1 ] );
				component.set( "v.recordId", urlRecordId.split( "=" ).length == 1 ? urlRecordId.split( "=" )[ 0 ] : urlRecordId.split( "=" )[ 1 ] );
				/* END - Manuel Medina - 10052019 */
			}
		}
		
		var action = component.get("c.getRecordDetails");
		
		action.setParams({"objectId": component.get("v.recordId")});

		// Configure response handler
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS") {
				var getRecordDetails = response.getReturnValue();
				component.set("v.name", getRecordDetails.name);
				component.set("v.firstname", getRecordDetails.firstName);
				component.set("v.lastname", getRecordDetails.lastName);
				component.set("v.idCnt", getRecordDetails.Id);
				

				// This flag makes sure all needed data has been loaded
				if(component.get("v.initFlag")){
					this.launchFlow(component);
				}else{
					component.set("v.initFlag", true);
				}
			} else {
				console.log('Problem getting contact, response state: ' + state);
			}
		});
		$A.enqueueAction(action);
	},
	getUserDetails : function(component, event) {
		var action = component.get("c.getUserDetails");
		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS') {
				var getUserDetails = response.getReturnValue();
				component.set("v.brand", getUserDetails.brand);
				component.set("v.country", getUserDetails.country);
				component.set("v.visualforceDomain", getUserDetails.sURLVF);
				if($A.util.isUndefinedOrNull(getUserDetails.country) || $A.util.isEmpty(getUserDetails.country) || (getUserDetails.country!= 'DZ' && getUserDetails.country!='PL')){
					//this.createRecord(component,event);  
				}

				// This flag makes sure all needed data has been loaded
				if(component.get("v.initFlag")){
					this.launchFlow(component);
				}else{
					component.set("v.initFlag", true);
				}

			} else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("getUserDetails:Error message: " + errors[0].message);
					}
				} else {
					console.log("getUserDetails:Unknown error");
				}
				//this.createRecord(component,event);
			}else{
				//this.createRecord(component,event);
				console.log('getUserDetails:Something went wrong, Please check with your admin');
			}
		});
		$A.enqueueAction(action);	
	},
	createRecord : function (component, event) {


		var createRecordEvent = $A.get("e.force:createRecord");
		createRecordEvent.setParams({
			"entityApiName": "Consent__c",
			"panelOnDestroyCallback": function(event) {
				window.history.back();
			}
		});
		createRecordEvent.fire();
		
		
	},
	launchFlow : function (cmp) {

		var flow = cmp.find("flowConsent");
        var inputVariables = [
            {
                name : 'ContactID',
                type : 'String',
                value : ($A.util.isUndefinedOrNull(cmp.get("v.idCnt")) || $A.util.isEmpty(cmp.get("v.idCnt"))) ? cmp.get("v.recordId") : cmp.get("v.idCnt")
			},
			{
                name : 'Activity',
                type : 'String',
                value : cmp.get('v.activity')
            },
			{
				name : 'DocumentType',
				type : 'String',
				value : cmp.get( 'v.documentType' )
			},
			{
				name : 'AskForActivityDocType',
				type : 'Boolean',
				value : cmp.get( 'v.askForActivityDocType' )
			}
        ];
        flow.startFlow("NewConsentWizard", inputVariables);

	},
	handleFlowFinish : function(cmp, event) {

		// Manage flow output variables 
		for(let temp of event.getParam('outputVariables')){
			if(temp && temp.value && temp.name && temp.name === 'LegalTextURL'){
				// var urlEvent = $A.get("e.force:navigateToURL");
				// urlEvent.setParams({
				// 	"url": temp.value
				// });
				// urlEvent.fire();
				window.open(temp.value,'_blank')
			}
		}

		// Close context
		// Quick Action
		$A.get( "e.force:closeQuickAction" ).fire();
		// Flow
		let navigate = cmp.get('v.navigateFlow');
		if(navigate){
			navigate("NEXT");
		}

		cmp.set('v.skipFlowFlag', true);
	},
	// handleToastEvent : function(component, event, helper) {
		// var toastMessageParams  = event.getParams();
		// var message             = toastMessageParams.message;
		// if (message.includes('was saved')) {
		//    window.history.back();
		// }
	// },
	
	/*
	printElement: function(elem) {
		var domClone = elem.cloneNode(true);
	
		var printSection = document.getElementById("divToPrint");
	
		if (!printSection) {
			var printSection = document.createElement("div");
			printSection.id = "divPrint";
			document.body.appendChild(printSection);
		}
	
		printSection.innerHTML = "";
	
		printSection.appendChild(domClone);
	},
	printDiv:function(component, event){
		var mywindow = window.open('', 'PRINT', 'height=400,width=600');
	
		mywindow.document.execCommand('write',true,'<html><head><title>' + 'Consent Document'  + '</title>');
		mywindow.document.execCommand('write',true,'</head><body >');
		mywindow.document.execCommand('write',true,'<h1>' + 'Consent Document'  + '</h1>');
		mywindow.document.execCommand('write',true,document.getElementById('divToPrint').innerHTML);
		mywindow.document.execCommand('write',true,'</body></html>');
	
		mywindow.document.close(); // necessary for IE >= 10
		mywindow.focus(); // necessary for IE >= 10
	
		mywindow.print();
		mywindow.close();
	},
	 */
})