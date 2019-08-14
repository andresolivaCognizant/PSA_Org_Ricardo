({
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
    showMessgae : function(component, event, stitle, smessage, stype){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title   : stitle,
            message : smessage,
            type    : stype
        });
        toastEvent.fire();
    },
    setComponentLabels: function(component){
        var headerLine1 = component.get("v.title");
        if(headerLine1 != undefined && headerLine1.indexOf('$')>=0 ){
            var labelRef = $A.getReference(headerLine1);
            component.set("v.title", labelRef);
        }
    },
    getRecordtHelper : function(component,event,defaultListView) {
        var selected;
        if(defaultListView == null){
            selected = component.find("selectedViewId").get("v.value");
        }else{
            selected = defaultListView;
        }
        var action 	 = component.get("c.getFilteredRecords");
        var sObj 	 = component.get("v.object");
        action.setParams({filterId : selected, sObjectName : sObj});
        action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
                var lstRowsAttributes = [];
                var lstAttributesType = [];
                //var actions = [{ label: 'Show details', name: 'show_details' }];
                //lstAttributesType.push({type: 'action',typeAttributes: { rowActions: actions }});
                var columns = response.getReturnValue().lstDataTableColumns;
                var rows    = response.getReturnValue().lstDataTableData;
                var iCol    = '';
                //columns.push({type:  'action', typeAttributes: { rowActions: actions } });
                for (var i = 0; i < columns.length; i++) {
                    if(columns[i].fieldName == 'Name'){
                    	columns[i].type             = 'url';
                        columns[i].fieldName        = 'ObjLink';
                        columns[i].typeAttributes   = {label: {fieldName: 'Name'},target:'_self'};
                    }else if(columns[i].fieldName == 'Account.Name'){
                    	columns[i].type             = 'url';
                        columns[i].fieldName        = 'AccLink';
                        columns[i].typeAttributes   = {label: {fieldName: 'Account.Name'},target:'_self'};
                    }else if(columns[i].fieldName == 'Owner.Name'){
                    	columns[i].type             = 'url';
                        columns[i].fieldName        = 'OwnLink';
                        columns[i].typeAttributes   = {label: {fieldName: 'Owner.Name'},target:'_self'};
                    }

                    if (columns[i].type == 'percent') {
                       iCol = columns[i].fieldName;
                    }


                }
    	    	
    	    	var lstRowsObjects          = [];
    	    	var isProduction = component.get("v.isProduction");
    	    	// Winter 18 <lightning:datatable> does not get values from a parent record
    	    	for (var i = 0; i < rows.length; i++) {
                    var row                 = this.setFlatten(rows[i]);
                    row.ObjLink             = this.getRecordURL(row.Id,'opportunity',isProduction); 
                    row.AccLink             = this.getRecordURL(row.AccountId,'account',isProduction); 
                    row.OwnLink             = this.getRecordURL(row.OwnerId,'profile',isProduction); 
                    if(iCol!=''){
                        row[iCol]          =  row[iCol]*0.01;
                    }
                    lstRowsObjects.push(row);
                }
                component.set("v.columns", response.getReturnValue().lstDataTableColumns);
                component.set("v.data", lstRowsObjects);
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
    getRecordURL: function (value,object,isProduction){
        /* BEGIN - Fix 23-10-2018 */
        var p = window.location.pathname;
        var sPageURL = decodeURIComponent(p);
        var	sURLVariables = sPageURL.split('/');
        var commName;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) { 
            console.log(sURLVariables[i]);
            if (i === 1) {
                commName = undefined ? null : sURLVariables[1];
                commName = '/' + commName + '/'; 
            }
        }
        
        if (isProduction){
        	var baseURL 	= commName + object + '/';
        } else {
        	var baseURL 	= commName + 's/' + object + '/';
        }
        	
        /* END - Fix 23-10-2018 */
    	//var baseURL 		= '/PSADealer/s/' + object + '/';   	
        return  baseURL + value;
    },
    
    isProduction: function(component,event) {
        var action = component.get("c.isProduction");

        action.setCallback(this, function(response) {
            var isProduction = response.getReturnValue(); // do any operation needed here

            component.set("v.isProduction", isProduction);
        });

        $A.enqueueAction(action);
    },
    setTransferRecords : function(component,event) {
        var action          = component.get("c.setTransferRecords");
        var selectedRecords = component.get("v.selectedRows");
        action.setParams({ 
            lstRecordsId : JSON.stringify(selectedRecords),
            sOwnerID     : component.get("v.selectedUser.Id")
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                showMessgae(component,event,"Success!",$A.get("$Label.c.cListViewTransferSuccess"),"Success");
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
    setFlatten : function(data) {
	    var result = {};
	    function recurse (oVaL, prop) {
	        if (Object(oVaL) !== oVaL) {
	            result[prop] = oVaL;
	        } else if (Array.isArray(oVaL)) {
	            for(var i=0, l=oVaL.length; i<l; i++)
	                recurse(oVaL[i], prop + "[" + i + "]");
	            if (l == 0)
	                result[prop] = [];
	        } else {
	            var isEmpty = true;
	            for (var o in oVaL) {
	                isEmpty = false;
	                recurse(oVaL[o], prop ? prop + "." + o : o);
	            }
	            if (isEmpty && prop)
	                result[prop] = {};
	        }
	    }
	    recurse(data, "");
	    return result;
	},
	capitalizeFirstLetter: function(data) { 
    	return data.replace(/^./, data[0].toUpperCase());
	}
})