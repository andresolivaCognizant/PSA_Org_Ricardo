({
	doInit : function(component, event, helper) { 
		var navTo					= component.get( "v.navigateTo ");
		var isCommunity				= component.get( "v.isCommunity ");

		var mUpName					= component.get( "v.mUpName ");
		var isFlow					= component.get( "v.isFlow ");

		var dealerId				= component.get( "v.dealerId ");
		var salesAgentId			= component.get( "v.salesAgentId ");
		var localeId				= component.get( "v.localeId ");
		var brand					= component.get( "v.brand ");
		var slCustomerId			= component.get( "v.slCustomerId ");
		var slDriverId				= component.get( "v.slDriverId ");
		var slLessorId				= component.get( "v.slLessorId ");
		var slContactPersonId		= component.get( "v.slContactPersonId ");
		var slOpportunityId			= component.get( "v.slOpportunityId ");
		var slQuoteId				= component.get( "v.slQuoteId ");
		var slContractId			= component.get( "v.slContractId ");
		var slOrderId				= component.get( "v.slOrderId ");
		var slCustomerType			= component.get( "v.slCustomerType ");
		// US 7183 BEGIN
		var slLeaserContactPersonId	= component.get( "v.slLeaserContactPersonId ");
		// US 7183 END

		/* BEGIN - Manuel Medina - C1STAGILE-207 - 08042019 */
		var sdhCustomerId			= component.get( "v.sdhCustomerId ");
		var sdhContactPersonId		= component.get( "v.sdhContactPersonId ");
		var sdhDriverId				= component.get( "v.sdhDriverId ");
		/* END - Manuel Medina - 08042019 */

		/* BEGIN - Manuel Medina - C1STAGILE-8027 - 08042019 */
		var sdhLessorId				= component.get( "v.sdhLessorId ");
		var sdhLeaserContactPersonId= component.get( "v.sdhLeaserContactPersonId ");
		var sdhQuoteId				= component.get( "v.sdhQuoteId ");
		var sdhContractId			= component.get( "v.sdhContractId ");
		var sdhOrderId				= component.get( "v.sdhOrderId ");
		var sdhVpoId				= component.get( "v.sdhVpoId ");
		/* END - Manuel Medina - 08042019 */
		// C1STAGILE-8758 - B
		var recId 					= component.get("v.recId");
		// C1STAGILE-8758 - E
		 
		var country 					= component.get("v.country");
		
		if( navTo === 'Record' ){
			// C1STAGILE-8758 - B
			//var recId				= component.get( "v.recId" );
			// C1STAGILE-8758 - E
			var navEvt				= $A.get( "e.force:navigateToSObject" );
			
			navEvt.setParams( {
				"recordId"		: recId,
				"slideDevName"	: "detail"
			} );

		}else if( !isCommunity ){
			var navEvt				= $A.get( "e.force:navigateToComponent" );
			
			navEvt.setParams( {
				componentDef : 'c:GenericMashUp',
				componentAttributes : {
					"dealerId" 					: dealerId,
					"salesAgentId" 				: salesAgentId,
					"localeId" 					: localeId,
					"brand" 					: brand,
					"slCustomerId" 				: slCustomerId,
					"slDriverId" 				: slDriverId,
					"slLessorId" 				: slLessorId,
					"slContactPersonId" 		: slContactPersonId,
					"slOpportunityId" 			: slOpportunityId,
					"slQuoteId" 				: slQuoteId,
					"slContractId"				: slContractId,
					"slOrderId"					: slOrderId,
					"slCustomerType"			: slCustomerType,
					"slLeaserContactPersonId"	: slLeaserContactPersonId,
					"mUpName"					: mUpName,
					"isFlow"					: isFlow,
					"isCommunity"				: isCommunity,
					"sdhCustomerId"				: sdhCustomerId,
					"sdhContactPersonId"		: sdhContactPersonId,
					"sdhDriverId"				: sdhDriverId,
					"sdhLessorId"				: sdhLessorId,
					"sdhLeaserContactPersonId"	: sdhLeaserContactPersonId,
					"sdhQuoteId"				: sdhQuoteId,
					"sdhContractId"				: sdhContractId,
					"sdhOrderId"				: sdhOrderId,
					"sdhVpoId"					: sdhVpoId,
					"recId"						: recId,
					"country"					: country
				}
			} );

		} else if( isCommunity ){
			var isButton			= false;
			
			// Param ORDER must be respected in GenericMashUp Component retrieving parameters from URL
			var address				= '/genericmashup?';
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
			p19 				slContractId
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
			// Now We send all parameters, in GenericMashUp component they will be evaluated and catched for every MashUp
			// New parameters must be maped and added at end, taking into account GenericButton Component has 2 parameters recId and objName
			address					= address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + 
										'&p7=' + localeId + '&p8=' + brand + '&p9=' + slCustomerId + '&p10=' + slDriverId + '&p11=' + slLessorId + '&p12=' + slContactPersonId + 
										'&p13=' + slOpportunityId + '&p14=' + slCustomerType + '&p15=' + slQuoteId + '&p16=' + recId + '&p18=' + slOrderId + '&p19=' + slContractId +
										'&p20=' + slLeaserContactPersonId + '&p21=' + sdhCustomerId + '&p22=' + sdhDriverId + '&p23=' + sdhLessorId + '&p24=' + sdhContactPersonId +
										'&p25=' + sdhLeaserContactPersonId + '&p26=' + sdhQuoteId + '&p27='	+ sdhContractId + '&p28=' + sdhOrderId + '&p29=' + sdhVpoId;
			
			/*
			if (mUpName === 'Quote VN Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slCustomerId + '&p10=' + slDriverId + '&p11=' + slLessorId + '&p12=' + slContactPersonId + '&p13=' + slOpportunityId + '&p14=' + slCustomerType;
			} else if (mUpName === 'Quote VD Creation' || mUpName === 'Quote VO Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slCustomerId + '&p13=' + slOpportunityId + '&p14=' + slCustomerType + '&p12=' + slContactPersonId;
			} else if (mUpName === 'Quote VN Edition' || mUpName === 'Quote VD Edition' || mUpName === 'Quote VO Edition'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p17=' + slQuoteId + '&p9=' + slCustomerId + '&p13=' + slOpportunityId + '&p14=' + slCustomerType + '&p12=' + slContactPersonId;
			} else if (mUpName === 'Contract VN Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p17=' + slQuoteId + '&p9=' + slCustomerId + '&p10=' + slDriverId + '&p11=' + slLessorId + '&p13=' + slContactPersonId + '&p14=' + slOpportunityId + '&p15=' + slCustomerType;
			} else if (mUpName === 'Contract VD Creation' || mUpName === 'Contract VO Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p17=' + slQuoteId + '&p9=' + slCustomerId + '&p13=' + slOpportunityId + '&p14=' + slCustomerType;
				if(slCustomerType == 'B2B'){
					address += '&p13=' + slContactPersonId;
				}
			} else if (mUpName === 'Contract VN Edition' || mUpName === 'Contract VN Validation' || mUpName === 'Contract VD Edition' || mUpName === 'Contract VD Validation' || mUpName === 'Contract VO Edition' || mUpName === 'Contract VO Validation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slContractId + '&p10=' + slCustomerId + '&p11=' + slOpportunityId + '&p12=' + slCustomerType;
			} else if (mUpName === 'Order VN Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slCustomerId + '&p10=' + slContractId + '&p11=' + slDriverId + '&p12=' + slLessorId + '&p13=' + slContactPersonId + '&p14=' + slOpportunityId + '&p15=' + slCustomerType;
			} else if (mUpName === 'Order VN Edition'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slOrderId + '&p10=' + slContractId + '&p11=' + slCustomerType;
			} else if (mUpName === 'Order VN Edition'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slCustomerId + '&p10=' + slCustomerType;
			} else if (mUpName === 'VN Delivery Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slOrderId + '&p10=' + slCustomerId + '&p11=' + slDriverId + '&p12=' + slLessorId + '&p13=' + slContactPersonId + '&p14=' + slOpportunityId + '&p15=' + slCustomerType;
			} else if (mUpName === 'VO Delivery Creation' || mUpName === 'VD Delivery Creation'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand + '&p9=' + slContractId + '&p10=' + slCustomerId + '&p11=' + slCustomerType;
			} else if (mUpName === 'OPV Menu Access'){
				address = address + 'p1=' + mUpName + '&p2=' + isCommunity + '&p3=' + isFlow + '&p4=' + isButton + '&p5=' + dealerId + '&p6=' + salesAgentId + '&p7=' + localeId + '&p8=' + brand;
			}
			*/
			
			console.log( 'address :' +address );
		
			var navEvt				= $A.get( "e.force:navigateToURL" );
			
			navEvt.setParams( {
			  "url": address
			} );
		}
		
		navEvt.fire();
	} 
})