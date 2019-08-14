@isTest
public class EmailUtilsTest{
    static testMethod void sendEmail() { 
    	String[] toAddresses = new String[]{'test@test.com'}; 
	    Test.startTest();
	    	EmailUtils.sendEmail(1, toAddresses, 'Display_Name', 'Subject', false, null, 'body');
	    Test.stopTest();    
    }	
}