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
            component.set("v.templates", opts);
        });
        // enqueue the action
        $A.enqueueAction(action);
	},
	loadBody : function (component,event){
		var action = component.get("c.loadBody");
		action.setParams({
			templatedId : component.get("v.selectedTemplate"),
			caseId : component.get("v.recordId")
		})
		action.setCallback(this, function(response) {
            var body =  response.getReturnValue();
            component.set("v.body",body);
        });
        // enqueue the action
        $A.enqueueAction(action);

	}
})