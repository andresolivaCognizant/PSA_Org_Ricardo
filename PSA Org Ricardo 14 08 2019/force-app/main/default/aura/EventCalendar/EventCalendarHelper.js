({
    //height in pixels of each hour in calendar
    hourHeight: 23,
    //Aux param to adjust the event in the calendar
    varAjuste: -1,
    //End position of mouse
    endPositionMouse: null,
    //Start position of mouse
    startPositionMouse: null,
    //EventElement in context
    eventElement: null,
    //Id of event element in context
    eventIdInContext: null,

    /*Resizes the event*/
    resizer: {
        resizable: false,
        position: null,

        resize: function(component, event, helper) {
            //console.log("currentMousePosition", event.clientY);
            var currentMousePosition = event.clientY;
            var hourHeight = helper.hourHeight;
            var module = currentMousePosition % hourHeight;
            //It adjust the height event to fixed hours
            if (module === 0 || module === Math.floor(hourHeight / 2)) {
                this.changeTimeByPosition(component, event, helper, currentMousePosition);
            }
        },

        changeTimeByPosition: function(component, event, helper, currentMousePosition) {
            var elementResizable = helper.eventElement;
            var eventId = elementResizable.getAttribute("data-id");
            var startPositionBottom = parseInt(elementResizable.style.bottom, 10);
            var startPosition = parseInt(elementResizable.style.top, 10);
            var startPositionMouse = parseInt(helper.startPositionMouse, 10);
            var endPositionMouse = currentMousePosition;
            var resizerPosition = this.position;

            var top = 0;
            var bottom = 0;

            var eventInContext = helper.getEventById(component, eventId);

            if (eventInContext !== null) {
                var startTime;
                var endTime;

                top = parseInt(startPosition + endPositionMouse - startPositionMouse, 10);
                bottom = parseInt(startPositionBottom - (endPositionMouse - startPositionMouse), 10);

                if (top >= 0 && resizerPosition === "top") {
                    startTime = helper.getTimeFromHeight(component, event, helper, top);
                    endTime = new Date(eventInContext.EndDateTime);
                } else if (bottom <= 0 && resizerPosition === "bottom") {
                    startTime = new Date(eventInContext.StartDateTime);
                    endTime = helper.getTimeFromHeight(component, event, helper, bottom);
                }

                helper.updateRenderEvent(component, event, helper, startTime, endTime, eventId);
                helper.endPositionMouse = currentMousePosition;

            }
        },
    },

    /*For drag & drop functionality*/
    dragger: {
        changeTimeByPosition: function(component, event, helper) {
            var elementId = event.dataTransfer.getData("id"); //retrieves dropped images data.
            var elementDraggable = document.getElementById(elementId);
            var eventId = elementDraggable.getAttribute("data-id");
            var startPositionBottom = parseInt(event.dataTransfer.getData("startPositionBottom"), 10);
            var startPosition = parseInt(event.dataTransfer.getData("startPosition"), 10);
            var startPositionMouse = parseInt(event.dataTransfer.getData("startPositionMouse"), 10);
            var endPositionMouse = helper.endPositionMouse;
            var top = 0;
            var bottom = 0;

            var startTime = null;
            var endTime = null;

            top = parseInt(startPosition + endPositionMouse - startPositionMouse, 10);
            bottom = parseInt(startPositionBottom - (endPositionMouse - startPositionMouse), 10);

            if (top >= 0) {
                startTime = helper.getTimeFromHeight(component, event, helper, top);
            }

            if (bottom <= 0) {
                endTime = helper.getTimeFromHeight(component, event, helper, bottom);
            }

            if (startTime !== null && endTime !== null) {
                helper.updateRenderEvent(component, event, helper, startTime, endTime, eventId);
            }

            helper.endPositionMouse = null;
            helper.startPositionMouse = null;
            helper.eventElement = null;
            helper.selectEventFire(component, eventId);
        },
    },

    getEventos: function(component, event, helper) {
        var self = this;
        var action = component.get("c.getEventos");
        var id = component.get("v.genIdAtt");
        var jsonData = '';
        var listaEventos = [];
        var listaEventosWrapped = [];
        var evento = {};
        var startDateTime;
        var endDateTime;
        var description;
        action.setParams({});

        action.setCallback(this, function(response) {
            jsonData = response.getReturnValue();
            listaEventos = JSON.parse(jsonData);
            if (listaEventos !== null && listaEventos !== undefined && listaEventos.length !== 0) {
                for (var i = 0; i < listaEventos.length; i++) {
                    evento = listaEventos[i];
                    startDateTime = new Date(evento.StartDateTime);
                    endDateTime = new Date(evento.EndDateTime);
                    description = evento.Description;
                    listaEventosWrapped.push({
                        Id: evento.id,
                        StartDateTime: startDateTime.getTime(),
                        EndDateTime: endDateTime.getTime(),
                        Asunto: evento.Subject,
                        Observaciones: evento.Description,
                        WhatName: evento.WhatName,
                        Concertada: null,
                        Canal: null,
                        Owner: '',
                        Offset: 0,
                        State: self.setOwnerEvent(startDateTime, evento.id, listaEventos),
                        //State: self.setOwnerEvent(evento.WhatId, id),
                    })
                }

                component.set("v.eventList", listaEventosWrapped);
            }
        });
        $A.enqueueAction(action);
    },

    setOwnerEvent: function(startDateTime, idEvent, listaEventos) {
        var evento;
        var id;
        var startDT;
        var endDT;
        
        if (startDateTime !== undefined && startDateTime !== null) {
            for (var i = 0; i < listaEventos.length; i++) {
                evento = listaEventos[i];
                id = evento.id;
                startDT = new Date(evento.StartDateTime);
                endDT = new Date(evento.EndDateTime);

                if (startDT <= startDateTime && startDateTime < endDT && idEvent !== id) {
                    return "owner";
                }
            }
        }
        return null;
    },

    getEventPage: function(component, event, helper) {
        var self = this;
        var targetDate = new Date(component.get("v.date"));

        targetDate.setHours(0, 0, 0, 0);

        var allEvents = component.get("v.eventList");
        var allEventsLength = allEvents.length;
        var ST = targetDate.getTime();
        var ET = ST + 86400000;
        var listaEventosPage = [];
        var SE = 0;
        var EE = 0;
        var duration = 0;

        if (allEvents !== null && allEvents !== undefined) {
            for (var i = 0; i < allEventsLength; i++) {
                SE = allEvents[i].StartDateTime;
                EE = allEvents[i].EndDateTime;
                allEvents[i].Offset = 0;
                //THE EVENT STARTS AND ENDS IN THE SAME DAY
                if (ST <= SE && ST <= EE && ET >= SE && ET >= EE) {
                    allEvents[i].Offset = 0;
                    listaEventosPage.push(allEvents[i]);
                    //THE EVENT STARTS THE DAY BEFORE 
                } else if (EE <= ET && EE >= ST && SE <= ST && SE <= ET) {
                    allEvents[i].Offset = -1;
                    listaEventosPage.push(allEvents[i]);
                    //ALL DAY EVENT
                } else if (EE >= ET && SE <= ST && EE >= ST && ET >= SE) {
                    allEvents[i].Offset = 1;
                    listaEventosPage.push(allEvents[i]);
                    // EVENT STARTS TODAY AND ENDS TOMORROW OR AFTER
                } else if (ST <= SE && ST <= EE && ET > SE && ET <= EE) {
                    allEvents[i].Offset = 2;
                    listaEventosPage.push(allEvents[i]);
                }
            }

            self.renderAllEvents(component, event, helper, listaEventosPage);
        }
    },


    /*UPDATE PAGE EVENTS, every event has a position and start and end date (AÑADIR DESCRIPCION DEL EVENTO)*/
    renderAllEvents: function(component, event, helper, listaEventos) {
        var self = this;
        var listaEventosOut = [];
        var evento = {};
        var listaEventosLength = listaEventos.length;
        var start;
        var finish;
        var offset;
        var eventColor = null;
        var draggable = false;

        if (listaEventosLength !== 0) {
            self.showMessage(component, event, helper, false);
            for (var i = 0; i < listaEventosLength; i++) {
                if (typeof(listaEventos[i].State) !== undefined) {
                    switch (listaEventos[i].State) {
                        case "new":
                            eventColor = "rgba(0, 138, 81, 0.72)";
                            break;
                        case "owner":
                            eventColor = "rgba(230, 159, 0, 0.92)";
                            break;
                        default:
                            eventColor = "rgba(0, 95, 178, 0.62)";
                            break;
                    }
                    if (listaEventos[i].Draggable === true) {
                        draggable = true;
                    }
                }

                start = new Date(listaEventos[i].StartDateTime);
                finish = new Date(listaEventos[i].EndDateTime);
                offset = listaEventos[i].Offset;

                evento = {
                    id: listaEventos[i].Id,
                    position: self.calculatePosition(start, finish, offset),
                    style: {
                        zindex: i,
                        left: (80 / listaEventosLength) * i,
                        background: eventColor
                    },
                    startTime: start.toISOString(),
                    endTime: finish.toISOString(),
                    observaciones: listaEventos[i].Observaciones,
                    asunto: listaEventos[i].Asunto,
                    whatName: listaEventos[i].WhatName,
                    draggable: draggable,
                }
                draggable = false;
                listaEventosOut.push(evento);
            }
        } else {
            self.showMessage(component, event, helper, true);
        }

        component.set("v.eventListRender", listaEventosOut);
    },

    getTime: function(dateString) {

        var date = new Date(dateString);

        var timeString = date.toTimeString().slice(0, 8);
        var year = date.getFullYear();
        var month = date.getMonth() + 1;
        var day = date.getDate();
        var hour = timeString[0] + timeString[1];
        var min = timeString[3] + timeString[4];
        var sec = timeString[6] + timeString[7];
        var milisecondsDate = 0;

        var resultTime = {
            day: day,
            month: month,
            year: year,
            hour: hour,
            min: min,
            sec: sec,
            timeToString: timeString,
            milisecondsDate: Date.parse(year + "-" + month + "-" + day + " " + hour + ":" + min),
        }

        return resultTime;
    },
    
	/*Calculate the top and botton position for the event in function start and end date*/
	calculatePosition : function(startTime, finishTime, Offset){
		var hourHeight = this.hourHeight;
		var varAjuste = this.varAjuste;
		var hourStart = startTime.getHours();
		var minStart = startTime.getMinutes();
		var hourFinish = finishTime.getHours();
		var minFinish = finishTime.getMinutes();
		
		var topMin = 0;
		var bottomMin = 0;
		var top = 0;
		var bottom = 0;
		
		switch(Offset){
			case 0: 
				topMin = (minStart/60)*hourHeight;
				bottomMin = (minFinish/60)*hourHeight;
				top = (hourHeight*hourStart)+varAjuste+topMin;
				bottom = (hourHeight*hourFinish)+varAjuste+bottomMin;
			break;
			
			case -1: 
				bottomMin = (minFinish/60)*hourHeight;
				bottom = (hourHeight*hourFinish)+varAjuste+bottomMin;
			break;
			
			case 1:
				bottom = (hourHeight*24)+varAjuste+bottomMin;
			break;
			
			case 2:
				topMin = (minStart/60)*hourHeight;
				bottomMin = (minFinish/60)*hourHeight;
				top = (hourHeight*hourStart)+19+topMin;
				bottom = (hourHeight*24)+varAjuste+bottomMin;
			break;
			
			default:
				topMin = (minStart/60)*hourHeight;
				bottomMin = (minFinish/60)*hourHeight;
				top = (hourHeight*hourStart)+varAjuste+topMin;
				bottom = (hourHeight*hourFinish)+varAjuste+bottomMin;
			 break;
		}
		

		var position = {
			top: top,
			bottom: bottom,
		}
		 
		return position;
	},

    /*Fires an event with the id of event in context*/
    selectEventFire: function(component, id_event) {
        var eventInfo = component.getEvent("eventInContext");
        var evento = {
            id: id_event,
        }
        eventInfo.setParams({
            "evento": evento
        });
        eventInfo.fire();
    },

    /*Adds a new event in client side*/
    addEvent: function(component, event, helper) {
        var id;

        if (this.checkNewEvent(component, event, helper) === true) {
            id = this.updateNewEvent(component, event, helper, "new");
        } else {
            id = this.updateNewEvent(component, event, helper, "update");
        }
        this.selectEventFire(component, this.eventIdInContext);
    },


    /*Updates the event list with the event selected*/
    updateNewEvent: function(component, event, helper, action) {
        var dataTime = event.currentTarget.getAttribute("data-time");
        var targetDate = new Date(component.get("v.date"));

        var listaEventos = [];
        listaEventos = component.get("v.eventList");
        var startDateObject = new Date(targetDate.toDateString() + " " + dataTime);
        var startDateTime = startDateObject.getTime();

        var durationInMinutes = 60;
        var endTimeObject = new Date(startDateObject.getTime() + durationInMinutes * 60000);
        var endDateTime = endTimeObject.getTime();

        var current_date = (new Date()).valueOf().toString();
        var random = Math.random().toString();
        var tempId = this.sdbmCode(random + current_date).toString();

        if (action === "new") {
            listaEventos.push({
                Id: tempId,
                State: "new",
                Draggable: true,
                StartDateTime: startDateTime,
                EndDateTime: endDateTime,
            });
            this.eventIdInContext = tempId;
            //console.log("ListaEventos Alcrearla de nuevo",  listaEventos);

        } else if (action === "update") {
            //console.log("Actualizo evento en vez de crearlo");
            for (var i = 0; i < listaEventos.length; i++) {
                if (listaEventos[i].Id === this.eventIdInContext) {
                    listaEventos[i].State = "new";
                    listaEventos[i].StartDateTime = startDateTime;
                    listaEventos[i].EndDateTime = endDateTime;
                }
            }
        }
        component.set("v.eventList", listaEventos);
    },

    /*Retrieves a integer code for temporal ids in the events*/
    sdbmCode: function(str) {
        var hash = 0;
        for (var i = 0; i < str.length; i++) {
            var char = str.charCodeAt(i);
            hash = char + (hash << 6) + (hash << 16) - hash;
        }
        return Math.abs(hash);
    },

    /*Retrieves the time from the target event position*/
    getTimeFromHeight: function(component, event, helper, pixels) {
        var time;
        var hh = 0;
        var mm = 0;
        var ss = 0;
        var height = this.hourHeight;
        var minutesDay = 24 * 60;
        var timeInMinutes = 0;
        var outputDate = new Date(component.get("v.date"));

        if (pixels >= 0) {
            //console.log("Pixels:", pixels);
            timeInMinutes = (pixels * minutesDay) / (24 * height);
            //console.log("TimeInMinutes:", timeInMinutes);
            hh = Math.floor(timeInMinutes / 60);
            //console.log("Horas", hh);
            mm = Math.floor(((timeInMinutes / 60) - hh) * 60);
            //console.log("minutos", mm);
            if (mm < 60) {
                mm = 0;
            }
            if (hh <= 0) {
                hh = 0;
                mm = 0;
            }
            if (hh >= 24) {
                hh = 23;
                mm = 59;
                ss = 59;
            }

        } else if (pixels < 0) {
            //console.log("Pixels:", pixels);
            timeInMinutes = (pixels * minutesDay) / (24 * height);
            //console.log("TimeInMinutes:", timeInMinutes);
            hh = -1 * Math.ceil(timeInMinutes / 60);
            //console.log("Horas", hh);
            mm = -1 * Math.floor(((timeInMinutes / 60) + hh) * 60);
            //console.log("minutos", mm);
            if (mm < 60) {
                mm = 0;
            }
            if (hh <= 0) {
                hh = 0;
                mm = 0;
            }
            if (hh > 24) {
                hh = 23;
                mm = 59;
                ss = 59;
            }
        }

        outputDate.setHours(hh);
        outputDate.setMinutes(mm);
        outputDate.setSeconds(ss);
        //console.log("FINAL DATE: ",outputDate);
        return outputDate;

    },


    /*Updates the position in time of the target element*/
    updateRenderEvent: function(component, event, helper, startTime, endTime, id_event) {
        var eventList = component.get("v.eventList");
        //console.log("START TIME REFINAL:",startTime);
        //console.log("END TIME REFINAL:",endTime);
        for (var i = 0; i < eventList.length; i++) {
            if (eventList[i].Id === id_event) {
                eventList[i].StartDateTime = startTime.getTime();
                eventList[i].EndDateTime = endTime.getTime();
            }
        }

        component.set("v.eventList", eventList);
    },

    /*Returns the event by Id*/
    getEventById: function(component, id_event) {
        var eventList = component.get("v.eventList");
        for (var i = 0; i < eventList.length; i++) {
            if (eventList[i].Id === id_event) {
                return eventList[i];
            }
        }
        return null;
    },

    /*Optional message window when there is not any events in the target day*/
    showMessage: function(component, event, helper, mode) {
        //console.log("SHOW");
        var div = component.find("message").getElement();

        if (mode) {
            $A.util.addClass(div, 'showMessageBox');
        } else {
            $A.util.removeClass(div, 'showMessageBox');
        }

    },

    /*Checks if the last element of the list is new, even, it lets the creation of a new event*/
    checkNewEvent: function(component, event, helper) {
        var eventList = [];
        var eventListLength;
        eventList = component.get("v.eventList");
        eventListLength = eventList.length;
        if (eventList !== undefined && eventList !== null) {
            if ((eventListLength - 1) >= 0 && eventList[eventListLength - 1] !== undefined) {
                if (eventList[eventListLength - 1].State === "new") {
                    this.eventIdInContext = eventList[eventListLength - 1].Id;
                    //If there is a new event, blocks the creation
                    return false;
                } else {
                    //If there is not any event lets the creation
                    return true;
                }
            } else {
                //If there is not any event lets the creation
                return true;
            }
        } else {
            return false;
        }
    }

})