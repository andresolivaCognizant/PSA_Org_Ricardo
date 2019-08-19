/**
	*   @Class 			: APS009_ScheduleMysteryLeadsDailyTest
	*   @Author         : Ruben Moreno Leyva
	*   @Created        : 22/5/2018
	*   @Description    : Test for APS009_ScheduleMysteryLeadsDaily
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Moreno Leyva		22/5/2018				 Creation.	
	*      Pedro Párraga            18/06/2019   			 Edit
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS009_ScheduleMysteryLeadsDailyTest {
    
    @isTest static void testProcess(){
        
        Test.startTest();
        APS009_ScheduleMysteryLeadsDaily batch = new APS009_ScheduleMysteryLeadsDaily();
        String sSch = '0 0 * * * ? 2019';
        System.schedule('Executing: APS009_ScheduleMysteryLeadsDailyTest - date: '+system.now(), sSch, batch);
        Test.stopTest();
        
    } 

}