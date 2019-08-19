@isTest
private class TestDataFactoryUtilTest {

	@isTest static void createDealers() {
		Test.startTest();
			List<String> lst_Acti = new List<String>();
	        lst_Acti.add('VN');
			List<Account> lst_account =  TestDataFactoryUtil.createDealers(11, 'B2B', '99291291', '1237770', '12312', 'AC', 'ES', 'asdas', lst_Acti, true);
		Test.stopTest();
	}

	@isTest static void createAccountContact() {
		Test.startTest();
			List<Account> lst_account =  TestDataFactoryUtil.createAccountContact(1, 'Dealer');
		Test.stopTest();
	}

	@isTest static void createOpportunities() {
		Test.startTest();
			List<Account> lst_account =  TestDataFactoryUtil.createAccount(1, 'B2B');
			List<Opportunity> lst_opp = TestDataFactoryUtil.createOpportunities(1, 'FleetRequestOpportunity', lst_account[0], 1, '1', 50);
		Test.stopTest();
	}

	@isTest static void createPartnerUser() {
		Test.startTest();
			List<String> lst_Acti = new List<String>();
	        lst_Acti.add('VN');
	        List<Contact> lst_contacts = TestDataFactoryUtil.createPartnerUser(2, 1, 'Dealer', '133225511','1237770', '9999999999','AP','CL', 'J',lst_Acti,true);
		Test.stopTest();
	}

	@isTest static void createUser() {
		Test.startTest();
			List<Contact> lst_contacts = TestDataFactoryUtil.createPartnerUser(1,1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
	        List<User> lst_users = TestDataFactoryUtil.createUser(lst_contacts,'Sales_Manager','Partner','Manager');
		Test.stopTest();
	}

	@isTest static void createAsset() {
		Test.startTest();
			List<Account> lst_account =  TestDataFactoryUtil.createAccount(1, 'B2B');
			List<Asset> lst_asset =  TestDataFactoryUtil.createAsset(1, lst_account);
		Test.stopTest();
	}

	@isTest static void createLead() {
		Test.startTest();
			List<Lead> lst_leads = TestDataFactoryUtil.createLead(3, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');
		Test.stopTest();
	}

        /////////////////////////////////// ACCOUNT///////////////////////////////////////////////////

		@isTest
		static void createAccountList_do_insert_Test(){
		map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'  => 'account test',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        };

        Test.startTest();
        TestDataFactoryUtil.createAccountList(mapApiNameToFieldValue, true, 2);
        Test.stopTest();


        List<Account> account = [Select id from Account where Name like 'account test%'];

        System.assertEquals(2, account.size());
		System.assertEquals('account test 0', [select name from Account where name = 'account test 0' limit 1].name);
		}

		@isTest
		static void createAccountList_do_not_insert_Test(){
		map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'  => 'account test',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        };

        Test.startTest();
        TestDataFactoryUtil.createAccountList(mapApiNameToFieldValue, false, 2);
        Test.stopTest();


        List<Account> account = [Select id from Account where Name like 'account test%'];
		
        System.assertEquals(0, account.size());
		}

		@isTest
		static void createAccount_do_insert_Test(){
		map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'  => 'account test',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C)
        };

        Test.startTest();
        TestDataFactoryUtil.createAccount(mapApiNameToFieldValue, true);
        Test.stopTest();


        List<Account> accounts = [Select id, name from Account where Name = 'account test'];
		
        System.assertEquals(1, accounts.size());
		System.assertEquals('account test', accounts.get(0).name);
		}

		@isTest
		static void createAccount_do_not_insert_Test(){
		map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'  => 'account test',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C)
        };

        Test.startTest();
        Account account = TestDataFactoryUtil.createAccount(mapApiNameToFieldValue, false);
        Test.stopTest();


        List<Account> accounts = [Select id, name from Account where Name = 'account test'];
		
        System.assertEquals(0, accounts.size());
		System.assertEquals('account test', account.name);
		}



        /////////////////////////////ACCOUNT CONTACT ASSET RELATION///////////////////////////////// 

        /*@isTest
		static void createAccountContactAssetRelation_do_insert_Test(){
            Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'Name'					=> 'TEST MATCH 26',
                'Phone'					=> '+8434334',
                'BillingPostalCode'		=> '23456',
                'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
            }, true);

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
                'PosessionChangeConfirmation__c' => true,
                'AccountRole__c'                 => 'Owner',
                'AccountId__c'                   => account.Id,
                'AssetId__c'                     => asset.Id,
                'RelationEndDate__c'             => System.today()
            };


            Test.startTest();
            TestDataFactoryUtil.createAccountContactAssetRelation(mapApiNameToFieldValue, true);
            Test.stopTest();


            List<AccountContactAssetRelation__c> accountContactAssetRelations = [Select id from AccountContactAssetRelation__c];

            System.assertEquals(2, accountContactAssetRelations.size());//one AccountContactAssetRelation__c record has been inserted at asset insert(trigger)
		}*/



		@isTest
		static void createAccountContactAssetRelation_do_not_insert_Test(){
            Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'Name'					=> 'TEST MATCH 26',
                'Phone'					=> '+8434334',
                'BillingPostalCode'		=> '23456',
                'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
            }, true);

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
                'PosessionChangeConfirmation__c' => true,
                'AccountRole__c'                 => 'Owner',
                'AccountId__c'                   => account.Id,
                'AssetId__c'                     => asset.Id,
                'RelationEndDate__c'             => System.today()
            };

            Test.startTest();
            TestDataFactoryUtil.createAccountContactAssetRelation(mapApiNameToFieldValue, false);
            Test.stopTest();


            List<AccountContactAssetRelation__c> accountContactAssetRelations = [Select id from AccountContactAssetRelation__c];

            System.assertEquals(1, accountContactAssetRelations.size());//one AccountContactAssetRelation__c record has been inserted at asset insert(trigger)
		}




        /*@isTest
		static void createAccountContactAssetRelationList_do_insert_Test(){
            Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'Name'					=> 'TEST MATCH 26',
                'Phone'					=> '+8434334',
                'BillingPostalCode'		=> '23456',
                'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
            }, true);

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
                'PosessionChangeConfirmation__c' => true,
                'AccountRole__c'                 => 'Owner',
                'AccountId__c'                   => account.Id,
                'AssetId__c'                     => asset.Id,
                'RelationEndDate__c'             => System.today()
            };


            Test.startTest();
            TestDataFactoryUtil.createAccountContactAssetRelationList(mapApiNameToFieldValue, true, 2);
            Test.stopTest();


            List<AccountContactAssetRelation__c> accountContactAssetRelations = [Select id from AccountContactAssetRelation__c];

            System.assertEquals(3, accountContactAssetRelations.size());//one AccountContactAssetRelation__c record has been inserted at asset insert(trigger)
		}*/



		/*@isTest
		static void createAccountContactAssetRelationList_do_not_insert_Test(){
            Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'Name'					=> 'TEST MATCH 26',
                'Phone'					=> '+8434334',
                'BillingPostalCode'		=> '23456',
                'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
            }, true);

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
                'PosessionChangeConfirmation__c' => true,
                'AccountRole__c'                 => 'Owner',
                'AccountId__c'                   => account.Id,
                'AssetId__c'                     => asset.Id,
                'RelationEndDate__c'             => System.today()
            };

            Test.startTest();
            TestDataFactoryUtil.createAccountContactAssetRelationList(mapApiNameToFieldValue, false, 2);
            Test.stopTest();


            List<AccountContactAssetRelation__c> accountContactAssetRelations = [Select id from AccountContactAssetRelation__c];

            System.assertEquals(1, accountContactAssetRelations.size());//one AccountContactAssetRelation__c record has been inserted at asset insert(trigger)
		}*/

		
        /////////////////////////////////// CONTACT///////////////////////////////////////////////////
    
        @isTest
        static void createContact_do_insert_Test(){
            Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'Name'					=> 'TEST MATCH 26',
                'Phone'					=> '+8434334',
                'BillingPostalCode'		=> '23456',
                'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
            }, true);
            
            
            map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
                'AccountId'				=> account.id,
                'FirstName'				=> 'Contact FirstName',
                'LastName'				=> 'Contact LastName',
                'Salutation'			=> '1',
                'Phone'					=> '9867767',
                'ACAnonymization__c'	=> true,
                'APAnonymization__c'	=> true,
                'DSAnonymization__c'	=> false,
                'TECH_OptOut__c'		=> true
            };

            Test.startTest();
            TestDataFactoryUtil.createContact(mapApiNameToFieldValue, true);
            Test.stopTest();


            List<Contact> contact = [Select id, LastName from contact where LastName = 'Contact LastName'];
            
            System.assertEquals(1, contact.size());
            System.assertEquals('Contact LastName', contact.get(0).LastName);
        }
    
    /////////////////////////////////// LEAD///////////////////////////////////////////////////

	@isTest
    static void createLeadList_do_insert_Test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'lastName'  => 'lastname test',
            'firstName' => 'firstname test',
            'Email'     => 'test@leadexample.com',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2B)
        };

        Test.startTest();
        TestDataFactoryUtil.createLeadList(mapApiNameToFieldValue, true, 2);
        Test.stopTest();


        List<Lead> leads = [Select id from Lead where lastname like 'lastname test%'];
        System.assertEquals(2, leads.size());
    }


    @isTest
    static void createLeadList_do_not_insert_Test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'lastName'  => 'lastname test',
            'firstName' => 'firstname test',
            'Email'     => 'test@leadexample.com',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2B)
        };

        Test.startTest();
        List<Lead> leadReturn = TestDataFactoryUtil.createLeadList(mapApiNameToFieldValue, false, 2);
        Test.stopTest();


        List<Lead> leadsSoql = [Select id from Lead where lastname like 'lastname test%'];
        System.assertEquals(0, leadsSoql.size());

        System.assertEquals('lastname test 0', leadReturn.get(0).lastname);
    }

    @isTest
    static void createLead_do_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'lastName'  => 'lastname test',
            'firstName' => 'firstname test',
            'Email'     => 'test@leadexample.com',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2C)
        };

        Test.startTest();
        TestDataFactoryUtil.createLead(mapApiNameToFieldValue, true);
        Test.stopTest();


        List<Lead> leads = [Select id from Lead where lastname = 'lastname test'];
        System.assertEquals(1, leads.size());
    }

    @isTest
    static void createLead_do_not_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'lastName'  => 'lastname test',
            'firstName' => 'firstname test',
            'Email'     => 'test@leadexample.com',
						'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2C)
        };

        Test.startTest();
        Lead leadReturn = TestDataFactoryUtil.createLead(mapApiNameToFieldValue, false);
        Test.stopTest();


        List<Lead> leadsSoql = [Select id from Lead where lastname = 'lastname test'];
        System.assertEquals(0, leadsSoql.size());

        System.assertEquals('lastname test', leadReturn.lastname);
    }
    
    ///////////////////////////////////CAMPAIGN///////////////////////////////////////////////////

    @isTest
    static void createCampaign_do_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'	  		=>	'Template Campaign', 
			'RecordTypeId'	=>	PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        };
            
        
        Test.startTest();
        TestDataFactoryUtil.createCampaign(mapApiNameToFieldValue, true);
        Test.stopTest();
        
        
        List<Campaign> campaignsSoql = [Select id, name from Campaign where Name = 'Template Campaign' limit 1];
        System.assertEquals(1, campaignsSoql.size());

        System.assertEquals('Template Campaign', campaignsSoql.get(0).name);
    }
    
    
    @isTest
    static void createCampaign_do_not_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'	  		=>	'Template Campaign', 
			'RecordTypeId'	=>	PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        };
            
        
        Test.startTest();
        Campaign campaignReturn = TestDataFactoryUtil.createCampaign(mapApiNameToFieldValue, false);
        Test.stopTest();
        
        
        List<Campaign> campaignsSoql = [Select id, name from Campaign where Name = 'Template Campaign'];
        System.assertEquals(0, campaignsSoql.size());

        System.assertEquals('Template Campaign', campaignReturn.name);
    }
    



    

    @isTest 
    static void createDataSetUser_test(){
        Test.startTest();
        User u = TestDataFactoryUtil.createUserCreatorDataSet();
        Test.stopTest();

        System.assertEquals('9876543' , [Select ldapid__c from user where ldapid__c = '9876543' limit 1].ldapId__c);
    }



    @isTest
    static void getDataSetUser_test(){
        TestDataFactoryUtil.createUserCreatorDataSet();
        Test.startTest();
        User u = TestDataFactoryUtil.getTestorUser();
        Test.stopTest();
        

        System.assertEquals('9876543' , u.ldapId__c);
    }


    ///////////////////////////////////OPPORTUNITY///////////////////////////////////////////////////
	@isTest 
    static void creatOpportunity_do_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'	  		=>	'opportunity name', 
            'Probability'   =>30,
            'Amount'        => 2,
            'AccountId'     => account.id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => 'PL',
            'StageName'     => '1'
        };




		Test.startTest();
		Opportunity opportunity = TestDataFactoryUtil.createOpportunities(mapApiNameToFieldValue, true);
		Test.stopTest();

        List<Opportunity> opportunitySoql = [Select id, name from Opportunity where Name = 'opportunity name' limit 1];
        System.assertEquals(1, opportunitySoql.size());

        System.assertEquals('opportunity name', opportunitySoql.get(0).name);
	}


    @isTest
    static void createOpportunity_do_not_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Name'	  		=>	'opportunity name', 
            'Probability'   =>30,
            'Amount'        => 2,
            'AccountId'     => account.id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => 'PL',
            'StageName'     => '1'
        };

            
        
        Test.startTest();
        Opportunity opportunitiesReturn = TestDataFactoryUtil.createOpportunities(mapApiNameToFieldValue, false);
        Test.stopTest();
        
        
        List<Opportunity> opportunitySoql = [Select id, name from Opportunity where Name = 'opportunity name'];
        System.assertEquals(0, opportunitySoql.size());

        System.assertEquals('opportunity name', opportunitiesReturn.name);
    }


    ///////////////////////////////////SBQQ__QUOTE///////////////////////////////////////////////////

    @isTest
    static void createSBQQQuote_do_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        Opportunity opportunity = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
            'Name'	  		=>	'opportunity name', 
            'Probability'   =>30,
            'Amount'        => 2,
            'AccountId'     => account.id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => 'PL',
            'StageName'     => '1'
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'SBQQ__ExpirationDate__c'	=> System.today(),
            'SBQQ__Status__c'           => '1',
            'SBQQ__Opportunity2__c'     => opportunity.id
        };

        Test.startTest();
        SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(mapApiNameToFieldValue, true);
        Test.stopTest();


        list<SBQQ__Quote__c> quoteSoql = [Select id, SBQQ__Status__c,name from SBQQ__Quote__C where SBQQ__Opportunity2__c = :opportunity.id];
        System.assertEquals(1, quoteSoql.size());

       System.assertEquals('1', quoteSoql.get(0).SBQQ__Status__c);
    }
    
    
    @isTest
    static void createSBQQQuote_do_not_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        Opportunity opportunity = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
            'Name'	  		=>	'opportunity name', 
            'Probability'   =>30,
            'Amount'        => 2,
            'AccountId'     => account.id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => 'PL',
            'StageName'     => '1'
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'SBQQ__ExpirationDate__c'	=> System.today(),
            'SBQQ__Status__c'           => '1',
            'SBQQ__Opportunity2__c'     => opportunity.id
        };

        Test.startTest();
        SBQQ__Quote__C quotesReturn = TestDataFactoryUtil.createSbqqQuote(mapApiNameToFieldValue, false);
        Test.stopTest();


        list<SBQQ__Quote__c> quoteSoql = [Select id, SBQQ__Status__c,name from SBQQ__Quote__C where SBQQ__Opportunity2__c = :opportunity.id];
        System.assertEquals(0, quoteSoql.size());

       System.assertEquals('1', quotesReturn.SBQQ__Status__c);
    }

    ///////////////////////////////////TASK///////////////////////////////////////////////////

    @isTest
    static void createTask_do_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Subject'        => 'Call',
            'CallStatus__c'  => '0', 
            'Activitydate'   => System.today()
        };
            
        
        Test.startTest();
        TestDataFactoryUtil.createTask(mapApiNameToFieldValue, true);
        Test.stopTest();
        
        
        List<Task> taskSoql = [Select id, Subject from Task where Subject = 'Call' limit 1];
        System.assertEquals(1, taskSoql.size());

        System.assertEquals('Call', taskSoql.get(0).Subject);
    }
    
    
    @isTest
    static void createTask_do_not_insert_test(){
        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
            'Subject'        => 'Call',
            'CallStatus__c'  => '0', 
            'Activitydate'   => System.today()
        };
            
        
        Test.startTest();
        Task taskReturn = TestDataFactoryUtil.createTask(mapApiNameToFieldValue, false);
        Test.stopTest();
        
        
        List<Task> taskSoql = [Select id, Subject from Task where Subject = 'Call'];
        System.assertEquals(0, taskSoql.size());

        System.assertEquals('Call', taskReturn.Subject);
    }


    ///////////////////////////////////TASK///////////////////////////////////////////////////

    @isTest static void createAsset_do_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
			'Name'                => 'Test Vehicle',
			'AssetType__c'        => 'VN',
			'CurrencyIsoCode'     => 'EUR',
			'AccountId'           => account.Id
		};




		Test.startTest();
		Asset Asset = TestDataFactoryUtil.createAsset(mapApiNameToFieldValue, true);
		Test.stopTest();

        List<Asset> AssetSoql = [Select id, name from Asset where Name = 'Test Vehicle' limit 1];
        System.assertEquals(1, AssetSoql.size());

        System.assertEquals('Test Vehicle', AssetSoql.get(0).name);
	}


    @isTest
    static void createAsset_do_not_insert_test(){
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);


        map<String, Object> mapApiNameToFieldValue = new map<String, Object>{
			'Name'                => 'Test Vehicle',
			'AssetType__c'        => 'VN',
			'CurrencyIsoCode'     => 'EUR',
			'AccountId'           => account.Id
		};

            
        
        Test.startTest();
        Asset assetsReturn = TestDataFactoryUtil.createAsset(mapApiNameToFieldValue, false);
        Test.stopTest();
        
        
        List<Asset> AssetSoql = [Select id, name from Asset where Name = 'Test Vehicle'];
        System.assertEquals(0, AssetSoql.size());

        System.assertEquals('Test Vehicle', assetsReturn.name);
    }
    

}