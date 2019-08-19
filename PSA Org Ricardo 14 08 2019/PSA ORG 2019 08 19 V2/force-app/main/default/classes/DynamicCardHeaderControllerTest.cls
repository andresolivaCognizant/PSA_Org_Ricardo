/**
	*   @Class : DynamicCardHeaderControllerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   11 April 2018
	*   @Description    :   Test for DynamicCardHeaderController
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				11/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class DynamicCardHeaderControllerTest {
    
    @isTest static void DynamicCardHeaderControllerTest(){
        // Test data setup
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        // Perform test
        Test.startTest();
        	String sObj                 =   'Account';
            CSResultWrapper rwRecords   =   new CSResultWrapper();
        	rwRecords 		= DynamicCardHeaderController.getObjectRecords('where isPersonAccount=False', sObj,'Name');
            List<String> lstLabels      =   DynamicCardHeaderController.getLabels(sObj,null,new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        	List<String> lstLabels2      =   DynamicCardHeaderController.getLabels(sObj,'Account',new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        Test.stopTest();
        
        System.assertEquals(4, lstLabels.size());
        System.assertEquals(4, lstLabels2.size());
    }

}