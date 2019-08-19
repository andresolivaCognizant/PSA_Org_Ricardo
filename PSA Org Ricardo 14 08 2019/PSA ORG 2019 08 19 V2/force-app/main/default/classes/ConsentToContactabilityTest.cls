/**
	*   @Class : ConsentToContactabilityTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   19 Feb 2018
	*   @Description    :   Test for ConsentToContactabilityTest Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				19/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class ConsentToContactabilityTest {
    
    @isTest static void ConsentAfterInsertTest(){
        // Test data setup
       	List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'Dealer');
        List<Contact> lstConts  =  TestDataFactoryUtil.createPartnerUser(1,1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        Consent__c consent = new Consent__c(Contact__c = lstConts[0].id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].id, 
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
                                            CheckBox6Value__c = true);
        Consent__c consent2 = new Consent__c(Contact__c = lstConts[0].id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].id, 
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
                                            CheckBox10Value__c = true);
        Consent__c consent3 = new Consent__c(Contact__c = lstConts[0].id, 
                                            Purpose__c = 'Cookies',
                                            CheckBox1Meaning__c = 'MkgPOSBrand', 
                                            CheckBox1Value__c = false,
                                            CheckBox2Meaning__c = 'MkgPOSBrandEmailSMS', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgGroupEmailSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgPartnersEmailSMS', 
                                            CheckBox4Value__c = true,
                                            CollectedEntityId__c = lstAccts[0].id 
                                            );
        // Perform test
        Test.startTest();
        	insert consent;
        	System.assertEquals(9, [select id from Contactability__c where Contact__c = :lstConts[0].id].size());
        	insert consent2;
            System.assertEquals(16, [select id from Contactability__c where Contact__c = :lstConts[0].id].size());
        	insert consent3;
        	System.assertEquals(24, [select id from Contactability__c where Contact__c = :lstConts[0].id].size());
        	ConsentTriggerHandler.dontRunTrigger();
        Test.stopTest();
        
    }

}