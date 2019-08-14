({    
	
	handleSuccess: function (component, event, helper) {
		component.set("v.isEnabledSpinner",false);
		//Show toast success
		helper.showToast(component, "", $A.get("$Label.c.CreateCase_Success"), "success");
		//Close modal component
		component.find("overlayLib").notifyClose();
		var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
		var caseId = updatedRecord.response.id;
		//Navigate to case
		var url = window.location.href;
		var urlSplit = url.split('/s/');
		var urlFinal = urlSplit[0]+'/s/case/'+caseId+'/detail';
		window.open(urlFinal,'_self');		
	},    
	
    handleLoad: function(cmp, event, helper) {
		component.set("v.isEnabledSpinner",true);
	},
		
	handleError: function (component, event, helper) {
		component.set("v.isEnabledSpinner",false);
	},

	handleSave : function( component, event, helper ){
		component.set("v.isEnabledSpinner",true);
		var submitForm					= 0;
		
		submitForm						+= helper.validateField( component, "Subject" );
		submitForm						+= helper.validateField( component, "Brand__c" );
		submitForm						+= helper.validateField( component, "Priority" );
		submitForm						+= helper.validateField( component, "Reason" );
		submitForm						+= helper.validateField( component, "Country__c" );
		submitForm						+= helper.validateField( component, "CategoryL1__c" );
		submitForm						+= helper.validateField( component, "AccountId" );
	
		if( submitForm === 0 ){
			component.find('editForm').submit();
		}
		else{
			component.set("v.isEnabledSpinner",false);
		}

	},

	removeRequiredStyles : function( component, event, helper ){
		var field						= event.getSource().getLocalId();

		helper.removeRequiredStyles( component, field );
	}	

	
})