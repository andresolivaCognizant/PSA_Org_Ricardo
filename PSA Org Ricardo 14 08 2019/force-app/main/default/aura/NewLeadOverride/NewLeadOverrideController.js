({ 
    doInit : function(component,event, helper){
    	helper.checkMoreLeads(component,event);	
	},
    
    save : function(component,event, helper){
        helper.saveLead(component,event);
    },
          
    handleClick: function (component, event, helper) {
        var idLead = component.get("v.leadId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idLead
        });
        navEvt.fire();
    },
    
    showRequiredFields: function(component, event, helper){
    	//$A.util.removeClass(component.find("LeadType"), "none");
        $A.util.removeClass(component.find("Activity"), "none");
        $A.util.removeClass(component.find("LeadRequestType"), "none");
    },
})