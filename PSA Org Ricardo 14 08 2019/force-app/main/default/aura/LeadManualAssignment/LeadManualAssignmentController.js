({
	doInit : function(component, event, helper) {
        console.log("Start of LeadManualAssignmentHelper.doInit...");
        var fieldList = component.get("v.fieldList");
        console.log('Fields: ' + fieldList);
        
        console.log('filter: ' + component.get("v.filter"));
        console.log('filterByPriority: ' + component.get("v.filterByPriority"));
        console.log('filterByActivity: ' + component.get("v.filterByActivity"));
        console.log('filterByActivityIsList: ' + component.get("v.filterByActivityIsList"));
        console.log('filterByStatus: ' + component.get("v.filterByStatus"));
        console.log('filterByCurrentUser: ' + component.get("v.filterByCurrentUser"));
  
        /* 
		component.set("v.Select", "Id,Name");
	    component.set("v.From", "Lead");
        
	    var priorityLevel = component.get("v.PriorityLevel");
        var leadStatus = component.get("v.Status");
        
        var priorityLevel = component.get("v.PriorityLevel");
        var leadStatus = component.get("v.Status");
        var whereClause = " status = '" + leadStatus + "' ";
        if (priorityLevel != 'ALL')
        {
            whereClause = whereClause + " and TreatmentPriorityLabel__c = '" + priorityLevel + "' ";
        }
        console.log("whereClause" + whereClause);
        component.set("v.WhereClause", whereClause);
*/
	},
    
	onOpenStaticModal : function(component, event, helper) { 
        console.log("Start of LeadManualAssignmentHelper.onOpenStaticModal...");      
		component.find("theStaticModal").openModal();
	},
    
	onConfirm : function(component, event, helper) {       
        console.log("Start of LeadManualAssignmentHelper.onConfirm...");   
        var checkboxField 	= component.find("checkFieldValue");
        if (checkboxField!=null){
        	checkboxField.set("v.value","false");
        }
        helper.setTransferRecords(component);
        component.set("v.selectedUser","");
        component.find("theStaticModal").closeModal();
	},
    
	onCancel : function(component, event, helper) {     
        console.log("Start of LeadManualAssignmentHelper.onCancel...");
        component.set("v.selectedUser","");
		component.find("theStaticModal").closeModal();
	},
    
    onCreateRecord : function (component, event, helper){     
        console.log("Start of LeadManualAssignmentHelper.onCreateRecord...");
        var createRecordLoad     = component.find('cmpCreateRecord');
        var attrObjects          = component.get("v.From");
        console.log('onCreateRecord ' + attrObjects);
        createRecordLoad.dataLoad(attrObjects);
    },
})