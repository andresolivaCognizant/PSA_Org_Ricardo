({
	getRecordURL: function (name, value, access){
		var baseURL                 = '/PSADealer/s/detail/';
		var sURL                    = '"javascript:void(0)"';
		if(access){
			if(name!=undefined && name!=''){
				sURL = baseURL + value;
			}
		}
		return sURL;
	},

	getDateFormated: function (Newdate, NewTimeZone){
		var dFormat = Newdate.replace( " ", "T" ) + ".000";
		var d       = new Date(dFormat);
		
		return d;
	},
	
	formatValue: function (value){
		var sValue  = ' ';
		if(value!=undefined && value.length>0){
			sValue = value;
		}
		return sValue;
	},
	
	getData: function (component,event,refreshData){
		this.toggleSpinner(component,event);

		var searchByAccount = event.getParam("searchByAccount");
		var searchByAsset   = event.getParam("searchByAsset");
		var filterResults   = component.get("v.filterrows");

		if(refreshData!=undefined){
			searchByAccount = component.get("v.searchByAccount");
			searchByAsset   = component.get("v.searchByAsset");
		}

		if( (searchByAccount==undefined || searchByAccount=='') && (searchByAsset==undefined || searchByAsset=='' ) ){
			this.toggleSpinner(component,event);
			this.showMessage(component,event, $A.get("$Label.c.CustomerSearchExceptionTitle"),$A.get("$Label.c.CustomerSearchErrorMessageLength"),'error');

		}else{
			if((searchByAccount!=undefined && searchByAccount!='' && searchByAccount.length<2) || (searchByAsset!=undefined && searchByAsset!='' && searchByAsset.length<2)) {
				this.toggleSpinner(component,event);
				this.showMessage(component,event, $A.get("$Label.c.CustomerSearchExceptionTitle"),$A.get("$Label.c.CustomerSearchErrorMessageLength"),'error');

			}else{
				var cmp					= component;
				var action 				= component.get("c.getfetchRecords");
				action.setParams({
					searchCriteria1 	: ( searchByAccount != undefined && searchByAccount != "" ? searchByAccount.replace( /[+]/g, " " ).trim() : searchByAccount ),
					searchCriteria2 	: ( searchByAsset != undefined && searchByAsset != "" ? searchByAsset.replace( /[+]/g, " " ).trim() : searchByAsset ),
					bFilter             : (filterResults==undefined)?false:filterResults
				});
				action.setCallback(this, function(response){
					this.toggleSpinner(component,event);

					if(response.getState() === 'SUCCESS'){
						var rows = response.getReturnValue().lstDataTableData;

						if(rows.length>0){
							var lstRowsAttributes = [];
							var lstAttributesType = [];
							var actions = this.getRowActions.bind(this, component);             
							lstAttributesType.push({type: 'action',typeAttributes: { rowActions: actions }});
							var columns = response.getReturnValue().lstDataTableColumns;
							columns.splice(columns.length-1, 1);
							component.set("v.shortcolumns",columns.slice(0,3));
							component.set("v.shortcolumnsb",columns.slice(3,7));
							columns[0].type             = 'url';
							columns[0].fieldName        = 'AstLink';
							columns[0].typeAttributes   = {label: {fieldName: 'LastKnownRegistrationNumber__c'},target:'_blank'};
							columns[3].type             = 'url';
							columns[3].fieldName        = 'AccLink';
							columns[3].typeAttributes   = {label: {fieldName: 'Name'},target:'_blank'};
							columns[7].type             = 'url';
							columns[7].fieldName        = 'ObjLink';
							columns[7].typeAttributes   = {label: {fieldName: 'AccountRole__c'},value:{fieldName: 'AccountRole__c'},target:'_blank'};
							columns.push({type:  'action', typeAttributes: { rowActions: actions } });
							var rows                    = response.getReturnValue().lstDataTableDataW;
							var lstRowsObjects          = [];
							for (var i = 0; i < rows.length; i++) {
								var row                                         = rows[i];
								row.lstWrapperVal.LastKnownRegistrationNumber__c    = this.formatValue(row.lstWrapperVal[0].fieldvalue);
								row.lstWrapperVal.Model__c                          = this.formatValue(row.lstWrapperVal[1].fieldvalue);
								row.lstWrapperVal.VIN__c                            = this.formatValue(row.lstWrapperVal[2].fieldvalue);
								row.lstWrapperVal.Name                              = row.lstWrapperVal[3].fieldvalue;
								row.lstWrapperVal.PersonEmail                       = row.lstWrapperVal[5].fieldvalue;
								row.lstWrapperVal.TECH_NationalId__c                = row.lstWrapperVal[4].fieldvalue;
								row.lstWrapperVal.TECH_Phone__c                     = row.lstWrapperVal[6].fieldvalue;
								row.lstWrapperVal.AccountRole__c                    = this.formatValue(row.lstWrapperVal[7].fieldvalue);
								row.lstWrapperVal.Id                                = row.lstWrapperVal[8].fieldvalue;
								row.lstWrapperVal.AccountId                         = row.lstWrapperVal[9].fieldvalue;
								row.lstWrapperVal.AssetId                           = row.lstWrapperVal[10].fieldvalue;
								row.lstWrapperVal.AccessType                        = (row.bHasReadAccess==true)?'utility:info':'';
								row.lstWrapperVal.AccLink                           = this.getRecordURL(row.lstWrapperVal[3].fieldvalue,row.lstWrapperVal[9].fieldvalue,row.bHasReadAccess); 
								row.lstWrapperVal.AstLink                           = this.getRecordURL(row.lstWrapperVal[0].fieldvalue,row.lstWrapperVal[10].fieldvalue,true);
								row.lstWrapperVal.ObjLink                           = this.getRecordURL(row.lstWrapperVal[7].fieldvalue,row.lstWrapperVal[8].fieldvalue,row.bHasReadAccess); 
								row.lstWrapperVal.UserRecordAccess                  = [];
								row.lstWrapperVal.UserRecordAccess.HasReadAccess    = row.bHasReadAccess;
								lstRowsObjects.push(row.lstWrapperVal);
							}
						}else{
							this.toggleErrMessage(component,event);
						}    
						
						component.set( "v.searchByAccount", ( searchByAccount != undefined && searchByAccount != "" ? searchByAccount.replace( /[+]/g, " " ).trim() : searchByAccount ) );
						component.set( "v.searchByAsset", ( searchByAsset != undefined && searchByAsset != "" ? searchByAsset.replace( /[+]/g, " " ).trim() : searchByAsset ) );
						
						component.set("v.columns", response.getReturnValue().lstDataTableColumns);             
						
						if( cmp.get( "v.showData" ) ){
							component.set( "v.data", lstRowsObjects );
							
						}else{
							component.set( "v.data_tmp", undefined )
							component.set( "v.data", undefined );
							component.set( "v.data_tmp", lstRowsObjects );
						}
						
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
						component.set("v.searchByAccount","");
						component.set("v.searchByAsset", "");
						this.toggleErrMessage(component,event);
					}else{
						component.set("v.searchByAccount","");
						component.set("v.searchByAsset", "");
						console.log('Something went wrong, Please check with your admin');
						this.toggleErrMessage(component,event);
					}
				});
				$A.enqueueAction(action);
			}
		}
	},
	
	handlePills : function (searchByAccount,searchByAsset){
    	var appEventSearchPill  = $A.get("e.c:AfterSalesSearchHeaderFieldEvent");  
      	if(appEventSearchPill != undefined){
          	appEventSearchPill.setParams({
            	"runPillsAcc"   : searchByAccount,
            	"runPillsAss"   : searchByAsset
          	});
        appEventSearchPill.fire();
      }
  	},
  	
	getRowActions: function (component, row, doneCallback) {
		var actions = [];
		if (row['UserRecordAccess'].HasReadAccess==true) {
			actions.push({
				'label'     : $A.get("$Label.c.AfterSalesSearchEditAccountDetail"),
				'iconName'  : 'utility:edit',
				'name'      : 'edit_details_account'
			});
			actions.push({
				'label'     : $A.get("$Label.c.AfterSalesSearchEditAssetDetail"),
				'iconName'  : 'utility:edit',
				'name'      : 'edit_details_asset'
			});
			actions.push({
				'label'     : 'Change Role',
				'iconName'  : 'utility:replace',
				'name'      : 'update_role'
			});
		} else {
			actions.push({
				'label'     : $A.get("$Label.c.CustomerSearchGetAccess"),
				'iconName'  : 'utility:shield',
				'name'      : 'get_access'
			});
		}
		setTimeout($A.getCallback(function(){doneCallback(actions);}),200);
	},
	
	getSecretQuestion : function (component, event, sId, sId2){
		component.set("v.selectedrecordSQ",sId);
		component.set("v.selectedrecordSQB",sId2);
		
		var action = component.get("c.getSecretQuestion");
		action.setParams({
			sId         :   sId,
			sObjectName :   'Account',
			sObjectType :   'SecretQuestionFields' + component.get("v.ObjectType")
		});

		action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var retResponse = response.getReturnValue();
				var outputValue = component.find("FieldSecret");
				if(retResponse!=null){
					component.find("theStaticModal").openModal();
					var lstResults  = retResponse.split(',');

					if(lstResults!=null){
						var sValue  =  lstResults[0];
						var sLabel  =  lstResults[1];  
						var sQuest  =  lstResults[2];  
						component.set("v.secretvalue", sQuest);
						outputValue.set("v.value", sValue);
						outputValue.set("v.label",sLabel);
					}
				}else{
					component.set("v.secretvalue", "-Error-");
					outputValue.set("v.value", "");
					outputValue.set("v.label","");
					component.find("theStaticModal").closeModal();
					this.showMessage(component, event,$A.get("$Label.c.SecretQuestionMessageNoQuestionTitle"),$A.get("$Label.c.SecretQuestionMessageNoQuestion"),'warning');
				}
			}else if (state === "ERROR") {
				console.log('Error getSecretQuestion (Helper)');
				component.find("theStaticModal").closeModal();
			}
		});
		$A.enqueueAction(action);
	},
	
	getSecretResponse : function (component, event, helper){
		var action      = component.get("c.getQuestionResponse");
		var outputValue = component.find("FieldSecret");
		var sId         = component.get("v.selectedrecordSQ");
		
		component.set("v.selectedrecordSQ","");
		component.set("v.message", "");

		action.setParams({
			sValue      :   component.get("v.secretvalue"),
			sResponse   :   outputValue.get("v.value"),
			sId         :   sId,
			sUserId     :   $A.get("$SObjectType.CurrentUser.Id")
		});

		action.setCallback(this,function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var retResponse = response.getReturnValue();
				component.find("theStaticModal").closeModal(); 
				if(retResponse){
					component.set("v.message", "Access");
					this.showToast(component, event, "success");
					this.allowAccess(component,event);
				}else{
					this.showToast(component, event, "error");
					component.set("v.message", "No Access");
				}
				outputValue.set("v.value","");
				component.set("v.secretvalue","");
			}else if (state === "ERROR") {
				console.log('Error getSecretResponse (Helper)');
			}
		});
		$A.enqueueAction(action);
	},
	
	fetchPickListVal: function(component, fieldName, elementId) {
		var action = component.get("c.getselectOptions");

		action.setParams({
			"objObject" : component.get("v.objInfo"),
			"fld"		: fieldName
		});

		var opts = [];
		action.setCallback(this, function(response) {
			if (response.getState() == "SUCCESS") {
				var optsField  = response.getReturnValue().lstOptions;
				if (optsField != undefined && optsField.length > 0) {
					opts.push({
						class: "optionClass",
						label: $A.get("$Label.c.AfterSalesSearchPicklistNoneEntry"),    
						value: ""
					});
				}
				for (var i = 0; i < optsField.length; i++) {
					opts.push({
						class: "optionClass",
						label: optsField[i].Value,
						value: optsField[i].Field
					});
				}
				component.find(elementId).set("v.options", opts);
			}
		});
		$A.enqueueAction(action);
	},
	
	setAccountRole: function(component, event) {
		var outputValue = component.find("FieldRole").get("v.value");
		var outputCheck = component.find("SaveRecord").get("v.value");
		var sId         = component.get("v.selectedRecordId");
		var action      = component.get("c.setAccountRoleValue");

		action.setParams({
			"sRecordId" : sId,
			"sValue"    : outputValue,
			"bValue"    : outputCheck
		});

		action.setCallback(this, function(response) {
			var state   = response.getState();
			if(state === 'SUCCESS'){
				var retResponse = response.getReturnValue();
				if(retResponse.length==4 && retResponse=='true'){
					this.refreshView(component, event);
					component.find("theStaticModalOwner").closeModal(); 
					this.showToast(component, event, "success");
				}else{
					this.showMessage(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),retResponse,'warning');
				}
			}else if (state === "ERROR"){
				this.showToast(component, event, "error");
			}
			component.find("FieldRole").set("v.value","");
			component.find("SaveRecord").set("v.value",false);
		});
		$A.enqueueAction(action);
	},
	
	createAccountAssetRel: function(component, event) {
		var selectValue = component.find("FieldRoleRel").get("v.value");
		var sAssetId    = component.get("v.selectedAssetRow");
		var sAccountId  = component.get("v.selectedAccRow");
		var bUpdate     = component.find("SaveRecordRel").get("v.value");
		var oRecords    = component.get("v.setdata");      
		var action      = component.get("c.setAccountAssetRelationship");

		action.setParams({
			"sAssetId"  : sAssetId,
			"sAccuntId" : sAccountId,
			"sRoleName" : selectValue,
			"bUpdate"   : bUpdate
		});

		action.setCallback(this, function(response) {
			var state   = response.getState();
			if(state === 'SUCCESS'){
				var retResponse = response.getReturnValue();
				if(retResponse.length==4 && retResponse=='true'){
					component.find("theStaticModalRelation").closeModal(); 
					this.refreshView(component, event);
					this.showToast(component, event, "success");
					component.set("v.setdata",undefined);
					
				}else{
					var sError = retResponse.split(',');
					this.showMessage(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),sError[1].trim(),'Error');
				}
			}else if (state === "ERROR"){
				this.showMessage(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),response.getError()[0].message,'Error');
			}
			component.find("FieldRoleRel").set("v.value","");
			component.find("SaveRecordRel").set("v.value",false);
		});
		$A.enqueueAction(action);
	},
	
	showToast : function(component, event, stype) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": stype + "!",
			"type" : stype,
			"message": stype=="success"?$A.get("$Label.c.SecretQuestionMessageSuccess"):$A.get("$Label.c.SecretQuestionMessageError"),
			"messageTemplateData": ['SFDC', {
                refresh: false,
            }],
		});
		toastEvent.fire();
	},
	
	handleError: function(component, event){
		var errorsArr  = component.get("v.errors");
		for (var i = 0; i < errorsArr.length; i++) {
			console.log("error " + i + ": " + JSON.stringify(errorsArr[i]));
			this.showMessage(component,event,$A.get("$Label.c.CustomerSearchExceptionTitle"),errorsArr[i].message,'warning');
		}
	},
	
	showMessage : function(component, event, stitle, smessage, stype){
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title"   : stitle,
			"message" : smessage,
			"type"    : stype,
			"messageTemplateData": ['SFDC', {
                refresh: false,
            }],
		});
		toastEvent.fire();
	},
	
	allowAccess: function (component,event) {
		this.getData(component,event,true)
	},
	
	refreshView: function (component,event) {
		this.getData(component, event, true);
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
	
	toggleSpinner: function (component, event) {
		var spinner = component.find("divSpinner");
		$A.util.toggleClass(spinner, "slds-hide");
	},
	
	toggleErrMessage: function (component, event) {
		var divNoResults = component.find("divNoResults");
		$A.util.removeClass(divNoResults, "slds-hide");
		$A.util.addClass(divNoResults, "slds-show");
	},

	isRepeatRepairJs: function(component, relation) {
		component.find("btnWorkshopAppointmentNext").set("v.value", relation);
		component.find("chkReturning").set("v.checked", false);

		var action = component.get("c.isRepeatRepair");

		action.setParams({
			sObjectId: relation
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var isRepeat = response.getReturnValue();
				if (isRepeat) {
					component.find("newAppointmentModal").openModal();
				} else {
					this.createWorkshopAppointment(
						component,
						relation,
						false
					);
				}
			}

			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});

		$A.enqueueAction(action);
	},

	createWorkshopAppointment: function( component, relation, blnIsQuickReception ) {
		var sb_data = component.get("v.myoRecord") ? JSON.stringify(component.get("v.myoRecord")) : null;

		var action = component.get("c.insertWorkshopAppointment");
		action.setParams({
			"idRelation": relation,
			"blnIsQuickReception": blnIsQuickReception,
			"strMyOResponse": sb_data
		});
		
		var self								= this;
		var evt									= event;

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				if( response.getReturnValue().hasError ){
					console.log( "Appointment couldn't be inserted" );
					
				}else if( response.getReturnValue().appBookedToday ){
					this.showMessage( component, event, "ERROR", $A.get( "$Label.c.AfterSalesQuickReceptionError" ), "error" );
					
				} else {
					var appointmentId					= response.getReturnValue().Id;
					
					self.fireNewAppointmentEvent( component, appointmentId, blnIsQuickReception );
				}
				
			}else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});

		$A.enqueueAction(action);
	},
	
	fireNewAppointmentEvent : function( component, appointmentId, blnIsQuickReception ){
		var navURL			= $A.get( "e.force:navigateToURL" );
		var URL				= "/workshopappointment/" + appointmentId; 
		var myoRecord		= component.get("v.myoRecord");
		
		if( blnIsQuickReception || ( myoRecord != undefined && myoRecord.EntityType != undefined && myoRecord.EntityType == "TIME_SLOT" ) ){
			URL				+= "?mode=new";
		}
		
		navURL.setParams( {
			"url" : URL
		} );
		
		navURL.fire();
	},
	
	setRowsSelected : function ( component, event, rowsSelected ) {
		var lstRowsSelected     = [];
		var lstFullRowsSelected = [];
	
		for (var i = 0; i < rowsSelected.length; i++){
			if(rowsSelected[i].UserRecordAccess.HasReadAccess){
				lstRowsSelected.push({value: rowsSelected[i].Id});
				lstFullRowsSelected.push(rowsSelected[i]);
			}
		}
		
		var auxCol0 = component.get("v.shortcolumns");
		var auxCol1 = component.get("v.shortcolumnsb");
		component.set("v.shortcolumns",undefined);
		component.set("v.shortcolumnsb",undefined);
		component.set("v.setdataRel",lstFullRowsSelected);
		component.set("v.selectedRows",lstRowsSelected);
		component.set("v.numberRows",rowsSelected.length);
		component.set("v.shortcolumns",auxCol0);
		component.set("v.shortcolumnsb",auxCol1);
	},

	startCORScall: function(component,sType,bCallBack) {
//	    console.log('Start Validation DMS');
	    var action = component.get("c.DMSWakeUpbyCORS");
	    var windowHash = component.get("v.windowHash");
	    action.setParams({
	       "sType": sType
	    });
	    action.setCallback(this, function(response) {
	       if (response.getState() == "SUCCESS") {
	          var allValues = response.getReturnValue();
	          this.executeCORScall(allValues.body,allValues.endpoint,bCallBack,windowHash);
	       }else{
	       	  this.closeCORScall(bCallBack,windowHash);
	          console.log('Callback Failed...');
	       }
	    });
	    $A.enqueueAction(action);
	},
	
	executeCORScall : function(message,url,bCallBack,windowHash) {
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
        	this.fixCORScallIE11(url);
	        console.log('body: ' + message);
	        console.log('url: ' + url);
	        var xmlHttp = new XMLHttpRequest();
	        xmlHttp.open( "POST", url, true );
	        xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	        xmlHttp.responseType = 'text';
	        xmlHttp.onload = function () {
	            console.log("onload");
	            console.log(xmlHttp.readyState);
	            console.log(xmlHttp.status);
	            if (xmlHttp.readyState === 4) {
	                if (xmlHttp.status === 200) {
	                    console.log(xmlHttp.response);
	                    console.log(xmlHttp.responseText);
	                }
	            }
	        };
	        xmlHttp.send( message );
	        console.log("Request sent");
        }
        this.closeCORScall(bCallBack,windowHash);
    },
    
    fixCORScallIE11 : function(url) { 
        try{
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('GET', url, true);
            xmlHttp.withCredentials = true;
            xmlHttp.send();
        }catch(e){
            console.log(e);
        }
    },
    
    closeCORScall : function(bCallBack,windowHash) { 
    	if (bCallBack){
    		//self.preventDefault();
        	self.location = windowHash;
        }
    },
    
	getURL : function(param1, param2) {
		var sParam			= '';
		var sPath = window.location.pathname;
		if(!$A.util.isUndefinedOrNull(param1) && !$A.util.isEmpty(param1)){
			sParam = '?' + 'searchCLI' +'='+ param1;
		}
		if(!$A.util.isUndefinedOrNull(param2) && !$A.util.isEmpty(param2)){
			//if(!$A.util.isUndefinedOrNull(var2) && !$A.util.isEmpty(var2)){
			if(!$A.util.isUndefinedOrNull(param1) && !$A.util.isEmpty(param1)){
				sParam += '&';
			}else{
				sParam += '?';
			}
			sParam += 'searchAST' +'='+ param2;
		}
		sPath += ($A.util.isUndefinedOrNull(sParam))?'':sParam;
		return sPath 
	},


})