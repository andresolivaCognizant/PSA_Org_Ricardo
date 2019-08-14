({
	createModal : function(component, response) {
		var state = response.getState();
		switch (state) {
			case "SUCCESS":
						if (!response.getReturnValue().hasConsent) {
					var e = $A.get("e.force:navigateToURL");
						
						/* BEGIN - Manuel Medina - C1STAGILE-7110 - New logic to improve the URL attributes - 14022019 */
						e.setParams({
							//"url": "/consent?"+ component.get("v.accountId")
							"url": "/consent?objId=" + component.get("v.accountId")
						});
						/* END - Manuel Medina - 14022019 */
			
								e.fire();                
						}
				
			 
				 
				$A.createComponents(
					this.getModalMarkup(response.getReturnValue()),
					function(elements, status, errorMessage) {
						var body = [];
			
						if (status === "SUCCESS") {
							var modal = elements[0];
							modal.set("v.body", elements[1]);
							body.push(modal);
							component.find("dynamic_container").set("v.body", body);
							component.find("dyn_modal").openModal();

						}
					}
				);
				break;
			case "INCOMPLETE":
				// do something
				break;
			case "ERROR":
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					} 
				} else {
					console.log("Unknown error");
				}
		}
	},

	getModalMarkup : function(response_obj) {
		var component_list = []

		// show marketing cloud landing page when consents are found
		if (response_obj.hasConsent) {
			component_list.push([
				"c:Modal",
				{
					"title"         : $A.get("$Label.c.AfterSalesHeaderConsentPreference"),
					"aura:id"       : "dyn_modal",
					"isDirectional" : true,
					"hasCloseIcon"  : true,
					"isLarge"       : false
				}
			]);

			component_list.push([
				"aura:html",
				{
					"tag"             : "iframe",
					"HTMLAttributes"  :
						{
							"id"      : "_mktLandingPage",
							"title"   : "Marketing Cloud Landing Page",
							"width"   : "100%",
							"height"  : "100%",
							"src"     : this.formatUrl(response_obj)
						}
				}
			]);

			return component_list;
		}

			


		return component_list;

	},

	// method to extract url from html markup
	formatUrl : function(response_obj) {
		var div = document.createElement('div');
		div.innerHTML = response_obj.updateUrl;
		return div.firstChild.getAttribute("href");
	}

})