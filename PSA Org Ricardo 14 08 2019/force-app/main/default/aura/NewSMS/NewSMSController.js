({
	doInit : function(component, event, helper) {
		var caseId = component.get("v.recordId");
		console.log("Case Id" + component.get("v.recordId"));
		helper.getCaseInfo(component,event,caseId);
	},
	doValidate : function(component,event,helper){
		var body = component.get("v.body");
		var phone = component.get("v.selectedPhone");
		if(body != "" && body != null && phone != "" && phone != null){
			helper.sendSMS(component,event);
		} 
		else{
			alert($A.get("$Label.c.SMS_Mandatory"));
		}
	},
	loadTemplate : function(component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedTemplate",selectedValue);
        helper.loadBody(component,event,helper);
	},
	loadPhone : function(component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedPhone",selectedValue);
	},
	smsCreated : function(component,event){ 
		alert($A.get("$Label.c.SMS_Sent"));
		window.location.reload();
	}

})