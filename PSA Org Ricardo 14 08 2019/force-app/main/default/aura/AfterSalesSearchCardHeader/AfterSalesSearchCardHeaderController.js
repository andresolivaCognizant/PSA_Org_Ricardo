({   
    handleOnClick1: function(component, event, helper) {
       
        console.log('Start of AfterSalesSearchCardHeaderController.handleOnClick1...');
        var sId     		= event.getSource().getLocalId();
        
        if (sId=='button1') {
            var createRecordLoad     = component.find('cmpCreateRecordAccount');
            //component.set("v.objectName","Account");
            var sAction = component.get("v.buttonAction1");
            var sObjectName = (!$A.util.isUndefinedOrNull(sAction) && !$A.util.isEmpty(sAction))?sAction:'Account';            
            component.set("v.objectName",sObjectName);
            createRecordLoad.dataLoad(sObjectName);
            
        } else if(sId=='button2'){
            // component.set("v.objectName","Asset");
            // if(component.get("v.buttonAction1")==undefined){
            //   createRecordLoad.dataLoad('Asset');
            // }
            var createRecordLoad     = component.find('cmpCreateRecordAsset');
            var sAction = component.get("v.buttonAction2");
            var sObjectName = (!$A.util.isUndefinedOrNull(sAction) && !$A.util.isEmpty(sAction))?sAction:'Asset';
            component.set("v.objectName",sObjectName);
            createRecordLoad.dataLoad(sObjectName);
      	} else if(sId=='button3'){
          if($A.util.isUndefinedOrNull(component.get("v.buttonAction3"))){
        		var appEvent = $A.get("e.c:AfterSalesSearchRelEvent");
             appEvent.setParams({
                "runRelationshipWizard": true
             });
             appEvent.fire();
          }
        }
    },

})