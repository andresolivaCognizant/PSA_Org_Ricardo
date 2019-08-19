/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

/**
	*   @Class : NotificationManagerInvocableTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Feb 2018
	*   @Description    :   Apex Unit test class for NotificationManagerInvocableTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				19 Feb 2018				 Creation.	
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class NotificationManagerInvocableTest {


   	public static testMethod void doTest() {
        
        
        
        
        Lead oLead = new Lead(
                FirstName                   = 'First Name 003',
            	Salutation					=  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude					=  39.9691,
                Longitude					= -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadRequestType__c 			= '1',
        		IdReservationVD__c 			= '12345323X',
            	status 						= 'Qualified',
            	OwnerId						= UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'));

        insert oLead;
		
        NotificationManagerInvocable.PostRequest requests = new NotificationManagerInvocable.PostRequest();
        requests.notificationName 	= 'ChangeStatus';
        requests.ownerCountry		='CL';
        requests.ownerEmail			='EXAMPLE@EXAMPLE.COM';
        requests.ownerId 			= UserInfo.getUserId();
        requests.sObjId 			= oLead.ID;
        
        User oUser = [select id,country__c from user where id = :UserInfo.getUserId()];
        ouser.Country__c = 'CL';
        update ouser;

        Test.startTest();    
        NotificationManagerInvocable.checkNotificacionManager(new List<NotificationManagerInvocable.PostRequest>{requests});
        NotificationManagerInvocable.sendNotification(new map<id,List<String>>{oLead.ID => new List<String>{olead.OwnerId,'EXAMPLE@EXAMPLE.COM'}}, 'ChangeStatus');
        Test.stopTest();
    }
    
    
}