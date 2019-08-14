({
	doInit : function(component, event, helper) {
		helper.getLabelList(component);
		helper.getsObjectRecords(component);
		helper.initPicklists(component,event,helper);
		var t = window.setInterval(
			$A.getCallback(function() {
				var selectedIds = component.get("v.selectedIds");
                //Check no page 1
                var page = component.get("v.page") || 1;
                var modal = component.get("v.modalUP") || false; 
                if (selectedIds.length > 0 || page > 1 || modal == true) {
                    console.log('No refresh');
                } else {
					helper.getsObjectRecords(component);
				}
			}),
		58500
		);
		component.set( "v.CheckIntervalId", t );
		//US 6822 BEGIN
		//helper.setInterval(component);
		//US 6822 END
	},

	handleTabEvent : function(component, event, helper) {
		//console.log('Start of LMAResultController.handleTabEvent...');
		var priorityLevel = event.getParam("filterByPriority");
		if (priorityLevel != null) component.set("v.filterByPriority", priorityLevel);
		
		var activityLevel = event.getParam("filterByActivity");
		if (activityLevel != null) component.set("v.filterByActivity", activityLevel);
		
		var refreshData = event.getParam("refreshData");
		
		if (refreshData)
		{
			helper.getsObjectRecords(component);
			helper.getLabelList(component);
			helper.initPicklists(component,event,helper);
		}
	},

	handleToggleEvent : function(component, event, helper) {
		var filterByCurrentUser = event.getParam("filterByCurrentUser");
		helper.getsObjectRecords(component);
		helper.getLabelList(component);
		helper.initPicklists(component,event,helper);
	},

	handleComponentEvent : function(component, event, helper) {
		var selectedUser = event.getParam("recordByEvent");
		component.set("v.selectedUser" , selectedUser);
	},

	onOpenStaticModal : function(component, event, helper) { 
		//US 6822 BEGIN
		var modal = component.set("v.modalUP", true);
		//US 6822 END
		component.set("v.selectedUser", null);
		var selectedRecords = component.get("v.selectedIds");
		if (selectedRecords.length == 0 || selectedRecords == 'undefined' || selectedRecords == null) {
			var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
				title   : "Warning!",
				message : "Please select at least one Lead first",
				type    : "warning"
				});
			toastEvent.fire();
			return;
				
		}
		helper.showModal(component);
	},

	onConfirm : function(component, event, helper) {
		helper.setTransferRecords(component,event);
	},

	onCancel : function(component, event, helper) {
		var modal = component.set("v.modalUP", false);
		component.set("v.selectedrecord","");
		helper.hideModal(component);
		component.set("v.message", "You clicked the 'Cancel' button.");
	},

	onCreateRecord : function (component, event, helper){
		var createRecordEvent = $A.get("e.force:createRecord");
		createRecordEvent.setParams({
			"entityApiName": "Lead" 
		});
		createRecordEvent.fire();
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
		var selectedIds = [];

		var checkvalue  =   component.find("checkField").get("v.value");
		var chk         =   component.find("checkFieldRow"); 

		if(checkvalue==true){
			for(var i=0;i<chk.length;i++){
				chk[i].set("v.value",true);
				selectedIds.push({value: chk[i].get("v.text")});
			}
		}
		else{ 
			for(var i=0;i<chk.length;i++){
				chk[i].set("v.value",false);
			}
		}
		component.set("v.selectedIds", selectedIds);
	},

	checkRowChange: function(component,event, helper){
		var selectedIds = [];
		var chk         =   component.find("checkFieldRow");

		if (chk.length > 0) {
			for (var i=0;i<chk.length;i++) {
				if(chk[i].get("v.value")==true){
					selectedIds.push({value: chk[i].get("v.text")});
					
				} else {
					chk[i].set("v.value",false);
				}
			}
		} else {
			if (chk.get("v.value")) {
				selectedIds.push({value: chk.get("v.text")});
			}
		}
		component.set("v.selectedIds", selectedIds);
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

		var icons 		= component.find("arrow");
		icons.forEach(function(icon) {
			icon.set("v.iconName","utility:arrowdown");
			icon.set("v.class","arrow");
		});

		var listLabels 	= component.get("v.labelList");
		var listFields 	= component.get("v.fields");
		listFields 		= listFields.replace(/\s/g, '');
		listFields 		= listFields.split(',');
		var labelPos;

		for (var i = listLabels.length - 1; i >= 0; i--) {
			if (listLabels[i] == whichone ) {
				whichone = listFields[i];
				labelPos = i;
			}
			if (whichone == undefined) whichone = listFields[0];
		}     
		var icon 		= icons[labelPos];
		icon.set("v.iconName","utility:arrowup");

		if (component.get("v.order") === whichone) {
			component.set("v.order", whichone + ' DESC');
			icon.set("v.iconName","utility:arrowdown");
			icon.set("v.class","arrowvisible");
		} else {
			component.set("v.order",whichone);
			icon.set("v.iconName","utility:arrowup");
			icon.set("v.class","arrowvisible");
		}

		if (component.get("v.paginate")) {
			helper.getsObjectRecords(component);
		} else {
			helper.orderPage(component);
		}
	}
})