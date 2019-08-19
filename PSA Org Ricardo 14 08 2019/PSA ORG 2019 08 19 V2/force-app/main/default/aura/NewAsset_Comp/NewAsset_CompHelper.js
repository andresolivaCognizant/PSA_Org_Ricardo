({
	getCountryType : function(cmp) {
		
		LightningUtilsLib(cmp).executeApexAction('c.getCountryType',{},true)
		.then($A.getCallback(
			function (result) {
				cmp.set('v.isOPV', result.getReturnValue());
			}
		))
		.catch($A.getCallback(
			function (result) {
			}
		));
	},
	createNewAsset : function(cmp) {
		//cmp.set('v.isLoading', true);
		/*LightningUtilsLib(cmp).executeApexAction('c.createNewAsset',{accountId: cmp.get('v.recordId')},false)
		.then($A.getCallback(
			function (result) {
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					'recordId': result.getReturnValue()
				});
				navEvt.fire();
			}
		))
		.catch($A.getCallback(
			function (result) {
				console.log(JSON.stringify(result));
			}
		))
		.finally($A.getCallback(
			function () {
				cmp.set('v.isLoading', false);
			}
		));*/

		let createRecordEvent = $A.get("e.force:createRecord");
		createRecordEvent.setParams({
			"entityApiName": "Asset",
			"defaultFieldValues": {
				'AccountId' : cmp.get('v.recordId')
			}
		});
		createRecordEvent.fire();
	}
})