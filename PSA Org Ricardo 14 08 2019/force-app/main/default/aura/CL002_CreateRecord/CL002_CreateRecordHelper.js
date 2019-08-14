({
	showMessage : function(component, event, stitle, smessage, stype){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"   : stitle,
            "message" : smessage,
            "type"    : stype
        });
        toastEvent.fire();
    },
    getRecordTypes: function(component, event) {
	    console.log('getRecordTypes');
	    var action = component.get("c.fetchRecordTypeValues");
	    action.setParams({
	       "sObjectName": component.get("v.objectName")
	    });
	    var opts = [];
	    action.setCallback(this, function(response) {
	       if (response.getState() == "SUCCESS") {
	          var allValues = response.getReturnValue();
	             for (var i = 0; i < allValues.length; i++) {
	                opts.push({
	                      label: allValues[i],
	                      value: allValues[i]
	                });
	             }
	             component.set("v.lstOfRecordType", opts);
	             this.fetchDefaultRecordType(component,event);
	       }else{
	           console.log('Callback Failed...');
	       }
	    });
	    $A.enqueueAction(action);
	},
	fetchDefaultRecordType: function(component, event) {
	    console.log('getDefaultRecordTypes');
	    var action = component.get("c.fetchDefaultRecordType");
	    action.setParams({
	       "sObjectName": component.get("v.objectName")
	    });
	    var opts = [];
	    action.setCallback(this, function(response) {
	       if (response.getState() == "SUCCESS") {
	          var allValues = response.getReturnValue();
	            component.set("v.rtselected",allValues);
	            component.find("theStaticModal").openModal();
	       }else{
	           console.log('Callback Failed...');
	       }

	    });
	    $A.enqueueAction(action);
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
	          console.log('Oppss!! ->> Callback failed...');
	       }
	    });
	    $A.enqueueAction(action);
	},
	executeCORScall : function(message,url,bCallBack,windowHash) { 
        
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
        	this.fixCORScallIE11(url);
        	var xmlHttp = new XMLHttpRequest();
	        console.log('body: ' + message);
	        console.log('url: ' + url);
	        xmlHttp.open( "POST", url, true );
	        xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	        xmlHttp.responseType = 'text';
	        xmlHttp.onload = function () {
	            console.log('executeCORScall-->onload');
	            console.log(xmlHttp.readyState + ' <|> ' + xmlHttp.status);
	            if (xmlHttp.readyState === 4) {
	                if (xmlHttp.status === 200) {
	                    console.log(' Response: ' + xmlHttp.response + ' Body: ' + xmlHttp.responseText);
	                }
	            }
	        };
	        xmlHttp.send( message );
	        console.log("Request sent");
        }
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
})