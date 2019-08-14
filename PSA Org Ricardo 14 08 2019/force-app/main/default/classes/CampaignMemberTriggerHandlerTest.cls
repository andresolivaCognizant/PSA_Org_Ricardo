/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignMemberTriggerHandler test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-30		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest
private class CampaignMemberTriggerHandlerTest {
	
   
	@testSetup
    static void makeData(){
        
        Campaign campaign = TestDataFactoryUtil.createCampaign(new map<String, Object>{
        	'Name'	  		=>	'Template Campaign', 
			'RecordTypeId'	=>	PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        }, true);
        
        
        Lead lead = TestDataFactoryUtil.createLead(new map<String, Object>{
                    'FirstName'                   	=> 'First Name lead 1',
                    'LastName'                    	=> 'Last Name lead 1',
                    'Street'                      	=> 'Calle de Sebastián Elcano',
                    'City'                        	=> 'Madrid',
                    'Country'                     	=> 'España',
                    'PostalCode'                  	=> '12121',
                    'Latitude'                    	=> 39.9691,
                    'Longitude'                   	=> -4.8237,
                    'Phone'                       	=> '0987654321',
                    'NationalId__c'               	=> '25354678A',
                    'DestinationGeographicalCode__c'=> 'accB2B',
                    'DestinationPOSCode__c'       	=> 'AZE123',
                    'Company'                     	=> 'TEST COMPANY_B2B',
                    'PSABrand__c'                 	=> 'DS',
                    'Email'                       	=> 'psaLeadName1@leadexample.com',
                    'LeadCountry__c'              	=>  'DO',
                    'Activity__c'                 	=>  '',
                    'CustomerType__c'             	=> '1',
                    'LeadChannel__c'              	=> '10',
                    'LeadRequestType__c'          	=> '1',
                    'LeadSource'                  	=> 'Partner',
                    'LeadType__c'                 	=> '1',
                    'MarketingCode__c'            	=> '01234567899876543210',
                    'RecordTypeId'                	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2B)
        }, true);
        
        
        Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'					=> 'TEST MATCH 26',
			'Phone'					=> '+8434334',
			'BillingPostalCode'		=> '23456',
			'RecordTypeId'			=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);
		
		
		
        
        Contact contact = TestDataFactoryUtil.createContact(new map<String, object>{
            'AccountId'				=> account.id,
			'FirstName'				=> 'Contact FirstName',
			'LastName'				=> 'Contact LastName',
			'Salutation'			=> '1',
			'Phone'					=> '9867767',
			'ACAnonymization__c'	=> true,
			'APAnonymization__c'	=> true,
			'DSAnonymization__c'	=> false,
			'TECH_OptOut__c'		=> true
        }, true);
		
	}
    
    @isTest
    static void campaignMemeberTriggerLeadBeforeInsert_Test(){
        Lead lead = [Select id from Lead limit 1];
        Campaign campaign = [Select id from Campaign limit 1];
        
        

		CampaignMember objLeadMember					= new CampaignMember();
		objLeadMember.LeadId							= lead.Id;
		objLeadMember.CampaignId						= campaign.Id;
        
        Test.startTest();
        insert objLeadMember;
		Test.stopTest();
      	
    }
    
    @isTest
    static void campaignMemeberTriggerContactBeforeInsert_Test(){
        Lead lead = [Select id from Lead limit 1];
        Campaign campaign = [Select id from Campaign limit 1];
        Contact contact = [Select id from Contact limit 1];
        
        Test.startTest();
		
		CampaignMember objContactMember					= new CampaignMember();
		objContactMember.ContactId						= contact.Id;
		objContactMember.CampaignId						= campaign.Id;
		
		insert objContactMember;

		Test.stopTest();
    }
}