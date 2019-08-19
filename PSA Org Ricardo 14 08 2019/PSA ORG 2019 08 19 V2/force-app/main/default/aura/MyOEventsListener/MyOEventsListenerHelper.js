({
	getUserDetails : function(component, event) {
		var action      = component.get("c.getUserDetails");
		var sHostType   = component.get("v.HostType");

		action.setParams({
			"sHostType" : sHostType,
			"sRecordId" : component.get("v.recordId"),
			"strMode"   : component.get( "v.mode" )
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS') {
				var getUserDetails = response.getReturnValue();
				component.set("v.MyOHost", getUserDetails.host + this.getParams(component, event, getUserDetails,sHostType) );
				component.set("v.SFDCHost", getUserDetails.host);

			}else if (response.getState() === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("getUserDetails:Error message: " + errors[0].message);
					}
				}
			}
		});

		$A.enqueueAction(action);	
	},

	getParams : function(component, event, sObj,sHostType){
		var sParams = '?idWorkshop=' + sObj.idWorkshop + '&brand=' + sObj.brand + '&idUser=' + sObj.idUser + '&Locale=' + sObj.locale;

		if(sHostType!='Agenda'){
			sParams = sParams + '&appointmentId=' + sObj.appointmentId + '&idCustomerSF=' + sObj.idCustomerSF + '&idVehicleSF=' + sObj.idVehicleSF + '&idVINSF=' + sObj.idVINSF;
			
		}else{
			var retrieveData = JSON.parse(localStorage.getItem('calendarSeletion'));
			var calendarDate = $A.util.isUndefinedOrNull(retrieveData)?'':'&calendarDate=' + retrieveData.paramsArray.calendarDate;

			sParams = sParams + calendarDate;

			if(!$A.util.isUndefinedOrNull(retrieveData)){
				localStorage.removeItem("calendarSeletion");
			}
		}
		return sParams.trim();
	},

	getOrigin : function(component){
		var SFDCOrigin          = component.get("v.SFDCHost");

		try{
			var SFDCOriginb     = SFDCOrigin.split('/');
			SFDCOrigin          = SFDCOriginb[0] + '//' + SFDCOriginb[2];

		}catch(e){
			console.log('Error: ' + e.message);
		}

		return SFDCOrigin;
	},

	pushPayLoad : function(component, payload,bdoSearch){
		var childCmp = component.find("MyOEventCMP");
		var auraMethodResult =  childCmp.handleMyOEvent(payload,bdoSearch);
	},

	pushPayLoadCalendar : function(component, payload){
		localStorage.setItem('calendarSeletion', JSON.stringify(payload));
	},

	getAppointmentId : function(component, sExtenralKey, oPayLoad, bdoSearch){
		var action = component.get("c.getAppointmentId");

		action.setParams({
			"sExternalId" : sExtenralKey
		});

		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS') {
				component.set("v.appointmentSFId",response.getReturnValue());
				this.navigateTo(response.getReturnValue());

			} else if (response.getState() === 'ERROR') {
				var errors = response.getError();
				
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("getAppointmentId:Error message: " + errors[0].message);
					}
				}
				
				this.pushPayLoad(component,oPayLoad,bdoSearch);
			}
		});

		$A.enqueueAction(action);   
	},

	manageCustomEvents : function(component, event,action){
		switch (action) {
			case 'CLOSE':
				this.navigateHomePage();
				break;
			case 'CANCEL': case 'DELETE':
				this.cancelAppointment( component );
				this.navigateHomePage();
				break;
			case 'ERROR':
				this.showMessgae(component, 'Error', $A.get("$Label.c.MyOEventErrorMessage"), 'Error');
				break;
		}
	},

	navigateTo : function(recordId){
		var navEvt      = $A.get("e.force:navigateToSObject");

		navEvt.setParams({
			  "recordId"      : recordId,
			  "slideDevName"  : "detail"
		});

		navEvt.fire();
	},

	navigateHomePage : function(){
		var navEvt      = $A.get("e.force:navigateHome");

		navEvt.fire();
	},

	showMessgae : function(component, stitle, smessage, stype){
		var toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
			"title"   : stitle,
			"message" : smessage,
			"type"    : stype
		});

		toastEvent.fire();
	},

	cancelAppointment : function( component ){
		var action												= component.get( "c.cancelAppointment" );
		
		var request												= {
																	strRecordId			: component.get( "v.recordId" ),
																	strAppointmentId	: component.get( "v.MyOPayLoad.paramsArray.appointmentId" )
																};

		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );

		action.setCallback( this, function( response ){
			var state											= response.getState();
			
			if( state === "SUCCESS" ){
				if( response.getReturnValue().hasError ){
					console.log( response.getReturnValue() );
				}
			
			}else if( state === "ERROR" ){
				var errors				= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}

				helper.hideSpinner( component );
			}
		} );

		$A.enqueueAction( action );
	}
})