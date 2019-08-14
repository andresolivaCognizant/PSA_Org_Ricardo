({
	getDataHelper : function(component, event) {
        var action = component.get("c.getObjectRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName 	: 'Lead',
            strFieldSetName : 'LeadManualAssigment'
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var lstRowsAttributes = [];
                var lstAttributesType = [];

                var actions = [
                    { label: 'Show details', name: 'show_details' }
                ];
                 lstAttributesType.push({type: 'action',typeAttributes: { rowActions: actions }});
                
                
                var columns = response.getReturnValue().lstDataTableColumns;
                columns.push({type:  'action', typeAttributes: { rowActions: actions } });
                // var iPos = -1;
                // for (var i = 0; i < columns.length; i++) {
                //     var col = columns[i];
                //     console.log('Column' + col);
                //     if (col.fieldName == 'LastName'){
                //         col.type            ='url';
                //         col.typeAttributes  = lstRowsAttributes;
                //         columns[i] = col;
                //         console.log('Column' + col);
                //         iPos = i;
                //     };
                // }
                
                // var rows = response.getReturnValue().lstDataTableData;
                // var sLink = [];
                // var sUrl  = window.location.href.split('/');
                // for (var i = 0; i < rows.length; i++) {
                //     var row = rows[i];
                //     sLink = [];
                //     if(iPos == i){
                //        sLink.push({
                //         id: i, 
                //         link: 'http://' + sUrl[2] + '/' + sUrl[3] + '/' + sUrl[4] + '/' + row.Id, 
                //         linkLabel: row.LastName});

                //        row.LastName =   sLink;
                //     }
                    
                //     console.log('row ' + row);
                    
                // }
                component.set("v.columns", response.getReturnValue().lstDataTableColumns);
                component.set("v.data", response.getReturnValue().lstDataTableData);
                component.set("v.totalNumberOfRows", response.getReturnValue().lstDataTableData.length);    
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);	
    },
    getListOfContacts : function(component, event) {
        var action = component.get("c.getPartnerUserAccountId");
        //Set the Object parameters and Field Set name
        action.setParams({
            sUserId         : $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var results = response.getReturnValue();
                var lstRowsSelected = [];
                for (var i = 0; i < results.length; i++){
                    lstRowsSelected.push({value: selectedRows[i]});
                    console.log(selectedRows[i]);
                }
                component.set("v.selectedRows",lstRowsSelected);
                
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);   
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
    setTransferRecords : function(component,event) {

        var action          = component.get("c.setTransferRecords");
        var selectedRecords = component.get("v.selectedRows");
        console.log('Owner Id: ' + component.get("v.selectedUser.Id"));
        action.setParams({ 
            lstRecordsId : JSON.stringify(selectedRecords),
            sOwnerID     : component.get("v.selectedUser.Id")
         });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('setTransferRecords.state : ' + state);
            if (state === "SUCCESS") {
                showMessgae(component,event,"Success!","Records has been transfered to the new user","Success");
                console.log("setTransferRecords.SUCCESS");
            }else if (state === "ERROR") {
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
    showMessgae : function(component, event, stitle, smessage, stype){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title   : stitle,
            message : smessage,
            type    : stype
        });
        toastEvent.fire();
    }
})