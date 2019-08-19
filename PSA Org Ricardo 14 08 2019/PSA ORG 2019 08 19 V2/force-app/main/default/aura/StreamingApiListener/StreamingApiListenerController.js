({
  doInit: function(component, event, helper) {
    var action = component.get("c.getSessionId");
    action.setCallback(this, function(response) {

      // Configure CometD for this component
      //var sessionId = response.getReturnValue();
      var sessionId = '00D5E0000000dHJ!AQ8AQCNAfpmSKcoRPjcr52ePPGbiEhUwjLFDLoTU7JWsKkKroaVtJnIrd6XGJyddwKVtp6nx7BSHVRNciQCBKGEvAhM.Qx9s';
      var cometd = new window.org.cometd.CometD();
      cometd.configure({
        url: window.location.protocol + '//' + window.location.hostname + '/cometd/43.0/',
        requestHeaders: { Authorization: 'OAuth ' + sessionId},
        appendMessageTypeToURL : false
      });
      cometd.websocketEnabled = false;
      component.set('v.cometd', cometd);

      // Connect to
      cometd.handshake($A.getCallback(function(status) {
          debugger;
        if (status.successful) {
          var eventName = component.get("v.channel");
          var subscription = 
            cometd.subscribe(eventName, $A.getCallback(function(message) {
              debugger;
                var messageEvent = component.getEvent("onMessage");
              
              if(messageEvent!=null) {
                messageEvent.setParam("payload", message.data);
                messageEvent.fire();
              }
            }
          ));
          component.set('v.subscription', subscription);
        } else {
          // TODO: Throw an event / set error property here?
          console.error('streaming component: ' + status);
        }
      }));

    });
    $A.enqueueAction(action);
  },
  handleDestroy : function (component, event, helper) {
    // Ensure this component unsubscribes and disconnects from the server
    var cometd = component.get("v.cometd");
    var subscription = component.get("v.subscription");
    cometd.unsubscribe(subscription, {}, function(unsubscribeReply) {
      if(unsubscribeReply.successful) {
        cometd.disconnect(function(disconnectReply) 
          { 
            console.log('streaming component: Success unsubscribe')
            if(disconnectReply.successful) {
              console.log('streaming component: Success disconnect')
            } else {
              console.error('streaming component: Failed disconnect')
            }
          });
      } else {
        console.error('streaming component: Failed unsubscribe')
      }
    });
  }
})