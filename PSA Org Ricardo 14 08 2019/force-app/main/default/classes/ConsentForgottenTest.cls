/**
	*   @Class : ConsentForgottenTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   05 March 2018
	*   @Description    :   Test for ConsentForgotten
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				05/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class ConsentForgottenTest {
    
    @isTest static void generateConsentsTest() {
        List<Contact> lstConts  =  TestDataFactoryUtil.createPartnerUser(3,3, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        lstConts.get(0).ACAnonymization__c = true;
        lstConts.get(1).APAnonymization__c = true;
        lstConts.get(2).APAnonymization__c = true;
        lstConts.get(2).DSAnonymization__c = true;
        lstConts.get(2).ACAnonymization__c = true;
        
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'Dealer');
        List<Consent__c> lstConsent = new List<Consent__c>();

        Consent__c consent = new Consent__c(Contact__c = lstConts[0].Id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );

        lstConsent.add(consent);

        Consent__c consent2 = new Consent__c(Contact__c = lstConts[1].Id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox1Meaning__c = 'MkgPOSBrand', 
                                            CheckBox1Value__c = false, 
                                            CheckBox2Meaning__c = 'MkgPOSBrandPhoneSMS', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSBrandPhone', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgPOSBrandSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox7Meaning__c = 'MkgPartners', 
                                            CheckBox7Value__c = true, 
                                            CheckBox8Meaning__c = 'MkgPartnersPhoneSMS', 
                                            CheckBox8Value__c = true, 
                                            CheckBox9Meaning__c = 'MkgPOSBrandMail', 
                                            CheckBox9Value__c = true, 
                                            CheckBox10Meaning__c = 'MkgPOSBrandEMail', 
                                            CheckBox10Value__c = true
        );

        lstConsent.add(consent2);
        
        Consent__c consent3 = new Consent__c(Contact__c = lstConts[1].Id, 
                                            DocumentBrand__c = 'AP', 
                                            CollectedEntityId__c = lstAccts[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );

        lstConsent.add(consent3);
        
        Consent__c consent4 = new Consent__c(Contact__c = lstConts[2].Id, 
                                            DocumentBrand__c = 'DS', 
                                            CollectedEntityId__c = lstAccts[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );

        lstConsent.add(consent4);   
        
        insert lstConsent;
        
        Test.startTest();   	
        	Update lstConts;
        Test.stopTest();

        System.assertEquals(144, [select id from Contactability__c].size());

    }
    
    @isTest static void generateConsentsB2CTest() {
        List<Account> lstAccts = new  List<Account>();
        
        String sKeyword             = '000000000';
        Id rt                   = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId();

        for(Integer i=0;i<3;i++) {
            Account acct = new Account(
                	Salutation			=	'1',
                    FirstName           =   'Prueba' + i,
                	LastName            =   'Tést' + i,
                    BillingStreet       =   'Eduardo Barreiro Nº' +sKeyword.right(4),
                    BillingCity         =   'Madrid',
                    BillingCountry      =   'España', 
                    BillingPostalCode   =   sKeyword.right(5),
                    Phone               =   sKeyword.right(9),
                	LandlineProfessionalTelephone__pc =   sKeyword.right(9),
                	PersonEmail				=	'test' + i + '@prueba.com',
                    RecordTypeId        =   rt
            );

           lstAccts.add(acct); 
        }
        
        insert lstAccts;
        
        List<Account> lstAccts3 = [select Id, PersonContactId, IsPersonAccount from account];
        
        List<Account> lstAccts2 = TestDataFactoryUtil.createAccount(1,'Dealer');
        
        lstAccts.get(0).ACAnonymization__pc = true;
        lstAccts.get(1).APAnonymization__pc = true;
        lstAccts.get(2).APAnonymization__pc = true;
        lstAccts.get(2).DSAnonymization__pc = true;
        lstAccts.get(2).ACAnonymization__pc = true;

        List<Consent__c> lstConsent = new List<Consent__c>();
        
        Consent__c consent = new Consent__c(Contact__c = lstAccts3[0].PersonContactId, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts2[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );
        
        lstConsent.add(consent);
       
        Consent__c consent2 = new Consent__c(Contact__c = lstAccts3[1].PersonContactId, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts2[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox1Meaning__c = 'MkgPOSBrand', 
                                            CheckBox1Value__c = false, 
                                            CheckBox2Meaning__c = 'MkgPOSBrandPhoneSMS', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSBrandPhone', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgPOSBrandSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox7Meaning__c = 'MkgPartners', 
                                            CheckBox7Value__c = true, 
                                            CheckBox8Meaning__c = 'MkgPartnersPhoneSMS', 
                                            CheckBox8Value__c = true, 
                                            CheckBox9Meaning__c = 'MkgPOSBrandMail', 
                                            CheckBox9Value__c = true, 
                                            CheckBox10Meaning__c = 'MkgPOSBrandEMail', 
                                            CheckBox10Value__c = true
        );
        
        lstConsent.add(consent2);
       
        Consent__c consent3 = new Consent__c(Contact__c = lstAccts3[1].PersonContactId, 
                                            DocumentBrand__c = 'AP', 
                                            CollectedEntityId__c = lstAccts2[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );
        
        lstConsent.add(consent3);
       
        Consent__c consent4 = new Consent__c(Contact__c = lstAccts3[2].PersonContactId, 
                                            DocumentBrand__c = 'DS', 
                                            CollectedEntityId__c = lstAccts2[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true
        );
        
        lstConsent.add(consent4);
       
        insert lstConsent;
        
        Test.startTest();       	
        	Update lstAccts;      	
        Test.stopTest();

        System.assertEquals(144, [select id from Contactability__c].size());
    } 
}