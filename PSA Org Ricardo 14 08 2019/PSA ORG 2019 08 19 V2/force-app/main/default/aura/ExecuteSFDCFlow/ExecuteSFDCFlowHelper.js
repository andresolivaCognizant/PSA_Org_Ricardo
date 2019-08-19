({
	getVariables : function(component, event, action,sRecordId,sFlowN,flow) {
		var sResult;
		switch (action) {
            case 'OrderForm.Order':
                sResult= [
         			{ name : "OrderFormID", type : "String", value: sRecordId},
         			{ name : "AccountID", type : "String", value: "" },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
        	case 'OrderFormVO.Order':
                sResult= [
         			{ name : "OrderFormID", type : "String", value: sRecordId},
         			{ name : "AccountID", type : "String", value: "" },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
        	case 'OrderFormVO.Delivery':
                sResult= [
         			{ name : "OrderFormID", type : "String", value: sRecordId},
         			{ name : "OrderID", type : "String", value: "" },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
        	case 'Order.Delivery':
                sResult= [
         			{ name : "OrderFormID", type : "String", value: ""},
         			{ name : "OrderID", type : "String", value: sRecordId },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
        	case 'Quote.Order':
                sResult= [
         			{ name : "AccountId", type : "String", value: ""},
         			{ name : "QuoteId", type : "String", value: sRecordId },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
            case 'Opportunity.Quote':
            	sResult= [
         			{ name : "AccountID", type : "String", value: ""},
         			{ name : "FleetRequestId", type : "String", value: "" },
         			{ name : "OppID", type : "String", value: sRecordId },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
            case 'Account.OrderForm':
 				sResult= [
         			{ name : "AccountID", type : "String", value: sRecordId},
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
            case 'Account.Quote':
            	sResult= [
         			{ name : "AccountID", type : "String", value: sRecordId},
         			{ name : "FleetRequestId", type : "String", value: "" },
         			{ name : "isCommunity", type : "Boolean", value: "true" }
        		];
        		break;
        }
        flow.startFlow(sFlowN,sResult); ;
	}
})