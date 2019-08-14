/**
	*   @Class : AssetUtilsTest.cls
	*
	*   @Author         :   Antoine Audollent
	*   @Created        :   14 may 2019
	*   @Description    :   Apex Unit test class for CRUDException
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Antoine Audollent		14 may 2019				 Creation.	
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class CRUDExceptionTest {
    @isTest static void CRUDException_test(){
        new CRUDException();
    }
}