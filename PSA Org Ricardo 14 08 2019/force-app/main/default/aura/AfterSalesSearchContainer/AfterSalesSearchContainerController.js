({
	doInit : function(component, event, helper) {   
		var divNoResults = component.find("divNoResults");
		$A.util.addClass(divNoResults, "slds-hide");
		
		var interval			= window.setTimeout(
			$A.getCallback( function(){
				component.find( "AfterSalesSearchCounters" ).reloadCounters(
					function( result ) {
						console.log( result );
					}
				);
			} ),
			1000
		);
		
		var loadURLs			= window.setTimeout(
			$A.getCallback( function(){
				component.find( "appointmentURLs" ).getRecords(
					[ 'APPOINTMENT' ],
					[ 'QuickReception_URL', 'Estimation_URL' ],
					function( result ) {
						component.set( "v.attributesByGlobalSetting", result );
					}
				);
			} ),
			1000
		);
	},
	
	handleSearchEvent: function(component, event, helper) {
		var searchByAccount = event.getParam("searchByAccount");
		var searchByAsset   = event.getParam("searchByAsset");
		var payload         = event.getParam("myoRecord");
		var doSearch        = event.getParam("doSearch");
		
		if(payload!=undefined){
			payload         = JSON.parse(JSON.stringify(payload));
			var NewTimeZone = payload.paramsArray.receptionDateTimeTimeZone;
			var Newdate     = payload.paramsArray.receptionDateTime;
			var iOffset     = NewTimeZone.substr(NewTimeZone.lastIndexOf('+'));
			var finaldate   = helper.getDateFormated(Newdate,iOffset);
			component.set("v.dateSelected",true);
			component.set( "v.receptionDateTime", " " + $A.localizationService.formatDateTime( finaldate, $A.get( "$Locale.datetimeFormat" ).replace( ":ss", "" ) ) );
			component.set("v.myoRecord",payload);
		}
		if(doSearch==undefined || doSearch)
			helper.getData(component, event);
	},
	
	handleRunSearchEvent: function(component, event, helper) {
		helper.getData(component, event,true);
	},
	
	handleRelationEvent : function(component, event, helper) {
		var sParam  = event.getParam("runRelationshipWizard");
		var oData   = component.get("v.setdata");
		
		if( component.get("v.setdataRel") != undefined && component.get("v.setdataRel").length == 2 ){
			component.set( "v.setdata", component.get("v.setdataRel") );
		}
		
		if (sParam !=undefined && ( ( oData != undefined && oData.length==2 ) || ( component.get("v.setdataRel") != undefined && component.get("v.setdataRel").length == 2 ) ) ){
			helper.fetchPickListVal(component, 'AccountRole__c', 'FieldRoleRel');
			component.find("theStaticModalRelation").openModal();
		}else{
			//TO DO: LABEL!!!
			helper.showMessage(component, event, "Error", "Please, make sure to select only 2 rows","warning");
		}
	},
	
	handleMyOEvent: function(component, event, helper){
		var searchByAccountFN = event.getParam("customerFirstName");
	},
	
	goToHomePage : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": "/"
		});
		urlEvent.fire();
	},
	
	handleToastEvent : function(component, event, helper) {
		var sParams  			= event.getParams();
		var message             = sParams.message;
		var sType               = sParams.type;
		var var1                = component.get("v.searchByAccount");
		var var2                = component.get("v.searchByAsset");
		var objectName          = component.get("v.EditObject");
		if (sType.toUpperCase() === 'SUCCESS'){
			var sParam = helper.getURL(var1,var2);
			component.set("v.windowHash",sParam);
			helper.startCORScall(component,objectName,true);
		}
	},
	
	updateColumnSorting: function (component, event, helper) {
		var fieldName 		= event.getParam('fieldName');
		var sortDirection 	= event.getParam('sortDirection');
		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);
		helper.sortData(component, fieldName, sortDirection);
	},
	
	getSelecteRowFilter: function (component, event,helper) {
		var lstRowsSelected     = [];
		var lstFullRowsSelected = [];
		var sRowsSelected       = '';
		
		var selectedRows        = event.getParam('selectedRows');	
		var sId                 = event.getSource().getLocalId();
		
		if(selectedRows != undefined){
			if (sId=='AssetSelectionTable' || sId=='AccountSelectionTable') {
				if(selectedRows.length==1){
					for (var i = 0; i < selectedRows.length; i++){
						sRowsSelected = (sId=='AssetSelectionTable')?selectedRows[i].AssetId:selectedRows[i].AccountId;
					}
					if (sId=='AssetSelectionTable'){
						component.set("v.selectedAssetRow",sRowsSelected);    
					}else{
						component.set("v.selectedAccRow",sRowsSelected);
					}
				}else if(selectedRows.length>1){
					helper.showMessage(component, event, $A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),$A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),'Error');
				}
			}else{
				for (var i = 0; i < selectedRows.length; i++){
					if(selectedRows[i].UserRecordAccess.HasReadAccess){
						lstRowsSelected.push({value: selectedRows[i].Id});
						lstFullRowsSelected.push(selectedRows[i]);
					}
				}
				var auxCol0 = component.get("v.shortcolumns");
				var auxCol1 = component.get("v.shortcolumnsb");
				component.set("v.setdata",undefined);
				component.set("v.shortcolumns",undefined);
				component.set("v.shortcolumnsb",undefined);
				
				component.set("v.setdata",lstFullRowsSelected);
				component.set("v.selectedRows",lstRowsSelected);
				component.set("v.numberRows",selectedRows.length);
				component.set("v.shortcolumns",auxCol0);
				component.set("v.shortcolumnsb",auxCol1);
			}
		}else{
			var vData = component.get("v.data");
			if(vData!=undefined && vData.length>0){
				helper.showMessage(component, event, $A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),$A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),'Error');
			}
		}
	},
	
	navigateToSObject: function (component, event, helper) {
		var action  = event.getParam('action');
		var row     = event.getParam('row');
		var selectedRows = event.getParam('selectedRows');
		var navEvt = $A.get("e.force:navigateToSObject");
		var ediEvt = $A.get("e.force:editRecord");
		var windowHash = window.location.hash;
		switch (action.name) {
		case 'edit_details_asset':
			component.set("v.EditObject","Asset");  
			ediEvt.setParams({
				"recordId": row.AssetId,
				"panelOnDestroyCallback": function(event) {window.location.hash = windowHash;}
			});
			ediEvt.fire();
			break;
		case 'edit_details_account':  
			component.set("v.EditObject","Account");     
			ediEvt.setParams({
				"recordId": row.AccountId,
			});
			ediEvt.fire();
			break;
		case 'get_access': 
			helper.getSecretQuestion(component, event, row.AccountId, row.AssetId);
			break;
		case 'update_role':
			component.set("v.EditObject","AccountContactAssetRelation__c");  
			component.set("v.selectedRecordId",row.Id);
			helper.fetchPickListVal(component, 'AccountRole__c', 'FieldRole');
			component.find("theStaticModalOwner").openModal();
			break;
		case 'new_appointment': 
			helper.isRepeatRepairJs(component, row.Id);
			break;
		}
	},
	
	handleClick: function(component, event, helper) {
		var e = event.getSource().getLocalId()
		var rel_id = component.get("v.setdata") != undefined && component.get("v.setdata") != "" ? component.get("v.setdata")[0][8].fieldvalue : "";

		switch( e ) {
			case "_new_appointment_bar":
				helper.createWorkshopAppointment(
					component,
					rel_id,
					false
				);
				
				break;
			
			case "_new_quickReception_bar":
				if( component.get( "v.setdata_tmp" )[ component.get( "v.setdata" )[0][9].fieldvalue + component.get( "v.setdata" )[0][10].fieldvalue ] == undefined ){
					helper.createWorkshopAppointment(
						component,
						rel_id,
						true
					);
					
					component.find( "AfterSalesSearchCounters" ).reloadCounters();
					
					var setdata_tmp				= component.get( "v.setdata_tmp" );
					setdata_tmp[ component.get( "v.setdata" )[0][9].fieldvalue + component.get( "v.setdata" )[0][10].fieldvalue ] = true;
					component.set( "setdata_tmp", setdata_tmp );
					
				}else{
					helper.showMessage( component, event, "ERROR", $A.get( "$Label.c.AfterSalesQuickReceptionError" ), "error" );
				}
				
				break;
				
			case "_new_estimation_bar":
				var navURL			= $A.get( "e.force:navigateToURL" );
				
				navURL.setParams( {
					"url" : component.get( "v.attributesByGlobalSetting.APPOINTMENT.Estimation_URL" )
				} );
				
				navURL.fire();
				
				break;
				
			default:
				break;
		}

		return;
	},

	onOpenStaticModal : function(component, event, helper) {
		helper.getSecretQuestion(component,event);
		component.find("theStaticModal").openModal();
	},

	onConfirm : function(component, event, helper) {
		var sId             = event.getSource().getLocalId();
		if (sId=='buttonConfirmRole') {
			helper.setAccountRole(component,event);

		}else if(sId=='buttonConfirmRel'){
			helper.createAccountAssetRel(component,event);
			helper.setRowsSelected( component, event, component.get( "v.setdata" ) );
			
		}else{
			helper.getSecretResponse(component,event);    
		}
	},
	
	onCancel : function(component, event, helper) {
		var sId             = event.getSource().getLocalId();
		if (sId=='buttonCancelRole') {
			component.set("v.selectedRecordId","");
			component.find("theStaticModalOwner").closeModal();
			
		}else if( sId == "buttonCancelRel" || sId=="buttonCloselRel" ){
			var setRows = [];
			component.set("v.setdata",undefined);
			component.set("v.selectedAssetRow","");
			component.set("v.selectedAccRow","");
			component.set("v.selectedRowsAcc",setRows);
			component.set("v.selectedRowsAst",setRows);
			component.set("v.selectedRowsRel",setRows);
			component.find("SaveRecordRel").set("v.value",false);
			component.find("theStaticModalRelation").closeModal();
			
		} else{
			component.set("v.selectedRecord","");
			component.find("theStaticModal").closeModal();
			helper.showToast(component, event, helper, "warning");
		}
		component.set("v.message", "You clicked the 'Cancel' button.");
	},
	
	onCreateRecord : function (component, event, helper){
		var createRecordLoad     = component.find('cmpCreateRecord');
		var attrObjects          = component.get("v.From");
		createRecordLoad.dataLoad(attrObjects);
	},
	
	changeState: function (component, event) {
		var isexpanded = component.find("sectionHide");
		
		if( component.get( "v.showData" ) ){
			component.set( "v.data", component.get( "v.data_tmp" ) );
			$A.util.removeClass( isexpanded, "slds-hide" );
			$A.util.addClass( isexpanded, "slds-show" );
			
		}else{
			component.set( "v.data_tmp", component.get( "v.data" ) );
			component.set( "v.data", undefined );
			$A.util.addClass( isexpanded, "slds-hide" );
			$A.util.removeClass( isexpanded, "slds-show" );
		}
	},
})