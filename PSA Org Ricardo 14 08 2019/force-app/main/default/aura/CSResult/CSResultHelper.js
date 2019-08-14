({
	getsObjectRecords : function(component,page) {
		//console.log('Start of CSResultHelper.getsObjectRecords...');
        component.set("v.Spinner", true); 
        component.set("v.filter", true);
        page            = page || 1;
        var action      = component.get("c.getRecords");
        var fields      = component.get("v.fields");    
        // Min number of records to show when infinite scroll is on
        var min_records = "10";
        fields          = fields.replace(/\s/g, '');
        fields          = fields.split(','); 
        var numrecords  = component.get("v.pageSize");
        component.set("v.fieldList", fields);

        //console.log('Fields: ' + component.get("v.fieldList"));
        //console.log('Where : ' + component.get("v.whereclause"));
        //console.log('filter: ' + component.get("v.filter"));
        
        // For infinite scroll we need to show at least a certain number of records
        if(!component.get("v.paginate")) {
            if (parseInt(component.get("v.pageSize"))<min_records){
                numrecords = min_records;                
            }
        }
        action.setParams({
            objectname : component.get("v.object"),
            fieldstoget: component.get("v.fields"),
            pageNumber : page,
            pageSize   : numrecords,
            order      : component.get("v.order").trim(),
            whereClause: component.get("v.whereclause"),
            //whereSOSL  : component.get("v.wheresosl")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                //console.log('response: ' + response);
                this.createData(component, response, fields, page);
                component.set("v.filter", true);
                component.set("v.Spinner", false); 
             }else if (state === "ERROR") {
                component.set("v.Spinner", false); 
                console.log('Error getsObjectRecords (Helper)');
            }
        });
        $A.enqueueAction(action);
    },  
    getLabelList : function(component) {
		//console.log('Start of CSResultHelper.getsLabelList...');
        var action  = component.get("c.getLabels");
        var fields  = component.get("v.fields");
        fields      = fields.replace(/\s/g, '');
        fields      = fields.split(',');
        action.setParams({
            objectname      : component.get("v.object"),
            relobjectname   : component.get("v.relobject"),
            fields          : fields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set('v.labelList', response.getReturnValue());
            }else if (state === "ERROR") {
                console.log('Error getLabelList (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    getNextPage : function(component) {
		//console.log('Start of CSResultHelper.getNextPage...');
        if ((component.get("v.total")<=component.get("v.recordsShown")) ||
                component.get("v.paginate")) {
            return;
        }
        var page    = 1;
        var action  = component.get("c.getRecords");
        var fields  = component.get("v.fields");
        fields      = fields.replace(/\s/g, '');
        fields      = fields.split(',');
        var toShow  = parseInt(component.get("v.recordsShown")) + parseInt(component.get("v.pageSize"));     
        action.setParams({
            objectname : component.get("v.object"),
            fieldstoget : component.get("v.fields"),
            pageNumber : page,
            pageSize : toShow.toString(),
            order: component.get("v.order").trim(),
            whereclause: component.get("v.whereclause")
        });       
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.createData(component, response, fields, page);
             }else if (state === "ERROR") {
                console.log('Error getNextPage (Helper)');
            }
        });
        $A.enqueueAction(action);    
    },   
    orderPage : function(component) {
        var page    = 1;
        var action  = component.get("c.getRecords");
        var fields  = component.get("v.fields");
        fields      = fields.replace(/\s/g, '');
        fields      = fields.split(',');
        var toShow = parseInt(component.get("v.recordsShown"));      
        action.setParams({
            objectname : component.get("v.object"),
            fieldstoget : component.get("v.fields"),
            pageNumber : 1,
            pageSize : toShow.toString(),
            order: component.get("v.order"),
            whereclause: component.get("v.whereclause")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.createData(component, response, fields, page);
             }else if (state === "ERROR") {
                console.log('Error orderPage (Helper)');
            }
        });
        $A.enqueueAction(action);  
    },
    createData : function(component,response, fields, page) {
		//console.log('Start of CSResultHelper.createData...');
        var retResponse = response.getReturnValue();
        if(retResponse!=null){
            component.set("v.latestRecords",retResponse.sObjectrecords);
            component.set("v.latestRecordsAccess",retResponse.sObjectrecordAccess);
            component.set("v.recordsShown", retResponse.sObjectrecords.length);
            component.set("v.page",page);
            component.set("v.total",retResponse.total);
            component.set("v.pages",Math.ceil(retResponse.total/component.get("v.pageSize")));
        }
    },
    initPicklists : function (component, event, helper ) {
		//console.log('Start of CSResultHelper.initPicklists...');
        var opts = [{value: 5, label: 5},{value: 10, label: 10},{value: 20, label: 20}];
        component.set("v.recordsPerPage", opts);
    },
    getSecretQuestion : function (component, event, helper){
		//console.log('Start of CSResultHelper.gaetSecretQuestion...');
        var sId     = event.getParam("Id");
        component.set("v.selectedrecord",sId);
        console.log('Secret. ' + sId);
        var action = component.get("c.getSecretQuestion");
        action.setParams({
            sId         :   sId,
            sObjectName :   component.get("v.object"),
            sObjectType :   "SecretQuestionFields" + component.get("v.objecttype")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                //var outputVal   = component.find("PhoneNumber");
                var outputValue = component.find("FieldSecret");
                if(retResponse!=null){
                    var lstResults  = retResponse.split(',');
                    console.log('lstResults: ' + lstResults);
                    if(lstResults!=null){
                        var sValue  =  lstResults[0];
                        var sLabel  =  lstResults[1];  
                        var sQuest  =  lstResults[2];  
                        component.set("v.secretvalue", sQuest);
                        outputValue.set("v.value", sValue);
                        outputValue.set("v.label",sLabel);
                    }
                }else{
                    component.set("v.secretvalue", "-Error-");
                    outputValue.set("v.value", "");
                    outputValue.set("v.label","");
                }
             }else if (state === "ERROR") {
                console.log('Error getSecretQuestion (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    getSecretResponse : function (component, event, helper){
		//console.log('Start of CSResultHelper.getSecretResponse...');
        var action      = component.get("c.getQuestionResponse");
        var outputValue = component.find("FieldSecret");
        var sId         = component.get("v.selectedrecord");
        component.set("v.selectedrecord","");
        action.setParams({
            sValue      :   component.get("v.secretvalue"),
            sResponse   :   outputValue.get("v.value"),
            sId         :   sId,
            sUserId     :   $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                if(retResponse){
                    // Close & Open
                    component.set("v.message", "Access");
                }else{
                    //showToast(component, event, helper, "warning");
                    component.set("v.message", "No Access");
                }
                component.find("theStaticModal").closeModal(); 
                outputValue.set("v.value","");
                component.set("v.secretvalue","");
             }else if (state === "ERROR") {
                console.log('Error getSecretResponse (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper, stype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": stype + "!",
            "type" : stype,
            "message": stype=="success"?"Now you have access to the record":"The response is not correct"
        });

    toastEvent.fire();
    }
})