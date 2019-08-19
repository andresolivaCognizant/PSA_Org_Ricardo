({
  doInit : function(component, event, helper) {
    console.log('CL002 START ');
    var sLocale           = window.location.toString();
    component.set("v.windowHash",sLocale);
  },
  onCreateRecord: function(component, event, helper) {
    component.set("v.isOpen", true);
    component.set("v.bCreate",true);
    var action 			      = component.get("c.getRecordTypeId");
    var recordTypeLabel 	= component.get("v.rtselected");
  
    if(recordTypeLabel!=undefined  && recordTypeLabel.length>0){
       action.setParams({
          "sObjectName" 		  : component.get("v.objectName"),
          "recordTypeLabel"   : recordTypeLabel
       });
       action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
             var createRecordEvent = $A.get("e.force:createRecord");
             var RecTypeID  = response.getReturnValue();
             createRecordEvent.setParams({
                "entityApiName" : component.get("v.objectName"),
                "recordTypeId" 	: RecTypeID,
             });
             createRecordEvent.fire();             
          } else if (state == "INCOMPLETE") {
             helper.showMessage(component, event, 'Oops!','No Internet Connection','Warning');
          } else if (state == "ERROR") {
             helper.showMessage(component, event,'Error!','Please contact your administrato','Error');
          }
          component.find("theStaticModal").closeModal();
       });
       $A.enqueueAction(action);
    }else{
       helper.showMessage(component, event, 'Value is Mandatory!','Please, select one value','Error');
    }
  },
  onOpenStaticModal : function(component, event, helper) {
    helper.getRecordTypes(component,event);
	},
	onCancel : function(component, event, helper) {
		component.find("theStaticModal").closeModal();
	},
	onRadioGroup : function(component, event, helper){
      // get the updated/changed values   
      var selectedOptionsList = event.getParam("value");
      // get the updated/changed source  
      var targetName = event.getSource().get("v.name");
       
      // update the selected itmes  
      if(targetName == 'Skills'){ 
         component.set("v.selectedSkillsItems" , selectedOptionsList);
      }
      console.log('radioSelected ' + selectedOptionsList );
		  component.set("v.rtselected",selectedOptionsList);
	},
  handleToastEvent : function(component, event, helper) {
    var sParams             = event.getParams();
    var sType               = sParams.type;
    var objectName          = component.get("v.objectName");
    var bCallBack           = (component.get("v.bCreate")!=undefined)?component.get("v.bCreate"):false;

    if (sType.toUpperCase() === 'SUCCESS'){
      if(bCallBack){
        helper.startCORScall(component,objectName,bCallBack);
      }
    }
  },
})