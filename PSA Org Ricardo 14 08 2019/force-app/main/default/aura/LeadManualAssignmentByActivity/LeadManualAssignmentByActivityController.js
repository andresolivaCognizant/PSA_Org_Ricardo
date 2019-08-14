({
  /* BEGIN - Manuel Medina - C1STAGILE-4826 New logic with ghtning:tabset to allow responsivity on small devices - 26092018 */
  changeTab : function(component, event, helper) {
    var tab = event._params.id;
    component.set( "v.defaultTab", tab );
  },
  /* END - Manuel Medina - 26092018 */
  doInit : function(component, event, helper) {
    helper.jsGetUserData(component);
  }
})