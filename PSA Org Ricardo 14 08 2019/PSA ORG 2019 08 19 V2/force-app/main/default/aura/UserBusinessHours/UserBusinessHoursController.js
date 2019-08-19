({
  doInit : function(component, event, helper) {
    var path = window.location.pathname;
    path = encodeURI(window.location.pathname);
    
    // ver como recuperar el nombre de la comunidad
    
    helper.getBHours(component);
    helper.getMnProfile(component);
  },
  
  handleSaveBHour : function(component, event, helper) {
    helper.updBHours(component);
  },

  handleSaveHoliday : function(component, event, helper) {
    if(helper.inputCheck(component)) {
      helper.updHolidays(component);
    }
  },
  
  changeState : function changeState (component){ 
    component.set('v.isexpanded',!component.get('v.isexpanded'));
  },
  
  changeStateH : function changeStateH (component){ 
    component.set('v.isexpandedH',!component.get('v.isexpandedH'));
  },

  changeStateT : function changeStateH (component){ 
    component.set('v.isexpandedT',!component.get('v.isexpandedT'));
  },

  navigate : function(component, event, helper) { 
    var id = event.target.getAttribute("data-id")
    var navEvt = $A.get("e.force:navigateToSObject");

    navEvt.setParams({
      "recordId": id,
      "slideDevName": "detail"
    });
    navEvt.fire();
  },

})