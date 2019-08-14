/**
    *   @Class          : CreatePermissionCheckControllerTest
    *   @Author         : Pedro Párraga
    *   @Created        : 07 June 2019
    *   @Description    : Test for CreatePermissionCheckControllerTest
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            07/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class CreatePermissionCheckControllerTest {

	@testSetup  static void setup() {
        List<Profile> lst_p = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ]);

        User u = new User(
                LastName            = 'Test',
                Email               = 'lead.utils@testclass.com',
                Alias               = 'test',
                TimeZoneSidKey      = 'GMT',
                LocaleSidKey        = 'en_GB',
                EmailEncodingKey    = 'ISO-8859-1',
                ProfileId           = lst_p.get(0).Id,
                LanguageLocaleKey   = 'en_US',
                UserName            = 'lead.utils@testclass.com',
                Country__c          = 'PL',
                Brand__c            = 'AC',
                VNRRDICode__c       = '12345'
            );

        insert u;
	}	
	
	@isTest static void isRecInsertable() {
		User us =[SELECT Id FROM User LIMIT 1];
		Test.startTest();
			System.runAs(us){
				System.assertEquals(true, CreatePermissionCheckController.isRecInsertable());
			}
		Test.stopTest();
	}	
}