({
	IsEmptyValue : function(value) {
		return ($A.util.isUndefinedOrNull(value) || $A.util.isEmpty(value))?true:false;
	},
	getValue : function(value) {
		return ($A.util.isUndefinedOrNull(value) || $A.util.isEmpty(value))?'':value;
	},
	handlePills : function (component,event,searchByAccount,searchByAsset){
		
		var appEventSearchPill  = $A.get("e.c:AfterSalesSearchHeaderFieldEvent");  
			if(appEventSearchPill != undefined){
					appEventSearchPill.setParams({
						"runPillsAcc"   : searchByAccount,
						"runPillsAss"   : searchByAsset
					});
			appEventSearchPill.fire();
		}
	},
})