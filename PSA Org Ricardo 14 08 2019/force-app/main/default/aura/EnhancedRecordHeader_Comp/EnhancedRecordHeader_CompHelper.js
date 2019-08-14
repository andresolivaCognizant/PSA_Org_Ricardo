({
	retrieveRecordDetails : function(cmp, idOfTheRecord, recordToSet) {
		const recordId = cmp.get(idOfTheRecord);

		if (recordId) {
			LightningUtilsLib(cmp).executeApexAction('c.getRecordDetails',{recordId},true)
			.then($A.getCallback(
				function (result) {
					cmp.set(recordToSet, result.getReturnValue().record);
				}
			));
		}
	},
	retrieveHeaderConfig : function(cmp) {
		const configName = cmp.get('v.configName');

		if (configName) {
			LightningUtilsLib(cmp).executeApexAction('c.getEnhancedHeaderConfig',{configName},true)
			.then($A.getCallback(
				function (result) {
					let config = JSON.parse(result.getReturnValue());
					cmp.set('v.config', config);
				}
			))
		}
	},
	getAccountDetails : function(cmp, idOfTheRecord, recordToSet) {
		const recordId = cmp.get(idOfTheRecord);

		if (recordId) {
			LightningUtilsLib(cmp).executeApexAction('c.getAccountDetails',{recordId},true)
			.then($A.getCallback(
				function (result) {
					cmp.set(recordToSet, result.getReturnValue().record);
					cmp.set('v.customerId', result.getReturnValue().recordId);
				}
			));
		}
	},
})