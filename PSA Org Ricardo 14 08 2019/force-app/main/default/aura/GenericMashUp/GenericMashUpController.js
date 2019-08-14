({
	doInit: function (component, event, helper) {
		debugger;
		var a = window.location.href;
		var b = a.substring(a.indexOf("?") + 1);

		var sPageURL = decodeURIComponent(b);
		var sURLVariables = sPageURL.split('&');

		var sParameterName;
		var i;

		var mUpName;
		var isCommunity;
		var isFlow;
		var isButton;
		var dealerId;
		var salesAgentId;
		var localeId;
		var brand;
		var slCustomerId;
		var slDriverId;
		var slLessorId;
		var slContactPersonId;
		var slOpportunityId;
		var slCustomerType;
		var slQuoteId;
		var slOrderId;
		var recId;
		var objName;
		var slContractId;
		// US 7183 BEGIN
		var slLeaserContactPersonId;
		// US 7183 END

		/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
		var sdhCustomerId;
		var sdhContactPersonId;
		var sdhDriverId;
		/* END - Manuel Medina - 08042019 */

		/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
		var sdhLessorId;
		var sdhLeaserContactPersonId;
		var sdhQuoteId;
		var sdhContractId;
		var sdhOrderId;
		var sdhVpoId;
		/* END - Manuel Medina - 08042019 */

		/*Parameter Number	Parameter Name
		p1					mUpName
		p2					isCommunity
		p3					isFlow
		p4					isButton
		p5					dealerId
		p6					salesAgentId
		p7					localeId
		p8					brand
		p9					slCustomerId
		p10					slDriverId
		p11					slLessorId
		p12					slContactPersonId
		p13					slOpportunityId
		p14					slCustomerType
		p15					slQuoteId
		p16					recId
		p17					objName
		p18					slOrderId
		p19					slContractId
		p20					slLeaserContactPersonId
		p21					sdhCustomerId
		p22					sdhDriverId
		p23					sdhLessorId
		p24					sdhContactPersonId
		p25					sdhLeaserContactPersonId
		p26					sdhQuoteId
		p27					sdhContractId
		p28					sdhOrderId
		p29					sdhVpoId
		*/

		for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('=');

			//p1 = mUpName
			if (sParameterName[0] === 'p1') {
				mUpName = undefined ? null : sParameterName[1];
			}
			//p2 = isCommunity
			if (sParameterName[0] === 'p2') {
				isCommunity = undefined ? null : sParameterName[1];
			}
			//p3 = isFlow
			if (sParameterName[0] === 'p3') {
				isFlow = undefined ? null : sParameterName[1];
			}
			//p4 = isButton
			if (sParameterName[0] === 'p4') {
				isButton = undefined ? null : sParameterName[1];
			}
			//p5 = dealerId
			if (sParameterName[0] === 'p5') {
				dealerId = undefined ? null : sParameterName[1];
			}
			//p6 = salesAgentId
			if (sParameterName[0] === 'p6') {
				salesAgentId = undefined ? null : sParameterName[1];
			}
			//p7 = localeId
			if (sParameterName[0] === 'p7') {
				localeId = undefined ? null : sParameterName[1];
			}
			//p8 = brand
			if (sParameterName[0] === 'p8') {
				brand = undefined ? null : sParameterName[1];
			}
			//p9 = slCustomerId
			if (sParameterName[0] === 'p9') {
				slCustomerId = undefined ? null : sParameterName[1];
			}
			//p10 = slDriverId
			if (sParameterName[0] === 'p10') {
				slDriverId = undefined ? null : sParameterName[1];
			}
			//p11 = slLessorId
			if (sParameterName[0] === 'p11') {
				slLessorId = undefined ? null : sParameterName[1];
			}
			//p12 = slContactPersonId
			if (sParameterName[0] === 'p12') {
				slContactPersonId = undefined ? null : sParameterName[1];
			}
			//p13 = slOpportunityId
			if (sParameterName[0] === 'p13') {
				slOpportunityId = undefined ? null : sParameterName[1];
			}
			//p14 = slCustomerType
			if (sParameterName[0] === 'p14') {
				slCustomerType = undefined ? null : sParameterName[1];
			}
			//p15 = slQuoteId
			if (sParameterName[0] === 'p15') {
				slQuoteId = undefined ? null : sParameterName[1];
			}
			//p16 = recId
			if (sParameterName[0] === 'p16') {
				recId = undefined ? null : sParameterName[1];
			}
			//p17 = objName
			if (sParameterName[0] === 'p17') {
				objName = undefined ? null : sParameterName[1];
			}
			//p18 = slOrderId
			if (sParameterName[0] === 'p18') {
				slOrderId = undefined ? null : sParameterName[1];
			}
			//p19 = slContractId
			if (sParameterName[0] === 'p19') {
				slContractId = undefined ? null : sParameterName[1];
			}
			// US 7183 BEGIN
			//p20 = slLeaserContactPersonId
			if (sParameterName[0] === 'p20') {
				slLeaserContactPersonId = undefined ? null : sParameterName[1];
			}
			// US 7183 END

			/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
			if (sParameterName[0] === 'p21') {
				sdhCustomerId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p22') {
				sdhDriverId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p23') {
				sdhLessorId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p24') {
				sdhContactPersonId = undefined ? null : sParameterName[1];
			}
			/* END - Manuel Medina - 08042019 */

			/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
			if (sParameterName[0] === 'p25') {
				sdhLeaserContactPersonId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p26') {
				sdhQuoteId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p27') {
				sdhContractId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p28') {
				sdhOrderId = undefined ? null : sParameterName[1];
			}

			if (sParameterName[0] === 'p29') {
				sdhVpoId = undefined ? null : sParameterName[1];
			}
			/* END - Manuel Medina - 08042019 */
		}

		// Control if is Community
		if (sURLVariables.length > 0 && (isCommunity === "true" || isCommunity === true)) {
			// Quote VN Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slCustomerId + '&' + slDriverId + '&' + slLessorId + '&' + slContactPersonId + '&' + slOpportunityId
			component.set("v.mUpName", mUpName);
			component.set("v.isCommunity", isCommunity);
			component.set("v.isFlow", isFlow);
			component.set("v.isButton", isButton);
			// C1STAGILE-8758 - B
			component.set("v.recId", recId);
			// C1STAGILE-8758 - E

			if (isButton === "true" || isButton === true) {
				// Called from Button
				// Param Order: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + recId + '&' + objName
				// C1STAGILE-8758 - B
				//component.set("v.recId", recId);
				// C1STAGILE-8758 - E
				component.set("v.objName", objName);
			} else {
				//Every MashUp must take its own parameters in this point
				if (mUpName === 'Quote VN Creation') {
					// Quote VN Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slCustomerId + '&' + slDriverId + '&' + slLessorId + '&' + slContactPersonId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slLeaserContactPersonId
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slDriverId", slDriverId);
					component.set("v.slLessorId", slLessorId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					// US 7183 BEGIN
					component.set("v.slLeaserContactPersonId", slLeaserContactPersonId);
					// US 7183 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhDriverId", sdhDriverId);
					component.set("v.sdhLessorId", sdhLessorId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhLeaserContactPersonId", sdhLeaserContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Quote VD Creation' || mUpName === 'Quote VO Creation') {
					// Quote VD/VO Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slCustomerId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slContactPersonId;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					component.set("v.slContactPersonId", slContactPersonId);

					//US C1STAGILE-6965 BEGIN
					if (mUpName === 'Quote VD Creation') {
						component.set("v.slDriverId", slDriverId);

						/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
						component.set("v.sdhDriverId", sdhDriverId);
						/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					}
					//US C1STAGILE-6965 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Quote VN Edition' || mUpName === 'Quote VD Edition' || mUpName === 'Quote VO Edition') {
					// Quote VN/VD Edition Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slQuoteId + '&' + slCustomerId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slContactPersonId;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slQuoteId", slQuoteId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					component.set("v.slContactPersonId", slContactPersonId);

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhQuoteId", sdhQuoteId);
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Contract VN Creation') {
					// Contract VN Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slQuoteId + '&' + slCustomerId + '&' + slDriverId + '&' + slLessorId + '&' + slContactPersonId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slLeaserContactPersonId;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slQuoteId", slQuoteId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slDriverId", slDriverId);
					component.set("v.slLessorId", slLessorId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					// US 7183 BEGIN
					component.set("v.slLeaserContactPersonId", slLeaserContactPersonId);
					// US 7183 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhDriverId", sdhDriverId);
					component.set("v.sdhLessorId", sdhLessorId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhLeaserContactPersonId", sdhLeaserContactPersonId);
					component.set("v.sdhQuoteId", sdhQuoteId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Contract VD Creation' || mUpName === 'Contract VO Creation') {
					// Contract VD/VO Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slQuoteId + '&' + slCustomerId + '&' + slOpportunityId + '&' + slCustomerType;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slQuoteId", slQuoteId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);

					if (slCustomerType == "B2B") {
						component.set("v.slContactPersonId", slContactPersonId);
					}

					//US C1STAGILE-6965 BEGIN
					if (mUpName === 'Contract VD Creation') {
						component.set("v.slDriverId", slDriverId);
					}
					//US C1STAGILE-6965 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhDriverId", sdhDriverId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhQuoteId", sdhQuoteId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Contract VN Edition' || mUpName === 'Contract VN Validation' || mUpName === 'Contract VD Edition' || mUpName === 'Contract VD Validation' || mUpName === 'Contract VO Edition' || mUpName === 'Contract VO Validation') {
					// Contract VN/VD/VO Edition/Validation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slContractId + '&' + slCustomerId + '&' + slOpportunityId + '&' + slCustomerType;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slContractId", slContractId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Order VN Creation') {
					// Order VN Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slCustomerId + '&' + slContractId + '&' + slDriverId + '&' + slLessorId + '&' + slContactPersonId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slLeaserContactPersonId;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slContractId", slContractId);
					component.set("v.slDriverId", slDriverId);
					component.set("v.slLessorId", slLessorId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					// US 7183 BEGIN
					component.set("v.slLeaserContactPersonId", slLeaserContactPersonId);
					// US 7183 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhDriverId", sdhDriverId);
					component.set("v.sdhLessorId", sdhLessorId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhLeaserContactPersonId", sdhLeaserContactPersonId);
					component.set("v.sdhContractId", sdhContractId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Order VN Edition') {
					// Order VN Edition Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slOrderId + '&' + slContractId + '&' + slCustomerType;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slOrderId", slOrderId);
					component.set("v.slContractId", slContractId);
					component.set("v.slCustomerType", slCustomerType);

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhOrderId", sdhOrderId);
					component.set("v.sdhCustomerId", sdhCustomerId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'Service Contract') {
					// Service Contract Param Order:  mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slCustomerId + slCustomerType;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slCustomerType", slCustomerType);

					if (slCustomerType == "B2B") {
						component.set("v.slContactPersonId", slContactPersonId);
					}

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'OPV Menu Access') {
					// Service Contract Param Order:  mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'VN Delivery Creation') {
					// VN Delivery Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slOrderId + '&' + slCustomerId + '&' + slDriverId + '&' + slLessorId + '&' + slContactPersonId + '&' + slOpportunityId + '&' + slCustomerType + '&' + slLeaserContactPersonId;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slOrderId", slOrderId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slDriverId", slDriverId);
					component.set("v.slLessorId", slLessorId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.slCustomerType", slCustomerType);
					// US 7183 BEGIN
					component.set("v.slLeaserContactPersonId", slLeaserContactPersonId);
					// US 7183 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhOrderId", sdhOrderId);
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhDriverId", sdhDriverId);
					component.set("v.sdhLessorId", sdhLessorId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhLeaserContactPersonId", sdhLeaserContactPersonId);
					/* END - Manuel Medina - 12042019 */

				} else if (mUpName === 'VO Delivery Creation' || mUpName === 'VD Delivery Creation') {
					// VO/VD Delivery Creation Param ORDER: mUpName + '&' + isCommunity + '&' + isFlow + '&' + isButton + '&' + dealerId + '&' + salesAgentId + '&' + localeId + '&' + brand + '&' + slContractId + '&' + slCustomerId + '&' + slCustomerType;
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slContractId", slContractId);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slCustomerType", slCustomerType);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slOpportunityId", slOpportunityId);

					//US C1STAGILE-6965 BEGIN
					if (mUpName === 'VD Delivery Creation') {
						component.set("v.slDriverId", slDriverId);

						/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
						component.set("v.sdhDriverId", sdhDriverId);
						/* END - Manuel Medina - 12042019 */
					}
					//US C1STAGILE-6965 END

					/* BEGIN - Manuel Medina - C1STAGILE-8027 - 12042019 */
					component.set("v.sdhContractId", sdhContractId);
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					/* END - Manuel Medina - 12042019 */

					/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
				} else if (mUpName === 'Online Configuration') {
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slCustomerType", slCustomerType);
					component.set("v.slDriverId", slDriverId);
					component.set("v.slOpportunityId", slOpportunityId);
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
					component.set("v.sdhDriverId", sdhDriverId);
					/* END - Manuel Medina - 08042019 */
				} else if (mUpName === 'Protocol solicitation') {
					component.set("v.dealerId", dealerId);
					component.set("v.salesAgentId", salesAgentId);
					component.set("v.localeId", localeId);
					component.set("v.brand", brand);
					component.set("v.slCustomerId", slCustomerId);
					component.set("v.slContactPersonId", slContactPersonId);
					component.set("v.slCustomerType", slCustomerType);
					component.set("v.sdhCustomerId", sdhCustomerId);
					component.set("v.sdhContactPersonId", sdhContactPersonId);
				}

			}
		}

		helper.getMUpParams(component);
	}
})