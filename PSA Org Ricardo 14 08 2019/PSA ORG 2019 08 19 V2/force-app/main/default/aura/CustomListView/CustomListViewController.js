({
	doInit : function(component, event, helper) {
        //helper.getDataHelper(component, event);
        helper.isProduction(component,event);
        
        var action = component.get("c.getListViews");
 		action.setParams({strObjectName   : component.get("v.object")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjectListViewList",response.getReturnValue());
                helper.getRecordtHelper(component,event,response.getReturnValue()[0].Id);
            }
        });
        $A.enqueueAction(action); 
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
        if(sSelected!=null && sSelected.length>0){
            component.find("theStaticModal").openModal();
        }else{
            helper.showMessgae(component,event,"",$A.get("$Label.c.cListViewSelectionMandatory"),"Error");     
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
        console.log('onCreateRecord');
        var attrObjects          = helper.capitalizeFirstLetter(component.get("v.object"));
        component.set("v.Newobject",attrObjects);
        createRecordLoad.dataLoad(attrObjects);
         // var createRecordEvent  = $A.get("e.force:createRecord");
         // createRecordEvent.setParams({
         //    "entityApiName"     : attrObjects //component.get("v.objectName"),
         //    //"recordTypeId"  : RecTypeID
         // });
         // createRecordEvent.fire();     
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
    getFilteredRecord : function (component, event, helper) {
    	var sView = component.get('v.viewselected');
    	//console.log(sView);
        helper.getRecordtHelper(component,event,sView);
    },
    onViewDetail : function ( component, event, helper ) {
      var htmlId    = event.target.id;
      var urlEvent  = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        "url": "", /* To complete. */
      });
      urlEvent.fire();
    },
})