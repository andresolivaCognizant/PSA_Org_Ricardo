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
	*   @Class : LeadConversionProcessTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Feb 2018
	*   @Description    :   Apex Unit test class for LeadConversionProcessTest.cls

	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				19 Feb 2018				 Creation.
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
private class LeadConversionProcessTest {

    @testSetup
    static void makeData(){
        List<Account> lst_acc = new List<Account>();
        Account accB2B = new Account(
                Name                                          =   'TEST MATCH B2B',
                Phone                                         =   '+843434',
                BillingPostalCode                             =   '234563',
                OwnerId                                       = UserInfo.getUserId(),            
            	Country__c									  =	'FR',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        lst_acc.add(accB2B);



        Account accPerson = new Account(
                Name                                          =   'TEST MATCH B2B',
                Phone                                         =   '+843434',
                BillingPostalCode                             =   '234563',
                OwnerId                                       = UserInfo.getUserId(),
            	Country__c									  =	'FR',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        lst_acc.add(accPerson);
        insert lst_acc;

        //insert accB2B;

        Contact cnt             =   new Contact (
                FirstName           =   'Contact_FirstName_Test',
                LastName            =   'Contact_LastName_Test',
                Salutation          =   '1',
                Phone               =   '9867767',
                AccountId           =   accB2B.Id,
                OwnerId             = UserInfo.getUserId(),
                Email               = 'contact1@gmail.com',
            	TECH_ContactCountry__c 			= 'FR'
        );

        insert cnt;

        List<Lead> lst_lead = new List<Lead>();
        Lead lea = new Lead(
                FirstName                   = 'First Name 044',
                Salutation                  =  '1',
                LastName                    = 'LastName 044',
                Street                      = 'Calle Test 472',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                DestinationPOSCode__c       = '1237771',
                PSABrand__c                 = 'AP',
                Email                       = 'test4@leadexample.com',
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
	            LeadCountry__c 				= 'FR',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'));

        lst_lead.add(lea);


        Lead leadTwo = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                Customer__c                 = accB2B.id,
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                CustomerContact__c          = cnt.id,
                Status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));

        lst_lead.add(leadTwo);


        Lead leadThree = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                Customer__c                 = accB2B.id,
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                Status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));

        lst_lead.add(leadThree);

        Lead leadFour = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                Status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'),
                CustomerContact__c          = cnt.Id);

        lst_lead.add(leadFour);

        Lead leadFive = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                Status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'),
                CustomerContact__c          = cnt.Id);

        lst_lead.add(leadFive);

        Lead leadSix = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadRequestType__c          = '1',
                Status                      = 'Nurturing',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'),
                CustomerContact__c          = cnt.Id,
                Customer__c                 = accB2B.id);

        lst_lead.add(leadSix);

        insert lst_lead;
    }

    
    @isTest
    static void sendEmailLeadConversion_test_01(){
        Lead lead = [Select id from Lead where firstName = 'First Name 044' Limit 1];
        
        Test.startTest();
        LeadConversionProcess.sendEmailLeadConversion('test@test.com','Lead Conversion Error', 'ERROR', lead.id);
        Test.stopTest();
    }
    
    @istest static void ConvertLead_test_01(){
        List<Lead> leads = [Select id, FirstName ,Salutation ,LastName , Street , City , PostalCode ,Latitude ,Longitude, Phone ,DestinationPOSCode__c ,Company ,PSABrand__c ,Email ,LeadRequestType__c, Status ,OwnerId ,RecordTypeId ,CustomerContact__c ,Customer__c, Address2__c, Industry, CompanyActivityType__c,
                            country,DescriptionofVehicleVPParcSize__c,DescriptionofVehicleVUParcSize__c,FiscalId__c ,FleetSize__c ,LocalIdOfCustomer__c ,MainBrandofVehicleVPParc__c ,MainBrandofVehicleVUParc__c ,
            MainModelofVehicleVPParc__c ,MainModelofVehicleVUParc__c ,NumberOfEmployees, RenewalDateVehicleVPParc__c ,RenewalDateVehicleVUParc__c ,State, Birthdate__c, LandlinePersonalTelephone__c, LandlineProfessionalTelephone__c, MobileProfessionalTelephone__c , MobilePersonalTelephone__c, NationalId__c,Title,
                            AgentCallCenterComments__c,AmountFinanced__c,AppointmentDate__c,CampaignContent__c,CampaignIDUSER__c,CampaignMedium__c,CampaignName__c,CampaignSource__c,CampaignTerm__c,CustomerComments__c,DaysBeforeCheckOut__c,DesiredRecallDateFromCustomer__c,DestinationGeographicalCode__c,
            EndContractDate__c,EvaluationPriceForVO__c,FinalPrice__c,FinanceContractNumber__c,FinanceDescription__c,FinanceOfferInterest__c,FinancingDuration__c,ProductCustomerInterest__c ,Activity__c,FirstAppointmentDateDesired__c,FirstDesiredSchedule__c,FiscalPower__c,FlagPSAProduct__c,IdCookies__c,
            IdReservationVD__c,InitialPurchaseDate__c,LCDVInterest__c,LCDVOwnedProduct__c,LeadCountry__c,LeadLabel__c,LeadRequestDate__c,LeadSource,Link__c,LinkDescription__c,MarketingCode__c,MonthlyPayments__c,NumberFleetVehiclesFinanceContract__c,OnTheRoadFirstDate__c,
            PreferredContactMethod__c,ProductOwned__c,PurchaseIntentionPeriod__c,RemainingAmount__c,SecondAppointmentDateDesired__c,SecondDesiredSchedule__c,ServiceOfferInterestFlag__c,Vehiclestatus__c,VehicleFinishingDescription__c,VehicleOfferInterestFlag__c,
            VehiclePerformances__c,VehicleRegistrationNumber__c,VehicleType__c,VINOwnedVehicle__c,TECH_Web2Lead__c,
                            Language__c from Lead];
        
        
        Test.startTest();
        LeadConversionProcess.ConvertLead(leads);
        Test.stopTest();
    }
 
    @isTest static void ConvertLeadStatus_test_01(){
        List<Lead> leads = [Select id, FirstName ,Salutation ,LastName , Street , City , PostalCode ,Latitude ,Longitude, Phone ,DestinationPOSCode__c ,Company ,PSABrand__c ,Email ,LeadRequestType__c, Status ,OwnerId ,RecordTypeId ,CustomerContact__c ,Customer__c, Address2__c, Industry, CompanyActivityType__c,
                            country,DescriptionofVehicleVPParcSize__c,DescriptionofVehicleVUParcSize__c,FiscalId__c ,FleetSize__c ,LocalIdOfCustomer__c ,MainBrandofVehicleVPParc__c ,MainBrandofVehicleVUParc__c ,
            MainModelofVehicleVPParc__c ,MainModelofVehicleVUParc__c ,NumberOfEmployees, RenewalDateVehicleVPParc__c ,RenewalDateVehicleVUParc__c ,State, Birthdate__c, LandlinePersonalTelephone__c, LandlineProfessionalTelephone__c, MobileProfessionalTelephone__c , MobilePersonalTelephone__c, NationalId__c,Title,
                            AgentCallCenterComments__c,AmountFinanced__c,AppointmentDate__c,CampaignContent__c,CampaignIDUSER__c,CampaignMedium__c,CampaignName__c,CampaignSource__c,CampaignTerm__c,CustomerComments__c,DaysBeforeCheckOut__c,DesiredRecallDateFromCustomer__c,DestinationGeographicalCode__c,
            EndContractDate__c,EvaluationPriceForVO__c,FinalPrice__c,FinanceContractNumber__c,FinanceDescription__c,FinanceOfferInterest__c,FinancingDuration__c,ProductCustomerInterest__c ,Activity__c,FirstAppointmentDateDesired__c,FirstDesiredSchedule__c,FiscalPower__c,FlagPSAProduct__c,IdCookies__c,
            IdReservationVD__c,InitialPurchaseDate__c,LCDVInterest__c,LCDVOwnedProduct__c,LeadCountry__c,LeadLabel__c,LeadRequestDate__c,LeadSource,Link__c,LinkDescription__c,MarketingCode__c,MonthlyPayments__c,NumberFleetVehiclesFinanceContract__c,OnTheRoadFirstDate__c,
            PreferredContactMethod__c,ProductOwned__c,PurchaseIntentionPeriod__c,RemainingAmount__c,SecondAppointmentDateDesired__c,SecondDesiredSchedule__c,ServiceOfferInterestFlag__c,Vehiclestatus__c,VehicleFinishingDescription__c,VehicleOfferInterestFlag__c,
            VehiclePerformances__c,VehicleRegistrationNumber__c,VehicleType__c,VINOwnedVehicle__c,TECH_Web2Lead__c,
                            Language__c from Lead];
        
        
        
        Test.startTest();
        LeadConversionProcess.ConvertLeadStatus(leads, true);
        Test.stopTest();
    }  
    
    @isTest static void createConsent_test_01(){
        List<Lead> leads = [Select id, FirstName ,Salutation ,LastName , Street , City , PostalCode ,Latitude ,Longitude, Phone ,DestinationPOSCode__c ,Company ,PSABrand__c ,Email ,LeadRequestType__c, Status ,OwnerId ,RecordTypeId ,CustomerContact__c ,Customer__c, Address2__c, Industry, CompanyActivityType__c,
                            country,DescriptionofVehicleVPParcSize__c,DescriptionofVehicleVUParcSize__c,FiscalId__c ,FleetSize__c ,LocalIdOfCustomer__c ,MainBrandofVehicleVPParc__c ,MainBrandofVehicleVUParc__c ,
            MainModelofVehicleVPParc__c ,MainModelofVehicleVUParc__c ,NumberOfEmployees, RenewalDateVehicleVPParc__c ,RenewalDateVehicleVUParc__c ,State, Birthdate__c, LandlinePersonalTelephone__c, LandlineProfessionalTelephone__c, MobileProfessionalTelephone__c , MobilePersonalTelephone__c, NationalId__c,Title,
                            AgentCallCenterComments__c,AmountFinanced__c,AppointmentDate__c,CampaignContent__c,CampaignIDUSER__c,CampaignMedium__c,CampaignName__c,CampaignSource__c,CampaignTerm__c,CustomerComments__c,DaysBeforeCheckOut__c,DesiredRecallDateFromCustomer__c,DestinationGeographicalCode__c,
            EndContractDate__c,EvaluationPriceForVO__c,FinalPrice__c,FinanceContractNumber__c,FinanceDescription__c,FinanceOfferInterest__c,FinancingDuration__c,ProductCustomerInterest__c ,Activity__c,FirstAppointmentDateDesired__c,FirstDesiredSchedule__c,FiscalPower__c,FlagPSAProduct__c,IdCookies__c,
            IdReservationVD__c,InitialPurchaseDate__c,LCDVInterest__c,LCDVOwnedProduct__c,LeadCountry__c,LeadLabel__c,LeadRequestDate__c,LeadSource,Link__c,LinkDescription__c,MarketingCode__c,MonthlyPayments__c,NumberFleetVehiclesFinanceContract__c,OnTheRoadFirstDate__c,
            PreferredContactMethod__c,ProductOwned__c,PurchaseIntentionPeriod__c,RemainingAmount__c,SecondAppointmentDateDesired__c,SecondDesiredSchedule__c,ServiceOfferInterestFlag__c,Vehiclestatus__c,VehicleFinishingDescription__c,VehicleOfferInterestFlag__c,
            VehiclePerformances__c,VehicleRegistrationNumber__c,VehicleType__c,VINOwnedVehicle__c,TECH_Web2Lead__c,CalculatedPOS__c,CheckBox1Meaning__c,CheckBox1Value__c,CheckBox2Meaning__c,CheckBox2Value__c,CheckBox3Meaning__c,CheckBox3Value__c,CheckBox4Meaning__c,CheckBox4Value__c,CheckBox5Meaning__c,
                            CheckBox5Value__c,CheckBox6Meaning__c,CheckBox6Value__c,CheckBox7Meaning__c,CheckBox7Value__c,CheckBox8Meaning__c,CheckBox8Value__c,CheckBox9Meaning__c,CheckBox9Value__c,CheckBox10Meaning__c,CheckBox10Value__c,LeadChannel__c,
                            Language__c from Lead];
        
        
        
        Test.startTest();
        LeadConversionProcess.createConsent(leads);
        Test.stopTest();
    }
}