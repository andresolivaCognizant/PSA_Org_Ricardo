({
	handleonclick : function(component, event, helper) {
		var appEvent 			= $A.get("e.c:DMSearchEvent");
        appEvent.setParams({
            "searchByAccount" 	: component.get("v.searchByAccount"),
            "searchByAsset"		: component.get("v.searchByAsset"),
            "searchBySales"		: component.get("v.searchBySales"),
            "searchByAfterSales": component.get("v.searchByAfterSales"),
            "filterDate"		: component.get("v.filterDate"),
            "filterField"		: component.get("v.filterField"),
            "filterCriteria"	: component.get("v.filterCriteria"),
            "refreshData" 		: component.get("v.filterrows")
        });
        appEvent.fire();
	},
	handleFilterSelection: function (component, event,helper) {
		console.log('fire');
        var selectedMenuItemValue  = event.getParam("value");
        var sSource 			   = event.getSource();

		if(sSource.getLocalId() === 'filterMenu'){
	        helper.setMenuSelection(component, 'mItemsFld',selectedMenuItemValue);
			component.set("v.filterField",selectedMenuItemValue);
		}else{
			helper.setMenuSelection(component, 'mItemsDtd',selectedMenuItemValue);
			component.set("v.filterDate",selectedMenuItemValue);
		}
		sSource.set("v.checked", !sSource.get("v.checked"));
    },
    onRemovePillDates: function(component, event, helper) {
		var pillId 			= event.getSource().get('v.name');
		var pills 			= [];
		helper.unsetMenuSelection(component, "mItemsDtd");
		component.set("v.FilterPillsDates", pills);
		component.set("v.filterDate","");
	},
	onRemovePillField: function(component, event, helper) {
		var pillId 			= event.getSource().get('v.name');
		var pills 			= [];
		helper.unsetMenuSelection(component, "mItemsFld");
		component.set("v.FilterPillsField", pills);
		component.set("v.filterField","");
	},
})