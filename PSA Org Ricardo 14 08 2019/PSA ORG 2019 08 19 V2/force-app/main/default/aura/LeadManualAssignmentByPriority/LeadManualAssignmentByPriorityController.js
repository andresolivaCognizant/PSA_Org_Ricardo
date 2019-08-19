({
  handleTabEvent: function(component, event, helper) {
    component.set("v.filterByCurrentUser", true);
  },

  changeTab : function( component, event, helper ) {
    var tab = event._params.id;
    component.set( "v.defaultTab", tab);
  },

  doInit : function(component, event, helper) {
    helper.jsGetUserData(component);
  }

})