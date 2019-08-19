({
	doInit : function(component, event, helper) {
		var chatId = component.get("v.recordId");
		console.log(chatId);
		helper.prepareCase(component,event,chatId);
	}
})