({
	doInit : function(component, event, helper) {
		var caseId = component.get("{!v.recordId}");
		helper.checkVIN(component,event,caseId);
	},
	doUpdate : function(component, event, helper){
		var caseId = component.get("{!v.recordId}");
		component.set("v.showLoadingSpinner",true);
		helper.getCaseInfo(component, event, caseId);
	},
	openVIN : function(component,event, helper){
		component.set("v.showLoadingSpinner", false);
		var oldVinId = component.get("v.caseVINId");
		var newVinId = component.get("v.updatedVINId");
		if(oldVinId !== newVinId){
			helper.updateCaseVin(component,event,newVinId);
		}
		var toastEvent = $A.get("e.force:showToast");
		var mess = $A.get("$Label.c.UpdateVIN_Updated");
		toastEvent.setParams({
			title: "",
			message: mess,
			type: "success"
		});
		toastEvent.fire();
	},
	showError : function (component,event,helper){
		var error = component.get("v.errorMessage");
		var toastEvent = $A.get("e.force:showToast");
		var mess = $A.get("$Label.c.UpdateVIN_NotValid");
		toastEvent.setParams({
			title: "",
			message: mess,
			type: "error"
		});
		component.set("v.showLoadingSpinner", false);
		component.set("v.errorMessage","");
		toastEvent.fire();
	}
})