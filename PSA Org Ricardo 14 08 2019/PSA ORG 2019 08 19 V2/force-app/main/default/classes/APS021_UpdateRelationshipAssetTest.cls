/**
*   @Class          :   APS021_UpdateRelationshipAssetTest
*   @Author         :   Nerea Leguinazabal
*   @Created        :   09/07/2019
*   @Description    :   Test class for APS021_UpdateRelationshipAsset
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Nerea Leguinazabal 09/07/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 

@isTest
public class APS021_UpdateRelationshipAssetTest {

    @isTest static void APS021_UpdateRelationshipAssetTest(){ 
        
        Test.startTest();
            //create accounts
            List<Account> accLst = new List<Account>();
            for (Integer i=0;i<100;i++) {
                Account acc = new Account(
                    Name                =   'TESTB2B_'+i,
                    FiscalId__c         =   '30.686.957-'+i,
                    RecordTypeId      	=   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B')
                );
                accLst.add(acc);
                
            }
            insert accLst;
        
            //Create Assets
            TestDataFactoryUtil.createAssetBulk(100,accLst.get(0));

            // Schedule the test job
	        APS021_UpdateRelationshipAsset sch = new APS021_UpdateRelationshipAsset();
            //scheduled once everyday 
			String sSchedule = '0 0 0 * * ?';
			String jobId = System.schedule('Update AccountContactAssetRelation__c Batch: APS021_UpdateRelationshipAsset', sSchedule, sch);

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
			System.assertEquals(sSchedule, ct.CronExpression);
 

        Test.stopTest();
		
		// Check schedulable is in the job list
		List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
		System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
		System.assertEquals('APS021_UpdateRelationshipAsset', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

		// check apex batch is in the job list
		List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
		System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
		System.assertEquals('APB021_UpdateAssetAccountRelationship', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');

		
        
    } 

  	
}