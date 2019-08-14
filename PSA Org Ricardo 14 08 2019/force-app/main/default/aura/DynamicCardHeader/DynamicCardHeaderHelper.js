({
    customHandler1: function(component, calledFrom) {
        // Add custom logic here 
        if (calledFrom == "LMAContainer") {
            var button1 = component.find("button1");
            var button1Value = button1.get("v.value");
            //var button1Label = button1.get("v.label");
            
            if (button1Value != "My Team") {
                button1.set("v.label", $A.get("$Label.c.LeadAssignmentMyTeam"));
                button1.set("v.value", "My Team");
                var appEvent = $A.get("e.c:LMAToggleFilterByUserEvent");
                appEvent.setParams({
                    "filterByCurrentUser": true
                });
                appEvent.fire();
            } else {
                button1.set("v.label", $A.get("$Label.c.LeadAssignmentMyLeads"));
                button1.set("v.value", "My Leads");
                var appEvent = $A.get("e.c:LMAToggleFilterByUserEvent");
                appEvent.setParams({
                    "filterByCurrentUser": false
                });
                appEvent.fire();
            }
        }
    },
    setComponentLabels: function(component){
      	var headerLine1 = component.get("v.headerLine1");
        if(headerLine1 != null && headerLine1.indexOf('$')>=0 ){
			var labelRef = $A.getReference(headerLine1);
			component.set("v.headerLine1", labelRef);
        }
        var headerLine2 = component.get("v.headerLine2");
        if(headerLine2 != null && headerLine2.indexOf('$')>=0){
			var labelRef = $A.getReference(headerLine2);
			component.set("v.headerLine2", labelRef);
        }  
    },
    getFieldLabels: function(component) {
        var action = component.get("c.getLabels");
        var fields = component.get("v.fields");
        fields = fields.replace(/\s/g, '');
        fields = fields.split(',');
        action.setParams({
            objectname: component.get("v.objectName"),
            relobjectname: component.get("v.relobject"),
            fields: fields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.labelList', response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('Error getLFieldLabels (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    getObjectRecords: function(component) {
        var action      = component.get("c.getObjectRecords");
        var objectName  = component.get("v.objectName");
        var fields      = component.get("v.fields");
        component.set("v.fieldList", fields);

        //fields = fields.replace(/\s/g, '');
        //fields = fields.split(',');
        action.setParams({
            objectName: objectName,
            whereClause: "WHERE id != null",
            fields: fields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.createData(component, response, fields);
            } else if (state === "ERROR") {
                console.log('Error getsObjectRecords (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    createData: function(component, response, fields) {
        var retResponse = response.getReturnValue();
        if (retResponse != null) {
            component.set("v.latestRecords", retResponse.sObjectrecords);
            component.set("v.latestRecordsAccess", retResponse.sObjectrecordAccess);
            component.set("v.recordsShown", "1");
        }
    },
})