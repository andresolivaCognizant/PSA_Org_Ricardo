/**
	*   @Class 			: 	OppQuoteLiveProcessQForms 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   27 Apr 2018
	*   @Description    :   Change Opportunity Status from Contact to Quote when all Orders have Expired or Denied Status
	*						and quote record type is CPQ/OPV Order Form
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				27/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global with sharing class OppQuoteLiveProcessQForms {
	
	@InvocableMethod(
        label       = 'Opportunities without Live Order Forms Process'
        description = 'Check Opps without Live Order Forms and change Status from Quote to Contract'
    )

    global static void handleProcess(List<Opportunity> oppList) { 
    	
    	// Call process for change stage in opps when Quote Record type is CPQ/OPV Order Forms	
    	OppQuoteLiveProcess.handleProcess(oppList, 'OForm');
    	
    }

}