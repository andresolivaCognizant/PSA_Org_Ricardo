@isTest
private class PushLeadToDealerTest {
	
	@isTest static void test_method_one() {

        Lead oLead  = new Lead(
                FirstName                   = 'First Name ', 
            	LocalIdOfCustomer__c		= '12345',
                LastName                    = 'Last',
                Street                      = 'Calle de Sebastián Elcano ',
                City                        = 'Madrid',
                Country                     = 'España', 
                Phone                       = '79834',
                NationalId__c               = '1234',
                Company                     = ' TEST COMPANY_',
                BrandOwnedVehicle__c        = 'DS',
                Email                       = 'test@example.com',
            	TreatmentDueDate__c			= System.now(),
            	LeadRequestType__c			= '1',
            	OwnerId						= UserInfo.getUserId()

        );
        
        insert oLead;

		JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
	        g.writeFieldName('lst_ids');
	            g.writeStartArray();
	                for (Lead lea : [
	                    SELECT Id
	                    FROM Lead
	                ]) {
	                    g.writeString(lea.Id);
	                }
	            g.writeEndArray();
        g.writeEndObject(); 


		JSONGenerator g2 = JSON.createGenerator(true);

        g2.writeStartObject();
	        g2.writeFieldName('lst_leads');
	            g2.writeStartArray();
	                for (Lead lea : [
	                    SELECT Id
	                    FROM Lead
	                ]) {
	                    g.writeString(lea.Id);
	                }
	            g2.writeEndArray();
        g2.writeEndObject(); 

		PushLeadToDealer.allocateLeads(g.getAsString());
		PushLeadToDealer.updateLeads(g2.getAsString());

		PushLeadToDealer.allocateLeads(g2.getAsString());
		PushLeadToDealer.updateLeads(g.getAsString());

		System.assertNotEquals(null, oLead.OwnerId);
	}
}