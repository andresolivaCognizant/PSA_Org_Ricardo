/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : EnqueueAssetsToInsertTest
  * Project       : PSA - C1ST
  * Author        : Carmen Hernandez    <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 05/23/2019
  * Description   : Test Class EnqueueAssetsToInsert
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         05/23/2019               Creation.      
  *-----------------------------------------------------------------------------------------------------------*/
@istest
public class EnqueueAssetsToInsertTest {
    
    /*********************************************************************************************************
    * @Method          :   makeData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   TestSetup
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @TestSetup
    static void makeData(){
		//Create new Account        
        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            Phone				= '987654321',
            RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
            NonResidentCustomer__pc = true);
        insert b2c;
        //Create new Case
        Case caseTmp = new Case(
            VIN__c = 'VF123456789012345',
            RegistrationNumber__c = '9876654',
            AccountId = b2c.Id,
            Brand__c = 'AP',
            Country__c = 'PT',
            Language__c = 'PT'
        );
        insert caseTmp;
    }
    
    /*********************************************************************************************************
    * @Method          :   EnqueueAssetsToInsert_test_01
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   This method executes EnqueueAssetsToInsert(cases)
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @isTest
    private static void EnqueueAssetsToInsert_test_01(){
        List<Case> cases = [Select Id, VIN__c, RegistrationNumber__c, AccountId, Language__c, Country__c, Brand__c FROM Case];
        Test.startTest();
		EnqueueAssetsToInsert.makeCallout = false;
        System.enqueueJob(new EnqueueAssetsToInsert(cases));
        Test.stopTest();
    }

    /*********************************************************************************************************
    * @Method          :   EnqueueAssetsToInsert_test_02
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   This method verifies that when the reponse=200 an asset is created and mapped correctly
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @isTest
    private static void EnqueueAssetsToInsert_test_02(){
        Case caseTmp = [Select Id, VIN__c, RegistrationNumber__c, AccountId, Language__c, Country__c, Brand__c FROM Case LIMIT 1];
        Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ) );
        Asset assetTmp = EnqueueAssetsToInsert.performCallout(caseTmp); 
        Test.stopTest();
        System.assert(assetTmp != null);
        System.assertEquals(caseTmp.VIN__c, assetTmp.VIN__c);
        System.assertEquals(caseTmp.VIN__c, assetTmp.Name);        
        System.assertEquals(caseTmp.Country__c, assetTmp.Country__c);
        System.assertEquals(caseTmp.Language__c, assetTmp.Language__c);
        System.assertEquals(caseTmp.AccountId, assetTmp.AccountId);
        System.assertEquals(caseTmp.RegistrationNumber__c, assetTmp.LastKnownRegistrationNumber__c);
    }  

    /*********************************************************************************************************
    * @Method          :   EnqueueAssetsToInsert_test_03
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   This method verifies that when the reponse=400 the asset is not created
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @isTest
    private static void EnqueueAssetsToInsert_test_03(){
        Case caseTmp = [Select Id, VIN__c, RegistrationNumber__c, AccountId, Language__c, Country__c, Brand__c FROM Case LIMIT 1];
        Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 400 ) );
        Asset assetTmp = EnqueueAssetsToInsert.performCallout(caseTmp); 
        Test.stopTest();
        System.assert(assetTmp == null);
    }     
}