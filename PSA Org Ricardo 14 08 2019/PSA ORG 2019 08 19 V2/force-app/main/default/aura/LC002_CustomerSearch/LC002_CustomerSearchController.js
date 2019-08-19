/**
*   @Class : LC002_CustomerSearchController.js
*
*   @Author         :   Ruben Fernandez
*   @Created        :   23 Feb 2018
*   @Description    :   Controller class for LC002_CustomerSearch.cmp

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer           		Date                     Description
*	   Ruben Fernandez			18/1/2018				 Creation.		
*   ----------------------------------------------------------------------------------------------------------------------------
**/
({
	doInit: function(component, event, helper) {
		helper.getLabelList(component, "Account", "v.AccountMap");
		helper.getLabelList(component, "Asset", "v.AssetMap");
		helper.getLabelList(component, "AccountContactAssetRelation__c", "v.AccountContactAssetRelationMap");
		helper.getLabelList(component, "Order", "v.OrderMap");
		helper.getLabelList(component, "Contact", "v.ContactMap");
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
	filter : function(component, event, helper) {
		helper.toggleSpinner(component,event);
		var where = '';

		var Ids = ["Account.Name", "FirstName", "LastName","Account.Phone" , "Phone"
					, "NationalId__pc", "Account.FiscalId__c", "Account.Email__c", "PersonEmail", "BillingPostalCode", 
					"BillingCountry" , "Account.BillingPostalCode", "Account.BillingCountry"
					, "Asset.VIN__C", "Asset.VIS__c", "Account.CommercialRegistrationNumber__c", "Asset.OrderId__r.OrderNumber", "DriverLicenceNumber__pc"];

		var IdsSearch = ["Account.StandardizedCompanyName__c", "StandardizedFirstName__pc", "StandardizedLastName__pc","Account.Phone" , "Phone"
					, "NationalId__pc", "Account.FiscalId__c", "Account.Email__c", "PersonEmail", "BillingPostalCode", 
					"BillingCountry" , "Account.BillingPostalCode", "Account.BillingCountry"
					, "Asset.VIN__C", "Asset.VIS__c", "Account.CommercialRegistrationNumber__c", "Asset.OrderId__r.OrderNumber", "DriverLicenceNumber__pc"];

		var IdsSearchB2B = ["Account.StandardizedCompanyName__c", "StandardizedFirstName__c", "StandardizedLastName__c","Account.Phone" , "Phone"
					, "NationalId__pc", "Account.FiscalId__c", "Account.Email__c", "PersonEmail", "BillingPostalCode", 
					"BillingCountry" , "Account.BillingPostalCode", "Account.BillingCountry"
					, "Asset.VIN__C", "Asset.VIS__c", "Account.CommercialRegistrationNumber__c", "Asset.OrderId__r.OrderNumber"];

		var changeObject    = true;
		var lstRowsSelected = '';
		var i = 0;
		var CSType = component.get("v.ObjectType");

		Ids.forEach(function(Id) {
			if(component.find(Id)!= undefined && component.find(Id).get("v.value") != null && component.find(Id).get("v.value") != ''){
				console.log('IndexOf ' + Id.indexOf("."));
				if(component.find(Id).get("v.value").length >1){                        
					if(Id.indexOf(".") == -1 ){
						changeObject = false;
					}
					var sField  =(CSType.includes( 'B2B' ) )?IdsSearchB2B[i]:IdsSearch[i];

					/* BEGIN - Manuel Medina - C1STAGILE-6094 - Clause .normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase() was commented because is not supported by Internet Explorer - 12122018 */
					/* Normalization logic was moved to APEX server side */
					if(where == ''){
						var auxPhone = ( sField=='Phone' && CSType.includes( 'B2C' ) ) ? '(' : '';
						if( sField=='Phone' && CSType.includes( 'B2C' ) ){
							where = where + auxPhone + sField + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
							where		= where + " OR Account.LandlinePersonalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.MobilePersonalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.LandlineProfessionalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.MobileProfessionalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
										")";
										
						}else{
							var aux = (sField=='Account.FiscalId__c')?'(':'';
							where = where + aux + sField + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
							if(sField=='Account.FiscalId__c'){
								where = where +  " OR Account.NonUniqueFiscalId__c LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\')";
							}
						}
						
						if( sField != 'Asset.OrderId__r.OrderNumber' ){
							lstRowsSelected = "\"" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "*\"";
						}
						
					}else{
						var aux = (sField=='Account.FiscalId__c')?' AND (':'';
						var auxPhone = ( sField=='Phone' && CSType.includes( 'B2C' ) ) ? '(' : '';
						
						if(sField=='Account.FiscalId__c'){
							where = where + aux + sField + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
							where = where +  " OR Account.NonUniqueFiscalId__c LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\')";
							
						}else if( sField=='Phone' && CSType.includes( 'B2C' ) ){
							where = where + "AND" + auxPhone + sField + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
							where		= where + " OR Account.LandlinePersonalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.MobilePersonalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.LandlineProfessionalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
											" OR Account.MobileProfessionalTelephone__pc LIKE \'" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'" +
										")";
							
						}else{
							where = where + " AND " + sField + " LIKE \'" +  component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "%\'";
						}
						
						if( sField != 'Asset.OrderId__r.OrderNumber' ){
							lstRowsSelected =  lstRowsSelected + " AND " + "\"" + component.find(Id).get("v.value")/*.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toUpperCase()*/ + "*\"";
						}
					}
				}else{
					component.set("v.errors", [{message: $A.get("$Label.c.CustomerSearchErrorMessageLength") + " " + Id }]);
					helper.handleError(component,event);
				}
				/* END - Manuel Medina - 12122018 */
			}
			i++;
		});


		var Object = "";
		if(CSType == "B2C"){
			Object = "Account";
			where = where + (where != ''?" AND":"") +" isPersonAccount=True";
			component.set("v.relobject",null);
			
			if( component.get( "v.selectedSalesman.Id" ) != undefined ){
				if( changeObject ){
					where = where + ( where != ''?" AND Owner.id = \'":" Owner.id = \'" ) + component.get( "v.selectedSalesman.Id" ) + "\'";
				}else{
					where = where + ( where != ''?" AND Account.Owner.id = \'":" Account.Owner.id = \'" ) + component.get( "v.selectedSalesman.Id" ) + "\'";	
				}
			}
			
		}else if(CSType == "Asset"){
			Object = "Asset";
			CSType = "Asset";
			component.set("v.relobject","Account");
		}else{
			console.log(changeObject);
			Object = (changeObject==true)?"Account":"Contact";
			CSType =  (changeObject==true)?"B2BAccount":"B2B";
			if(component.get("v.selectedUsuario.Id") != undefined){
				if(changeObject==true){
					where = where + (where != ''?" AND Owner.id = \'":" Owner.id = \'") + component.get("v.selectedUsuario.Id") + "\'";
				}else{
					where = where + (where != ''?" AND Account.Owner.id = \'":" Account.Owner.id = \'") + component.get("v.selectedUsuario.Id") + "\'";	
				}
			}
			
			where = where + (where != ''?" AND":"") +" isPersonAccount=false";            
			component.set("v.relobject","Account");
		}
		component.set("v.ObjectType",CSType);
		component.set("v.From", Object);

		var action = component.get("c.getfetchRecords");
		if(where != ''){
			action.setParams({
				sObjectName 	: Object,
				sObjectType 	: CSType,
				sWhereClause	: where,
				whereSOSL		: lstRowsSelected,
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
						columns.push({ label: '', fieldName: 'HasReadAccess', type: 'boolean', cellAttributes: { iconName: { fieldName: 'AccessType' }, iconPosition: 'right' } });
						columns.push({type:  'action', typeAttributes: { rowActions: actions } });
						var rows = response.getReturnValue().lstDataTableData;
						var lstRowsObjects = [];
						for (var i = 0; i < rows.length; i++) {
							var row = rows[i];
							row.sObjectVal.UserRecordAccess.HasReadAccess = row.bHasReadAccess;
							if(row.bHasReadAccess){
								row.sObjectVal.AccessType = '';
							}else{
								row.sObjectVal.AccessType = 'utility:shield';
							}
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
	},
	/* Added by Ruben Fernandez */
	handleClick: function (component, event, helper) {
		var selectedButtonLabel =   event.getSource().get("v.name");
		var lstCMP = ["btnB2B", "btnB2C", "btnAsset"];
		lstCMP.forEach(function(Id) {
			if(component.find(Id)!=undefined){
				var auxcmp = component.find(Id);
				if(auxcmp.get("v.name")==selectedButtonLabel){ 
					$A.util.removeClass(auxcmp, "slds-button--neutral");
					$A.util.addClass(auxcmp, "slds-button--brand");
				}else{
					$A.util.removeClass(auxcmp, "slds-button--brand");
					$A.util.addClass(auxcmp, "slds-button--neutral");
				}
			}
		});
		component.set("v.data","");
		component.set("v.columns","");
		component.set("v.totalNumberOfRows", "-1");
		helper.setFormFilter(component, selectedButtonLabel);
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
	/* Added by Ruben Fernandez */
	onOpenStaticModal : function(component, event, helper) {       
		helper.getSecretQuestion(component,event);
		component.find("theStaticModal").openModal();
	},
	/* Added by Ruben Fernandez */
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