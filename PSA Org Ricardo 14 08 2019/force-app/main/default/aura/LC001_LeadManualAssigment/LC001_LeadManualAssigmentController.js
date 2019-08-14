({
	
	doInit : function(component, event, helper) {		                
        helper.getDataHelper(component, event);
        helper.getListOfContacts(component, event);
    },
	updateColumnSorting: function (component, event, helper) {
        var fieldName 		= event.getParam('fieldName');
        var sortDirection 	= event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
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
    onOpenStaticModal : function(component, event, helper) { 
        var sSelected = component.get("v.selectedRows");
        console.log('Selected ' + sSelected);
        if(sSelected!=null && sSelected.length>0){
            component.find("theStaticModal").openModal();
        }else{
            helper.showMessgae(component,event,"","Select at least one record and try again.","Error");     
        }
    },
    onConfirm : function(component, event, helper) { 
        helper.setTransferRecords(component,event);
        component.set("v.selectedUser","");
        component.find("theStaticModal").closeModal();
    },
    onCancel : function(component, event, helper) {
        component.set("v.selectedUser","");
        component.find("theStaticModal").closeModal();
    },
    onCreateRecord : function (component, event, helper){
        var createRecordLoad     = component.find('cmpCreateRecord');
        var attrObjects          = component.get("v.From");
        console.log('onCreateRecord ' + attrObjects);
        createRecordLoad.dataLoad(attrObjects);
    },
    navigateToSObject: function (component, event) {

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
        }
    },
})