({
	handleEvent : function(component, event, helper) {
		helper.getUserDetails(component, event);
		
		window.addEventListener(
			"message", function(myoevent) {
				if(myoevent.origin !== helper.getOrigin(component)) {
					return;
				}

				var oPayLoad    = [];
				var bdoSearch   =  true;

				if (myoevent.data.name === "timeslotSelection" || myoevent.data.name === "appointmentSelection" || myoevent.data.name === "endOfProcess" ) {
					oPayLoad    = JSON.parse(myoevent.data.payload);
					component.set("v.MyOPayLoad", oPayLoad);

					switch (oPayLoad.EntityType) {
						case 'APPOINTMENT':
							if(oPayLoad.Action=='CREATE' || oPayLoad.Action=='SELECTION'){
								helper.getAppointmentId(component,oPayLoad.paramsArray.appointmentId,oPayLoad,bdoSearch);
							}else{
								helper.manageCustomEvents(component, event,oPayLoad.Action);
							}
							break;
						case 'OLB_APPOINTMENT':
							if(oPayLoad.Action =='CREATE' || oPayLoad.Action =='SELECTION'){
								helper.getAppointmentId(component,oPayLoad.paramsArray.appointmentId,oPayLoad,bdoSearch);
							}else{
								helper.manageCustomEvents(component, event,oPayLoad.Action);
							}
							break;
						case 'TIME_SLOT':
							if(oPayLoad.Action =='CREATE' || oPayLoad.Action =='SELECTION'){
								helper.pushPayLoad(component,oPayLoad,false);
							}else{
								helper.manageCustomEvents(component, event,oPayLoad.Action);
							}
							break;
					}

				}else if(myoevent.data.name === "calendarSelection" ){
					oPayLoad    = JSON.parse(myoevent.data.payload);
					if(oPayLoad.Action =='SELECTION'){
						helper.pushPayLoadCalendar(component,oPayLoad);
					}
				}
			}, 
			false
		);
	},
})