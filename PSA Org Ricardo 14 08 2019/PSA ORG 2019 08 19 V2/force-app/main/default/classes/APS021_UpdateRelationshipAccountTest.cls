/**
*   @Class          :   APS021_UpdateRelationshipAccountTest
*   @Author         :   Nerea Leguinazabal
*   @Created        :   3/07/2019
*   @Description    :   Test class for APS021_UpdateRelationshipAccount
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Nerea Leguinazabal 3/07/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 

@isTest
public class APS021_UpdateRelationshipAccountTest {
    
    @testSetup static void setupCommonData(){

        //Create User with Bypass 
        User creatorDataSetUser = TestDataFactoryUtil.createOneUser('System Administrator', 'PSA', 'AP', 'PL', '9876543');
        creatorDataSetUser.ByPassApexTriggers__c = 'AllObjects_All_Interfaces';
        insert creatorDataSetUser;
        
        //create accounts
        System.runAs(creatorDataSetUser){
            List<Account> accLst = new List<Account>();
            for (Integer i=0;i<200;i++) {
                Account acc = new Account(
                    Name                =   'TESTB2B_'+i,
                    FiscalId__c         =   '30.686.957-'+i,
                    RecordTypeId      	=   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B')
                );
                accLst.add(acc);
            }
            insert accLst;                    
        }
    }

    @isTest static void APS021_UpdateRelationshipAccountTest(){ 
        
        List<Account> accLst = [SELECT Id FROM Account];
        
         Test.startTest();
            //Create Assets
            TestDataFactoryUtil.createAssetBulk(200,accLst.get(0));

            // Schedule the test job
	        APS021_UpdateRelationshipAccount sch = new APS021_UpdateRelationshipAccount();
            //scheduled once everyday 
			String sSchedule = '0 0 0 * * ?';
			String jobId = System.schedule('Update AccountContactAssetRelation__c Batch: APS021_UpdateRelationshipAccount', sSchedule, sch);

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
			System.assertEquals(sSchedule, ct.CronExpression);
 

        Test.stopTest();
		
		// Check schedulable is in the job list
		List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
		System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
		System.assertEquals('APS021_UpdateRelationshipAccount', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

		// check apex batch is in the job list
		List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
		System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
		
		/**

		//Asserts
		List<AccountContactAssetRelation__c> relationLst = [SELECT 	
																	AccountId__r.TECH_FiscalId__c,
																	AccountId__r.LandlinePersonalTelephone__pc,
																	AccountId__r.PersonEmail,
																	AccountId__r.Name,
																	AccountId__r.BillingPostalCode,
																	TECH_AssetVIN__c,
																	TECH_AssetModel__c,
																	TECH_AssetLastKnownRegistrationNumber__c,
																	TECH_AccountName__c,
																	TECH_AccountFiscalID__c,
																	TECH_AccountPhone__c,
																	TECH_AccountEmail__c,
																	TECH_AccountBillingPostalCode__c,
																	AccountId__r.LandlineProfessionalTelephone__pc,
																	AccountId__r.MobilePersonalTelephone__pc,
																	AccountId__r.MobileProfessionalTelephone__pc,
																	AccountId__r.Phone 	
																	FROM AccountContactAssetRelation__c WHERE AccountId__c IN :accLst];
		System.debug('##########relationLst:'+relationLst);
		//Verify changes in Accounts
        for (AccountContactAssetRelation__c acRelation: relationLst) {
				System.assertEquals(acRelation.AccountId__r.Name,acRelation.TECH_AccountName__c);
				System.assertEquals(acRelation.AccountId__r.TECH_FiscalId__c,acRelation.TECH_AccountFiscalID__c);
				System.assertEquals(acRelation.AccountId__r.PersonEmail,acRelation.TECH_AccountEmail__c);
				System.assertEquals(acRelation.AccountId__r.BillingPostalCode,acRelation.TECH_AccountBillingPostalCode__c);
		}
		
		**/
		
        
    } 

  	
}