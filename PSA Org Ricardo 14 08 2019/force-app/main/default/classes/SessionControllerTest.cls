/**
    *   @Class          : SessionControllerTest
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for SessionController
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class SessionControllerTest {
	
	@isTest static void SessionController() {
		Test.startTest();
			String sessionId = SessionController.getSessionId();
		Test.stopTest();

		System.assertEquals(sessionId, UserInfo.getSessionId());
	}

}