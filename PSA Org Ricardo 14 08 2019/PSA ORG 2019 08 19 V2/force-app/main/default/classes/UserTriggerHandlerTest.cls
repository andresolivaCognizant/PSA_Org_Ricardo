/**
	*   @Class : UserTriggerHandlerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 March 2018
	*   @Description    :   Test for UserTriggerHandler Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/3/2018				 Creation.	
    *      Pedro Párraga            11/06/2019               Edit.	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class UserTriggerHandlerTest {
    
    @isTest static void populatedPublicGroup() {
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(8,'Dealer');

        for(Account acc : lstAccts){        
            acc.VNContractBeginDate__c = date.today().addDays(-1);
            acc.VNContractEndDate__c = date.today().addDays(1);
            acc.IsPartner = true;
        }

        lstAccts.get(0).VNPrincipalSite__c = true;
        lstAccts.get(0).VNContractNumber__c = '1010';
        lstAccts.get(1).VNContractNumber__c = '1010';
        lstAccts.get(3).VNPrincipalSite__c = true;
        lstAccts.get(3).VNContractNumber__c = '1111';
        lstAccts.get(3).Country__c = 'ES';
        lstAccts.get(4).VNContractNumber__c = '1010';
        lstAccts.get(4).TECH_PublicGroups__c = '0000000';
        lstAccts.get(5).VNContractNumber__c = '1010';
        lstAccts.get(5).TECH_PublicGroups__c = '0000000';
        lstAccts.get(6).TECH_PublicGroups__c = '0000000';
        lstAccts.get(0).SiteGeoIdPK__c = '1010101';
        lstAccts.get(3).SiteGeoIdPK__c = '1111111';      
        lstAccts.get(7).VNContractBeginDate__c = null;
        lstAccts.get(7).VNContractEndDate__c = null;
        lstAccts.get(7).IsPartner = false;

		update lstAccts;

        PartnerAccountLink__c part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(2).Id
        );

		insert part;


        part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(5).Id
        );

		insert part;

        part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(6).Id
        );

		insert part;
        
        Contact cnt1             =   new Contact (
                    FirstName           =   'First Name 1',
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName1@contactexample.com',
                    NationalId__c       =   '12345678C',
                    Phone               =   '123456789',
                    AccountId           =   lstAccts.get(0).Id
        );

        Contact cnt2             =   new Contact (
                    FirstName           =   'First Name 2',
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName2@contactexample.com',
                    NationalId__c       =   '12345679C',
                    Phone               =   '123456789',
                    AccountId           =   lstAccts.get(1).Id
        );

        insert cnt1;
        insert cnt2;
        
        Contact cnt3             =   new Contact (
                    FirstName           =   'First Name 2',
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName2@contactexample.com',
                    NationalId__c       =   '12345671C',
                    Phone               =   '123456789',
                    AccountId           =   lstAccts.get(7).Id
        );

        insert cnt3;
        
        lstAccts.remove(6);
        
        // Perform test
        Test.startTest();
        	List<Contact> lstConts1 = [SELECT Id FROM Contact WHERE Id = : cnt1.Id];
        	List<Contact> lstConts2 = [SELECT Id FROM Contact WHERE Id = : cnt2.Id];
        	List<Contact> lstConts3 = [SELECT Id FROM Contact WHERE Id = : cnt3.Id];
        	UserTriggerHandler.dontRunTrigger();
        Test.stopTest();

    }

}