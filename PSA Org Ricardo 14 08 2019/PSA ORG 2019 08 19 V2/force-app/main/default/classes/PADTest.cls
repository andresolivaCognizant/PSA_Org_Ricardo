/*
-- - Name         : PADTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 22/01/2018
-- - Description  : Test class for CSResultAController
--                  1. PADMethodsTest.
--                  2. PADNegativeMethodsTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
private class PADTest {

    /******************************************************************************************************
	* @Method			: setup
	* @Author			: Ruben Fernandez
	* @Created			: 08/07/2019
	* @Description		: Setup Method
	******************************************************************************************************/
    @testSetup static void setup() {

        List<String> lstActivities              =   new List<String>{'VN'};
        List<Contact> lstContsA                 =   TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        
        List<Contact> lstSales                  = new List<Contact>();
        List<Contact> lstASales                 = new List<Contact>();
        lstSales.add(lstContsA.get(0));
        lstSales.add(lstContsA.get(2));
        lstASales.add(lstContsA.get(1));
        List<User> lstUsers1                    =   TestDataFactoryUtil.createUser(lstSales,'Sales_Manager','Partner','Manager');
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstASales,'Aftersales_Manager','Partner','Manager'));
        Insert lstUsers1;
    }
    
    /******************************************************************************************************
	* @Method			: PADMethodsTest
	* @Author			: Ruben Fernandez
	* @Created			: 08/07/2019
	* @Description		: Test for PAD methods.
	******************************************************************************************************/
    public static testMethod void PADMethodsTest() {

        Test.startTest();
            
                //Boolean bByPass =   PAD.CanTrigger('Lead_BeforeInsert');
                String sToken   =   PAD.getToken();
                String sID      =   PAD.getObjRecordType('Account','B2B');
                String sRecID   =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B');
                Boolean bByPass =   PAD.CanTrigger('Account_BeforeInsert');
                String sDMSEnd  =   PAD.getDMSEndpoint('Account');
                Map<String, String> AccountFields   =   PAD.getFieldLabel('Account');
                system.assertEquals(32, sToken.length());
                system.assertEquals(18, sID.length());
                system.assertEquals(sID, sRecID);
                system.assertEquals(true, AccountFields.containsKey('Name'));
        Test.stopTest();
    }

    /******************************************************************************************************
	* @Method			: PADMethodsTest
	* @Author			: Ruben Fernandez
	* @Created			: 08/07/2019
	* @Description		: Test for PAD methods.
	******************************************************************************************************/
    public static testMethod void PADNegativeMethodsTest() {

        Test.startTest();
          
            String sID      =   PAD.getObjRecordType('Account','X');
            String sRecID   =   PAD.getRecordTypeIdByDeveloperName('Account','X');
            system.assertEquals(0, sID.length());
            system.assertEquals(null, sRecID);

        Test.stopTest();
    }
    
    /******************************************************************************************************
	* @Method			: PADMethodsTest
	* @Author			: Ruben Fernandez
	* @Created			: 08/07/2019
	* @Description		: Test for PAD methods.
	******************************************************************************************************/
    public static testMethod void PADUserMethodsTest() {

        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Aftersales_Manager' LIMIT 1];
        String sID;
        String sRecID;
        Boolean bByPass;
        String sDMSEnd;
        System.runAs(usr) {
            Test.startTest();
                sID     =   PAD.getObjRecordType('Account','B2B');
                sRecID  =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B');
                bByPass =   PAD.CanTrigger('Account_BeforeInsert');
                sDMSEnd =   PAD.getDMSEndpoint('Account');
            Test.stopTest();
        }
        system.assertEquals(18, sID.length());
        system.assertEquals(sID, sRecID);
    }
    
    /******************************************************************************************************
	* @Method			: PAD_APIUserTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for PAD methods with an API User.
	******************************************************************************************************/
	public static testMethod void PAD_APIUserTest() {
		User objUser							= [SELECT Id FROM User WHERE Profile.Name = 'Api_Users' AND IsActive = true LIMIT 1];
		
		String strUserType;

		Test.startTest();
			System.runAs( objUser ){
				strUserType						= PAD.sUserTypeCode;
			}

			System.assertEquals( true, strUserType.equals( '3' ) );
		Test.stopTest();
	}
}