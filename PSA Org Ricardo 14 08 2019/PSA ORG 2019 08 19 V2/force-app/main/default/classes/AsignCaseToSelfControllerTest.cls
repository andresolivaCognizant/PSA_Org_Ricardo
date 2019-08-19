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
*******************************************************************************************/
@isTest
public class AsignCaseToSelfControllerTest {
    @TestSetup
    static void setup(){
        List<Profile> lstP = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name='System Administrator'
        ]);
        User us = (User)TestDataFactoryUtil.createSobject(Constants.SOT_USER,new map<String,Object>{
                'LastName'            => 'Test',
                'Email'               => 'asigncasetoself@testclass.com',
                'Alias'               => 'test',
                'TimeZoneSidKey'      => 'GMT',
                'LocaleSidKey'        => 'en_GB',
                'EmailEncodingKey'    => 'ISO-8859-1',
                'ProfileId'           => lstP.get(0).Id,
                'LanguageLocaleKey'   => 'en_US',
                'UserName'            => 'asigncasetoself@testclass.com',
                'Country__c'          => 'PT',
                'Brand__c'            => 'AP',
                'VNRRDICode__c'       => '12345'
        },true);
        Group g1 =(Group)TestDataFactoryUtil.createSobject(Constants.SOT_GROUP, new map<String, Object>{
        'Name' => 'TestQueue',
        'Type' => 'Queue'
        },true);
        QueuesObject q1 =(QueuesObject)TestDataFactoryUtil.createSobject(Constants.SOT_QUEUES_OBJECT, new map<String, Object>{
        'QueueID' => g1.id,
        'SobjectType' => 'Case'
        },true);

    }

    @isTest
    private static void asignCaseToSelfTest(){
        List<Group> lstGr = [SELECT id FROM Group WHERE Name = 'TestQueue'];
        User us = [SELECT id FROM User WHERE Username ='asigncasetoself@testclass.com' LIMIT 1];
        Account acc = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'Email__c'              => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);
        Case cas = (Case)TestDataFactoryUtil.createSobject(Constants.SOT_CASE, new map<String, Object>{
            'Status'                    => CareConstants.CASE_STATUS_OPEN,
            'Origin'                    => CareConstants.CASE_ORIGIN_WEBFORM,
            'Reason'                    => CareConstants.CASE_REASON_COMPLAINT,
            'AccountId'                 => acc.Id,
            'ContactId'                 => acc.PersonContactId,
            'SuppliedName'              => 'Name LastName',
            'SuppliedEmail'             => 'b2ctestMethod2@test.com',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'PT',
            'Language__c'               => 'PT',
            'Brand__c'                  => 'AP',
            'OwnerId'                   => lstGr[0].id
        },true);
        system.runAs(us){
            Test.startTest();
                System.debug(cas.Status);
                Boolean result = AsignCaseToSelfController.asignCaseToSelf(cas.id);
                System.assertEquals(true, result, 'AsignCaseToSelfControllerTest - asignCaseToSelfTest');
            Test.stopTest();
        }
    }

}