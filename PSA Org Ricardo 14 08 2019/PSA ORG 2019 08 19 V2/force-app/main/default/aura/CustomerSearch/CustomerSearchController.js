/**
	*   @Class : CSFilterController.js
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   18 Jan 2018
	*   @Description    :   Controller class for CSFilter.cmp
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Raul Barba				18/1/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
({
    doInit: function(component, event, helper) {
    	helper.getLabelList(component, "Account", "v.AccountMap");
    	helper.getLabelList(component, "Asset", "v.AssetMap");
    	helper.getLabelList(component, "AccountContactAssetRelation__c", "v.AccountContactAssetRelationMap");
    	helper.getLabelList(component, "Order", "v.OrderMap");
    	helper.getLabelList(component, "Contact", "v.ContactMap");
    	
    },
    
    /*
     * @Method          :   filter
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   18 Jan 2018
     * @Description     :   Method that converts and adapts all the filter 
     * information so that it can be used directly in a query for the Customer Search.
     */	
	filter : function(component, event, helper) {
        var where = '';
        var Ids = ["Account.Name", "FirstName", "LastName","Account.Phone" , "Phone"
                   , "NationalId__pc", "NationalId__c", "Email", "PersonEmail", "BillingPostalCode", 
                   "BillingCountry" , "Account.BillingPostalCode", "Account.BillingCountry"
                   , "AssetId__r.VIN__C", "AssetId__r.VIS__c", "RegistrationNumber__c", "AssetId__r.OrderId__r.OrderNumber"];
        var changeObject    = true;
        var lstRowsSelected = '';
        
        Ids.forEach(function(Id) {
            if(component.find(Id)!= undefined && component.find(Id).get("v.value") != null && component.find(Id).get("v.value") != ''){
            	console.log('IndexOf ' + Id.indexOf("."));
            	if(Id.indexOf(".") == -1 ){
            		changeObject = false;
            	}
                if(where == ''){
                	where = where + Id + " LIKE \'%" +  component.find(Id).get("v.value") + "%\'";
                    lstRowsSelected = "\"" + component.find(Id).get("v.value") + "\"";
            	}else{
                	where = where + " AND " + Id + " LIKE \'%" +  component.find(Id).get("v.value") + "%\'";
                    lstRowsSelected =  lstRowsSelected + " AND " + "\"" + component.find(Id).get("v.value") + "\"";
            	}
                
            }
		});
		
        var CSType = component.get("v.ObjectType");
        var Object = "";
        if(CSType == "B2C"){
            Object = "Account";
            where = where + (where != ''?" AND":"") +" isPersonAccount=True";
            component.set("v.relobject",null);
        }else if(CSType == "ASSET"){
            Object = "AccountContactAssetRelation__c";
            CSType = "Asset";
            component.set("v.relobject","Account");
        }else{
        	console.log(changeObject);
            Object = (changeObject==true)?"Account":"Contact";
            //Object = (changeObject==true)?"Contact":"Contact";
            CSType =  (changeObject==true)?"B2BAccount":"B2B";
            if(component.get("v.selectedUsuario.Id") != undefined){
            	if(changeObject==true){
            		where = where + (where != ''?" AND Owner.id = \'":" Owner.id = \'") + component.get("v.selectedUsuario.Id") + "\'";
            	}else{
            		where = where + (where != ''?" AND Account.Owner.id = \'":" Account.Owner.id = \'") + component.get("v.selectedUsuario.Id") + "\'";	
            	}
            }
            where = where + (where != ''?" AND":"") +" isPersonAccount=false";
            console.log(component.get("v.selectedUsuario.Id"));
            component.set("v.ObjectType",CSType);
            component.set("v.relobject","Account");
        }
	        
        if(where != ''){
	        
	        var action = component.get("c.setSelect");
	        action.setParams({ sObjectType : CSType });
	
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	                component.set("v.Select", response.getReturnValue());
	                component.set("v.From", Object);
	                component.set("v.Where", where);
                    component.set("v.WhereSOSL", lstRowsSelected);
	                component.set("v.Filter", true);
	                var attrFields      = component.get("v.Select");
	                var attrObjects     = component.get("v.From");
	                var attrCondition   = component.get("v.Where");
	                var attrFilter      = component.get("v.Filter");
                    var attrSOSL        = component.get("v.WhereSOSL");
	                var resultsLoad     = component.find('cmpResults');
	                var resultsBox      = component.find('cmpResultBox');
					$A.util.removeClass(resultsBox, "slds-hide");
	                resultsLoad.dataFilter(attrFields,attrObjects,attrCondition,attrFilter,attrSOSL);
	            }
	            else if (state === "ERROR") {
	                var errors = response.getError();
	                if (errors) {
	                    if (errors[0] && errors[0].message) {
	                        console.log("Error message: " + 
	                                 errors[0].message);
	                    }
	                } else {
	                    console.log("Unknown error");
	                }
	            }
	        });
	
	        $A.enqueueAction(action);
        }
	},
    handleClick: function (component, event, helper) {
        var selectedButtonLabel =   event.getSource().get("v.label");
        //var resultsBox = event.getSource();

        var lstCMP = ["btnB2B", "btnB2C", "btnAsset"];
        lstCMP.forEach(function(Id) {
            if(component.find(Id)!=undefined){
                var auxcmp = component.find(Id);
                if(auxcmp.get("v.label")==selectedButtonLabel){ 
                    $A.util.removeClass(auxcmp, "slds-button--neutral");
                    $A.util.addClass(auxcmp, "slds-button--brand");
                }else{
                    $A.util.removeClass(auxcmp, "slds-button--brand");
                    $A.util.addClass(auxcmp, "slds-button--neutral");
                }
            }
        });
        helper.setFormFilter(component, selectedButtonLabel);
    }
})