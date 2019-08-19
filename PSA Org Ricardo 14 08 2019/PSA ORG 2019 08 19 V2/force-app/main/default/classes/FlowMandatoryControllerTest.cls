@isTest
public class FlowMandatoryControllerTest {
    
    @isTest static void testMethod1(){
        
        Test.startTest();
            FlowMandatoryController.isMandatoryComplete('select id from account where name = \'1234\'');
        	FlowMandatoryController.isMandatoryComplete('select id from user' );
        Test.stopTest();
    }

}