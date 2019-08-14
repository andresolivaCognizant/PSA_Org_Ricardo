({
    checkMoreLeads : function(component,event){       
        var caseId = component.get("v.recordId");      
        var action = component.get("c.isOnlyLead");
        var isOnly;

        action.setParams({
            "caseId": caseId
        });
             
        action.setCallback(this, function(response){                    
            var state = response.getState();
            if(state === "SUCCESS"){
                isOnly = response.getReturnValue();
                if(isOnly != null){
                    component.set("v.leadName", isOnly[0].Name);
                    component.set("v.leadId", isOnly[0].Id);
                    component.set("v.IsMoreLeads", true);
                    component.set("v.showLoadingSpinner", false);
                }else{
                    this.isCorrectAcc(component, caseId);                    
                }
            }         
        });
        $A.enqueueAction(action);	   
    },

    isCorrectAcc : function(component, caseId){
        var action = component.get("c.isCorrectAccount");

        action.setParams({
            "caseId": caseId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var isCorrect;
            if(state === "SUCCESS"){
                isCorrect = response.getReturnValue();
                if(isCorrect == true){
                    component.set("v.edit", true);
                }else{
                    component.set("v.IsPerson", true);
                }
            }
            component.set("v.showLoadingSpinner", false);
        });
        $A.enqueueAction(action);
    },


    saveLead : function(component,event){
        component.set("v.showLoadingSpinner", true);

        var caseId = component.get("v.recordId");
        var Activity =  component.find("Activity").get("v.value");
        var LeadRequestType =  component.find("LeadRequestType").get("v.value");
        var ProductCustomerInterest =  component.find("ProductCustomerInterest").get("v.value");
        var ProductOwned =  component.find("ProductOwned").get("v.value");
        
        if(!Activity == '' && !LeadRequestType == ''){          
            var action = component.get("c.createLead");
            action.setParams({
                "caseId" : caseId,
                "activity" : Activity,
                "leadRequestType" : LeadRequestType,
                "productCustomerInterest" : ProductCustomerInterest,
                "productOwned" : ProductOwned
                
            });
            
            action.setCallback(this, function(response){
                component.set("v.showLoadingSpinner", true);
                var state = response.getState();
                var isAccount = response.getReturnValue();
                if(state === "SUCCESS"){
                    if(isAccount != null){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: $A.get("$Label.c.LeadSave"),
                            type: "success"
                        });
                        toastEvent.fire();
                        
                        component.set("v.showLoadingSpinner", false);
                        component.set("v.edit", false);
                        this.checkMoreLeads(component, event);                                                     
                        $A.get('e.force:refreshView').fire();                        
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Warning!",
                            message: $A.get("$Label.c.LeadSave"),
                            type: "warning"
                        });
                        toastEvent.fire(); 

                        component.set("v.showLoadingSpinner", false);
                        component.set("v.edit", true);
                        this.checkMoreLeads(component, event);                                                     
                        $A.get('e.force:refreshView').fire();  
                    }
                }else if(state === "ERROR"){
                    let jsonError = JSON.parse(action.getError()[0].message);
                    var errorData = jsonError.sName;
                    if(errorData.indexOf("FIELD_CUSTOM_VALIDATION_EXCEPTION" > 0)){
                        let lstmessage = errorData.split(",");
                        let messageSplit = '';
                    for (var i = 1; i < lstmessage.length; i++) { 
                          messageSplit += lstmessage[i] +', ';
                        }

                        let message =  messageSplit.slice(0, -2);

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : "Error!",
                            message : message,
                            type: "error"
                        });
                        toastEvent.fire();
                        component.set("v.showLoadingSpinner", false);
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : "Error!",
                            message : $A.get("$Label.c.Error_Administrator"),
                            type: "error"
                        });
                        toastEvent.fire();                       
                    }

                } 
            });
            $A.enqueueAction(action);      
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning!",
                message: $A.get("$Label.c.FillRequiredFields"),
                type: "warning"
            });
            toastEvent.fire(); 
            component.set("v.showLoadingSpinner", false);
        }
    },
})