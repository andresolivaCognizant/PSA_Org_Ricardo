/**
	*   @Class : APS003_ManagersPublicGroupTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 March 2018
	*   @Description    :   Test for APS003_ManagersPublicGroup
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS003_ManagersPublicGroupTest {
    
    @isTest static void PublicGroupTest() {
        
        // Perform test
        Test.startTest();
        APS003_ManagersPublicGroup p = new APS003_ManagersPublicGroup();
		String sch = '0 0 * * * ?';
		system.schedule('Manager public group Batch', sch, p);	
        Test.stopTest();
        
    } 

}