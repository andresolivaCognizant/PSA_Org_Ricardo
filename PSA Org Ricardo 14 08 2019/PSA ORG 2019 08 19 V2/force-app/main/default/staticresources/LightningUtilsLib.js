/**
* @Name             :   LightningUtilsLib
* @Author           :   Ricardo Pereira Ramirez
* @Created          :   13/12/2018
* @Description      :   This library should provide reusable, useful and accesible common functions to use on lightning components.
* 						Component context must be provided everytime this library is called.
* @Methods (public)   
* 		- executeApexAction: calls a method of the component's Apex controller and returns a Promise() with the result
* @Methods (private)   
*       - displayErrorToast
*/ 
window.LightningUtilsLib = function (cmp) {
	/******************** PRIVATE ATTRIBUTES AND FUNCTIONS *********************/

	const displayErrorToast = function (title,message) {
		const toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			message,
			mode: 'sticky',
			title,
			type: 'error',
		});
		toastEvent.fire();
	};

	return {
		/****************** PUBLIC ACCESIBLE FUNCTIONS **********************/

		/*
		* @Method			:	executeApexAction
		* @Description		:	calls a method of the component's Apex controller and returns a Promise() with the result
		* @Params			:	methodName: String - The name of the Apex method as c.methodName
		* @Params			:	params: Object - Method parameters as key/value pairs
		* @Params			:	showErrorToast: Boolean - true if a lightning toast should be shown in case of an error
		* @Returns			:	a resolved or rejected Promise() depending on the re
		*/ 
		executeApexAction : function (methodName, params, showErrorToast) {

			return new Promise(function (resolve, reject) {
				const action = cmp.get(methodName);
				if (params) {
					action.setParams(params);
				}
				action.setCallback(this, function (response) {
					if (response.getState() === 'SUCCESS') {
						resolve(response);
					} else {
						const errors = response.getError();
						if (errors) {
							if (errors[0] && errors[0].message) {
								if (showErrorToast) {
									displayErrorToast('Error',errors[0].message + '\n' );
								}
								reject(Error(errors[0].message));
							}else{
								if (showErrorToast) {
									displayErrorToast('Error', '');
								}
								reject(Error(errors));
							}
						}
						else {
							if (showErrorToast) {
								displayErrorToast('Error', '' );
							}
							reject(Error('Unknown error'));
						}
					}
				});
				
				// setTimeout could be use to avoid diferent calls in the same transaction
				/* setTimeout($A.getCallback(
					function() {
						$A.enqueueAction(action);
					}),
					0,
				); */
				$A.enqueueAction(action);
			});
		}
	};
}