/**
	*   @Class 			: LC005_CreateRecordControllerTest.cls
	*
	*   @Author         :   Ruben Fernandez Lopez
	*   @Created        :   26 Mar 2018
	*   @Description    :   Apex Unit test class for CustomerSearchAController.csl
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Ruben Fernandez			26/03/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
public with sharing class LC005_CreateRecordControllerTest {
    
    @isTest static void testMethod1(){
        Test.startTest();
            CL002_CreateRecordController.fetchDefaultRecordType('Lead');
           
        Test.stopTest();
    }

    static testMethod void PositiveCaseCreateRecordTest() {

    	Test.startTest();
			CL002_CreateRecordController.fetchRecordTypeValues('Lead');
    		CL002_CreateRecordController.getRecordTypeId('Account','Dealer');	
    	Test.stopTest();

    }


    static testMethod void NegativeCaseCreateRecordTest() {

    	Test.startTest();
			List<String> auxResult 	= CL002_CreateRecordController.fetchRecordTypeValues('');
    		Id auxIDResult 			= CL002_CreateRecordController.getRecordTypeId('','');
    	Test.stopTest();

    }
}