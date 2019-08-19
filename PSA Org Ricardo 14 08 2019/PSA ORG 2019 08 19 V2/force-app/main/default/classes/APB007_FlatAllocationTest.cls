/**
    *   @Class          : APB007_FlatAllocationTest
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for APB007_FlatAllocation
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APB007_FlatAllocationTest {
	
	@isTest static void APB007_FlatAllocationTest() {
        List<String> lstActivities   =   new List<String>{'VN'};
        List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);          
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstContsA ,'Salesman','Partner','Manager');
        Insert lstUsers;

        Map<Id,Integer> mapIdvalue = new Map<Id,Integer>();
        mapIdvalue.put(lstContsA[0].Id, 0);

        Test.startTest();
	        APB007_FlatAllocation b = new APB007_FlatAllocation(mapIdvalue);
			String sch = '0 0 * * * ?';
			Database.executeBatch(b); 	
        Test.stopTest();

        Contact cont = [SELECT Id, TECH_CounterSalesman__c FROM Contact LIMIT 1];

        System.assertEquals(0, cont.TECH_CounterSalesman__c);
	}
	
}