/**
	*   @Class          : TeleAlertStatusChangeControllerTest
	*   @Author         : Pedro Párraga
	*   @Created        : 1 Juli 2019
	*   @Description    : Test for TeleAlertStatusChangeController
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer                   Date                     Description   
	*      Pedro Párraga                09/04/2019               Creation.   
	*      Pedro Párraga                11/06/2019               Edit.              
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class TeleAlertStatusChangeControllerTest {
	
	@isTest static void getData() {
		TeleAlert__c teleAlert = new TeleAlert__c(Country__c = 'PT', Brand__c = 'AP');
		insert teleAlert;

		JSONGenerator g = JSON.createGenerator(true);
		g.writeStartObject();
		g.writeStringField('record_id', teleAlert.Id);
		g.writeEndObject();


		Test.startTest();
			TeleAlertStatusChangeController.getData(g.getAsString());
		Test.stopTest();
	}

	@isTest static void saveData() {
		TeleAlert__c teleAlert = new TeleAlert__c(Country__c = 'PT', Brand__c = 'AP');
		insert teleAlert;

		List<VehicleEvent__x> lstVehicleEvent = new List<VehicleEvent__x>();
		VehicleEvent__x ve = new VehicleEvent__x();
		VehicleEvent__x ve2 = new VehicleEvent__x();
		lstVehicleEvent.add(ve);
		lstVehicleEvent.add(ve2);
		
		Test.startTest();
			TeleAlertStatusChangeController.saveData(teleAlert.Id, '11', 'Other', null, '4', lstVehicleEvent);
			TeleAlertStatusChangeController.saveData(teleAlert.Id, '9', Label.Appointment_Created, null, '3', lstVehicleEvent);
		Test.stopTest();

		TeleAlert__c teleA = [SELECT Id, APVDealer__c, Status__c FROM TeleAlert__c LIMIT 1];
		System.assertEquals(null, teleA.APVDealer__c);
		System.assertEquals('3', teleA.Status__c);
	}
}