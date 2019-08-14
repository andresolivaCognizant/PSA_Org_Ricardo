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
@isTest
public class APS017_ServiceTerritoryOpHourTest{
	
	@isTest static void ServiceTerritoryOpHourTest1(){ 
        setupData1();
        
        // Perform test
        Test.startTest();
   			APS017_ServiceTerritoryOpHour pLD = new APS017_ServiceTerritoryOpHour();
			String sSchedule = '0 0 * * * ?';
			System.schedule('Mark Bourse Batch: APS017_ServiceTerritoryOpHour', sSchedule, pLD); 
        Test.stopTest();
        
    } 
    
    
  static void setupData1() { 
   	RecordType	rType = [SELECT Id FROM RecordType WHERE Name like '%Dealer%' LIMIT 1];
	   	
		Account account_Obj											=  new Account(
																		Name				= 'Dealer',
																		RecordTypeId		= rType.Id
																	);

		insert account_Obj;
    BusinessHour__c businesshour_Obj = new BusinessHour__c(Dealer__c = account_Obj.id);
    Insert businesshour_Obj;  
  }
}