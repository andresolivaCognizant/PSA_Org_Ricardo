/******************************************************************************************
* Name: 			CTITaskCaseRelationTest
* Author: 			Marcos Garcia Garcia
* Description:		Test class for CTITaskCaseRelation class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-08		Marcos Garcia Garcia (MGG)	Initial definition.
*******************************************************************************************/
@isTest 
public class CTITaskCaseRelationTest {

	 /******************************************************************************************************
	 * @Method          : setup
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 08/05/2019
	 * @Description     : Setup Method
	 ******************************************************************************************************/
    @testSetup 
    static void setup() {
        Map<String, Object> mapApiNameToFieldValueAccount = new Map<String, Object>();
    	mapApiNameToFieldValueAccount.put('Name', 'AccountTest');
        TestDataFactoryUtil.createAccount(mapApiNameToFieldValueAccount, true);

        //BULK Cases insert
        List<Case> bulkCases = new List<Case>();
		Account acc = [Select id From Account Where name =: 'AccountTest'];
		for (Integer i=0; i<200; i++){
        	Map<String, Object> mapApiNameToFieldValueCase = new Map<String, Object>();
	    	mapApiNameToFieldValueCase.put('Subject', 'CTITaskCaseRelationTest' + i);
	    	mapApiNameToFieldValueCase.put('Brand__c', 'AC');
	    	mapApiNameToFieldValueCase.put('Country__c', 'ES');
	    	mapApiNameToFieldValueCase.put('Language__c', 'ES');
	    	mapApiNameToFieldValueCase.put('Priority', '1');
	    	mapApiNameToFieldValueCase.put('Reason', '2');
	    	mapApiNameToFieldValueCase.put('AccountId', acc.Id);
	        
	        bulkCases.add((Case)TestDataFactoryUtil.createSobject('Case', mapApiNameToFieldValueCase, false));
        }

        insert bulkCases;
    }

     /******************************************************************************************************
	 * @Method          : testPopulateCaseInfo
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 08/05/2019
	 * @Description     : Positive case - Skill All Values and good format
	 ******************************************************************************************************/
    @isTest
    public static void testPopulateCaseInfo(){
        User u = [Select Id From User where Id =: UserInfo.getUserId()];
    	List<Case> cases = [Select Id From Case Where Subject like '%CTITaskCaseRelationTest%'];

    	System.runAs(u){
    		Map<String, Object> mapApiNameToFieldValueTask = new Map<String, Object>();
	    	mapApiNameToFieldValueTask.put('Skill__c', 'PSA CC Peugeot pt-PT');
	    	mapApiNameToFieldValueTask.put('Type', 'Call');
	    	mapApiNameToFieldValueTask.put('WhatId', cases.get(0).Id);
			Task t = TestDataFactoryUtil.createTask(mapApiNameToFieldValueTask, true);

    		Case cUpdated = [Select Id, Brand__c, Country__c, Language__c From Case Where Id =: cases.get(0).Id];

			System.assertEquals('AP', cUpdated.Brand__c);
			System.assertEquals('PT', cUpdated.Country__c);
			System.assertEquals('PT', cUpdated.Language__c);
    	}
    }

    /******************************************************************************************************
	 * @Method          : testPopulateCaseInfoNonSkillValues
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 08/05/2019
	 * @Description     : Negative case - Bad Formatted Skill__c values
	 * @Comments 		: Si no se incluye Skill o se inserta vacio, peta porque da un null en linea 72 de CTITaskCaseRelation
	 ******************************************************************************************************/
    @isTest
    public static void testPopulateCaseInfoBadSkillFormat(){
        User u = [Select Id From User where Id =: UserInfo.getUserId()];
    	List<Case> cases = [Select Id From Case Where Subject like '%CTITaskCaseRelationTest%'];

    	System.runAs(u){
    		Map<String, Object> mapApiNameToFieldValueTask = new Map<String, Object>();
	    	mapApiNameToFieldValueTask.put('Skill__c', 'PSA CC Peugeot');
	    	mapApiNameToFieldValueTask.put('Type', 'Call');
	    	mapApiNameToFieldValueTask.put('WhatId', cases.get(0).Id);
			Task t = TestDataFactoryUtil.createTask(mapApiNameToFieldValueTask, true);

    		Case cUpdated = [Select Id, Brand__c, Country__c, Language__c From Case Where Id =: cases.get(0).Id];

			System.assertEquals('AC', cUpdated.Brand__c);
			System.assertEquals('ES', cUpdated.Country__c);
			System.assertEquals('ES', cUpdated.Language__c);
    	}
    }

    /******************************************************************************************************
	 * @Method          : testPopulateCaseInfoBulk
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 08/05/2019
	 * @Description     : BULK case - 200 Task inserted 
	 * @Comments 		: Problema debido a que si inserto varias tareas sobre el mismo caso de manera bulk 
						  da un error ya que trata de actualizar en la misma lista el mismo caso 200 veces
	 ******************************************************************************************************/
    @isTest
    public static void testPopulateCaseInfoBulk(){
        User u = [Select Id From User where Id =: UserInfo.getUserId()];
    	List<Case> cases = [Select Id From Case Where Subject like '%CTITaskCaseRelationTest%'];

    	List<Task> bulkTask = new List<Task>();
    	System.runAs(u){
    		for (Integer i=0; i<200; i++){
    			Map<String, Object> mapApiNameToFieldValueTask = new Map<String, Object>();
		    	mapApiNameToFieldValueTask.put('Skill__c', 'PSA CC Peugeot pt-PT');
		    	mapApiNameToFieldValueTask.put('Type', 'Call');
	    		mapApiNameToFieldValueTask.put('WhatId', cases.get(i).Id);
				bulkTask.add(TestDataFactoryUtil.createTask(mapApiNameToFieldValueTask, false));
    		}
    		
    		insert bulkTask;

    		List<Case> cUpdated = [Select Id, Brand__c, Country__c, Language__c From Case Where Id =: cases];

    		for (Case c : cUpdated){
				System.assertEquals('AP', c.Brand__c);
				System.assertEquals('PT', c.Country__c);
				System.assertEquals('PT', c.Language__c);
    		}
    	}
    }
}