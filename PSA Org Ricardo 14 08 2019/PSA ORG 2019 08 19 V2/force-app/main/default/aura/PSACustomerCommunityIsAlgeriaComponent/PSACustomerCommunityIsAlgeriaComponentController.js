({
	doInit : function(component, event, helper) {
        var isAlgeriaEvent = $A.get("e.c:PSACustomerCommunityIsAlgeria");
        isAlgeriaEvent.setParams({ "country" : "DZ" });
		isAlgeriaEvent.fire();
        console.log("Lanzado");
	}
})