({
	startCORScall: function(component) {
        var action = component.get("c.DMSWakeUpbyCORS");
        action.setParams({
            "sRecordId_A" : component.get("v.sRecordId"),
            "sRecordId_B" : ''
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
              var allValues = response.getReturnValue();
              if(!$A.util.isUndefinedOrNull(allValues) && !$A.util.isEmpty(allValues)){
              	this.executeCORScall(allValues.body,allValues.endpoint);
              }else{
                this.executeServerCall(component);
              }
           }
        });
        $A.enqueueAction(action);
    },
    executeServerCall : function(component) { 
        var action = component.get("c.DMSWakeUpbyServer");
        action.setParams({
			"sRecordId" : component.get("v.sRecordId")
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
           		//console.log('Ok');
           }
        });
        $A.enqueueAction(action);
    },
    
    executeCORScall : function(message,url) { 
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
            this.fixCORScallIE11(url);
            var xmlHttp = new XMLHttpRequest();
            //console.log('body: ' + message + ' · URL: ' + url);
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