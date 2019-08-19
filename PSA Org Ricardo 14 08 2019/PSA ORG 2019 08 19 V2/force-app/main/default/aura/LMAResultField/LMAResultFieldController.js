({
	doInit : function(component, helper) {
		//console.log('Start of LMAResultField.doInit...');
        var vRecord 	     = component.get('v.record');
        var vFieldName 	     = component.get('v.fieldName');
        var outputText 	     = component.find("outputTextId");
        var outputCheckbox   = component.find("outputCheckbox");
        var outputURL 	     = component.find("outputURLId");
        //debugger;
        //console.log(':::vRecord: ' + vRecord);
        if (vFieldName.indexOf(".") >= 0) {
        //console.log('GAS-DBG1');
            var sParentObject 	= vFieldName.split(".")[0];
            var oParentSobject;
            if(vRecord != undefined){
                oParentSobject 	= vRecord[sParentObject];
            }
            if(oParentSobject != undefined){
            	//console.log('GAS-DBG1.1');
                if(sParentObject  == 'UserRecordAccess'){
                	//console.log('GAS-DBG1.2');
                    var sValue = component.get("v.latestRecordsAccess");
                    if( sValue != undefined){
                    	//console.log('GAS-DBG1.3');
                         component.set("v.hasAccess",sValue[vRecord.Id]);
                    }
                    //var sValue = vRecord[vFieldName.split(".")[0]][vFieldName.split(".")[1]];
                    // //console.log('sValue ' + sValue);
                    // if(sValue==null || sValue==false){
                    //     component.set("v.hasAccess",false);
                    // }else{
                    //     component.set("v.hasAccess",sValue);
                    // }
                }else{
                	//console.log('GAS-DBG1.2.1');
                    if(vFieldName.split(".")[1]== 'Name' && sParentObject!='RecordType'){
                	//console.log('GAS-DBG1.2.2');
                      //outputURL.set("v.value", '/'+ vRecord.Id);
                      outputURL.set("v.label", oParentSobject[vFieldName.split(".")[1]]);
                    }else{
                    	//console.log('GAS-DBG1.2.3');
                	  outputText.set("v.value",oParentSobject[vFieldName.split(".")[1]]);
                    }
                }
            }
        }
        else if (vFieldName == 'Name' || vFieldName == 'LastName') {
            //console.log('GAS-DBG2');
            //   outputURL.set("v.value", '/'+ vRecord.Id);
             if(vRecord != undefined){
                outputURL.set("v.label", vRecord[vFieldName]);
             }
        }
        else{
            //console.log('GAS-DBG3'
            if(vRecord != undefined){
                outputText.set("v.value",vRecord[vFieldName]);
            }
            //console.log(':::value: ' + vRecord[vFieldName]);
        }
    },
    
    openModal : function(component, helper){
    	var openModalEvent 	= component.getEvent("ModalShow");
        var vRecord 		= component.get("v.record");
        //console.log('OpenModal Id: ' + vRecord["Id"]);
        openModalEvent.setParams({"Id":vRecord["Id"]});
  		openModalEvent.fire();
	},
	
    handleClick: function (component, event, helper) {
		console.log('Start of LMAResultField.handleClick...');
        var navEvt  = $A.get("e.force:navigateToSObject");
        var vRecord = component.get('v.record');
        navEvt.setParams({
            "recordId": vRecord.Id
        });
        navEvt.fire();
    }
})