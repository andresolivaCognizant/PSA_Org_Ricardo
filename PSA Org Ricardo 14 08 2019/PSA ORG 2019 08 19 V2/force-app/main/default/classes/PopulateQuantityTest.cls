/******************************************************************************************
* Name: 			PopulateQuantityTest
* Author: 			---------
* Description:		---------
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		---------		---------          		Initial definition.
 			1.1		2019-07-11		Nerea Leguinazabal		#C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
*******************************************************************************************/
@isTest
private class PopulateQuantityTest {
    
    static testMethod void myUnitTest() {
        
        id rt = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId();
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2', FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;        
        
        SBQQ__Quote__C quote1 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
            'ReservedVehicle__c'  	=> false,
            'RecordTypeId'			=> rt,
            'SBQQ__Opportunity2__c'	=> opp.Id,
            'SBQQ__Account__c'		=> acc2.id
            } ,true);   
        
        Test.startTest();
        PopulateQuantity.setQuantity(new List<SBQQ__Quote__c> {quote1});
        Test.stopTest();
    }

}