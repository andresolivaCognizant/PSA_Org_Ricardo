({
	rerender : function(component, helper){
        this.superRerender();
		var delimiter 		= component.get("v.delimiter");		
		var currentInput 	= component.get("v.searchField");
			
        helper.addNewPills(component, currentInput.split(delimiter));
    },
})