({
	doInit : function(component, event, helper) {
		//a.       Si la URL del documento del PDF va contra el APIC: Salesforce sobreescribe la URL (la solución propuesta con Alvaro): 
		// https://preprod.api.inetpsa.com/applications/opv/v1/filemanagement/6?client_id=a7cba853-7ef0-49de-8b6c-4148ad95b61b&hash=zxasqwwP 
		//b.      OPV devuelve la URL directa al documento PDF sin pasar por el APIC (fácil para todo el mundo, pero no la acordada en el CCT): 
		// https://opv2-preprod.mpsa.com/acpl/api/v1/filemanagement/6?hash=zxasqwwP 
		// var sURL = component.get("v.attributesByGlobalSetting.QuoteToPDF.QuoteToPDF_URL");
		
		// if(!$A.util.isUndefinedOrNull(sURL) && !$A.util.isEmpty(sURL)){
		helper.getPDFFile(component,event);	
	 //      }else{
	 //      	var childCmp = component.find("GlobalSettings");
			// childCmp.getRecords();
			// helper.getPDFFile(component,event);	
	 //      }

	},
	downloadPDF : function(component,event,helper){
		var pdfContainer = component.get("v.pdfData");
		if ($A.util.isUndefinedOrNull(pdfContainer)){return;} 
			
		var hiddenElement = document.createElement('a');
		hiddenElement.href = 'data:text/plain;base64,' + encodeURI(pdfContainer);
		hiddenElement.target = '_self'; // 
		hiddenElement.download = 'Quote.pdf'; 
		document.body.appendChild(hiddenElement);
		hiddenElement.click(); 
	},

	cancelBtn : function(component, event, helper) { 
		// Close the action panel 
		var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire(); 
	},

	/* BEGIN - Manuel Medina - C1STAGILE-5479 - Redirects to SendEmail quick action - 25042019 */
	sendEmail : function( component, event, helper) {
		$A.get( "e.force:closeQuickAction" ).fire();

		var appEvent						= $A.get( "e.c:SendEmailEvent" );

		appEvent.setParams( {
			"event" : "OPEN"
		} );
		
		appEvent.fire();
	}
	/* BEGIN - Manuel Medina - 25042019 */
})