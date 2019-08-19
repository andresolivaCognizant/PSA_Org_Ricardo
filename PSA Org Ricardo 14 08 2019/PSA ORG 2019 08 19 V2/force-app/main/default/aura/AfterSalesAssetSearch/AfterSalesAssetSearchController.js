/**
	*   @Class          : AfterSalesAssetSearchController.js
	*   @Created        : 31 May 2018
	*   @Description    : Controller class for AfterSalesAssetSearch.cmp
**/
({
    doInit: function(component, event, helper) {
    	helper.getLabelList(component, "Asset", "v.AssetMap");
        helper.getLabelList(component, "AccountContactAssetRelation__c", "v.AccountContactAssetRelationMap");
        helper.toggleSpinner(component,event);	
    },
    
    /*
     * @Method          :   filter
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   18 Jan 2018
     * @Description     :   Method that converts and adapts all the filter 
     * information so that it can be used directly in a query for the Customer Search.


     * @Updated         :   Updated to work with SOSL and redefined the queries.
     */	
	setFilter : function(component, event, helper) {
        helper.toggleSpinner(component,event);
        var where = '';
        var Ids = ["Asset.VIN__c", "Asset.VIS__c", "Asset.LastKnownRegistrationNumber__c"];  //registrationnumber__c

        var lstRowsSelected = '';
        var i = 0;

        Ids.forEach(function(Id) {
            if(component.find(Id)!= undefined && component.find(Id).get("v.value") != null && component.find(Id).get("v.value") != ''){
            	console.log('IndexOf ' + Id.indexOf("."));
            	
            	/* BEGIN - Manuel Medina - C1STAGILE-6169 - Clause .normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase() was commented because is not supported by Internet Explorer - 12122018 */
				/* Normalization logic was moved to APEX server side */
                if(component.find(Id).get("v.value").length >1){                        
                    if(where == ''){
                    	where = where +  Ids[i] + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
                        lstRowsSelected = "\"" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "*\"";
                	}else{
                    	where = where + " AND " + Ids[i] + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
                        lstRowsSelected =  lstRowsSelected + " AND " + "\"" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "*\"";
                	}
                }else{
                    component.set("v.errors", [{message: $A.get("$Label.c.CustomerSearchErrorMessageLength") + " " + Id }]);
                    helper.handleError(component,event);
                    helper.toggleSpinner(component,event);
                }
                /* END - Manuel Medina - 12122018 */
            }
            i++;
	    });
       /* Start Changes */
        /* Added by Ruben Fernandez */
    	var action = component.get("c.getfetchRecords");
        var CSType = component.get("v.ObjectType");
        var Object = "AccountContactAssetRelation__c";
        
        Object = "Asset";
        CSType = "AssetFieldResults";

        if(where != ''){
            //Set the Object parameters and Field Set name
            action.setParams({
                sObjectName 	: Object,
                sObjectType 	: CSType,
                sWhereClause	: where,
                whereSOSL		: lstRowsSelected,
                bAllowAccess    : false
            });
            action.setCallback(this, function(response){
                helper.toggleSpinner(component,event);
                if(response.getState() === 'SUCCESS'){
                    var rows = response.getReturnValue().lstDataTableData;
                    if(rows.length>0){
    	                var lstRowsAttributes = [];
    	                var lstAttributesType = [];
                        var actions = helper.getRowActions.bind(this, component);             
    	                lstAttributesType.push({type: 'action',typeAttributes: { rowActions: actions }});
    	                var columns = response.getReturnValue().lstDataTableColumns;
                        //columns.push({ label: '', fieldName: 'HasReadAccess', type: 'boolean', cellAttributes: { iconName: { fieldName: 'AccessType' }, iconPosition: 'right' } });
                        columns.push({type:  'action', typeAttributes: { rowActions: actions } });
    	                var rows = response.getReturnValue().lstDataTableData;
                        var lstRowsObjects = [];
    	                for (var i = 0; i < rows.length; i++) {
                            var row = rows[i];
                            row.sObjectVal.UserRecordAccess.HasReadAccess = row.bHasReadAccess;
                            // if(row.bHasReadAccess){
                            //     row.sObjectVal.AccessType = '';
                            // }else{
                            //     row.sObjectVal.AccessType = 'utility:shield';
                            // }
                            lstRowsObjects.push(row.sObjectVal);
    	                 }
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
            
        }
        /* BEGIN - Manuel Medina - Logic to prevent infinte spinner when the user doesn't insert search criterias - 16082018 */
        else{
        	helper.toggleSpinner(component,event);
        }
        /* END - Manuel Medina - 16082018 */
	},
    /* Added by Ruben Fernandez */
    updateColumnSorting: function (component, event, helper) {
        var fieldName 		= event.getParam('fieldName');
        var sortDirection 	= event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    /* Added by Ruben Fernandez */
    getSelectedName: function (component, event) {
        var lstRowsSelected = [];
        var selectedRows = event.getParam('selectedRows');
        for (var i = 0; i < selectedRows.length; i++){
            lstRowsSelected.push({value: selectedRows[i].Id})
            console.log(selectedRows[i].Id);
        }
        component.set("v.selectedRows",lstRowsSelected);
        component.set("v.numberRows",selectedRows.length);
    },
    /* Added by Ruben Fernandez */
    navigateToSObject: function (component, event, helper) {
        var action  = event.getParam('action');
        var row     = event.getParam('row');
        var selectedRows = event.getParam('selectedRows');
        var navEvt = $A.get("e.force:navigateToSObject");
        switch (action.name) {
            case 'show_details':       
                navEvt.setParams({
                  "recordId": row.Id,
                });
                navEvt.fire();
                break;
            case 'get_access': 
            	helper.getSecretQuestion(component, event, row.Id);
				component.find("theStaticModal").openModal();
				break;
        }
    },
    onConfirm : function(component, event, helper) {
        helper.getSecretResponse(component,event);
    },
    /* Added by Ruben Fernandez */
	onCancel : function(component, event, helper) {
        component.set("v.selectedrecord","");
		component.find("theStaticModal").closeModal();
        helper.showToast(component, event, helper, "warning");
        component.set("v.message", "You clicked the 'Cancel' button.");
	},
    /* Added by Ruben Fernandez */
    onCreateRecord : function (component, event, helper){
        var createRecordLoad     = component.find('cmpCreateRecord');
        var attrObjects          = component.get("v.From");
        console.log('onCreateRecord ' + attrObjects);
        createRecordLoad.dataLoad(attrObjects);
    },
    /*Infinite Loading*/
    loadMoreData: function (component, event, helper) {
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', 'Please wait ');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
    
})