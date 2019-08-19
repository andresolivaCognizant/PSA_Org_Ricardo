({
	getUserDetails : function(component, event, helper) {
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                component.set("v.userRecord", response.getReturnValue());
            } else if (state === 'ERROR'){
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
    },
    startCORScall: function(component,sType) {
        var action = component.get("c.DMSWakeUpbyCORS");
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
              var allValues = response.getReturnValue();
              this.executeCORScall(allValues.body,allValues.endpoint);
           }
        });
        $A.enqueueAction(action);
    },
    executeCORScall : function(message,url) { 
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
            this.fixCORScallIE11(url);
            var xmlHttp = new XMLHttpRequest();
            console.log('body: ' + message + ' · URL: ' + url);
            xmlHttp.open( "POST", url, true );
            xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xmlHttp.responseType = 'text';
            xmlHttp.onload = function () {
                if (xmlHttp.readyState === 4) {
                    if (xmlHttp.status === 200) {
                        //console.log(xmlHttp.response);
                        //console.log(xmlHttp.responseText);
                    }
                }
            };
            xmlHttp.send( message );
            //console.log("Request sent");
        }
    },
    fixCORScallIE11 : function(url) { 
        try{
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('GET', url, true);
            xmlHttp.withCredentials = true;
            xmlHttp.send();
        }catch(e){
            //console.log(e);
        }
    }
})