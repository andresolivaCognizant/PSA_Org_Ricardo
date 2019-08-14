/**
	*   @Class 			: APS006_LeadDiscardTest
	*   @Author         : Ruben Fernandez Lopez
	*   @Created        : 27 March 2018
	*   @Description    : Test for APS006_LeadDiscard
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Fernandez			27/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS006_LeadDiscardTest {
    
    @isTest static void LeadDiscardBatchTest(){
        
        // Perform test
        Test.startTest();
	        APS006_LeadDiscard pLD = new APS006_LeadDiscard();
			String sSchedule = '0 0 * * * ?';
			System.schedule('Lead Discard Batch: APS006_LeadDiscard', sSchedule, pLD);	
        Test.stopTest();
        
    } 

}