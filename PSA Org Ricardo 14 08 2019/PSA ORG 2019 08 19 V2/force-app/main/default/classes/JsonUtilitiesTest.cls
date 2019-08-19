/**
	*   @Class 			: BusinessHoursHandlerTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for BusinessHoursHandler
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			11/06/2019				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class JsonUtilitiesTest {
	
	@isTest static void getValuesFromJson() {
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
        g.writeStringField('record_id', '5000Q000003I9XAQA0');
        g.writeEndObject();

		Test.startTest();
			JsonUtilities.getValuesFromJson(g.getAsString());
		Test.stopTest();
	}

	@isTest static void JsonUtilExceptionOne() {
		JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
        g.writeEndObject();

		Test.startTest();
			try{
				JsonUtilities.getValuesFromJson(g.getAsString());
			}catch(Exception e){

			}
		Test.stopTest();
	}
	
	@isTest static void JsonUtilExceptionTwo() {
		try{
			JsonUtilities.getValuesFromJson(null);
		}catch(Exception e){

		}
	}
}