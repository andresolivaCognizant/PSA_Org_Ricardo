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
    sendAction : function(component, event) {
        var appEvent            = $A.get("e.c:AfterSalesSearchEvent");
        appEvent.setParams({
            "searchByAccount"   : component.get("v.searchByAccount"),
            "searchByAsset"     : component.get("v.searchByAsset"),
            "refreshData"       :true
        });
        appEvent.fire();
    },

})