({
	handleMyOEvent : function(component, event, helper) {
		console.log('Start handleMyOEvent');
		var params 				      = event.getParams();
		if(params!=undefined && params.arguments.myoRecord != undefined){
			var payload 		      = JSON.parse(JSON.stringify(params.arguments.myoRecord));
			/* START - Ruben Fernandez - C1STAGILE-5761 - Fix MyO data received to perform the search */
			//var searchByAccount = payload.paramsArray.customerSalutation + ' ' + payload.paramsArray.customerFirstName + ' ' +  
			//    payload.paramsArray.customerLastName  + ' ' + payload.paramsArray.customerPhone + ' ' + payload.paramsArray.customerEmail;
			//var searchByAsset 	= payload.paramsArray.vehicleVIN + ' ' + payload.paramsArray.vehicleRegistrationNumber;
			
			//--> Customer Search Key
			var searchByAccount   = '';
			var searchByAsset     = '';
			if(!helper.IsEmptyValue(payload.paramsArray.customerFirstName)){
				searchByAccount     = helper.getValue(payload.paramsArray.customerFirstName)+' ';
			}
			if(!helper.IsEmptyValue(payload.paramsArray.customerLastName)){
				searchByAccount     += helper.getValue(payload.paramsArray.customerLastName)+' ';
			}
			if(!helper.IsEmptyValue(payload.paramsArray.customerEmail)){
				searchByAccount     += payload.paramsArray.customerEmail+' ';
			}
			if(!helper.IsEmptyValue(payload.paramsArray.customerPhone)){
				searchByAccount     += payload.paramsArray.customerPhone;
			}
			//--> Asset Search Key
			if(!helper.IsEmptyValue(payload.paramsArray.vehicleRegistrationNumber)){
				searchByAsset       = payload.paramsArray.vehicleRegistrationNumber+' ';
			}
			if(!helper.IsEmptyValue(payload.paramsArray.vehicleVIN)){
				searchByAsset       += payload.paramsArray.vehicleVIN + ' ';
			}

			if( !helper.IsEmptyValue( payload.paramsArray.vehicleModel ) ){
				searchByAsset       += payload.paramsArray.vehicleModel;
			}
			/* END - C1STAGILE-5761 */
			var appEventSearch    = $A.get("e.c:AfterSalesSearchEvent");  
			if(appEventSearch != undefined){
				appEventSearch.setParams({
						"searchByAccount" 	: searchByAccount.trim() == '' ? undefined : searchByAccount.trim() + " ",
						"searchByAsset"		: searchByAsset.trim() == '' ? undefined : searchByAsset.trim() + " ",
						"myoRecord"			: payload,
						"refreshData" 		: true,
						"doSearch"			: params.arguments.doSearch
				});
				appEventSearch.fire();
			}
			//helper.handlePills(component,event,searchByAccount.trim(),searchByAsset.trim());
			// var appEventSearchPill  = $A.get("e.c:AfterSalesSearchHeaderFieldEvent");  
			// if(appEventSearchPill != undefined){
			//     appEventSearchPill.setParams({
			//         "runPillsAcc"   : searchByAccount.trim(),
			//         "runPillsAss"   : searchByAsset.trim()
			//     });
			//   appEventSearchPill.fire();
			// }

		}
	},
})