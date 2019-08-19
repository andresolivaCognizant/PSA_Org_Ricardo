/******************************************************************************************
* Name: 			  UpdateVINControllerTest
* Author: 			  Borja Gay
* Description:		  Test class for UpdateVINController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		xxxx-xx-xx		        Borja Gay 	         Initial definition.
*           1.1		2019-05-08		        Borja Gay            Covering all methods. Cover: 98%
*           1.2     2019-06-11              Pedro Parraga        Covering all methods. Cover: 99%
*******************************************************************************************/
@isTest
public with sharing class UpdateVINControllerTest {

    
    @TestSetup static void setup(){
        Account account = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'          => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
            }, true);

        Case cas = (Case)TestDataFactoryUtil.createSobject(Constants.SOT_CASE, new map<String, Object>{
            'Status'                    => CareConstants.CASE_STATUS_OPEN,
            'Origin'                    => CareConstants.CASE_ORIGIN_PHONE,
            'Reason'                    => CareConstants.CASE_REASON_COMPLAINT,
            'AccountId'                 => account.Id,
            'SuppliedName'              => 'Name',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'PT',
            'Language__c'               => 'PT',
            'Brand__c'                  => 'AC'
        },true);


        Asset vehicle1 = (Asset)TestDataFactoryUtil.createSobject(Constants.SOT_ASSET, new map<String, Object>{
                'Name'                => 'Asset Test 1',
                'AssetType__c'        => 'VN',
                'CurrencyIsoCode'     => 'EUR',
                'VIN__c'                 => 'AAAAAAAAAAAAAAAAA'
            }, true);
    }

	
    @isTest static void getVINInfoTest(){
        List<Account> lstAcc = [SELECT Id FROM Account];
        List<Asset> lstAss = [SELECT Id, VIN__c FROM Asset];

        Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ) );
            UpdateVINController.Int91Result res;
            Test.startTest(); 
            String result = UpdateVINController.getVINInfo(lstAss[0].Id, lstAss[0].VIN__c, 'pt', 'PT', 'AC',lstAcc[0].Id);
            res = (UpdateVINController.Int91Result)JSON.deserialize(result,UpdateVINController.Int91Result.class);         
        Test.stopTest();

        System.assertEquals(res.result,'200','UpdateVINControllerTest - getVINInfoTest1');
    }

    
    @isTest static void getVINInfoTest2(){
        List<Account> lstAcc = [SELECT Id FROM Account];

        Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ) );
            UpdateVINController.Int91Result res;
            Test.startTest(); 
            String result = UpdateVINController.getVINInfo('', 'BBBBBBBBBBBBBBBBB', 'pt', 'PT', 'AC',lstAcc[0].Id);
            res = (UpdateVINController.Int91Result)JSON.deserialize(result,UpdateVINController.Int91Result.class);
        Test.stopTest();

        System.assertEquals(res.result,'200','UpdateVINControllerTest - getVINInfoTest2');
    }

     
    @isTest static void getVINInfoTest3(){
        List<Account> lstAcc = [SELECT Id FROM Account];

        Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 404 ) );
            UpdateVINController.Int91Result res;
            Test.startTest(); 
            String result = UpdateVINController.getVINInfo('', 'BBBBBBBBBBBBBBBBB', 'pt', 'PT', 'AC',lstAcc[0].Id);
            res = (UpdateVINController.Int91Result)JSON.deserialize(result,UpdateVINController.Int91Result.class);
        Test.stopTest();

        System.assertEquals(res.result,'404','UpdateVINControllerTest - getVINInfoTest3');
    }

    
    @isTest static void getInfoCaseTest(){
        List<Account> lstAcc = [SELECT Id FROM Account];
        List<Case> lstCas = [SELECT Id FROM Case];
        List<Asset> lstAss = [SELECT Id, VIN__c FROM Asset];

        Test.startTest(); 
            UpdateVINController.getInfoCase(lstCas[0].Id);
            UpdateVINController.getCaseVIN(lstCas[0].Id);
            UpdateVINController.updateVIN(lstCas[0].Id, lstAss[0].Id);
            List<Case> lstCase = [SELECT Id, AssetId from Case where Id = : lstCas[0].Id];
        Test.stopTest();

        System.assertEquals(lstAss[0].Id, lstCase[0].assetId,'UpdateVINControllerTest - getInfoCaseTest');
    }

}