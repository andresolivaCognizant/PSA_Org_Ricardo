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
	*   @Class : CheckStockReservationTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Jul 2018
	*   @Description    :   Apex Unit test class for CheckStockReservation.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				31 Jul 2018				 Creation.	
	*	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation    
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class CheckStockReservationTest {

    @isTest private static void mainTest(){ 

        Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 3', StageName = '4', Country__c = 'IT');
		insert opp;
        
        Account acc = new Account(Name = 'Test'); 
	   	insert acc;

        SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'          => acc.id,
                    'ReservedVehicle__c'        => false,
                    'SBQQ__ExpirationDate__c'   => system.today()-1,
                    'SBQQ__Status__c'           => 'Draft',
                    'SBQQ__Opportunity2__c'     => opp.Id
                } ,true);   
    	
        //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = acc.id, ReservedVehicle__c = false,SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = 'Draft', SBQQ__Opportunity2__c = opp.Id);
		//insert quote;
        
        SBQQ__Quote__C quote1 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'          => acc.id,
                    'ReservedVehicle__c'        => false,
                    'SBQQ__ExpirationDate__c'   => system.today()-1,
                    'SBQQ__Status__c'           => 'Draft',
                    'SBQQ__Opportunity2__c'     => opp.Id
                } ,true);   
    	
        //SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__Account__c = acc.id, ReservedVehicle__c = true,SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = 'Draft', SBQQ__Opportunity2__c = opp.Id);
		//insert quote1;
        
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = 'X', StockBourse__c = 'X', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = false,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Family = Label.ProductFamilyVersion );      
        Product2 prd1 = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = 'X', StockBourse__c = 'X', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Family = Label.ProductFamilyVersion );        
        Product2 prd2 = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = 'X', StockBourse__c = 'X', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Family = Label.ProductFamilyVersion, Reserved__c = true );

		List<Product2> lProduct = new list<Product2> {prd,prd1,prd2};
        insert lProduct;

        SBQQ__QuoteLine__c oQline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.id,Stock__c=true,SBQQ__Product__c=prd.id);        
        SBQQ__QuoteLine__c oQline1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.id,Stock__c=true,SBQQ__Product__c=prd1.id);        
        SBQQ__QuoteLine__c oQline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.id,Stock__c=true,SBQQ__Product__c=prd2.id);        
        
        List<SBQQ__QuoteLine__c> lQuotes = new list<SBQQ__QuoteLine__c> {oQline,oQline1,oQline2};
        insert lQuotes;

        Test.startTest();
        quote.ReservedVehicle__c = true;
        quote1.ReservedVehicle__c = false;
        try {
            update new List<SBQQ__Quote__c> {quote, quote1};

            CheckStockReservation.reservationProcess(
                new List<SBQQ__Quote__c> {quote},
                new Map<Id,SBQQ__Quote__c>{quote.Id => new SBQQ__Quote__c(
                    Id                  = quote.Id,
                    ReservedVehicle__c  = false
                )}
            );

            CheckStockReservation.cancelreservationProcess(
                new List<SBQQ__Quote__c> {quote1},
                new Map<Id,SBQQ__Quote__c>{quote1.id => new SBQQ__Quote__c(
                    Id                  = quote1.Id,
                    ReservedVehicle__c  = true
                )}
            );

        } catch(Exception e){
        	System.debug('Exception ERROR CheckStockReservation.reservationProcess-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }

        Test.stopTest();
        
    }


}