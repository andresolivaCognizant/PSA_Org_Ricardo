/**
	*   @Class : LeadMetricsHeaderControllerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   12 April 2018
	*   @Description    :   Test for LeadMetricsHeaderController
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				12/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class LeadMetricsHeaderControllerTest {
    
    @isTest static void LeadMetricsHeaderControllerTest(){
        // Test data setup
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');
        lstLeads.addall(TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0001',null, 'AP','ES','VO', '22334455'));
        lstLeads.addall(TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0001',null, 'AP','ES','APV', '22334455'));
        insert lstLeads;
        // Perform test
        Test.startTest();
        	String role1 = LeadMetricsHeaderController.getUserPortalRole();
        	LeadMetricsHeaderController.getLeadTotals(false,'New', '');
        	LeadMetricsHeaderController.getLeadTotals(false, 'New', 'where City=\'Madrid\'');
        	LeadMetricsHeaderController.getLeadMetrics(false, 'New', '');
        	LeadMetricsHeaderController.getLeadMetrics(false, 'New', 'where City=\'Madrid\'');
        	LeadMetricsHeaderController.getLeadTotals(True,'New', '');
        	LeadMetricsHeaderController.getLeadTotals(True, 'New', 'where City=\'Madrid\'');
        	LeadMetricsHeaderController.getLeadMetrics(True, 'New', '');
        	LeadMetricsHeaderController.getLeadMetrics(True, 'New', 'where City=\'Madrid\'');
        Test.stopTest();
        
        System.assertEquals('Worker', role1);
    }

}