({
	init : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		var idCase = myPageRef.state.c__recordId;
		var workspaceAPI = component.find("workspace");
		component.set("v.idCase", idCase);
		component.set("v.isCallCenter", (idCase != null));
		workspaceAPI.getFocusedTabInfo().then(function (response) {
				var focusedTabId = response.tabId;
				workspaceAPI.setTabLabel({
					tabId: focusedTabId,
					label: $A.get("$Label.c.CreateCase_NewCase")
				});
			});
		var action				= component.get( "c.getCurrentUser" );
		action.setCallback( this, function( response ){
			var state			= response.getState();
			if(state === "SUCCESS" ){
				component.set( "v.currentUserInfo", response.getReturnValue() );
			}
		});

		$A.enqueueAction( action );
	},

	handleSuccess : function(component, event, helper) {
		var newCase = event.getParams().response;
		var newCaseId = newCase.id;
		var workspaceAPI = component.find("workspace");
		workspaceAPI.openTab({
			url: '#/sObject/'+newCaseId+'/view',
			label: 'newCase.CaseNumber'
		}).then(function(response) {
			workspaceAPI.focusTab({tabId : response});
		})
		.catch(function(error) {
			console.log(error);
		});
		workspaceAPI.getFocusedTabInfo().then(function(response) {
			var newCaseTab = response.tabId;
			workspaceAPI.closeTab({tabid : newCaseTab.tabid})
		});
	},

	closeTab : function(component,event,helper){
		var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function(response) {
			var newCaseTab = response.tabId;
			workspaceAPI.closeTab({tabid : newCaseTab.tabid})
		});
	},

	doRefresh : function(component,event,helper){
		$A.get("e.force:refreshView").fire();
	},

	validateRequiredFields : function( component, event, helper ){
		component.set("v.isDisabled",true);
		var submitForm					= 0;
		
		submitForm						+= helper.validateField( component, "Subject" );
		submitForm						+= helper.validateField( component, "Brand__c" );
		submitForm						+= helper.validateField( component, "Priority" );
		submitForm						+= helper.validateField( component, "Reason" );
		submitForm						+= helper.validateField( component, "Country__c" );
		submitForm						+= helper.validateField( component, "CategoryL1__c" );
		submitForm						+= helper.validateField( component, "AuxAccountId" );

		if( submitForm === 0 ){
			let acc = component.get( "v.oCase" );
			
 			component.find( "AccountId" ).set( "v.value",  acc.AccountId);
			component.find( "AssetId" ).set( "v.value", acc.AssetId);

			component.find( "Status" ).set( "v.value", component.get( "v.currentUserInfo.Profile" ) == "ProfileCECUser0" ? "2" : "1" );

			component.find( "case" ).submit();
		}
		else{
			component.set("v.isDisabled", false);
		}
	},

	removeRequiredStyles : function( component, event, helper ){
		var field						= event.getSource().getLocalId();

		helper.removeRequiredStyles( component, field );
	}
})