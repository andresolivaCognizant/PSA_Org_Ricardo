/**
	*   @Class : CSFilterAController_test.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   18 Jan 2018
	*   @Description    :   Apex Unit test class for CSFilterAController.csl
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				18/1/2018				 Creation.	
	*	   Raul Barba				22/1/2018				 Update.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class CSFilterAController_test {

    static testMethod void myUnitTest() {  	
    	Test.startTest();
	    	CSFilterAController.setSelect('B2B');
	        CSFilterAController.setSelect('');
	        CSFilterAController.setSelect(null);
	        CSFilterAController.getLabels('Account');
    	Test.stopTest(); 
    }
}