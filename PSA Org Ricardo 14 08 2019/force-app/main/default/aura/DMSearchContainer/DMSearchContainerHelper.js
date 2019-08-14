({
	getRecordURL: function (name, value, access){
		var baseURL                 = '/PSADealer/s/detail/';
		var sURL                    = '"javascript:void(0)"';
		if(access){
			if(name!=undefined && name!=''){
				sURL = baseURL + value;
			}
		}
		return sURL;
	},
	getDateFormated: function (Newdate, NewTimeZone){
		var d       = new Date(Newdate);
		var utc     = d.getTime() + (d.getTimezoneOffset() * 60000);
		var result  = new Date(utc + (3600000*NewTimeZone));
		return result;
	},
	formatValue: function (value){
		var sValue  = ' ';
		if(value!=undefined && value.length>0){
			sValue = value;
		}
		return sValue;
	},
	getData: function (component,event,refreshData){

		this.toggleSpinner(component,event);
		console.log('getData');
		var searchByAccount = event.getParam("searchByAccount");
		var searchByAsset   = event.getParam("searchByAsset");
        var searchBySales 	= event.getParam("searchBySales");
		var searchByAfterSales   = event.getParam("searchByAfterSales");
		var filterField 	= event.getParam("filterField");
		var filterDate 		= event.getParam("filterDate");
		var filterCriteria 	= event.getParam("filterCriteria");
		var filterResults   = component.get("v.filterrows");
		var recordId   		= component.get("v.recordId");

		if( (searchByAccount==undefined || searchByAccount=='') && (searchByAsset==undefined || searchByAsset=='' ) 
          && (searchBySales==undefined || searchBySales=='' ) && (searchByAfterSales==undefined || searchByAfterSales=='' )){
			this.toggleSpinner(component,event);
			this.showMessage(component,event, $A.get("$Label.c.CustomerSearchExceptionTitle"),$A.get("$Label.c.CustomerSearchErrorMessageLength"),'error');
		}else{
			if((searchByAccount!=undefined && searchByAccount!='' && searchByAccount.length<2) || (searchByAsset!=undefined && searchByAsset!='' && searchByAsset.length<2)
              || (searchBySales!=undefined && searchBySales!='' && searchBySales.length<2) || (searchByAfterSales!=undefined && searchByAfterSales!='' && searchByAfterSales.length<2)) {
				this.toggleSpinner(component,event);
				this.showMessage(component,event, $A.get("$Label.c.CustomerSearchExceptionTitle"),$A.get("$Label.c.CustomerSearchErrorMessageLength"),'error');
			}else{
				var cmp					= component;
			
				var action 				= component.get("c.findRecords");
				action.setParams({
					searchCriteria1 	: searchByAccount,
					searchCriteria2 	: searchByAsset,
                    searchCriteria3 	: searchBySales,
					searchCriteria4 	: searchByAfterSales,
					searchFilterF 		: filterField,
					searchFilterD 		: filterDate,
					searchFilterC 		: filterCriteria,
					recordId 			: recordId,
					bFilter             : (filterResults==undefined)?false:filterResults
				});
				action.setCallback(this, function(response){
					this.toggleSpinner(component,event);
					if(response.getState() === 'SUCCESS'){
						var rows = response.getReturnValue().lstDataTableData;
						if(rows.length>0){
							var lstRowsAttributes = [];
							var lstAttributesType = [];		
							var columns = response.getReturnValue().lstDataTableColumns;
							columns.splice(columns.length-1, 1);
							component.set("v.shortcolumns",columns.slice(0,3));
							columns.push({fieldName: 'CampaignMember',label: 'Member', type: 'text', sortable: true, iconName: 'standard:campaign', cellAttributes: {iconName: { fieldName: 'CampaignMember_chk' },iconPosition: 'left'}});
							var rows                    = response.getReturnValue().lstDataTableDataW;
							var iCampaignMembers        = response.getReturnValue().iCampaignMembers;
							var lstRowsObjects          = [];
							for (var i = 0; i < rows.length; i++) {
								var row                                     = rows[i];
								var newRow		={};
								for (var j = 0; j < row.lstWrapperVal.length; j++) {
									if(row.lstWrapperVal[i].fieldName=='CampaignMember'){
										if(row.lstWrapperVal[i].fieldvalue=='true'){
											newRow[row.lstWrapperVal[j].fieldName+'_chk'] = 'utility:privately_shared';
										}else{
											newRow[row.lstWrapperVal[j].fieldName+'_chk'] = '';
										}
									}else{
										newRow[row.lstWrapperVal[j].fieldName] = row.lstWrapperVal[j].fieldvalue;
									}
								}
								lstRowsObjects.push(newRow);
							}
						}else{
							this.toggleErrMessage(component,event);
						}    
						component.set("v.CampaignMembers",iCampaignMembers);
						component.set("v.columns", response.getReturnValue().lstDataTableColumns);
						
						if( cmp.get( "v.showData" ) ){
							component.set( "v.data", lstRowsObjects );
						}else{
							component.set( "v.data_tmp", undefined )
							component.set( "v.data", undefined );
							component.set( "v.data_tmp", lstRowsObjects );
						}			
						component.set("v.totalNumberOfRows", response.getReturnValue().lstDataTableData.length);    
					}else if (state === 'ERROR'){
						var errors = response.getError();
						if (errors) {
							if (errors[0] && errors[0].message) {
								console.log("Error message: " + errors[0].message);
							}
						} else {
							console.log("Unknown error");
						}
						this.toggleErrMessage(component,event);
					}else{			
						console.log('Something went wrong, Please check with your admin');
						this.toggleErrMessage(component,event);
					}
				});
				$A.enqueueAction(action);
			}
		}
	},
	fetchPickListVal: function(component, event) {
		var action = component.get("c.getselectOptions");
		var optsDates = [];
		var optsField = [];
		action.setCallback(this, function(response) {
			if (response.getState() == "SUCCESS") {
				var opts  = response.getReturnValue().lstOptions;
				// C1STAGILE - 8442: Labels must be added to LabelComponent in order to be recovered
				for (var i = 0; i < opts.length; i++) {
					var sType =  opts[i].Type;
					var sLabel = "$Label.c." + opts[i].Field;
					var labelRef = $A.getReference(sLabel);
					component.set("v.AuxField",labelRef);
					if(sType === 'DATE'){
						optsDates.push({
							Value: opts[i].Value,
							Field: component.get("v.AuxField")
						});
					}else{
						optsField.push({
							Value: opts[i].Type + '.' + opts[i].Value,
							Field: component.get("v.AuxField")  
						});
					}
				}
				component.set("v.FilterDates", optsDates);
				component.set("v.FilterField", optsField);
			}
		});
		$A.enqueueAction(action);
	},
	createEntries : function(component, event){
		var action = component.get("c.createNewRecords");
		var lstRecords = component.get("v.validRows");
		var idListJSON=JSON.stringify(lstRecords);
		action.setParams({
			"lstRecords" : idListJSON,
			"sCampaignId" : component.get("v.recordId")
		});		
		action.setCallback(this, function(response) {
			if (response.getState() == "SUCCESS") {
				this.showMessage(component,event,'Members Added','Members added to the campaign successfully','SUCCESS');
			}else{
				this.showMessage(component,event,'Members NOT Added','Members Not added to the campaign','Error');
			}
		});
		$A.enqueueAction(action);
	},
	showToast : function(component, event, stype) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": stype + "!",
			"type" : stype,
			"message": stype=="success"?$A.get("$Label.c.SecretQuestionMessageSuccess"):$A.get("$Label.c.SecretQuestionMessageError")
		});
		toastEvent.fire();
	},
	handleError: function(component, event){
		/* do any custom error handling
		* logic desired here */
		// get v.errors, which is an Object[]
		var errorsArr  = component.get("v.errors");
		for (var i = 0; i < errorsArr.length; i++) {
			console.log("error " + i + ": " + JSON.stringify(errorsArr[i]));
			this.showMessage(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),errorsArr[i].message,'warning');
		}
	},
	
	showMessage : function(component, event, stitle, smessage, stype){
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title"   : stitle,
			"message" : smessage,
			"type"    : stype
		});
		toastEvent.fire();
	},

	refreshView: function (component,event) {
		this.getData(component, event, true);
	},
	
	sortData: function (component, fieldName, sortDirection) {
		var data        = component.get("v.data");
		var reverse     = sortDirection !== 'asc';
		data.sort(this.sortBy(fieldName, reverse));
		component.set("v.data", data);
	},
	
	sortBy: function (field, reverse, primer) {
		var key = primer ?
		function(x) {return primer(x[field])} :
		function(x) {return x[field]};
		reverse = !reverse ? 1 : -1;
		return function (a, b) {
			return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
		}
	},
	
	toggleSpinner: function (component, event) {
		var spinner = component.find("divSpinner");
		$A.util.toggleClass(spinner, "slds-hide");
	},
	
	toggleErrMessage: function (component, event) {
		var divNoResults = component.find("divNoResults");
		$A.util.removeClass(divNoResults, "slds-hide");
		$A.util.addClass(divNoResults, "slds-show");
	},
	onOpenStaticModal : function(component) {
		component.find("theStaticModal").openModal();
	},
	
})