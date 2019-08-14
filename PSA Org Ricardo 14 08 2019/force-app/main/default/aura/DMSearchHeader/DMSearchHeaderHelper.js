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
    setMenuSelection : function setMenuSelection(component, sField, selectedValue){
        
            var menuItems   = component.find(sField);
            var sNField     = '';
            var sLabel      = '';
            menuItems.forEach(function (menuItem) {
                // For each menu item, if it was checked, un-check it. This ensures that only one
                // menu item is checked at a time
                if (menuItem.get("v.checked")) {
                    menuItem.set("v.checked", false);
                }
                // Check the selected menu item
                if (menuItem.get("v.value") === selectedValue) {
                    var val = menuItem.get("v.label");
                    if(sField==='mItemsFld'){
                        component.set("v.filterFieldLabel",val);
                        sNField =  'FilterPillsField';
                    }else{
                        component.set("v.filterDateLabel",val);
                        sNField =  'FilterPillsDates';
                    }
                    sLabel      = val;
                    menuItem.set("v.checked", true);
                }
            });
            this.addNewPills(component, sLabel, sNField);
    },
    unsetMenuSelection : function(component, sField){
        var menuItems   = component.find(sField);
        menuItems.forEach(function (menuItem) {
            // For each menu item, if it was checked, un-check it. This ensures that only one
            // menu item is checked at a time
            if (menuItem.get("v.checked")) {
                menuItem.set("v.checked", false);
            }
            
        });
    },
    addNewPills: function(component,values,sField) {
        console.log("Enter");
        var pills = [];
        var trimmedVal = values.trim();
        if (trimmedVal !== "") {
            pills.push({
                id        : this.guidGenerator(component),
                label     : trimmedVal,
                isValid   : this.isInputValid(component, trimmedVal)
            });
        }
        if(sField === 'FilterPillsField'){
            component.set("v.FilterPillsField", pills);
        }else{
            component.set("v.FilterPillsDates", pills);
        }
    },
    guidGenerator: function(component) {
      var S4 = function() {
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
      };
      return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
    },
    isInputValid: function(component, value) {
        return true;
    },
    parseFieldToPills: function(component,label,field) {
        var pills               = [];
        pills.push({
            id      : this.guidGenerator(component),
            label   : label,
            isValid : true
        });
        if(field === 'FilterPillsField'){
            component.set("v.FilterPillsField", pills);
        }else{
            component.set("v.FilterPillsDates", pills);
        }
    },
    /*sendAction : function(component, event) {
        var appEvent            = $A.get("e.c:DMSearchEvent");
        appEvent.setParams({
            "searchByAccount"   : component.get("v.searchByAccount"),
            "searchByAsset"     : component.get("v.searchByAsset"),
            "searchBySales"   	: component.get("v.searchBySales"),
            "searchByAfterSales"     : component.get("v.searchByAfterSales"),
            "refreshData"       :true
        });
        appEvent.fire();
    },*/

})