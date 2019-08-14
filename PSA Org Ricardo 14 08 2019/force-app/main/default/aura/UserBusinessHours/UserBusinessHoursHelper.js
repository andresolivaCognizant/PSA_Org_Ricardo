({
    getBHours: function(component) {

        var userId = component.get("v.recordId");

        var action = component.get("c.getBHours");

        action.setParams({
            userId: userId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = JSON.parse(response.getReturnValue());

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                
                if (storeResponse.length === 0 || storeResponse === undefined || storeResponse === null) {
                    var toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams({
                        "type": "error",
                        "duration": 5000,
                        "message": $A.get("$Label.c.NoBHFound")
                    });

                    toastEvent.fire();
                } else {
                    var mondayStart = storeResponse.MondayStart__c;
                    var mondayEnd = storeResponse.MondayEnd__c;
                    var tuesdayStart = storeResponse.TuesdayStart__c;
                    var tuesdayEnd = storeResponse.TuesdayEnd__c;
                    var wednesdayStart = storeResponse.WednesdayStart__c;
                    var wednesdayEnd = storeResponse.WednesdayEnd__c;
                    var thursdayStart = storeResponse.ThursdayStart__c;
                    var thursdayEnd = storeResponse.ThursdayEnd__c;
                    var fridayStart = storeResponse.FridayStart__c;
                    var fridayEnd = storeResponse.FridayEnd__c;
                    var saturdayStart = storeResponse.SaturdayStart__c;
                    var saturdayEnd = storeResponse.SaturdayEnd__c;
                    var sundayStart = storeResponse.SundayStart__c;
                    var sundayEnd = storeResponse.SundayEnd__c;
                    var holiStart = storeResponse.HolidayStart__c;
                    var holiEnd = storeResponse.HolidayEnd__c;

                    component.set("v.mondayStart", mondayStart);
                    component.set("v.mondayEnd", mondayEnd);
                    component.set("v.tuesdayStart", tuesdayStart);
                    component.set("v.tuesdayEnd", tuesdayEnd);
                    component.set("v.wednesdayStart", wednesdayStart);
                    component.set("v.wednesdayEnd", wednesdayEnd);
                    component.set("v.thursdayStart", thursdayStart);
                    component.set("v.thursdayEnd", thursdayEnd);
                    component.set("v.fridayStart", fridayStart);
                    component.set("v.fridayEnd", fridayEnd);
                    component.set("v.saturdayStart", saturdayStart);
                    component.set("v.saturdayEnd", saturdayEnd);
                    component.set("v.sundayStart", sundayStart);
                    component.set("v.sundayEnd", sundayEnd);
                    component.set("v.holiStart", holiStart);
                    component.set("v.holiEnd", holiEnd);
                }

            } else if (state === "ERROR") {
                var errors = response.getError();

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },

    getMnProfile: function(component) {
        var userId = component.get("v.recordId");

        var action = component.get("c.getMnProfile");

        action.setParams({
            userId: userId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                
                if (storeResponse.length === 0 || storeResponse === undefined || storeResponse === null || storeResponse === false) {
                    component.set("v.showTm", false);
                } else {
                	this.isProduction(component);
                    this.isCommunity(component);
                    this.getTeamMembs(component);
                }

            } else if (state === "ERROR") {
                var errors = response.getError();

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    getTeamMembs: function(component) {
        var eventList = [];

        var action = component.get("c.getTeamMembs");

        action.setParams({});

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = JSON.parse(response.getReturnValue());

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                
                if (storeResponse.length === 0 || storeResponse === undefined || storeResponse === null) {
                    component.set("v.showTm", false);
                } else {
                    component.set("v.userList", storeResponse);
                }

            } else if (state === "ERROR") {
                var errors = response.getError();

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },

    updBHours: function(component) {

        var userId = component.get("v.recordId");
        var mSt = component.get("v.mondayStart");
        var mEn = component.get("v.mondayEnd");
        var tuSt = component.get("v.tuesdayStart");
        var tuEn = component.get("v.tuesdayEnd");
        var wSt = component.get("v.wednesdayStart");
        var wEn = component.get("v.wednesdayEnd");
        var thSt = component.get("v.thursdayStart");
        var thEn = component.get("v.thursdayEnd");
        var fSt = component.get("v.fridayStart");
        var fEn = component.get("v.fridayEnd");
        var saSt = component.get("v.saturdayStart");
        var saEn = component.get("v.saturdayEnd");
        var suSt = component.get("v.sundayStart");
        var suEn = component.get("v.sundayEnd");
        var hSt = component.get("v.holiStart");
        var hEn = component.get("v.holiEnd");

        var action = component.get("c.updBHours");

        action.setParams({
            bHours: true,
            userId: userId,
            mStart: mSt,
            mEnd: mEn,
            tuStart: tuSt,
            tuEnd: tuEn,
            wStart: wSt,
            wEnd: wEn,
            thStart: thSt,
            thEnd: thEn,
            fStart: fSt,
            fEnd: fEn,
            saStart: saSt,
            saEnd: saEn,
            suStart: suSt,
            suEnd: suEn,
            hoStart: hSt,
            hoEnd: hEn
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            console.log('getMUpParams.state : ' + state);

            if (state === "SUCCESS") {

                var storeResponse = response.getReturnValue();

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0 || storeResponse == false) {
                    var toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams({
                        "type": "error",
                        "duration": 5000,
                        "message": $A.get("$Label.c.NoBHError")
                    });

                    toastEvent.fire();
                } else {

                    var toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams({
                        "type": "success",
                        "duration": 5000,
                        "message": $A.get("$Label.c.BHHoursUpdated")
                    });

                    toastEvent.fire();
                }

            } else if (state === "ERROR") {
                var errors = response.getError();

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },

    updHolidays: function(component) {

        var userId = component.get("v.recordId");
        var mSt = component.get("v.mondayStart");
        var mEn = component.get("v.mondayEnd");
        var tuSt = component.get("v.tuesdayStart");
        var tuEn = component.get("v.tuesdayEnd");
        var wSt = component.get("v.wednesdayStart");
        var wEn = component.get("v.wednesdayEnd");
        var thSt = component.get("v.thursdayStart");
        var thEn = component.get("v.thursdayEnd");
        var fSt = component.get("v.fridayStart");
        var fEn = component.get("v.fridayEnd");
        var saSt = component.get("v.saturdayStart");
        var saEn = component.get("v.saturdayEnd");
        var suSt = component.get("v.sundayStart");
        var suEn = component.get("v.sundayEnd");
        var hSt = component.get("v.holiStart");
        var hEn = component.get("v.holiEnd");

        var action = component.get("c.updBHours");

        action.setParams({
            bHours: false,
            userId: userId,
            mStart: mSt,
            mEnd: mEn,
            tuStart: tuSt,
            tuEnd: tuEn,
            wStart: wSt,
            wEnd: wEn,
            thStart: thSt,
            thEnd: thEn,
            fStart: fSt,
            fEnd: fEn,
            saStart: saSt,
            saEnd: saEn,
            suStart: suSt,
            suEnd: suEn,
            hoStart: hSt,
            hoEnd: hEn
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            console.log('getMUpParams.state : ' + state);

            if (state === "SUCCESS") {

                var storeResponse = response.getReturnValue();

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0 || storeResponse == false) {
                    var toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams({
                        "type": "error",
                        "duration": 5000,
                        "message": $A.get("$Label.c.NoBHError")
                        
                    });

                    toastEvent.fire();
                } else {

                    var toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams({
                        "type": "success",
                        "duration": 5000,
                        "message": $A.get("$Label.c.BHUpdated")
                    });

                    toastEvent.fire();
                }

            } else if (state === "ERROR") {
                var errors = response.getError();

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "type": "error",
                    "duration": 5000,
                    "message": errors[0].message
                });

                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },

    isProduction: function(component) {
        var action = component.get("c.isProduction");

        action.setCallback(this, function(response) {
            var isProduction = response.getReturnValue(); // do any operation needed here

            component.set("v.isProduction", isProduction);
        });

        $A.enqueueAction(action);
    },
    
    isCommunity: function(component) {
        var action = component.get("c.isCommunity");

        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); // do any operation needed here
            var isProduction = component.get("v.isProduction");

            if (isCommunity === true && !isProduction) {
                var p = window.location.pathname;
                var sPageURL = decodeURIComponent(p);
                var sURLVariables = sPageURL.split('/');
                var commName;
                var i;

                for (i = 0; i < sURLVariables.length; i++) {
                    console.log(sURLVariables[i]);
                    if (i === 1) {
                        commName = undefined ? null : sURLVariables[1];
                        commName = '/' + commName + '/';
                    }
                }
            } else {
                commName = '/';
            }

            component.set("v.commName", commName);
        });

        $A.enqueueAction(action);
    },

    inputCheck: function(component) {
        var s = component.get("v.holiStart");
        var e = component.get("v.holiEnd");

        // check if start or end dates are blank
        var bs = !s || !s.trim();
        var be = !e || !e.trim();

        if ((bs && !be) || (!bs && be)) {
            var t = $A.get("e.force:showToast");

            t.setParams({
                "type": "error",
                "duration": 5000,
                "message": $A.get("$Label.c.HolidayDatesError")
            });

            t.fire();
            return false;
        }

        return true;
    }
})