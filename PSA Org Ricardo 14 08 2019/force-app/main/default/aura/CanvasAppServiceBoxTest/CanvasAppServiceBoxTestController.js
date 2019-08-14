({
	sendMessage : function(component, event, helper) {
        var msg = {
            name: "statusChanged",
            value: component.get("v.messageToSend")
        };
        component.find("ServiceBoxTest").message(msg);
    },
    handleMessage: function(component, message, helper) {
        var payload = message.getParams().payload;
        var name    = payload.name;
        if (name === "statusChanged") {
            component.set("v.messageReceived", payload.value);
        }
        else if (name === "Foo") {
            // A different response
        }
    },
    handleError: function(component, error, helper) {
        var e = error;
    },
    doInit : function(component, event, helper) {
        //var SFDCOrigin = "https://" + component.get("v.SFDCHost");
        //var SFDCOrigin = "http://localhost.8080"; --> Service Box domain
        var SFDCOrigin = "https://cedacritest.000webhostapp.com";
        
		window.addEventListener("message", function(event) {
			if (event.origin !== SFDCOrigin) {
				// Not the expected origin: reject message
				return;
			}
			// Only handle messages we are interested in
			if (event.data.name === "com.psa.testmessage") {
				var SBOXMessages  = component.get("v.SBOXMessages");
				SBOXMessages      = SBOXMessages + event.data.payload + "\n";
				component.set("v.SBOXMessages", SBOXMessages);
			}
		}, false);
	},
	sendToSBOX : function(component, event, helper) {
        console.log(' Frame ' + component.find("vfFrame"));
        //var SFDCOrigin = "https://" + component.get("v.SFDCHost");
        var SFDCOrigin =  "https://cedacritest.000webhostapp.com";
        //var SFDCOrigin = "https://cedacritest.000webhostapp.com";
		var vfWindow = component.find("vfFrame").getElement().contentWindow;
		var message = {
			name: "com.psa.testmessage",
			payload: component.get("v.SFDCmessage")
		};
        vfWindow.postMessage(message, SFDCOrigin);
	},
})