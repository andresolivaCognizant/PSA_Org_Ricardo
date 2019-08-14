({
	afterRender : function(component, helper){
    	this.superAfterRender();
        helper.setComponentLabels(component);
        console.log('Rerender');
	},
})