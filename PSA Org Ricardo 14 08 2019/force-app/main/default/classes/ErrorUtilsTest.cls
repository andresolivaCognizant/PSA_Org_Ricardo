/**
    *   @Class          :   ErrorUtilsTest   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  test class to cover class ErrorUtilsTest
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer             Date                     Description    
    *      Pedro Párraga         05/06/2019               Creation      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class ErrorUtilsTest {
    
    @isTest static void HandleAuraExceptionTest() {
		
        Test.startTest();
        	try {
  				insert new Account();
			}catch (System.DmlException e) {
                ErrorUtils oData = new ErrorUtils(e.getTypeName(), e.getMessage(), 
                                                  e.getDmlType(0).ordinal(), 
                                                  e.getStackTraceString(), 
                                                  e.getDmlType(0).name(), 
                                                  String.valueOf(e.getCause()));
      			System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING.ordinal(),oData.iCode);
                System.assertEquals('System.DmlException',oData.sName);
			}
		Test.stopTest();
	}
}