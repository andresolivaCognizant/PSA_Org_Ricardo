/**
	*   @Class : ConsentOptOutTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   1 March 2018
	*   @Description    :   Test for ConsentOptOut
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				1/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class ConsentOptOutTest {
    
    @isTest static void generateConsentsTest() {
        // Test data setup
        List<Contact> lstConts  =  TestDataFactoryUtil.createPartnerUser(3,3, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        lstConts.get(0).TECH_OptOutBrand__c = 'AC';
        lstConts.get(0).TECH_OptOutEntity__c = 'POS';
        lstConts.get(0).TECH_OptOutMeanOfContact__c = 'PhoneSMS';
        lstConts.get(0).TECH_OptOutRequest__c = True;
        lstConts.get(0).TECH_OptOut__c = True;
        lstConts.get(1).TECH_OptOutBrand__c = 'AC';
        lstConts.get(1).TECH_OptOutEntity__c = 'Brand';
        lstConts.get(1).TECH_OptOutMeanOfContact__c = 'Mail';
        lstConts.get(1).TECH_OptOutRequest__c = True;
        lstConts.get(1).TECH_OptOut__c = True;
        lstConts.get(2).TECH_OptOutBrand__c = 'DS';
        lstConts.get(2).TECH_OptOutEntity__c = 'POS';
        lstConts.get(2).TECH_OptOutMeanOfContact__c = 'Email';
        lstConts.get(2).TECH_OptOut__c = True;
        
        List<Account> lstAccts = TestDataFactoryUtil.createAccountContact(1,'Dealer');
        List<Account> lstPAccts = TestDataFactoryUtil.createPersonAccount(1); 

        Consent__c consent = new Consent__c(Contact__c = lstConts[0].id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].id, 
                                            TECH_AccountId__c = lstPAccts[0].id, 
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
        Consent__c consent2 = new Consent__c(Contact__c = lstConts[1].id, 
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
        Consent__c consent3 = new Consent__c(Contact__c = lstConts[2].id, 
                                            CollectedEntityId__c = lstAccts[0].id, 
                                            Purpose__c = 'Cookies',
                                            CheckBox1Meaning__c = 'MkgPOSBrand', 
                                            CheckBox1Value__c = false);
        
        Insert consent;
        Insert consent2;
        Insert consent3;
        
        // Perform test
        Test.startTest();
        	System.assertEquals(29, [select id from Contactability__c].size());
        	Update lstConts;
            System.assertEquals(32, [select id from Contactability__c].size());

            List<Consent__c> lCSnT = [SELECT TECH_AccountId__r.PersonContactId,TECH_AccountId__c, Contact__c, CollectedCountry__c, DocumentBrand__c 
                                    FROM Consent__c where Id = :consent.Id];
            Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :lCSnT[0].TECH_AccountId__c LIMIT 1]; 
            ConsentOptOut.createConsentsOptOut(acc,lCSnT[0].CollectedCountry__c,lCSnT[0].DocumentBrand__c);
            System.assertEquals(36, [select id from Contactability__c].size());
        	
        Test.stopTest();

    } 
}