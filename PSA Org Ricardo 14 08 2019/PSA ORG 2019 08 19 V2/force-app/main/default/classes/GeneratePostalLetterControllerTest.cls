/******************************************************************************************
* Name: 			  GeneratePostalletterControllerTest
* Author: 			  Borja Gay
* Description:		  Test class for GeneratePostalLetterController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		xxxx-xx-xx		        Borja Gay 	         Initial definition.
*           1.1		2019-05-08		        Borja Gay            Covering all methods.
*******************************************************************************************/
@isTest
public with sharing class GeneratePostalLetterControllerTest {
    @TestSetup
    static void setup(){
        EmailTemplate et =(EmailTemplate)TestDataFactoryUtil.createSobject(Constants.SOT_EMAIL_TEMPLATE, new map<String, Object>{
        'Name' => 'TestTemplate',
        'DeveloperName' => 'AP_PT_Test',
        'TemplateType' => 'text',
        'FolderId' => UserInfo.getUserId(),
        'Body' => 'Test {!Case.CaseNumber}',
        'HtmlValue' => 'Test {!Case.CaseNumber}', 
        'IsActive' => true},true);
    }
    @isTest
    private static void getCaseInfoTest(){
        Account acc = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);
        Case cas = (Case)TestDataFactoryUtil.createSobject(Constants.SOT_CASE, new map<String, Object>{
            'Status'                    => CareConstants.CASE_STATUS_OPEN,
            'Origin'                    => CareConstants.CASE_ORIGIN_PHONE,
            'Reason'                    => CareConstants.CASE_REASON_COMPLAINT,
            'AccountId'                 => acc.Id,
            'ContactId'                 => acc.PersonContactId,
            'SuppliedName'              => 'Name',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'PT',
            'Language__c'               => 'PT',
            'Brand__c'                  => 'AC'
        },true);
        Test.startTest();
        List<String> data =GeneratePostalLetterController.getCaseInfo(cas.id);
        System.assertEquals('PT', data[0],'GeneratePostalLetterControllerTest - getCaseInfoTest');
        Test.stopTest();
    }
    @isTest
    private static void getTemplatesTest(){
        Test.startTest();
        String lstPck = GeneratePostalLetterController.getTemplates('PT','AP');
        System.debug(lstPck);
        Boolean template = lstPck.contains('TemplateId');
        System.assertEquals(true, template ,'GeneratePostalLetterControllerTest - getTemplatesTest');
        Test.stopTest();
    }
    @isTest
    private static void loadMergeFieldsTest(){
        Account acc = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);
        Case cas = (Case)TestDataFactoryUtil.createSobject(Constants.SOT_CASE, new map<String, Object>{
            'Status'                    => CareConstants.CASE_STATUS_OPEN,
            'Origin'                    => CareConstants.CASE_ORIGIN_PHONE,
            'Reason'                    => CareConstants.CASE_REASON_COMPLAINT,
            'AccountId'                 => acc.Id,
            'ContactId'                 => acc.PersonContactId,
            'SuppliedName'              => 'Name',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'PT',
            'Language__c'               => 'PT',
            'Brand__c'                  => 'AC'
        },true);
        EmailTemplate et = [SELECT id from EmailTemplate where DeveloperName = 'AP_PT_Test' limit 1];
        
        Test.startTest();
        String body = GeneratePostalLetterController.loadBody(et.id,cas.id);
        Boolean template = body.contains('Test');
        System.assertEquals(true, template ,'GeneratePostalLetterControllerTest - loadMergeFieldsTest');
        Test.stopTest();
    }
}