({
	doInit : function(component, event, helper) {
		var caseId = component.get("v.recordId");
		helper.getCaseInfo(component,event,caseId);	
	},
	loadTemplate : function(component,event,helper){
        	var selectedValue = event.getParam("value");
        	component.set("v.selectedTemplate",selectedValue);
        	helper.loadBody(component,event,helper);
	},
	onPreview : function(component,event,helper) {
		component.find("theStaticModalPreview").openModal();
	},
	onCancel : function(component, event, helper) {
		component.find("theStaticModalPreview").closeModal();
	},
	onPrint : function(component, event, helper) {
		window.print();
	}
})