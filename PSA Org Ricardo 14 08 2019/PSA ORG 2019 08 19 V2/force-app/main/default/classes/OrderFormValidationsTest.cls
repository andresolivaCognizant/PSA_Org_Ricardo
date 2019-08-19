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
    *   @Class : OrderFormValidationsTest.cls
    *
    *   @Author         :   Raul Barba Tamargo <raul.barbatamarg@ext.mpsa.com>
    *   @Created        :   25 7 2018
    *   @Description    :   Apex Unit test class for FleetRequestValidations.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Raul Barba               25/7/2018                 Creation.  
    *	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation             
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
public class OrderFormValidationsTest {
	
    static testMethod void myUnitTest() {

        
       	List<Account> lstAccts 		= TestDataFactoryUtil.createAccount(2,'B2B');
        Opportunity opp         	=   new Opportunity (
                Name                =   'Test',
                StageName           =   '5',
                AccountId           =   lstAccts[0].Id,
                CloseDate           =   System.today(),
                Activity__c         =   'VN',
            	Segment__c			=	'25',
            	Country__c			= 	'IT'
        );
        insert opp;
        
        SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                'SBQQ__Status__c'  	                => '2',
				'RecordTypeId'			            => Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('OPV OrderForm VO').getRecordTypeId(),
				'SBQQ__Opportunity2__c'	            => opp.Id,
				'SalesManagerValidationFlag__c'		=> true
                } ,true); 
        
        Test.startTest();		
        OrderFormValidations.OrderFormValidation(new list<Opportunity>{opp});
        test.stopTest();

        
    }
}