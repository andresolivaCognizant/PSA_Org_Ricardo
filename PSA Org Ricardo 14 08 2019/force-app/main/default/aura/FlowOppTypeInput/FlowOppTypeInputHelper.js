({
	loadTypes : function(cmp, helper) {

		// Lock picklists interactions
		const typeCombo = cmp.find('typeSelection');
		typeCombo.set("v.spinnerActive", true);
		typeCombo.set("v.disabled", true);
		
		const oppCombo = cmp.find('opportunitySelection');
		oppCombo.set("v.spinnerActive", true);
		oppCombo.set("v.disabled", true);

		const country = cmp.get('v.country');
		if(!$A.util.isUndefinedOrNull(country)){
			LightningUtilsLib(cmp).executeApexAction('c.getTypeOptions',{country},true)
			.then($A.getCallback(
				function (result) {
					const retrievedTypes = result.getReturnValue()
					cmp.set('v.lstTypes', retrievedTypes);

					if(retrievedTypes && !$A.util.isEmpty(retrievedTypes)){

						cmp.set('v.type', result.getReturnValue()[0].value);
						
						// Refresh opportunities
						helper.loadOpportunities(cmp);
						
						// Unlock interactions
						const typeCombo = cmp.find('typeSelection');
						typeCombo.set("v.spinnerActive", false);
						typeCombo.set("v.disabled", false);
					}
				}
			))
			.catch($A.getCallback(
				function (result) {
				}
			));
		}
	},
	loadOpportunities : function(cmp) {
		const accountId = cmp.get('v.accountId');
		const type = cmp.get('v.type');

		if(!$A.util.isUndefinedOrNull(accountId) 
		 && !$A.util.isUndefinedOrNull(type) ){

			LightningUtilsLib(cmp).executeApexAction('c.getOpportunityOptions',{accountId, type},true)
			.then($A.getCallback(
				function (result) {
					const retrievedOpps = result.getReturnValue();
					cmp.set('v.lstOpportunities', retrievedOpps);

					if(retrievedOpps && !$A.util.isEmpty(retrievedOpps)){

						cmp.set('v.oppId', result.getReturnValue()[0].value);
						
						// Unlock combobox interactions 
						const oppCombo = cmp.find('opportunitySelection');
						oppCombo.set("v.spinnerActive", false);
						oppCombo.set("v.disabled", false);
					}
				}
			))
			.catch($A.getCallback(
				function (result) {
				}
			));
		}

	},
})