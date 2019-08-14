@isTest
private class ContactTriggerHandlerTest {

    private static final String MAILING1_ADRAR			= '1000';
    private static final String MAILING2_ORAN			= '31000';
    private static final String KEY_PHONE				= '+36640780345';
    
    
    /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is used to create test records once and then access them in every test 
    *                  :   method in the test class
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/    
    @testSetup static void setupCommonData(){
        
        //Insert B2B Account
		List<Account> lstBAccounts     =   TestDataFactoryUtil.createAccount(1,'B2B');
        
        //Insert B2B Contact
        Contact contact = TestDataFactoryUtil.createContact(new map<String, object>{
            'AccountId'				=> lstBAccounts.get(0).Id,
                'FirstName'				=> 'Contact FirstName',
                'LastName'				=> 'Contact LastName',
                'Salutation'			=> '1',
                'Phone'					=> KEY_PHONE,
                'TECH_OptOut__c'		=> true,
                'MailingState'          => MAILING1_ADRAR
                }, true);        
    }
        
    
    static testMethod void myUnitTest() {
        
        Account accB3 = new Account(
                Name                                          =   'TEST MATCH 26',
                phone                                         =   '+8434334',
                BillingPostalCode                             =   '23456',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );
        
        insert accB3;
        
        Contact c=   new Contact (
            AccountId		=   accB3.id,
            FirstName		=   'Contact FirstName',
            LastName		=   'Contact LastName',
            Salutation		=   '1',
            Phone			=   '9867767',
            ACAnonymization__c=true,
            APAnonymization__c=true,
            DSAnonymization__c=false,
            TECH_OptOut__c=true            
        );
        
        insert c;
        
        map<id,contact> mapIdContact = new Map<Id,Contact>();
        mapIdContact.put(c.id, c);
        
        c.nationalid__c = '30.686.957-4';
        c.DSAnonymization__c = true;
        update c;
        
        List<Contact> l = new List<Contact>{c};
        Test.startTest();
            //ContactTriggerHandler.beforeInsert(new List<Contact>{c});       
            //ContactTriggerHandler.beforeUpdate(new List<Contact>{c}, mapIdContact);
            ContactTriggerHandler.shouldRunTrigger();
            ContactTriggerHandler.dontRunTrigger();
        Test.stopTest();
        
    }

    static testMethod void validateNIFContact() {
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
         Country__c = 'PT');

      System.runAs(u2) {
        
            Account accB3 = new Account(
                    Name                                          =   'TEST MATCH 26',
                    phone                                         =   '+8434334',
                    BillingPostalCode                             =   '23456',
                    RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
            );
            
            insert accB3;

            List<Contact> lst_con = new List<Contact>();

            List<RecordType> lst_recordType = [SELECT Id FROM RecordType where DeveloperName = 'B2BContact'];
            
            Contact c =   new Contact (
                AccountId       =   accB3.id,
                FirstName       =   'Contact FirstName',
                LastName        =   'Contact LastName',
                Salutation      =   '1',
                Phone           =   '9867767',
                ACAnonymization__c=true,
                APAnonymization__c=true,
                DSAnonymization__c=false,
                TECH_OptOut__c=true,
                NationalId__c          =   '500206007',
                NationalId2__c         =   '500206007',
                //NationalIdType__c = 'NIF',
                RecordTypeId = lst_recordType[0].Id
            );

            Contact cOne =   new Contact (
                AccountId       =   accB3.id,
                FirstName       =   'Contact FirstName',
                LastName        =   'Contact LastName',
                Salutation      =   '1',
                Phone           =   '9867767',
                ACAnonymization__c=true,
                APAnonymization__c=true,
                DSAnonymization__c=false,
                TECH_OptOut__c=true,
                NationalId__c          =   '500206007',
                NationalId2__c         =   '500206007',
                //NationalIdType__c = 'NIF',
                RecordTypeId = lst_recordType[0].Id
            );

            lst_con.add(c);
            lst_con.add(cOne);

            
            Test.startTest(); 

                insert lst_con;

                try{
                    c.NationalId__c = '500234007';
                    update c;
                }catch(DmlException e){ 

                }

                try{
                    cOne.NationalId2__c = '500234007';
                    update cOne;
                }catch(DmlException e){ 

                }

                try{
                    c.NationalId__c = '50023400734';
                    update c;
                }catch(DmlException e){ 

                }

                try{
                    cOne.NationalId2__c = '50023400743';
                    update cOne;
                }catch(DmlException e){ 

                }       

            Test.stopTest();
        }
        
    }
    

    /*********************************************************************************************************
    * @Method          :   addressUpdateFromWilayaFieldTest
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method checks the functionality of the 'addressUpdateFromWilayaField' method, 
    *                      updates the address from the 'Wila' fields
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @isTest static void addressUpdateFromWilayaFieldTest(){
        
        Contact contactTest = [SELECT Id, MailingState FROM Contact WHERE Phone =: KEY_PHONE LIMIT 1];
        
        //Check Case 1: Insert Contact, Verify that the address has been populated with the data of the 'XXWilaya__c' field
        System.assertEquals(MAILING1_ADRAR, contactTest.MailingState);
        
        //Update the Wilaya field...
        contactTest.MailingWilaya__c = MAILING2_ORAN;
        Test.startTest();
        update contactTest;
        Test.stopTest();
            
        //Get updated data
        contactTest = [SELECT Id, MailingState FROM Contact WHERE Id =: contactTest.Id];            
        
        //Check Case 2: Update Contact, Verify that the address has been populated with the data of the 'MailingWilaya__c' field
        System.assertEquals(MAILING2_ORAN, contactTest.MailingState);
    }    
	
}