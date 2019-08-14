/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			CARE
* Description:		Test class for NewCaseOverrideController.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-04-01		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest
public class NewCaseOverrideControllerTest {
	
	@isTest static void test_SuccessScenario(){
		Test.startTest();

		Map<String, Object> mapResponse					= new Map<String, Object>();
		mapResponse										= NewCaseOverrideController.getCurrentUser();

		User objUser									= new User();
		objUser											= ( User ) mapResponse.get( 'UserInfo' );

		System.assertEquals( true, objUser != null );

		Test.stopTest();
	}
}