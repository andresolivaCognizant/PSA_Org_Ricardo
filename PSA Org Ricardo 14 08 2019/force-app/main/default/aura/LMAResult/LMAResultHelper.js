({
    getsObjectRecords: function(component, page) {
        component.set("v.Spinner", true);
        component.set("v.filter", true);
        page = page || 1;
        var action = component.get("c.getRecords");
        var fields = component.get("v.fields");
        var pagend = component.get("v.pageEnd");
        // Min number of records to show when infinite scroll is on
        var min_records = "10";
        fields = fields.replace(/\s/g, '');
        fields = fields.split(',');
        var numrecords = component.get("v.pageSize");
        component.set("v.fieldList", fields);
        component.set("v.pageEnd",pagend);
        // For infinite scroll we need to show at least a certain number of records
        if (!component.get("v.paginate")) {
            if (parseInt(component.get("v.pageSize")) < min_records) {
                numrecords = min_records;
            }
        }
        //GAS could be refactored to use wrapper to pass parameters
        action.setParams({
            objectname: component.get("v.object"),
            fieldstoget: component.get("v.fields"),
            labelFields: component.get("v.labelFields"),
            pageNumber: page,
            pageSize: numrecords,
            pageEnd: pagend,
            order: component.get("v.order").trim(),
            filterByStatus: component.get("v.filterByStatus"),
            filterByActivity: component.get("v.filterByActivity"),
            filterByActivityIsList: component.get("v.filterByActivityIsList"),
            filterByPriority: component.get("v.filterByPriority"),
            filterByCurrentUser: component.get("v.filterByCurrentUser"),
            whereClause: component.get("v.whereClause")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.createData(component, response, fields, page);
                component.set("v.filter", true);
                component.set("v.Spinner", false);
                component.set("v.pageEnd",response.getReturnValue().pageEnd);
            } else if (state === "ERROR") {
                component.set("v.Spinner", false);
                console.log('Error getsObjectRecords (Helper)');
            }
        });
        $A.enqueueAction(action);
    },
    
    getLabelList: function(component) {
        var action = component.get("c.getFieldLabels");
        var fields = component.get("v.fields");
        fields = fields.replace(/\s/g, '');
        fields = fields.split(',');
        action.setParams({
            objectname: component.get("v.object"),
            relobjectname: component.get("v.relobject"),
            fields: fields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.fieldLabelList', response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('Error getLabelList (Helper)');
            }
        });
        $A.enqueueAction(action);
    },

    getNextPage: function(component) {
        if ((component.get("v.total") <= component.get("v.recordsShown")) ||
            component.get("v.paginate")) {
            return;
        }
        var page = 1;
        var action = component.get("c.getRecords");
        var fields = component.get("v.fields");
        fields = fields.replace(/\s/g, '');
        fields = fields.split(',');
        var toShow = parseInt(component.get("v.recordsShown")) + parseInt(component.get("v.pageSize"));
        action.setParams({
            objectname: component.get("v.object"),
            fieldstoget: component.get("v.fields"),
            pageNumber: page,
            pageSize: toShow.toString(),
            order: component.get("v.order").trim()
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.createData(component, response, fields, page);
            } else if (state === "ERROR") {
                console.log('Error getNextPage (Helper)');
            }
        });
        $A.enqueueAction(action);
    },

    orderPage: function(component) {
        var page = 1;
        var action = component.get("c.getRecords");
        var fields = component.get("v.fields");
        fields = fields.replace(/\s/g, '');
        fields = fields.split(',');
        var toShow = parseInt(component.get("v.recordsShown"));
        action.setParams({
            objectname: component.get("v.object"),
            fieldstoget: component.get("v.fields"),
            pageNumber: 1,
            pageSize: toShow.toString(),
            order: component.get("v.order"),
            whereclause: component.get("v.whereclause")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.createData(component, response, fields, page);
            } else if (state === "ERROR") {
                console.log('Error orderPage (Helper)');
            }
        });
        $A.enqueueAction(action);
    },

    createData: function(component, response, fields, page) {
        var retResponse = response.getReturnValue();
        if (retResponse != null) {
            component.set("v.latestRecords", retResponse.sObjectrecords);
            component.set("v.latestRecordsAccess", retResponse.sObjectrecordAccess);
            component.set("v.recordsShown", retResponse.sObjectrecords.length);
            component.set("v.page", page);
            component.set("v.total", retResponse.total);
            component.set("v.pages", Math.ceil(retResponse.total / component.get("v.pageSize")));
        }
    },

    initPicklists: function(component, event, helper) {
        var opts = [{
            value: 5,
            label: 5
        }, {
            value: 10,
            label: 10
        }, {
            value: 20,
            label: 20
        }];
        component.set("v.recordsPerPage", opts);
    },

    getSecretQuestion: function(component, event, helper) {
        var sId     = event.getParam("Id");
        component.set("v.selectedrecord", sId);
        var action  = component.get("c.getSecretQuestion");
        action.setParams({
            sId: sId,
            sObjectName: component.get("v.object"),
            sObjectType: "SecretQuestionFields" + component.get("v.objecttype")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var retResponse = response.getReturnValue();
                var outputValue = component.find("FieldSecret");
                if (retResponse != null) {
                    var lstResults = retResponse.split(',');
                    if (lstResults != null) {
                        var sValue = lstResults[0];
                        var sLabel = lstResults[1];
                        var sQuest = lstResults[2];
                        component.set("v.secretvalue", sQuest);
                        outputValue.set("v.value", sValue);
                        outputValue.set("v.label", sLabel);
                    }
                } else {
                    component.set("v.secretvalue", "-Error-");
                    outputValue.set("v.value", "");
                    outputValue.set("v.label", "");
                }
            } else if (state === "ERROR") {
                console.log('Error getSecretQuestion (Helper)');
            }
        });
        $A.enqueueAction(action);
    },

    getSecretResponse: function(component, event, helper) {
        var action = component.get("c.getQuestionResponse");
        var outputValue = component.find("FieldSecret");
        var sId = component.get("v.selectedrecord");
        component.set("v.selectedrecord", "");
        action.setParams({
            sValue: component.get("v.secretvalue"),
            sResponse: outputValue.get("v.value"),
            sId: sId,
            sUserId: $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var retResponse = response.getReturnValue();
                if (retResponse) {
                    // Close & Open
                    component.set("v.message", "Access");
                } else {
                    //showToast(component, event, helper, "warning");
                    component.set("v.message", "No Access");
                }
                component.find("theStaticModal").closeModal();
                outputValue.set("v.value", "");
                component.set("v.secretvalue", "");
            } else if (state === "ERROR") {
                console.log('Error getSecretResponse (Helper)');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(component, event, helper, stype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": stype + "!",
            "type": stype,
            "message": stype == "success" ? "Now you have access to the record" : "The response is not correct"
        });
        toastEvent.fire();
    },

    setTransferRecords: function(component, event) {
        var action = component.get("c.setTransferRecords");
        var selectedRecords = component.get("v.selectedIds");
        var selectedUser = component.get("v.selectedUser");
        if (selectedUser == 'undefined' || selectedUser == null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning!",
                message: "Please select a new owner first",
                type: "warning"
            });
            toastEvent.fire();
            return;
        }
        action.setParams({
            lstRecordsId: JSON.stringify(selectedRecords),
            sOwnerID: selectedUser.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.hideModal(component);
                if(response.getReturnValue()){
                    this.showToast ("Success!", $A.get("$Label.c.LeadAssigmentSuccessOwnerTransfer"), "success","dismissible");
                    this.refreshLeadBoard(component);

                }else{
                    this.showToast ("Error", $A.get("$Label.c.LeadAssigmentNOTSuccessOwnerTransfer"), "error","dismissible");
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("setTransferRecords.Error message: " + errors[0].message);
                    }
                } else {
                    console.log("setTransferRecords.Error: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getUserLeadCounts: function(component, event) {
        var action = component.get("c.getUserLeadCounts");
        action.setStorable();
        action.setParams({
            filterByCurrentUser: false
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set("v.userMetrics", response.getReturnValue());
                this.refreshLeadBoard(component);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    },

    setInterval: function (component) {
        var t = window.setInterval(
            $A.getCallback(function () {
                var selectedIds = component.get("v.selectedIds");
                var page = component.get("v.page") || 1;
                var modal = component.get("v.modalUP") || false; 
                if (selectedIds.length > 0 || page > 1 || modal == true) {
                    console.log('No refresh');
                } else {
                    let vActivity   = component.get("v.filterByActivity");
                    $A.get("e.c:LeadManualAssignmentTabEvent").setParams({
                        "filterByPriority" : component.get("v.filterByPriority"),
                        "filterByActivity" : vActivity,
                        "tabsToShow": ($A.util.isUndefinedOrNull(vActivity)|| $A.util.isEmpty(vActivity))?"leadsByPriority":"leadsByActivity",
                        "refreshData": true}).fire();
                }
            }), 60000
        );
        component.set( "v.CheckIntervalId", t );
    },
    refreshLeadBoard : function (component) {
        let vActivity   = component.get("v.filterByActivity");
        $A.get("e.c:LeadManualAssignmentTabEvent").setParams({
            "filterByPriority" : component.get("v.filterByPriority"),
            "filterByActivity" : vActivity,
            "tabsToShow": ($A.util.isUndefinedOrNull(vActivity)|| $A.util.isEmpty(vActivity))?"leadsByPriority":"leadsByActivity",
            "refreshData": true}).fire();
    },

    showToast : function( msgTitle, msg, msgType, msgMode ) {
		var toastEvent      = $A.get( "e.force:showToast" );
		var availableModes  = "dismissible&pester&sticky";
		var availableTypes  = "info&success&warning&error";

		toastEvent.setParams( {
			title :   msgTitle,
			message:  msg,
			duration: "5000",
			key:      "info_alt",
			type:     availableTypes.includes( msgType ) ? msgType : "info",
			mode:     availableModes.includes( msgMode ) ? msgMode : "pester"
		} );

		toastEvent.fire();
    },

    showModal : function(component) {
		var lookUpTarget = component.find("theStaticModal");
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        $A.util.addClass(lookUpTarget, 'slds-show');
    },
    
	hideModal : function(component) {
		var lookUpTarget = component.find("theStaticModal");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
	}
})