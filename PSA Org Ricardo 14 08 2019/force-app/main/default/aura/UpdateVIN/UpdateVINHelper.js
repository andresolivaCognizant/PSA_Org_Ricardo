({
	updateVINInfo : function(component,event,vinId,vin,country,lang,brand,accId) {
		var action = component.get("c.getVINInfo");
		action.setParams({
            vinid : vinId,
            vin : vin,
            country : country,
            lang : lang,
            brand : brand,
            accId : accId
        });
        action.setCallback(this, function(response) {
            // store the response  
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                var values = JSON.parse(result);
                console.log(values.result);
                if (values.result === "200"){
                    component.set("v.updatedVINId",values.assetId);

                }
                else{
                	component.set("v.errorMessage",values.assetId);
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    checkVIN : function (component,event,caseId){
        var action = component.get("c.getCaseVIN");
        action.setParams({
            caseId: caseId
        });

        action.setCallback(this, function (response) {
            // store the response  
            var result = response.getReturnValue();
            var state = response.getState();

            if (state === "SUCCESS") {
                var values = JSON.parse(result);
                component.set("v.vinPopulated", result);
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    updateCaseVin : function (component,event,VINId){
        var action = component.get("c.updateVIN");
        action.setParams({
            caseId: component.get("{!v.recordId}"),
            vinId : VINId
        });
        action.setCallback(this, function (response) {
            // store the response  
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
	getCaseInfo : function (component,event,caseid){
		console.log(caseid);
		var action = component.get("c.getInfoCase");
		action.setParams({
			caseId : caseid
        });

        action.setCallback(this, function(response) {
            // store the response  
            var result = response.getReturnValue();
            var state = response.getState();

            if (state === "SUCCESS") {
                var values = JSON.parse(result);
                component.set("v.caseVINId",values.vinId);
                console.log(result);
                this.updateVINInfo(component,event,values.vinId,values.vin,values.country,values.lang,values.brand,values.accId);
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
	}
})