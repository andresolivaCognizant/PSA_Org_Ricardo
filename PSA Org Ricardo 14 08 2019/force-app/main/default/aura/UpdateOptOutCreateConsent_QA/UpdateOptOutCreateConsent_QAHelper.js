({
    executeInit: function (component, event, helper){

        var caseId = component.get("v.recordId");
        var action = component.get("c.check");

        action.setParams({
            "recordId": caseId,
            "invocationType" : "case"
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();

            if(state === "SUCCESS"){
                if(result === 'AVAILABLE_OPT_OUT'){
                    component.set('v.showConfirmButton', true);
                }
                else{
                    component.set('v.showConfirmButton', false);
                    component.set('v.informativeMessage', result);
                }
            }
            else{
                component.set('v.showConfirmButton', false);
                component.set('v.informativeMessage', $A.get("$Label.c.GenericErrorMessage"));                
            }
        });
        $A.enqueueAction(action);
    },

    executeSave : function (component, event, helper){

        var caseId = component.get("v.recordId");
        var action = component.get("c.updateOptOut");

        action.setParams({
            "recordId": caseId,
            "invocationType" : "case"
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            var variant;

            if(state === "SUCCESS"){
                //Case Error
                if(result === $A.get("$Label.c.GenericErrorMessage")){
                    variant = 'error';
                }
                //Case saved successfully
                else if(result === $A.get("$Label.c.Opt_Out_succes")){
                    variant = 'success';
                    component.set('v.showConfirmButton', false);
                }
                //Case saved successfully with warning
                else if(result === $A.get("$Label.c.Opt_Out_Successfully_Saved_With_Warning")){
                    variant = 'warning';
                    component.set('v.showConfirmButton', false);
                }
                //Unexpected error
                else{
                    variant = 'error';
                    result =  $A.get("$Label.c.GenericErrorMessage");                    
                }
                component.set('v.informativeMessage', result);
            }               
            else{
                variant = 'error';
                result =  $A.get("$Label.c.GenericErrorMessage");
            }
            component.find('notifLib').showToast({
                "variant": variant,      
                "message": result
            }); 
        });
        $A.enqueueAction(action);
    }
})