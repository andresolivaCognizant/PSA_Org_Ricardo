@isTest
private class AssetRelationTriggerHandlerTest {
    
    @testSetup static void setup() {
        List<String> lstActivities   =   new List<String>{'VN'};
		List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);   		
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstContsA,'Sales_Manager','Partner','Manager');
        Insert lstUsers1;

        system.runAs(lstUsers1.get(0)){

            Account B2C = TestDataFactoryUtil.createAccount(new map<String, Object>{
                'FirstName'             => 'Account FirstName',
                'LastName'              => 'Account LastName',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2c@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
            }, true);

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Asset Test 1',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => B2C.Id
            }, true);

        }

        
    }
    
    @isTest static void buildTECHExtId_test_01(){

        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account account = [Select id from Account where recordTypeId = :PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA) limit 1];
            

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle 1',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            AccountContactAssetRelation__c assetRelation = [Select id, AccountId__r.name, AssetId__r.name, AccountRole__c, PosessionChangeConfirmation__c,TECHExtId__c from AccountContactAssetRelation__c where assetid__c = :asset.id];
            System.assertEquals(account.id + '_' + asset.id + '_Owner_', assetRelation.TECHExtId__c);
        }
    }
    
    @isTest static void buildTECHExtId_test_02(){

        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account account = [Select id from Account where recordTypeId = :PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA) limit 1];
            

            Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
                'Name'                => 'Test Vehicle 1',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => account.Id
            }, true);

            AccountContactAssetRelation__c assetRelation = [Select id, AccountId__r.name, AssetId__r.name, AccountRole__c, PosessionChangeConfirmation__c,TECHExtId__c, RelationEndDate__c from AccountContactAssetRelation__c where assetid__c = :asset.id limit 1];
            
            assetRelation.RelationEndDate__c = Date.today();
            
            update assetRelation;
            
            assetRelation = [Select RelationEndDate__c, TECHExtId__c from AccountContactAssetRelation__c where assetid__c = :asset.id limit 1];
            
            System.assertEquals(account.id + '_' + asset.id + '_Owner_' + Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('yyMMdd'), assetRelation.TECHExtId__c);
        }
    }

    

    @isTest static void testMethod1(){
        
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];

            
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
               'AccountId__c'    => b2c.Id,
               'AssetId__c'      => a.Id,
               'AccountRole__c'  => 'Keeper'
            }, true);
            
            
        }
    }
    
    @isTest 
    static void testMethod2(){

        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod2',
                'LastName'              => 'Account LastNametestMethod2',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
            }, true);

            Asset a = (Asset)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET, new map<String, Object>{
                'Name'                => 'Asset Test 1 testMethod2',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'AccountId'           => B2C.Id
            }, true);
            
            Test.startTest();
            AccountContactAssetRelation__c assetRelation1 = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
               'AccountId__c'    				=> b2c.Id,
               'AssetId__c'      				=> a.Id,
               'AccountRole__c'  				=> 'Keeper',
               'PosessionChangeConfirmation__c' => false
            }, true);
            Test.stopTest();

        }
    }

    @isTest static void testMethod3(){

        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];

            TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountId__c'    				=> b2c.Id,
                'AssetId__c'      				=> a.Id,
                'AccountRole__c'  				=> 'Keeper',
                'PosessionChangeConfirmation__c' => true
            }, true);
            
            
            try {
                TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                    'AccountId__c'    				=> b2c.Id,
                    'AssetId__c'      				=> a.Id,
                    'AccountRole__c'  				=> 'Keeper',
                    'PosessionChangeConfirmation__c' => false
                }, true);
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains(Label.AssetPossessionKeeperError), 'AssetRelationTriggerHandlerTest.testMethod3');
            }
        }
    }

    @isTest static void testMethod4(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];

            try {
                AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                    'AccountId__c'    				=> b2c.Id,
                    'AssetId__c'      				=> a.Id,
                    'AccountRole__c'  				=> 'Owner',
                    'PosessionChangeConfirmation__c' => false
                }, true);
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains(Label.AssetPossessionOwnerError), 'AssetRelationTriggerHandlerTest.testMethod4');
            }

        }
    }
    
    @isTest static void testMethod5(){

        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];

            TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountId__c'    				=> b2c.Id,
                'AssetId__c'      				=> a.Id,
                'AccountRole__c'  				=> 'OldKeeper',
                'PosessionChangeConfirmation__c' => true
            }, true);
            
            
            try {
                TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                    'AccountId__c'    				=> b2c.Id,
                    'AssetId__c'      				=> a.Id,
                    'AccountRole__c'  				=> 'OldKeeper',
                    'PosessionChangeConfirmation__c' => true
                }, true);
            }
            catch(Exception e) {
            }
        }
    }
    
    @isTest static void testMethod6(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];

        System.runas(user){

            Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];


            TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountId__c'    				=> b2c.Id,
                'AssetId__c'      				=> a.Id,
                'AccountRole__c'  				=> 'Driver',
                'PosessionChangeConfirmation__c' => true
            }, true);
            
        }
    }
    
    @isTest static void getNewRoleValTest_01(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        system.runas(user){
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountRole__c' => 'Owner'
            }, false);
            
			AssetRelationTriggerHandler.getNewRoleVal('Owner', assetRelation);
            
            system.assertEquals('OldOwner', assetRelation.AccountRole__c);
            system.assertEquals(System.today(), assetRelation.RelationEndDate__c);
        }
    }
    
    @isTest static void getNewRoleValTest_02(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        system.runas(user){
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountRole__c' => 'Keeper'
            }, false);
            
			AssetRelationTriggerHandler.getNewRoleVal('Owner', assetRelation);
            
            system.assertEquals('OldKeeper', assetRelation.AccountRole__c);
            system.assertEquals(System.today(), assetRelation.RelationEndDate__c);
        }
    }
    
    @isTest static void getNewRoleValTest_03(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        system.runas(user){
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountRole__c' => 'Driver'
            }, false);
            
			AssetRelationTriggerHandler.getNewRoleVal('Owner', assetRelation);
            
            system.assertEquals('OldDriver', assetRelation.AccountRole__c);
            system.assertEquals(System.today(), assetRelation.RelationEndDate__c);
        }
    }
    
    @isTest static void getNewRoleValTest_04(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        system.runas(user){
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountRole__c' => 'Keeper'
            }, false);
            
			AssetRelationTriggerHandler.getNewRoleVal('Keeper', assetRelation);
            
            system.assertEquals('OldKeeper', assetRelation.AccountRole__c);
            system.assertEquals(System.today(), assetRelation.RelationEndDate__c);
        }
    }
    
    @isTest static void getNewRoleValTest_05(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        system.runas(user){
            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountRole__c' => 'Driver'
            }, false);
            
			AssetRelationTriggerHandler.getNewRoleVal('Driver', assetRelation);
            
            system.assertEquals('OldDriver', assetRelation.AccountRole__c);
            system.assertEquals(System.today(), assetRelation.RelationEndDate__c);
        }
    }
    
    /*@isTest static void padCanTriggerTest_01(){
        List<Account> auxAcc = [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%'];
        User user = [SELECT Id, Contact.AccountId, ByPassApexTriggers__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        user.ByPassApexTriggers__c = 'AccountContactAssetRelation_BeforeUpdate;AccountContactAssetRelation_BeforeInsert;AccountContactAssetRelation_AfterInsert;AccountContactAssetRelation_AfterUpdate';
        
        update user;
        
        
        system.runas(user){
        	Account b2c = [SELECT Id FROM Account where FirstName = 'Account FirstName'];
            Asset a = [SELECT Id FROM Asset where name = 'Asset Test 1'];


            AccountContactAssetRelation__c assetRelation = (AccountContactAssetRelation__c)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET_RELATION, new map<String, object>{
                'AccountId__c'    				=> b2c.Id,
                'AssetId__c'      				=> a.Id,
                'AccountRole__c'  				=> 'Driver',
                'PosessionChangeConfirmation__c' => true
            }, false);
            
            update assetRelation;
            
            
        }
    }*/

}