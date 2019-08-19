({

	/*--------------------------------------------*/
	/*--------------ON INIT LOADING---------------*/
	/*--------------------------------------------*/
	doInit : function(component, event, helper){
		//Set de current date to att date
		var today = new Date();
		component.find("dateField").set("v.value",today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
	
        helper.getEventos(component, event, helper);  
	},
		
	/*--------------------------------------------*/
	/*--------------CALENDAR EVENTS---------------*/
	/*--------------------------------------------*/
	
	/*Updates the event page*/
	updateRender : function(component, event, helper){		
		helper.getEventPage(component, event, helper);
	},
	
	/*Updates the date input*/
	updateDate : function(component, event, helper){
		var date = new Date(event.getSource().get("v.value")+" 00:00:00");
		component.set("v.date", date);
		helper.getEventPage(component, event, helper);
	},
	
	
	/*Selects the clicked event and puts it in context*/
	selectEvent : function(component, event, helper){
		var eventTarget = event.currentTarget;
		var eventId = eventTarget.getAttribute("data-id");
		var currentTarget = event.currentTarget; 
		if(currentTarget.getAttribute("draggable") === "true"){
			helper.selectEventFire(component, eventId);
		}
	},
	
	/*Navigate to the target event sObject*/
	navigate : function(component, event, helper){
		var eventTarget = event.target;
		var eventId = eventTarget.getAttribute("data-id");

		if(eventId !== undefined && eventId !== null && eventTarget.getAttribute("draggable") !== "true"){
			var navEvt = $A.get("e.force:navigateToSObject");
		    navEvt.setParams({
		      "recordId": eventId,
		      "slideDevName": "related"
		    });
		    navEvt.fire();
	    }else{
	    	var toastEvent = $A.get("e.force:showToast");
		    toastEvent.setParams({
		        "title": "Atención!",
		        "message": "Se debe guardar primero el evento para poder visualizarlo"
		    });
		    toastEvent.fire();
	    }
	},
	
	
	/*Creates a new event in context in client side*/
	newEvent : function(component, event, helper){
		helper.addEvent(component, event, helper);
	},
	
	/*Makes resizable the target component before the user can drag it*/
	doResizable : function(component, event, helper){
		//Paramos el evento drag and drop
        event.preventDefault();
		var eventElementInContext = event.currentTarget.parentElement;
		helper.resizer.resizable = true;
		helper.resizer.position = event.currentTarget.getAttribute("data-position");
		helper.startPositionMouse = event.clientY;
		helper.eventElement = eventElementInContext;
		helper.selectEventFire(component, eventElementInContext.getAttribute("data-id"));
	}, 
	
	/*Resizes the event in context to the end position of mouse*/
	resize : function(component, event, helper){
		if(helper.resizer.resizable === true && helper.eventElement !== null){
			helper.resizer.resize(component, event, helper);
		}
	},
	
	/*When the user finishes the dragging*/
	removeResizable : function(component, event, helper){
		if(helper.resizer.resizable === true){
			helper.resizer.resizable = false;
			helper.selectEventFire(component, helper.eventElement.getAttribute("data-id"));
			helper.eventElement = null;
		}
	},
	
	/*Prevents the event in drop container*/
	onDragOverEvent: function(component, event, helper){
		event.preventDefault();
	},
	
	/*Captures the event when the user drops the event*/
	onDropEvent: function(component, event, helper){
		event.stopPropagation();
        event.preventDefault();
        helper.dragger.changeTimeByPosition(component, event, helper);
	},
	
	/*Drag the event to the position required*/
	drag : function(component, event, helper){
		helper.endPositionMouse = event.offsetY;
	},
	
	/*Set the event drag before the dragging starts*/
	dragStart : function(component, event, helper){
		event.dataTransfer.setData('id', event.target.id);
		event.dataTransfer.setData('startPosition', event.target.offsetTop);
		event.dataTransfer.setData('startPositionBottom', event.target.style.bottom);
		event.dataTransfer.setData('startPositionMouse', event.offsetY);
	},
	
	
	
	/*--------------------------------------------*/
	/*---------------EVENT TOOLTIPS---------------*/
	/*--------------------------------------------*/
	
	/*Prevent the event if there is an currentTarget*/
	preventEvent : function(component, event, helper){
		var ct = event.currentTarget;
		if(ct !== null && ct !== undefined){
			event.preventDefault();
			event.stopPropagation();
		}
	},
	
	/*Lets close the tooltip */
	closeWindow : function(component, event, helper){
		event.getSource().focus();
	}

})