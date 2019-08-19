({
	doInit : function(component, event, helper) {
		//console.log('Start of CSResultController.doInit...');
        helper.getsObjectRecords(component);
        helper.getLabelList(component);
        helper.initPicklists(component,event,helper);
    },
    pageChange: function(component, event, helper) {
         var page 		= component.get("v.page") || 1;
         var direction 	= event.getParam("direction");
         if (direction === "first") page = 1;
         if (direction === "last") page = component.get("v.pages");
         if (direction === "previous") page = page - 1;
         if (direction === "next") page = page + 1;
         helper.getsObjectRecords(component,page);
    },
    checkChange: function(component,event, helper){

        var checkvalue  =   component.find("checkField").get("v.value");
        var chk         =   component.find("checkFieldRow"); 

        if(checkvalue==true){
            for(var i=0;i<chk.length;i++){
                chk[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0;i<chk.length;i++){
                chk[i].set("v.value",false);
            }
        }
    },
    checkRowChange: function(component,event, helper){

        var chk         =   component.find("checkFieldRow");

        for(var i=0;i<chk.length;i++){
            if(chk[i].get("v.value")==true){
                
            }else{
                chk[i].set("v.value",false);
            }
        }
    },
    loadMore: function(component, event, helper) {
        helper.getNextPage(component);
    },
    changeRecordsPerPage: function(component,event,helper) {
        helper.getsObjectRecords(component);
    },
    order: function(component, event, helper) {
        if (component.get("v.recordsShown")==0) return;
        var whichone    = event.target.id;
        if (whichone == 'Has Read Access') return;
    	//console.log('starg order which ' + whichone);
        var icons 		= component.find("arrow");
        icons.forEach(function(icon) {
            icon.set("v.iconName","utility:arrowdown");
            icon.set("v.class","arrow");
        });
        // We have the label value, we need the Field value instead
        var listLabels 	= component.get("v.labelList");
        var listFields 	= component.get("v.fields");
        listFields 		= listFields.replace(/\s/g, '');
        listFields 		= listFields.split(',');
        var labelPos;
    	//console.log('starg order listFields ' + listFields);
    	//console.log('starg order listLabels ' + listLabels);
        for (var i = listLabels.length - 1; i >= 0; i--) {
            if (listLabels[i] == whichone ) {
                whichone = listFields[i];
                labelPos = i;
            }
            if (whichone == undefined) whichone = listFields[0];
        }     
        var icon 		= icons[labelPos];
        icon.set("v.iconName","utility:arrowup");
        //console.log(icons[labelPos]);

        // once we have the field, we change v.order and place the arrow
        if (component.get("v.order") === whichone) {
            component.set("v.order", whichone + ' DESC');
            icon.set("v.iconName","utility:arrowdown");
            icon.set("v.class","arrowvisible");
        } else {
            component.set("v.order",whichone);
            icon.set("v.iconName","utility:arrowup");
            icon.set("v.class","arrowvisible");
        }
        // Reload records
        if (component.get("v.paginate")) {
            helper.getsObjectRecords(component);
        } else {
            helper.orderPage(component);
        }
    },
    onOpenStaticModal : function(component, event, helper) {       
        helper.getSecretQuestion(component,event);
		component.find("theStaticModal").openModal();
	},
	onConfirm : function(component, event, helper) {
        helper.getSecretResponse(component,event);
        helper.showToast(component, event, helper, "success");
        //helper.getsObjectRecords(component);
	},
	onCancel : function(component, event, helper) {
        component.set("v.selectedrecord","");
		component.find("theStaticModal").closeModal();
        helper.showToast(component, event, helper, "warning");
        component.set("v.message", "You clicked the 'Cancel' button.");
	},
	// onOpenDynamicModal : function(component, event, helper) {
	// 	component.set("v.message", "");
 //        // We create progammatically a modal alert box
 //        $A.createComponent(
	// 		"ui_modal:modal", {'aura:id': 'theDynamicModal'},
	// 		function(newModal, status, errorMessage){
	// 			//Add the new modal to the app body
	// 			if (status === "SUCCESS") {
	// 				var body = component.get("v.body");
	// 				body.push(newModal);
	// 				component.set("v.body", body);
 //                    // Pre-configure the title, message and an OK button
	// 				newModal.openModalAlert("Alert", "Hello world!");
	// 			} else {
	// 				//console.log("Failed to create modal");
	// 				//console.log("Error status: " + status);
	// 				//console.log("Error message: " + errorMessage);
	// 			}
	// 		}
	// 	);
	// }
})