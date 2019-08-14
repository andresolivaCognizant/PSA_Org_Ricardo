/**
	*   @Class : EventTriggerHandlerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 March 2018
	*   @Description    :   Test for Event Trigger
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class EventTriggerHandlerTest {
    
    @isTest static void EventBeforeDeleteTest(){
        // Test data setup
       	Event e = new Event();
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        
        insert e;
        // Perform test
        Test.startTest();
        	delete e;
        	EventTriggerHandler.dontRunTrigger();
        Test.stopTest();
    }

}