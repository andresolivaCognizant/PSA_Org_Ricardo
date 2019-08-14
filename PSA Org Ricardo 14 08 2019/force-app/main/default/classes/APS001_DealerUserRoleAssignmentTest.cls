/**
	*   @Class : APS001_DealerUserRoleAssignmentTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 March 2018
	*   @Description    :   Test for APS001_DealerUserRoleAssignment
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS001_DealerUserRoleAssignmentTest {
    
    @isTest static void LeadAssignmentTest() {
        
        // Perform test
        Test.startTest();
        APS001_DealerUserRoleAssignment p = new APS001_DealerUserRoleAssignment();
		String sch = '0 0 * * * ?';
		system.schedule('Dealer User Role Assignment', sch, p);	
        Test.stopTest();
        
    } 

}