({
    loadListBtt: function (component, event, helper) {

        var listType = component.get("v.listaBotones");
        var action = component.get("c.loadListBtt");

        action.setParams({
            listType: listType,
        });

        action.setCallback(this, function (a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.bttList", a.getReturnValue());

                // C1STAGILE-8442 - Began
                // ***** Labels must be added to LabelComponent in order to be recovered ******
                var list = component.get('v.bttList');
                
                for (var i = 0; i < list.length; i++) { 
                    var labelSubStr = "$Label.c." + list[i].label;
                    var labelReference = $A.getReference(labelSubStr);
                    component.set("v.tempLabelAttr", labelReference);
                    list[i].label = component.get("v.tempLabelAttr");
                }

                component.set("v.bttList", list);
                // C1STAGILE-8442 - End
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });

        $A.enqueueAction(action);
    },

    startCORScall: function (component) {
        var action = component.get("c.dmsWakeUpbyCORS");
        action.setParams({
            "sRecordId_A": component.get("v.recordId"),
            "sRecordId_B": ''
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var allValues = response.getReturnValue();
                if (!$A.util.isUndefinedOrNull(allValues) && !$A.util.isEmpty(allValues)) {
                    this.executeCORScall(allValues.body, allValues.endpoint);
                } else {
                    this.executeServerCall(component);
                }
            }
        });
        $A.enqueueAction(action);
    },

    executeServerCall: function (component) {
        var action = component.get("c.dmsWakeUpbyServer");
        action.setParams({
            "sRecordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                //console.log('Ok');
            }
        });
        $A.enqueueAction(action);
    },

    executeCORScall: function (message, url) {
        if (!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)) {
            this.fixCORScallIE11(url);
            var xmlHttp = new XMLHttpRequest();
            //console.log('body: ' + message + ' · URL: ' + url);
            xmlHttp.open("POST", url, true);
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
            xmlHttp.send(message);
            //console.log("Request sent");
        }
    },

    fixCORScallIE11: function (url) {
        try {
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('GET', url, true);
            xmlHttp.withCredentials = true;
            xmlHttp.send();
        } catch (e) {
            //console.log(e);
        }
    },

})