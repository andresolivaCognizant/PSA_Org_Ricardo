({
	loadpdf : function(component, event, helper) {
		if(window.screen.availHeight>768){
			component.set("v.wHeight","580");
		}else{
			component.set("v.wHeight","480");
		}
		helper.loadpdf(component,event);
	}
})