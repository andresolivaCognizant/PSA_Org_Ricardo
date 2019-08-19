({
	goBack : function(cmp, event, helper){
		window.history.back();
	},
	goToRecord : function(cmp, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": cmp.get('v.recordId')});
        navEvt.fire();
	},
	goToAccount : function(cmp, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": cmp.get('v.customerId')});
        navEvt.fire();
	},
	doLibLoaded : function(cmp, event, helper) {

		helper.retrieveHeaderConfig(cmp);

		// Get the record data.
		helper.retrieveRecordDetails(cmp, 'v.recordId', 'v.record');

		let customerId = cmp.get('v.customerId');

		// If the Id of the Account (customerId) happens to be null, empty or undefined, get it from a Query.
		if (customerId) {
			// Get the Account Data.
			helper.retrieveRecordDetails(cmp, 'v.customerId', 'v.accountRecord');
		}
		else {

			// As we do not have the Id of the Account (customerId), get it with the method bellow
			//  which will call the method retrieveRecordDetails passing it as a parameter.
			helper.getAccountDetails(cmp, 'v.recordId', 'v.accountRecord');
		}
	},

})