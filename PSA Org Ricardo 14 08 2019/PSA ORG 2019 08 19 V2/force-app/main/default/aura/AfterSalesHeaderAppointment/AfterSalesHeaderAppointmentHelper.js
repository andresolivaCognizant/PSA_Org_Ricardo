({
	getUrlParameter : function getUrlParameter(sParam) {
		var sPageURL = decodeURIComponent(window.location.search.substring(1)),
		sURLVariables = sPageURL.split('&'),
		sParameterName,
		i;
		for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('=');
			if (sParameterName[0] === sParam) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		}
	},
	
	getAllRecords : function( component, type, sID, consentUpdateAction ){
		var action              = component.get("c.getRelatedRecords");
		var idAcc               = component.get("v.sRelationId");
		var lstRowsObjects      = [];

		action.setParams({
			sAccountId          : (sID!=undefined)?sID:idAcc,
			sType               : type
		});

		action.setCallback(this, function(response){
			var sRow = component.get("v.metricsData")[0];

			if(response.getState() === 'SUCCESS'){
				var sResult = response.getReturnValue();
				if(type=== 'Campaign'){
					component.set("v.Campaigns",sResult)
					sRow.Campaigns = sResult.length;
					
				}else if(type ==='Opportunity'){
					component.set("v.Opportunities",sResult);
					sRow.Leads = sResult.length;

				}else if(type === 'TestDrive'){
					component.set("v.TestDrives",sResult);
					sRow.TestDrives = sResult.length;

				}else if(type === 'Consents') {
					sRow.Consentement = sResult;
					this.consentsOutput(component, sResult, consentUpdateAction );

				}else if( type === 'DMS' ){
					this.getIdDMS( component, sResult );
				}
			}else if (response.getState() === 'ERROR'){
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
				if(type=== 'Campaign'){
					component.set("v.Campaigns","");
					sRow.Campaigns = 0;
				}else if(type ==='Opportunity'){
					component.set("v.Opportunities","");
					sRow.Leads = 0;
				}else if(type === 'TestDrive'){
					component.set("v.TestDrives","");
					sRow.TestDrives = 0;
				}
			}
			lstRowsObjects.push(sRow);
			component.set("v.metricsData",lstRowsObjects)
		});
		$A.enqueueAction(action);
	},

	ldsOnLoad: function(component) {

		component.set("v.timerId", null);
		component.set(
				"v.iFrameUrl",
				this.getLandingPageUrl(
				component.get("v.wa.fields.Driver__r.value.fields.TECH_UnsubscribeURL__c.value")
			)
		);

		var action = component.get("c.getRecordDetails");
		
		action.setParams({
			sRecordId : component.get("v.wa").fields.TECH_AccountAssetRelation__c.value
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				var rows = response.getReturnValue().lstDataTableData;
				if(rows[0]!= undefined){
					var row  = rows[0];
					var lstRowsObjects 		= [];		
					var oRow1 ={};

					oRow1.Id                = row.sObjectVal.AccountId__c;
					oRow1.Firstname			= row.sObjectVal.AccountId__r.FirstName != undefined ? row.sObjectVal.AccountId__r.FirstName : '';
					oRow1.Lastname			= row.sObjectVal.AccountId__r.LastName != undefined ? row.sObjectVal.AccountId__r.LastName : '';
					oRow1.Salutation		= '';//row.AccountId__r.Salutation;
					
					var isPAcc = row.sObjectVal.AccountId__r.IsPersonAccount;

					if (isPAcc === true){
						oRow1.MobilePhone	= row.sObjectVal.AccountId__r.PersonMobilePhone;
						oRow1.Phone			= row.sObjectVal.AccountId__r.MobileProfessionalTelephone__pc;
						oRow1.Email			= row.sObjectVal.AccountId__r.PersonEmail;
						oRow1.Name			= oRow1.Firstname + ' ' + oRow1.Lastname;

					} else {
						oRow1.MobilePhone	= row.sObjectVal.AccountId__r.MobilePersonalTelephone__pc;
						oRow1.Phone			= row.sObjectVal.AccountId__r.Phone;
						oRow1.Email			= row.sObjectVal.AccountId__r.Email__c;
						oRow1.Name			= row.sObjectVal.AccountId__r.Name;
					}

					oRow1.Consentement		= '-';
					oRow1.Leads				= row.opportunities;
					oRow1.TestDrives		= row.testdrives;
					oRow1.LastContact		= row.sObjectVal.AccountId__r.LastModifiedDate;
					oRow1.LastAccess		= row.sObjectVal.AccountId__r.SystemModstamp;
					oRow1.Campaigns			= row.campaigns;
					oRow1.SMobile			= 'No';
					oRow1.Satisfaction		= 'Yes';
					oRow1.Sentiment			= 'utility:smiley_and_people';
					oRow1.Role				= row.sObjectVal.AccountRole__c;
					oRow1.LCard				= (row.sObjectVal.AccountId__r.LoyaltyCardId__pc!=undefined)?'Yes':'No';

					lstRowsObjects.push(oRow1);

					component.set("v.metricsData",lstRowsObjects);
					component.set("v.sRelationId",oRow1.Id);

					this.getAllRecords( component, 'Campaign', row.sObjectVal.AccountId__r.PersonContactId, null );
					this.getAllRecords( component, 'Opportunity', row.sObjectVal.AssetId__c, null );
					this.getAllRecords( component, 'Consents', component.get("v.recordId"), false );
					this.getAllRecords( component, 'DMS', row.sObjectVal.AccountId__c, null );
					
					this.addEditLink( component );
				}
			}else if (state === 'ERROR'){
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			} else{
				console.log('Something went wrong, Please check with your admin');
			}
		});
		$A.enqueueAction(action);
	},

	consentsOutput: function( component, c, consentUpdateAction ) {
		var body = [];

		if( c.length == 0 ){
			if( this.displayToast( component ) && !component.get("v.timerId") && component.get("v.showConsentToast")){
				this.showToast( "", $A.get( "$Label.c.AfterSalesHeaderWithoutConsentMsg" ), "error", "dismissible" );
				component.set("v.showConsentToast", false);
			}
			
			component.set( "v.wa.fields.TECH_ConsentCount__c.value", -1 );
			component.find( "forceRecord" ).saveRecord();

			$A.createComponent(
				"lightning:formattedUrl",
				{
					"value"     : "#",
					"label"     : $A.get( "$Label.c.AfterSalesNoLabel" ),
					"onclick"   : component.getReference("c.showConsentModal"),
					"tooltip"	: $A.get( "$Label.c.AfterSalesOutdatedConsentsMessage" )
				},
				function(e, status, errorMessage) {
					if (status === "SUCCESS") {
						body.push(e);
						component.find("_consents").set("v.body", body);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);
			
		}else if( c.length > 0 ){
			if( component.get( "v.wa.fields.TECH_ConsentStatus__c.value" ) == "2" ){
				this.displayToast( component );
				component.set( "v.consentClass", "success" );
			
			}else if( component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) != undefined &&
				component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) == -1 &&
				component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) < c.length
			){
				this.displayToast( component );
				component.set( "v.consentClass", "success" );
				
				component.set( "v.wa.fields.TECH_ConsentStatus__c.value", "2" );
				component.set( "v.wa.fields.TECH_ConsentCount__c.value", c.length );
				component.find( "forceRecord" ).saveRecord();
			
			}else if( (
					component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) != undefined &&
					component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) === c.length
				) || (
					!consentUpdateAction &&
					component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) != undefined &&
					component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) < c.length
				)
			){
				if( this.displayToast( component ) && !component.get("v.timerId") ){
					this.showToast( "", $A.get( "$Label.c.AfterSalesHeaderConsentOutOfDated" ), "warning", "dismissible" );
				}
				
				component.set( "v.consentClass", "warning" );
				component.set( "v.wa.fields.TECH_ConsentStatus__c.value", "1" );
				component.set( "v.wa.fields.TECH_ConsentCount__c.value", c.length );
				component.find( "forceRecord" ).saveRecord();
			
			}else if( component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) != undefined && consentUpdateAction && component.get( "v.wa.fields.TECH_ConsentCount__c.value" ) < c.length ){
				this.displayToast( component );
				component.set( "v.consentClass", "success" );
				
				component.set( "v.wa.fields.TECH_ConsentStatus__c.value", "2" );
				component.set( "v.wa.fields.TECH_ConsentCount__c.value", c.length );
				component.find( "forceRecord" ).saveRecord();
			}
		
			$A.createComponent(
				"lightning:formattedText",{
					"value"		: c[0].formatedCreatedDate.split( " " )[0],
					"onclick"	: component.getReference( "c.showConsentModal" ),
					"class"		: "consents-date-link",
					"title"		: c[0].formatedCreatedDate
				},
				function(e, status, errorMessage) {
					if (status === "SUCCESS") {
						body.push( e );
						component.find("_consents").set("v.body", body);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);
			
			
		}
	},

	getLandingPageUrl: function(strHtml) {
		var div = document.createElement('div');
		div.innerHTML = strHtml;
		return div.firstChild.getAttribute("href");
	},

	getMyBrandSettings: function(component) {
		var action = component.get("c.myBrandElegibility");

		action.setParams({
			recordId : component.get("v.recordId")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			switch (state) {
			case 'SUCCESS':
				component.set("v.objMyM", response.getReturnValue().myBrand);
				component.set("v.objReminder", response.getReturnValue().reminder);

				break;
			case 'INCOMPLETE':
				break;
			case 'ERROR':
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
		});

		$A.enqueueAction(action);
	},

	createConsentModal: function(component) {
		var account_id = component.get("v.wa.fields.Driver__c.value");

		if (!account_id) {
			return;
		}

		$A.createComponent(
			"c:ConsentsPopUpModal", {
				"accountId": account_id
			},
			function(e, status, errorMessage) {
				var body = []; 
				if (status === "SUCCESS") {
					body.push(e);
					component.find("consent_modal_container").set("v.body", body);
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
	},

	showToast : function( msgTitle, msg, msgType, msgMode ) {
		var toastEvent      = $A.get( "e.force:showToast" );
		var availableModes  = "dismissible&pester&sticky";
		var availableTypes  = "info&success&warning&error";

		toastEvent.setParams( {
			title :   msgTitle,
			message:  msg,
			duration: "5000",
			key:      "info_alt",
			type:     availableTypes.includes( msgType ) ? msgType : "info",
			mode:     availableModes.includes( msgMode ) ? msgMode : "pester"
		} );

		toastEvent.fire();
	},

	displayToast : function( component ){
		var country = component.get( "v.parentFields.Asset__r.Country__c" ) != undefined ? component.get( "v.parentFields.Asset__r.Country__c" ) : "";
		var brand   = component.get( "v.parentFields.Asset__r.Brand__c" ) != undefined ? component.get( "v.parentFields.Asset__r.Brand__c" ) : "";
		var status  = component.get( "v.wa.fields.AppointmentStatus__c" ) != undefined ? component.get( "v.wa.fields.AppointmentStatus__c.value" ) : "";

		var key			= country == "" && brand == "" ? "All" + status : country + brand + status;

		this.displayConsentsHighlightedIcon( component, key );

		return component.get( "v.activeActionsByName" ) != undefined && component.get( "v.activeActionsByName" )[ key ] != undefined ? component.get( "v.activeActionsByName" )[ key ].ShowToast__c : false;
	},

	displayConsentsHighlightedIcon : function( component, key ){
		component.set( "v.showConsentsHighlightedIcon", component.get( "v.activeActionsByName" ) != undefined && component.get( "v.activeActionsByName" )[ key ] != undefined ? component.get( "v.activeActionsByName" )[ key ].ShowHighlightedIcon__c : false );
	},

	hasChanged : function(component, response, timer_id) {
		var state = response.getState();
		switch (state) {
		case "SUCCESS":
			var old_map = {};
			old_map[component.get("v.wa.fields.Id.value")] = component.get("v.wa");
			var new_map = response.getReturnValue();

			if (Object.keys(new_map).length < 1) {
				break;
			}

			for (var rec_id in old_map) {
				if (new_map.hasOwnProperty(rec_id)) {

					if (
						old_map[rec_id].fields.AppointmentStatus__c.value != new_map[rec_id].AppointmentStatus__c &&
						new_map[rec_id].AppointmentStatus__c == '1'
					) {
						this.createConsentModal(component, new_map[rec_id].Driver__c)
						if (timer_id) {
							clearInterval(timer_id);
						}
						break;
					}
				}
			}
			break;

		case "INCOMPLETE":
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
		}
	},
	
	addCustomerReceptionButton : function( component, event, helper ) {
		var headerCard_btnContainer					= component.find( "headerCard" ).find( "buttonContainer" );
		
		$A.createComponent(
			"lightning:button",
			{
				"aura:id": "customerReception",
				"label": $A.get( "$Label.c.AfterSalesCustomerReceptionButton" ),
				"variant": "neutral",
				"value": $A.get( "$Label.c.AfterSalesCustomerReceptionButton" ),
				"onclick": component.getReference( "c.redirectToPanier" )
			},
			function( newButton, status, errorMessage ){
				if (status === "SUCCESS") {
					var body						= [];
					body.push( newButton );
					headerCard_btnContainer.set( "v.body", body );
				}
				else if (status === "INCOMPLETE") {
					console.log( "No response from server or client is offline." );
				}
				else if (status === "ERROR") {
					console.log( "Error: " + errorMessage );
				}
			}
		);
	},
	
	addEditLink : function( component ){
		var headerLine1									= component.find( "headerCard" ).find( "headerLine1" );
		
		$A.createComponent(
			"lightning:formattedText",
			{
				"aura:id"	: "editAccount",
				"value"		: component.get( "v.metricsData[0].Role" ),
				"title"		: $A.get( "$Label.c.AfterSalesEditTooltip" ),
				"onclick"	: component.getReference( "c.editRecord" ),
				"class"		: "edit_link"
			},
			function( e, status, errorMessage ){
				if (status === "SUCCESS") {
					var body							= [];
					body.push( e );
					headerLine1.set( "v.body", body );
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
	},

	getIdDMS : function( component, dmsData ){
		var body = [];

		if( dmsData == undefined || ( dmsData.length === 1 && dmsData[0].ExternalId__c == undefined ) ){
			component.set( "v.showIDDMSHighlightedIcon", true );

			$A.createComponent(
				"lightning:formattedText",
				{
					"value"     : $A.get( "$Label.c.AfterSalesNoLabel" ),
					"title"		: $A.get( "$Label.c.AfterSalesMissingIDDMSMessage" ),
					"onclick"   : component.getReference( "c.callDMS" ),
					"class"		: "consents-date-link"
				},
				function( e, status, errorMessage ){
					if( status === "SUCCESS" ){
						body.push(e);
						component.find( "_idDMS" ).set( "v.body", body );
					
					}else if( status === "INCOMPLETE" ){
						console.log( "No response from server or client is offline." )
					
					}else if( status === "ERROR" ){
						console.log( "Error: " + errorMessage );
					}
				}
			);

		}else if( dmsData.length === 1 && dmsData[0].ExternalId__c != undefined ){
			component.set( "v.showIDDMSHighlightedIcon", false );

			$A.createComponent(
				"lightning:formattedText",
				{
					"value"     : dmsData[0].ExternalId__c
				},
				function( e, status, errorMessage ){
					if( status === "SUCCESS" ){
						body.push(e);
						component.find( "_idDMS" ).set( "v.body", body );
					
					}else if( status === "INCOMPLETE" ){
						console.log( "No response from server or client is offline." )
					
					}else if( status === "ERROR" ){
						console.log( "Error: " + errorMessage );
					}
				}
			);
		}
	},
	startDMScall: function(component) {
		var action = component.get("c.DMSWakeUp");
		action.setParams({
			"sRecordId_A" : component.get( "v.metricsData[0].Id" ),
			"sRecordId_B" : component.get( "v.parentFields.Asset__r.Id")
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
              var allValues = response.getReturnValue();
              if(!$A.util.isUndefinedOrNull(allValues) && !$A.util.isEmpty(allValues)){
              	this.executeCORScall(allValues.body,allValues.endpoint);
              }else{
                this.executeServerCall(component);
              }
           }
        });
        $A.enqueueAction(action);
    },
    executeServerCall : function(component) { 
        var action = component.get("c.DMSWakeUpbyServer");
        action.setParams({
			"sRecordId" : component.get("v.sRecordId")
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
           		//console.log('Ok');
           }
        });
        $A.enqueueAction(action);
    },
    executeCORScall : function(message,url) { 
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
            this.fixCORScallIE11(url);
            var xmlHttp = new XMLHttpRequest();
            console.log('body: ' + message + ' · URL: ' + url);
            xmlHttp.open( "POST", url, true );
            xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xmlHttp.responseType = 'text';
            xmlHttp.onload = function () {
                if (xmlHttp.readyState === 4) {
                    if (xmlHttp.status === 200) {}
                }
            };
            xmlHttp.send( message );
        }
    },
    fixCORScallIE11 : function(url) { 
        try{
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('GET', url, true);
            xmlHttp.withCredentials = true;
            xmlHttp.send();
        }catch(e){}
    }
})