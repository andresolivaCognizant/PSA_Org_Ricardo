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
    *   @Class : CL00_RUTValidationTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   21 Feb 2018
    *   @Description    :   Apex Unit test class for CL00_RUTValidationTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             21/2/2018                Creation.  
    *      Pedro Párraga            18/06/2019               Edit. 
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class CL00_RUTValidationTest {

    static testMethod void myUnitTest() {
        
        User u = [Select id,Country__c FROM USER where Profile.name = 'System Administrator' LIMIT 1];
        U.Country__c = 'CL';
        UPDATE U;
        
        Account accB2B = new Account(
                Name                =   'TEST MATCH B2B',
                BillingPostalCode   =   '234563',
                FiscalId__c         =   '30686957-4',
                RecordTypeId        =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId(),
                Country__c      =   'CL'
                
        );
        
        insert accB2B;

        Account accB2C              =   new Account (
            FirstName               =   'Account FirstName',
            LastName                =   'Account LastName',
            Salutation              =   '1',
            PersonalEmail__pc       =   'testaccB2C@test.com',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            Phone                       = '915001000'
        );
        
        insert accB2C;
        
        Account accB2C2= new Account(
                FirstName           =   'TEST 2',
                Salutation          =   '1',
                LastName            =   'TEST MATCH B2C 2',
                LandlinePersonalTelephone__pc               =   '+63323434',
                BillingPostalCode   =   '29956',
                NationalId__pc      =   '30686957-4',
                BillingCountry      =   'Chile',
                NonResidentCustomer__pc = true,
                RecordTypeId        =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
        );
        
        insert accB2C2;
        
        Contact cnt                 =   new Contact (
                Accountid           =   accB2B.id,
                FirstName           =   'Contact_FirstName_Test',
                LastName            =   'Contact_LastName_Test',
                Salutation          =   '1',
                LandlinePersonalTelephone__c               =   '9867767',
                MailingCountry      =   'Chile',
                NationalId__c       =   '27446784-3',
                NonResidentCustomer__c = true
        );
        
        
        insert cnt;        
        
        Lead oLead                          = new Lead(
                FirstName                   = 'First Name ', 
                LocalIdOfCustomer__c        = '12345',
                LastName                    = 'Last',
                Street                      = 'Calle de Sebastián Elcano ',
                City                        = 'Madrid',
                LeadCountry__c              = 'CL', 
                LandlinePersonalTelephone__c                       = '79834',
                NationalId__c               = '30686957-4',
                Company                     = ' TEST COMPANY_',
                BrandOwnedVehicle__c        = 'DS',
                Email                       = 'test@example.com',
                TreatmentDueDate__c         = System.now(),
                LeadRequestType__c          = '1',
                ownerid                     = U.ID,
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C')

        );
        
        Lead oLead1 = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                NationalId__c               = '30686957-4',
                fiscalid__c                 ='30686957-4',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadCountry__c              = 'CL',
                customer__c                 = accB2B.id,
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                customerContact__c          = cnt.id,
                status                      = 'Qualified',
                OwnerId                     = U.ID,
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        List<sObject> lSObjects = new List<sObject>();

        lSObjects.add(oLead);
        lSObjects.add(oLead1);

        insert lSObjects;
        System.debug('***** lSObjects: '+lSObjects);
        
        test.startTest();
        
        Boolean bTrue = CL00_RUTValidation.validateRut('30686957-4');
        Boolean bFalse = CL00_RUTValidation.validateRut('30686957-4');
        CL00_RUTValidation.mainFunction(lSObjects);
        CL00_RUTValidation.validateRut('');

        System.assertEquals(bTrue, true);
                
        test.stopTest();       
    }
    
    @isTest
    public static void TestMainFunctionAccount() {

        Account accB2B = new Account(
                Name				=   'TEST MATCH B2B',
                BillingPostalCode	=   '234563',
                FiscalId__c			=   '30686957-4',
                RecordTypeId		=   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B),
            	Country__c			=   'CL'     	
        );        
        
        List<sObject> lSObjects = new List<sObject>();
        lSObjects.add(accB2B);
        insert lSObjects;
        
        Test.startTest();        
            Boolean bTrue = CL00_RUTValidation.validateRut('30686957-4');
            CL00_RUTValidation.mainFunction(lSObjects);            
            System.assertEquals(bTrue, true);                
        Test.stopTest();       
    }
    
    @isTest
    public static void TestMainFunctionAccount2() {
		User u = [Select id,Country__c FROM USER where Profile.name = 'System Administrator' LIMIT 1];
        u.Country__c = 'CL';
        update u;
        
        Account accB2C = new Account(
            	FirstName			=   'TEST',
            	Salutation			=	'1',
                LastName			=   'TEST MATCH B2C',
                LandlinePersonalTelephone__pc				=   '+351916837824',
                BillingPostalCode	=   '29956',
                NationalId__pc		=   '30686957-4',
            	BillingCountry		=   'Chile',
            	NonResidentCustomer__pc = false,
                RecordTypeId		=   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        );

        List<sObject> lSAccountObjects = new List<sObject>();
        lSAccountObjects.add(accB2C);
        insert lSAccountObjects;
        
        Test.startTest();        
            Boolean bFalse = CL00_RUTValidation.validateRut('30686957-5');
            CL00_RUTValidation.mainFunction(lSAccountObjects);            
            System.assertEquals(bFalse, false);                
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestMainFunctionContact() {

        Account accB2B = new Account(
                Name				= 'TEST MATCH B2B',
                BillingPostalCode	= '234563',
                FiscalId__c			= '30686957-4',
                RecordTypeId		= PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B),
            	Country__c			= 'CL'
            	
        );       
        insert accB2B;
        
        Contact c = new Contact (
            	Accountid			=	accB2B.id,
                FirstName           =   'Contact_FirstName_Test',
                LastName            =   'Contact_LastName_Test',
                Salutation          =   '1',
                LandlinePersonalTelephone__c               =   '9867767',
                MailingCountry		=   'Chile',
            	NationalId__c		=	'27446784-3',
            	NonResidentCustomer__c = true
        );       
        
        List<sObject> lSContactObjects = new List<sObject>();
        lSContactObjects.add(c);
        insert lSContactObjects;
        
        System.debug('lsObjects: ' + lSContactObjects);
        
        Test.startTest();                   
            CL00_RUTValidation.duplicateRut(lSContactObjects);            
        Test.stopTest();       
    }
}