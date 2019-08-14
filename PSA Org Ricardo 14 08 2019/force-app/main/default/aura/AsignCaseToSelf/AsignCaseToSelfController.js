({
  doInit : function(component, event, helper) {
    var caseId = component.get("v.recordId");
    helper.assignCase(component,event,caseId);
  },

  doReload : function(component,event,helper){
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
      var newCaseTab = response.tabId;
      workspaceAPI.refreshTab({tabid: newCaseTab.tabid})
      component.set("v.asigned", false);
    });
  }
})