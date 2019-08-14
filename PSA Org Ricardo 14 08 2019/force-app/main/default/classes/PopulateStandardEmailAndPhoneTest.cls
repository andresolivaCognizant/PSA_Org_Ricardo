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
	*   @Class : PopulateStandardEmailAndPhoneTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Feb 2018
	*   @Description    :   Apex Unit test class for PopulateStandardEmailAndPhoneTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				19 Feb 2018				 Creation.	
    *      Pedro Parraga            17 Jun 2019              Edit.
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
public class PopulateStandardEmailAndPhoneTest {
    static testMethod void myUnitTest() {
        
        Account accB2B = new Account(
                Name                                          =   'TEST MATCH B2B',
                Phone                                         =   '+843434',
                BillingPostalCode                             =   '234563',
                FiscalId__c                                   =   '123111',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );
        
        insert accB2B;
        
        Account accB2C = new Account(
                Firstname                                     =   'TEST MATCH B2C',
            	Salutation									  =	  '1',
            	LastName									  =	  'V2',
                BillingPostalCode                             =   '29956',
                LocalIdOfCustomer__c                          =   '987732',
                PersonalEmail__pc							  =   'test@test.com',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
        );
        
        insert accB2C;
   		
        accB2C.LandlinePersonalTelephone__pc='9867767';
        accb2c.MobilePersonalTelephone__pc='9867767';
        update accB2C;
        
        Contact cnt             			=   new Contact (
                FirstName           		=   'Contact_FirstName_Test',
                LastName            		=   'Contact_LastName_Test',
                Salutation          		=   '1',
                ProfessionalEmail__c		=   'test@test.com',           	
                AccountId           		=   accB2B.Id,
            	RecordTypeId				=	Schema.SObjectType.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId()
        );
        
        insert cnt;
        
        cnt.LandlineProfessionalTelephone__c='9867767';
        cnt.MobileProfessionalTelephone__c  ='9867767';
        
        update cnt;
        List<sObject> lSObjects = new List<sObject>();
        lSObjects.add(cnt);
        lSObjects.add(accB2C);
        lSObjects.add(accB2B);
        
        Map<Id,sObject> mapIdSobj = new Map<Id,sObject>();
        mapIdSobj.put(cnt.id,cnt);
        mapIdSobj.put(accB2C.id,accB2C);
        mapIdSobj.put(accB2B.id,accB2B);
        
        
        Test.startTest();
        PopulateStandardEmailAndPhone.setEmailAndPhone(lSObjects,mapIdSobj);
        PopulateStandardEmailAndPhone.setEmailAndPhone(lSObjects,null);
        Test.stopTest();
    }
    
    
}