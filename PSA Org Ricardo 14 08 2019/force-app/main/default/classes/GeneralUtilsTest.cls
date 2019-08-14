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
    *   @Class : GeneralUtilsTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   13 Feb 2018
    *   @Description    :   Apex Unit test class for GeneralUtilsTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             13/2/2018                 Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class GeneralUtilsTest {

    static testMethod void myUnitTest() {
  
        test.startTest();
        
        GeneralUtils.removeAccents(null);
        GeneralUtils.removeAccents('Test');
        GeneralUtils.sendEmail('Test@example.com', 'Test' , 'Test method');
        System.assertEquals(GeneralUtils.removeAccents('áéíóú'), 'aeiou');

        test.stopTest();

        
    }
}