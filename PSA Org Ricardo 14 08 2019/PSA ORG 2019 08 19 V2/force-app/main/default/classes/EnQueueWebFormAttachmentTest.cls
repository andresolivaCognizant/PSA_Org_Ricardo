/******************************************************************************************
* Name: 			  EnQueueWebFormAttachmentTest
* Author: 			  Borja Gay
* Description:		  Test class for EnQueueWebFormAttachment class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		2019-05-15		        Borja Gay 	         Initial definition.
*******************************************************************************************/
@isTest
public with sharing class EnQueueWebFormAttachmentTest {
@isTest
    static void enqueueAttachmentTest(){
        Account account = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
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
            'AccountId'                 => account.Id,
            'SuppliedName'              => 'Name',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'PT',
            'Language__c'               => 'PT',
            'Brand__c'                  => 'AC'
        },true);
        Attachment att = (Attachment) TestDataFactoryUtil.createSobject(Constants.SOT_Attachment, new Map<String,Object>{
            'Name'      => 'Unit Test Attachment',
            'body'      => Blob.valueOf('Unit Test Attachment Body'),
            'parentId'  => cas.id
        },false);
        List<Attachment> lstAtt = new List<Attachment>();
        lstAtt.add(att);
        Test.startTest();
            System.enqueueJob(new EnQueueWebFormAttachment(lstAtt));
        Test.stopTest();
        List<Attachment> lstAttFinal = [SELECT id from Attachment where ParentId = :cas.id];
        System.assertEquals(1,lstAttFinal.size(),'EnQueueWebFormAttachmentTest - enqueueAttachmentTest');
    }
}