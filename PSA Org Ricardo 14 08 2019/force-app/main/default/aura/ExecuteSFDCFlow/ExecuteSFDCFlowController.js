({
    init : function (component,event, helper) {
        console.log('Flow');
        // Find the component whose aura:id is "flowData"
        var flow 		= component.find("flowData");
        var sRecordId 	= component.get("v.recordId");

        var sAction   = component.get("v.ActionName");
        var sFlowN   = component.get("v.FlowName");
        

        console.log(sRecordId);
        helper.getVariables(component,event, sAction,sRecordId,sFlowN,flow);
        // [
        //  	{ name : "OrderFormID", type : "String", value: sRecordId},
        //  	{ name : "AccountID", type : "String", value: "" }
        // ];
        // In that component, start your flow. Reference the flow's Unique Name.
        //flow.startFlow(sFlowN,inputVariables);
    }
})