({
	doLibLoaded : function(cmp, evt, helper) {
		helper.getCountryType(cmp);
	},
	handletNextClick : function(cmp, evt, helper) {
		helper.createNewAsset(cmp);
	}
})