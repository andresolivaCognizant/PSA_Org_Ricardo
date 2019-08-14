({
	openModal: function (component, event, helper) {
		var modalBody;
		var modalFooter;
		$A.createComponents([
			["c:DealerCreateCaseForm", {}],
			["c:DealerCreateCaseFormFooter", {}]
			],
			function (content, status) {
				if (status === "SUCCESS") {
					modalBody = content[0];			//Component Body: Case Form
					modalFooter = content[1];		//Component Footer: Buttons Cancel & Save
					component.find('overlayLib').showCustomModal({
						header: $A.get("$Label.c.CreateCase_NewCase"),
						body: modalBody,
						showCloseButton: true,
						cssClass: "mymodal",
						footer: modalFooter,
						closeCallback: function () {}
					})
				}
			}
		);
	},
})