/**
*   @Class 			: CustomerPortalThemeControllerTest
*   @Author         : Ruben Fernandez
*   @Created        : 07 May 2019
*   @Description    : Test class for CustomerPortalThemeController
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer           		Date                    Description
* 	   Ruben Fernandez			07/05/2019				Creation:
*														- getUserCountryAndLangGuestUserTest
*														- getUserCountryAndLangAdminUserTest
*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest 
public class CustomerPortalThemeControllerTest {
    /**
    * This test method is used to guest users
    * Conditions: Run as Guest User
    */
	@isTest 
    static void getUserCountryAndLangGuestUserTest(){
        // Setup: Run as Guest User. Create User and Assign
        String sCountryLang;
        User usr          = [SELECT Id, Contact.AccountId,Profile.UserLicense.Name FROM User WHERE Profile.UserLicense.Name = 'Guest User License' LIMIT 1];        
        System.runAs(usr) {      
        	Test.startTest();
        		sCountryLang = CustomerPortalThemeController.getUserCountryAndLang();
        	Test.stopTest();
        }
        System.assertEquals('guest', sCountryLang);
    }
    /**
    * This test method is used to test logged users
    * Conditions: Run as logged user
    */
    @isTest 
    static void getUserCountryAndLangAdminUserTest(){

        String sCountryLang;
        Test.startTest();
        	sCountryLang = CustomerPortalThemeController.getUserCountryAndLang();
        Test.stopTest();
        System.assertEquals(5, sCountryLang.length());
    }
}