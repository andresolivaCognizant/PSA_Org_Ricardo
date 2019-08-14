({
	getMUpParams: function(component) {

		var isFlow = component.get("v.isFlow");
		var isButton = component.get("v.isButton");
		var isCommunity = component.get("v.isCommunity");
		var mUpName = component.get("v.mUpName");

		if (isFlow === "true" || isFlow === true) {
			var dealerId            = this.clearUndefined(component.get("v.dealerId"));
			var salesAgentId        = this.clearUndefined(component.get("v.salesAgentId"));
			var localeId            = this.clearUndefined(component.get("v.localeId"));
			var brand               = this.clearUndefined(component.get("v.brand"));
			var slCustomerId        = this.clearUndefined(component.get("v.slCustomerId"));
			var slDriverId          = this.clearUndefined(component.get("v.slDriverId"));
			var slLessorId          = this.clearUndefined(component.get("v.slLessorId"));
			var slContactPersonId   = this.clearUndefined(component.get("v.slContactPersonId"));
			var slOpportunityId     = this.clearUndefined(component.get("v.slOpportunityId"));
			var slQuoteId           = this.clearUndefined(component.get("v.slQuoteId"));
			var slContractId        = this.clearUndefined(component.get("v.slContractId"));
			var slOrderId           = this.clearUndefined(component.get("v.slOrderId"));
			var slCustomerType      = this.clearUndefined(component.get("v.slCustomerType"));
			// US 7183 BEGIN
			var slLeaserContactPersonId = this.clearUndefined(component.get("v.slLeaserContactPersonId"));
			// US 7183 END

			/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
			var sdhCustomerId		= this.clearUndefined( component.get( "v.sdhCustomerId" ) );
			var sdhContactPersonId	= this.clearUndefined( component.get( "v.sdhContactPersonId" ) );
			var sdhDriverId			= this.clearUndefined( component.get( "v.sdhDriverId" ) );
			/* END - Manuel Medina - 08042019 */

			/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
			var sdhLessorId					= this.clearUndefined( component.get( "v.sdhLessorId" ) );
			var sdhLeaserContactPersonId	= this.clearUndefined( component.get( "v.sdhLeaserContactPersonId" ) );
			var sdhQuoteId					= this.clearUndefined( component.get( "v.sdhQuoteId" ) );
			var sdhContractId				= this.clearUndefined( component.get( "v.sdhContractId" ) );
			var sdhOrderId					= this.clearUndefined( component.get( "v.sdhOrderId" ) );
			var sdhVpoId					= this.clearUndefined( component.get( "v.sdhVpoId" ) );
			/* END - Manuel Medina - 08042019 */

			var country = this.clearUndefined( component.get( "v.country" ) );


			var action = component.get("c.getFlowMUpParamsByBrandCountry");

			action.setParams({
				mUpName: mUpName,
				countryParam: country,
				brandParam: brand
			});
		
			action.setCallback(this, function(response) {
				var state = response.getState();
				console.log('setTransferRecords.state : ' + state);

				if (state === "SUCCESS") {

					var storeResponse = response.getReturnValue();
					var exception = storeResponse.includes("exception");

					// if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
					if (storeResponse.length === 0 || exception === true) {
						var toastEvent = $A.get("e.force:showToast");

						toastEvent.setParams({
							"type": "error",
							"duration": 5000,
							"message": "No URL was found"
						});

						toastEvent.fire();
					} else if (exception === true) {
						var toastEvent = $A.get("e.force:showToast");

						toastEvent.setParams({
							"type": "error",
							"duration": 5000,
							"message": storeResponse
						});

						toastEvent.fire();
					} else {
						component.set("v.Message", '');

						var iframeURL = storeResponse;

						if (mUpName === 'Quote VN Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							iframeURL = iframeURL + "&slLessorId=" + slLessorId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							// US 7183 BEGIN
							iframeURL = iframeURL + "&slLeaserContactPersonId=" + slLeaserContactPersonId;
							// US 7183 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							iframeURL = iframeURL + "&sdhLessorId=" + sdhLessorId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhLeaserContactPersonId=" + sdhLeaserContactPersonId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Quote VD Creation' || mUpName === 'Quote VO Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
						
						//US C1STAGILE-6965 BEGIN
						if (mUpName === 'Quote VD Creation'){
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							/* END - Manuel Medina - 08042019 */
						}
						//US C1STAGILE-6965 END	

						/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
						iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
						iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
						/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Quote VN Edition' || action === 'Quote VD Edition' || action === 'Quote VO Edition') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slQuoteId=" + slQuoteId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhQuoteId=" + sdhQuoteId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Contract VN Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slQuoteId=" + slQuoteId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							iframeURL = iframeURL + "&slLessorId=" + slLessorId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							// US 7183 BEGIN
							iframeURL = iframeURL + "&slLeaserContactPersonId=" + slLeaserContactPersonId;
							// US 7183 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							iframeURL = iframeURL + "&sdhLessorId=" + sdhLessorId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhLeaserContactPersonId=" + sdhLeaserContactPersonId;
							iframeURL = iframeURL + "&sdhQuoteId=" + sdhQuoteId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Contract VD Creation' || mUpName === 'Contract VO Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slQuoteId=" + slQuoteId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;

							if (slCustomerType == 'B2B') {
								iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							}
						
							//US C1STAGILE-6965 BEGIN
							if (mUpName === 'Contract VD Creation'){
								iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							}
							//US C1STAGILE-6965 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhQuoteId=" + sdhQuoteId;
							/* END - Manuel Medina - 08042019 */
							
						} else if (mUpName === 'Contract VN Edition' || mUpName === 'Contract VN Validation' || mUpName === 'Contract VD Edition' || mUpName === 'Contract VD Validation' || mUpName === 'Contract VO Edition' || mUpName === 'Contract VO Validation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slContractId=" + slContractId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhContractId=" + sdhContractId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Order VN Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slContractId=" + slContractId;
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							iframeURL = iframeURL + "&slLessorId=" + slLessorId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							// US 7183 BEGIN
							iframeURL = iframeURL + "&slLeaserContactPersonId=" + slLeaserContactPersonId;
							// US 7183 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhLessorId=" + sdhLessorId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhLeaserContactPersonId=" + sdhLeaserContactPersonId;
							iframeURL = iframeURL + "&sdhContractId=" + sdhContractId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Order VN Edition') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slOrderId=" + slOrderId;
							iframeURL = iframeURL + "&slContractId=" + slContractId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhOrderId=" + sdhOrderId;
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'Service Contract') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;

							if (slCustomerType == 'B2B') {
								iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							}

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'OPV Menu Access') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'VN Delivery Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slOrderId=" + slOrderId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							iframeURL = iframeURL + "&slLessorId=" + slLessorId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							// US 7183 BEGIN
							iframeURL = iframeURL + "&slLeaserContactPersonId=" + slLeaserContactPersonId;
							// US 7183 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhOrderId=" + sdhOrderId;
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							iframeURL = iframeURL + "&sdhLessorId=" + sdhLessorId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhLeaserContactPersonId=" + sdhLeaserContactPersonId;
							/* END - Manuel Medina - 08042019 */

						} else if (mUpName === 'VO Delivery Creation' || mUpName === 'VD Delivery Creation') {
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slContractId=" + slContractId;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							
							//US C1STAGILE-6965 BEGIN
							if (mUpName === 'VD Delivery Creation') {
								iframeURL = iframeURL + "&slDriverId=" + slDriverId;

								/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
								iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
								/* END - Manuel Medina - 08042019 */
							}
							//US C1STAGILE-6965 END

							/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
							iframeURL = iframeURL + "&sdhContractId=" + sdhContractId;
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							/* END - Manuel Medina - 08042019 */

						/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
						}else if( mUpName === 'Online Configuration' ){
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							iframeURL = iframeURL + "&slDriverId=" + slDriverId;
							iframeURL = iframeURL + "&slOpportunityId=" + slOpportunityId;
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
							iframeURL = iframeURL + "&sdhDriverId=" + sdhDriverId;
							/* END - Manuel Medina - 08042019 */
							
						}else if( mUpName === 'Protocol solicitation' ){
							iframeURL = iframeURL + "&dealerId=" + dealerId;
							iframeURL = iframeURL + "&salesAgentId=" + salesAgentId;
							iframeURL = iframeURL + "&localeId=" + localeId;
							iframeURL = iframeURL + "&brand=" + brand;
							iframeURL = iframeURL + "&slCustomerId=" + slCustomerId;
							iframeURL = iframeURL + "&slContactPersonId=" + slContactPersonId;
							iframeURL = iframeURL + "&slCustomerType=" + slCustomerType;
							iframeURL = iframeURL + "&sdhCustomerId=" + sdhCustomerId;
							iframeURL = iframeURL + "&sdhContactPersonId=" + sdhContactPersonId;
						}

						//iframeURL = iframeURL + "&protocol=https";
						console.log("iframe: ", iframeURL);
						component.set("v.iframeURL", iframeURL);
					}

				} else if (state === "ERROR") {
					var errors = response.getError();

					var toastEvent = $A.get("e.force:showToast");

					toastEvent.setParams({
						"type": "error",
						"duration": 5000,
						"message": errors[0].message
					});

					toastEvent.fire();
				}
			});

			$A.enqueueAction(action);

		} else {

			if (isButton === "true" || isButton === true) {
				var objName = component.get("v.objName");
				var recId = component.get("v.recId");
			} else {
				var p = window.location.pathname;
				var sPageURL = decodeURIComponent(p);
				var sURLVariables = sPageURL.split('/');
				var objName;
				var i;

				for (i = 0; i < sURLVariables.length; i++) {
					if (i === 3) {
						objName = undefined ? null : sURLVariables[3];
					}
				}

				var recId = component.get("v.recordId");
			}

			var action = component.get("c.getMUpParams");

			action.setParams({
				mUpName: mUpName,
				objName: objName,
				recId: recId
			});

			action.setCallback(this, function(response) {
				var state = response.getState();

				console.log('setTransferRecords.state : ' + state);

				if (state === "SUCCESS") {

					var storeResponse = response.getReturnValue();
					var exception = storeResponse.includes("exception");

					// if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
					if (storeResponse.length === 0 || exception === true) {
						var toastEvent = $A.get("e.force:showToast");

						toastEvent.setParams({
							"type": "error",
							"duration": 5000,
							"message": storeResponse
						});

						toastEvent.fire();
					} else {
						component.set("v.Message", '');

						var iframeURL = storeResponse;

						console.log("iframe: ", iframeURL);

						component.set(
							"v.iframeURL",
							iframeURL //.replace(/(?<==)null(?=(&|$))/gm,"")
						);
					}

				} else if (state === "ERROR") {
					var errors = response.getError();

					var toastEvent = $A.get("e.force:showToast");

					toastEvent.setParams({
						"type": "error",
						"duration": 5000,
						"message": errors[0].message
					});

					toastEvent.fire();
				}
			});

			$A.enqueueAction(action);
		}
	},

	clearUndefined: function(val) {
		if (val == "undefined" || val == "null" || !val) {
			return "";
		}
		return val;
	}
})