({
	getLabelList : function(component, objectName, mapName) {
        var action  = component.get("c.getLabels");
        action.setParams({
            objectName : objectName
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                component.set(mapName, response.getReturnValue());
            }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    setFormFilter : function(component, newValue) {
        component.set("v.ObjectType",newValue);
        //var resultsBox = component.find('cmpResultBox');
        //$A.util.addClass(resultsBox, "slds-hide");
    },
    sortData: function (component, fieldName, sortDirection) {
        var data        = component.get("v.data");
        var reverse     = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    getSecretQuestion : function (component, event, sId){
	   // var sId     = event.getParam("Id");
	    component.set("v.selectedrecord",sId);
	    console.log('Secret. ' + sId);
	    var action = component.get("c.getSecretQuestion");
	    action.setParams({
	        sId         :   sId,
	        sObjectName :   component.get("v.From"),
	        sObjectType :   "SecretQuestionFields" + component.get("v.ObjectType")
	    });
	    action.setCallback(this,function(response){
	        var state = response.getState();
	        if(state === 'SUCCESS'){
	            var retResponse = response.getReturnValue();
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
                    component.find("theStaticModal").closeModal();
                    this.showMessgae(component, event,$A.get("$Label.c.SecretQuestionMessageNoQuestionTitle"),$A.get("$Label.c.SecretQuestionMessageNoQuestion"),'warning');
	            }
	         }else if (state === "ERROR") {
	            console.log('Error getSecretQuestion (Helper)');
                component.find("theStaticModal").closeModal();
	        }
        });
        $A.enqueueAction(action);
    },
    getSecretResponse : function (component, event, helper){
        var action      = component.get("c.getQuestionResponse");
        var outputValue = component.find("FieldSecret");
        var sId         = component.get("v.selectedrecord");
        component.set("v.selectedrecord","");
        component.set("v.message", "");
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
                component.find("theStaticModal").closeModal(); 
                if(retResponse){
                    component.set("v.message", "Access");
                    this.showToast(component, event, "success");
                    this.allowAccess(component,sId);
                }else{
                    this.showToast(component, event, "error");
                    component.set("v.message", "No Access");
                }
                outputValue.set("v.value","");
                component.set("v.secretvalue","");
             }else if (state === "ERROR") {
                console.log('Error getSecretResponse (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, stype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": stype + "!",
            "type" : stype,
            "message": stype=="success"?$A.get("$Label.c.SecretQuestionMessageSuccess"):$A.get("$Label.c.SecretQuestionMessageError")
        });
        toastEvent.fire();
    },
    handleError: function(component, event){
        /* do any custom error handling
         * logic desired here */
        // get v.errors, which is an Object[]
        var errorsArr  = component.get("v.errors");
        for (var i = 0; i < errorsArr.length; i++) {
            console.log("error " + i + ": " + JSON.stringify(errorsArr[i]));
            this.showMessgae(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),errorsArr[i].message,'warning');
        }
    },
    showMessgae : function(component, event, stitle, smessage, stype){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"   : stitle,
            "message" : smessage,
            "type"    : stype
        });
        toastEvent.fire();
    },
    getRowActions: function (component, row, doneCallback) {
        var actions = [];
        if (row['UserRecordAccess'].HasReadAccess==true) {
            actions.push({
                'label'     : $A.get("$Label.c.CustomerSearchShowDetails"),
                'iconName'  : 'utility:preview',
                'name'      : 'show_details'
            });
        } else {
            actions.push({
                'label'     : $A.get("$Label.c.CustomerSearchGetAccess"),
                'iconName'  : 'utility:shield',
                'name'      : 'get_access'
            });
        }
        setTimeout($A.getCallback(function(){doneCallback(actions);}),200);
    },
    allowAccess: function (component,row) {
        var a = component.get('c.filter');
        $A.enqueueAction(a);
    },
    toggleSpinner: function (component, event) {
        var spinner = component.find("divSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    //Adapting to SOSL + SOQL
    fetchData: function(component, rows){
        return new Promise($A.getCallback(function(resolve, reject) {
            var currentDatatemp = component.get('c.getfetchRecords');
            var counts          = component.get("v.currentCount");
            currentDatatemp.setParams({
                "sObjectName"     : component.set("v.From"),
                "sObjectType"     : component.get("v.ObjectType"),
                "sWhereClause"    : where,
                "whereSOSL"       : lstRowsSelected,
                "iLimits"         : component.get("v.initialRows"),
                "iOffsets"        : counts
            });
            currentDatatemp.setCallback(this, function(a) {
                resolve(a.getReturnValue());
                var countstemps = component.get("v.currentCount");
                countstemps     = countstemps+component.get("v.initialRows");
                component.set("v.currentCount",countstemps);
            });
            $A.enqueueAction(currentDatatemp);
        }));
    },

})