({
  jsGetEvents : function(component) {
    var action = component.get("c.getEvents");
      action.setParams({
        "request": JSON.stringify({
          "record_id" : component.get("v.dealer_id")
        })
      });

      action.setCallback(this, function(response) {
        this.handleEvents(component, response);
      });

    $A.enqueueAction(action);

  },

  handleEvents : function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        debugger;
        var server_payload = this.formatPayload(response.getReturnValue().payload);
        this.buildCalendar(component, server_payload.lst_events);
        this.buildUserList(component, server_payload.users);
        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  },

  buildCalendar : function(component, events) {
    $('#calendar').fullCalendar({
      "header" : {
        "left"    : 'month,agendaWeek,agendaDay,today',
        "center"  : 'title',
        "right"   : 'prev,next'
      },
      "events" : events
    });
  },

  formatPayload : function(server_response) {
    debugger;

    var lst_user = Object.values(server_response.users);

    var colors = [];
    if (lst_user.length <= 65) {
      colors = window.palette('mpn65', lst_user.length);
    } else {
      colors = window.palette('tol-rainbow', lst_user.length);
    }

    lst_user.forEach((element, index) => {
      element.unique_color = '#' + colors[index];
    });

    server_response.lst_events = [];
    server_response.events.forEach(element => {
      server_response.lst_events.push({
        title   : element.Subject,
        start   : element.StartDateTime,
        end     : element.EndDateTime,
        color   : server_response.users[element.OwnerId].unique_color
      });
    });

    return server_response;
  },

  buildUserList : function(component, users) {
    var list_cmp = [];
    Object.values(users).forEach(element => {
      list_cmp.push([
        "c:DealerSalesmenCalendarUser",
        {
          "config_obj" : {
            "Name"         : element.Name,
            "Activity__c"  : element.Activity__c,
            "unique_color" : element.unique_color
          }
        }
      ]);
    });

    if (list_cmp.length == 0) {
      return;
    }

    $A.createComponents(
      list_cmp,
      function(elements, status, errorMessage) {
        var body = [];
        if (status === "SUCCESS") {
          body.push(...elements);
          component.find("dealer_users").set("v.body", body);
        }
      }
    )
  }

})