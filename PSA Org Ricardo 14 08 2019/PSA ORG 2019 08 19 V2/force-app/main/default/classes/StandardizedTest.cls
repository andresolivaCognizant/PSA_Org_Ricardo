/**
	*   @Class : StandardizedTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   06 March 2018
	*   @Description    :   Test for Standardized
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				06/3/2018				 Creation.	
    *      Pedro Párraga            18/06/2019               Edit.	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class StandardizedTest {
    
    @isTest static void RecordsStandardizedTest() {
        // Test data setup
        List<Contact> lstConts = TestDataFactoryUtil.createPartnerUser(3,3, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'Dealer');  
        
        String sKeyword         = '000000000';
        Id rt                   = PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA);
        Account acct = new Account(
            	Salutation			=	'1',
                FirstName           =   'Prueba',
            	LastName            =   'Tést',
                BillingStreet       =   'Eduardo Barreiro Nº' +sKeyword.right(4),
                BillingCity         =   'Madrid',
                BillingCountry      =   'España', 
                BillingPostalCode   =   sKeyword.right(5),
                Phone               =   sKeyword.right(9),
            	LandlineProfessionalTelephone__pc =   sKeyword.right(9),
                RecordTypeId        =   rt);
        
        insert acct;
        
        acct.FirstName 				= 'TéstPrueba';
        lstAccts.get(0).Name 		= 'Prúébá';
        lstConts.get(0).FirstName 	= 'Prûébá';
        lstAccts.add(acct);

        Test.startTest();
        	System.assertEquals(1, [SELECT Id FROM Account WHERE StandardizedFirstName__pc != null AND StandardizedLastName__pc != null].size());
        	System.assertEquals(4, [SELECT Id FROM Account WHERE StandardizedCompanyName__c != null ].size());
        	System.assertEquals(10, [SELECT Id FROM Contact WHERE StandardizedFirstName__c != null AND StandardizedLastName__c != null ].size());
        	update lstAccts;
        	Update lstConts;
        	System.assertEquals(1, [SELECT Id FROM Account WHERE StandardizedFirstName__pc != null AND StandardizedLastName__pc != null].size());
        	System.assertEquals(4, [SELECT Id FROM Account WHERE StandardizedCompanyName__c != null ].size());
        	System.assertEquals(10, [SELECT Id FROM Contact WHERE StandardizedFirstName__c != null AND StandardizedLastName__c != null ].size());
        Test.stopTest();
    }
}