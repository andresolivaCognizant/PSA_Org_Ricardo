({
	getCaseInfo : function(component,event,recordid) {
		var action = component.get("c.getCaseInfo");
        action.setParams({
            caseId : recordid
        });
        action.setCallback(this, function(response) {
            var details =  response.getReturnValue();
            component.set("v.country",details[0]);
            component.set("v.brand",details[1]);
            console.log("country", component.get("v.country"));
            console.log("brand", component.get("v.brand"));
            this.getTemplates(component,event);
            this.getPhones(component,event,recordid);
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	getPhones : function(component,event,recordid){
		var action = component.get("c.getPhones");
        action.setParams({
            caseId : recordid
        });
        action.setCallback(this, function(response) {
            var phones =  response.getReturnValue();
           	var opts = [];
            for(var index = 0;index<phones.length;++index){
             	opts.push({
                            class: "optionClass",
                            label: phones[index],
                            value: phones[index]
                        });
             }
            component.set("v.phones", opts);
            component.set("v.selectedPhone",phones[0]) 
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	sendSMS : function(component,event){
		component.set("v.showLoadingSpinner",true);
		var action = component.get("c.sendSMS");
        action.setParams({

            phone : component.get("v.selectedPhone"),
           	body : component.get("v.body"),
           	brand : component.get("v.brand"),
            caseId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	console.log("Enviado SMS");
            	this.createTask(component,event);
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	createTask : function(component,event){
		var action = component.get("c.createTask");
		action.setParams({
			caseId : component.get("v.recordId"),
			body : component.get("v.body")
		})
		action.setCallback(this, function(response) {
            var value = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.smsId",value);
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	getTemplates : function(component,event) {
		var action = component.get("c.getTemplates");
        action.setParams({
            country : component.get("v.country"),
            brand : component.get("v.brand")
        });
        action.setCallback(this, function(response) {
            var values =  response.getReturnValue();
            console.log(values);
            var lstValues = JSON.parse(values);
            var opts = [];
            opts.push({
                            class: "optionClass",
                            label: "--",
                            value: ""
                        });
             for(var index = 0;index<lstValues.length;++index){
             	opts.push({
                            class: "optionClass",
                            label: lstValues[index].Name,
                            value: lstValues[index].TemplateId
                        });
             }
            component.set("v.smsTemplates", opts);
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	loadBody : function (component,event){
		var action = component.get("c.loadBody");
		action.setParams({
			templatedId : component.get("v.selectedTemplate")
		})
		action.setCallback(this, function(response) {
            var body =  response.getReturnValue();
            component.set("v.body",body);
        });
        // enqueue the action
        $A.enqueueAction(action);

	}
})