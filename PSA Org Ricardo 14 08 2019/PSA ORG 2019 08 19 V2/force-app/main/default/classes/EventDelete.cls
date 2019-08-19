/**
	*   @Class 			: 	EventDelete 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   20 Sep 2018
	*   @Description    :   Invocable Class for Delete Events related to Canceled Service Appointments
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				20/09/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global with sharing class EventDelete {
	
	global class WrapperEvent {
       
        @InvocableVariable
   		global Id sAppId;
        
    }
	
	@InvocableMethod(label='Delete Event')
	public static void deleteEvent(List<WrapperEvent> lWrEvent){
		
		System.debug('@@@ EventDelete lWrEvent: ' + lWrEvent);
		
		try {
			
			if(lWrEvent!=null && !lWrEvent.isEmpty() && lWrEvent[0].sAppId!=null){
				List<Event> events=[SELECT id FROM Event WHERE WhatId = :lWrEvent[0].sAppId];
				
				if (events.size() > 0 ) { 
					System.debug('@@@ EventDelete events: ' + events);
					
					delete events; 
				} 
			}
			
		}catch(exception e){
			System.debug('EventDelete.deleteEvent ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
		}
		
	}
    
}