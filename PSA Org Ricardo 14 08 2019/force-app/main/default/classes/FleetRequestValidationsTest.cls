/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

/**
    *   @Class : FleetRequestValidationsTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   20 6 2018
    *   @Description    :   Apex Unit test class for FleetRequestValidations.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             20/6/2018                 Creation.  
    *	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation            
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class FleetRequestValidationsTest {

    private final static Id RT_OPPORTUNITYFLEET             = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FleetRequestOpportunity').getRecordTypeId();
    private final static Id RT_QUOTEFLEET                   = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('FleetRequestQuote').getRecordTypeId();

    static testMethod void myUnitTest() {

        
       	List<Account> lstAccts 		= TestDataFactoryUtil.createAccount(2,'B2B');
        lstAccts[0].AccountType__c = '1';
        lstAccts[0].CompanyActivityType__c= '1';
        lstAccts[0].country__c= 'AF';
        update lstAccts[0];
        Opportunity opp         	=   new Opportunity (
                Name                =   'Test',
                StageName           =   'FR1',
                AccountId           =   lstAccts[0].Id,
                CloseDate           =   System.today(),
                Activity__c         =   'VN',
                RecordTypeId        =   RT_OPPORTUNITYFLEET,
            	Country__c			=	'AF'
        );
        insert opp;
		
        AccountFleet__c oAccFleet	= new AccountFleet__c(VolumeOfVehicles__c = 6 , Account__c = opp.accountid);
        INSERT oAccFleet;
        AccountFleet__c oAccFleet2	= new AccountFleet__c(VolumeOfVehicles__c = 16 , Account__c = opp.accountid);
        INSERT oAccFleet2;
        
        SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Opportunity2__c' => opp.id,
                    'recordtypeid'  => RT_QUOTEFLEET
                } ,true);

        
        Test.startTest();	
        FleetRequestValidations.quoteValidateEdition(new List<SBQQ__Quote__c>{oQuote}, new map<id,SBQQ__Quote__c>{oQuote.id => oQuote});
        FleetRequestValidations.quoteValidateInsert(new List<SBQQ__Quote__c>{oQuote});
        FleetRequestValidations.minParkValidation(new list<Opportunity>{opp});
        test.stopTest();

    }

    @isTest static void testMethod1(){
        List<Account> lstA = TestDataFactoryUtil.createAccount(2,'B2B');
            lstA.get(0).AccountType__c          = '1';
            lstA.get(0).CompanyActivityType__c  = '1';
            lstA.get(0).Country__c              = 'AF';
        update lstA;

        Opportunity o = new Opportunity(
            Name                = 'Test',
            StageName           = 'FR1',
            AccountId           = lstA.get(0).Id,
            CloseDate           = System.today(),
            Activity__c         = 'VN',
            RecordTypeId        = RT_OPPORTUNITYFLEET,
            Country__c          = 'AF'
        );
        insert o;
        
        insert new List<AccountFleet__c>{
            new AccountFleet__c(
                VolumeOfVehicles__c = 6,
                Account__c = o.AccountId
            ),
            new AccountFleet__c(
                VolumeOfVehicles__c = 16,
                Account__c = o.AccountId
            )
        };

        
         SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Opportunity2__c' => o.id,
                    'RecordTypeId'  => RT_QUOTEFLEET
                } ,true);

        Test.startTest();
            FleetRequestValidations.minParkValidationEdition(
                new List<Opportunity>{o},
                new Map<Id, Opportunity>{
                    o.Id => new Opportunity(
                        Id          = o.Id,
                        Segment__c  = '1'
                    )
                }
            );
        Test.stopTest();
    }
}