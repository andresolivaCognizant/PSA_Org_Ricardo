({
	doInit : function(component, event, helper) {   
		var divNoResults = component.find("divNoResults");
		$A.util.addClass(divNoResults, "slds-hide");
		
		var interval			= window.setTimeout(
			$A.getCallback( function(){
				component.find( "DMSearchCounters" ).reloadCounters(
					function( result ) {
						console.log( result );
					}
				);
			} ),
			1000
		);
		helper.fetchPickListVal(component,event);
	},
	
	handleSearchEvent: function(component, event, helper) {
		var searchByAccount 	= event.getParam("searchByAccount");
		var searchByAsset   	= event.getParam("searchByAsset");
		var searchBySales 		= event.getParam("searchBySales");
		var searchByAfterSales  = event.getParam("searchByAfterSales");
		var refreshData        	= event.getParam("refreshData");
		var doSearch        	= event.getParam("doSearch");
		component.set("v.searchByAccount",searchByAccount);
		component.set("v.searchByAsset",searchByAsset);
		component.set("v.searchBySales",searchBySales);
		component.set("v.searchByAfterSales",searchByAfterSales);
		component.set("v.filterrows",refreshData);
		if(doSearch==undefined || doSearch)
			helper.getData(component, event);
	},
	handleRunSearchEvent: function(component, event, helper) {
		helper.getData(component, event,true);
	},
	handleFilterSelection: function (component, event) {
        var selectedMenuItemValue = event.getParam("value");
        console.log('Item selected with value: ' + selectedMenuItemValue);
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
		var lstValidRowsSelected= [];
		var iMembers			= 0;
		var selectedRows        = event.getParam('selectedRows');
		if(selectedRows != undefined){
			for (var i = 0; i < selectedRows.length; i++){
				lstRowsSelected.push({value: selectedRows[i].Id});
				lstFullRowsSelected.push(selectedRows[i]);
				if(selectedRows[i].CampaignMember=="true"){
					iMembers +=1;
				}else{
					lstValidRowsSelected.push(selectedRows[i].Id);
				}
			}
			var auxCol0 = component.get("v.shortcolumns");
			component.set("v.setdata",undefined);
			component.set("v.shortcolumns",undefined);
			component.set("v.setdata",lstFullRowsSelected);
			component.set("v.selectedRows",lstRowsSelected);
			component.set("v.validRows",lstValidRowsSelected);
			component.set("v.numberRows",selectedRows.length);
			component.set("v.numberRowsKO",iMembers);
			component.set("v.shortcolumns",auxCol0);
		}else{
			var vData = component.get("v.data");
			if(vData!=undefined && vData.length>0){
				helper.showMessage(component, event, $A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),$A.get("$Label.c.AfterSalesSearchErrorAssetSelection"),'Error');
			}
		}
	},
	handleClick: function(component, event, helper) {
	 	var e = event.getSource().getLocalId()
		switch( e ) {
			case "_add_campaign_members":
				helper.onOpenStaticModal(component);
				break;
			default:
				break;
		}
		return;
	},
	onConfirm : function(component, event, helper) {
		var sId             = event.getSource().getLocalId();
		if (sId=='buttonConfirmResponse') {
			var aux1 = component.get("v.numberRows");
			var aux2 = component.get("v.numberRowsKO");
			if( aux1 - aux2 > 0 ){
				helper.createEntries(component,event);
			}
			component.find("theStaticModal").closeModal();
		}
	},
	onCancel : function(component, event, helper) {
		var sId             = event.getSource().getLocalId();
		if (sId=='buttonCancelResponse') {
			component.set("v.selectedRecordId","");
			component.find("theStaticModal").closeModal();
		}
		component.set("v.message", "You clicked the 'Cancel' button.");
	},
	// changeState: function (component, event) {
	// 	console.log('OK');	
	// 	var isexpanded = component.find("sectionHide");
		
	// 	/* BEGIN - Manuel Medina - C1STAGILE-5325 - New logic to avoid deformed table when the table is close/open after visibilty toggle action - 08112018 */
	// 	if( component.get( "v.showData" ) ){
	// 		component.set( "v.data", component.get( "v.data_tmp" ) );
	// 		$A.util.removeClass( isexpanded, "slds-hide" );
	// 		$A.util.addClass( isexpanded, "slds-show" );
			
	// 	}else{
	// 		component.set( "v.data_tmp", component.get( "v.data" ) );
	// 		component.set( "v.data", undefined );
	// 		$A.util.addClass( isexpanded, "slds-hide" );
	// 		$A.util.removeClass( isexpanded, "slds-show" );
	// 	}
	// },
})