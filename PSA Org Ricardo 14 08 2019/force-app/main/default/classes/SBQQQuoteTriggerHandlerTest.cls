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
    *   @Class : SBQQQuoteTriggerHandlerTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   20 6 2018
    *   @Description    :   Apex Unit test class for SBQQQuoteTriggerHandler.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *       Developer                 Date                     Description
    *       Rubén Moreno              20/6/2018                Creation.  
    *       Nerea Leguinazabal        11 07 2019               #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
    *       Andrés Oliva              12/08/2019               Test methods included: TestInsertQuotes, TestupdateQuotesStautusChange , TestNoTaskCreated
    *   ----------------------------------------------------------------------------------------------------------------------------
**/ 

@isTest
public class SBQQQuoteTriggerHandlerTest {
    /*
    @isTest static void myUnitTest() {
        List<Account> lstAccts 		= TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'Proposal', 75);
		//SBQQ__Quote__c oQuote 		= new SBQQ__Quote__c(Type__c='VN', SBQQ__Opportunity2__c = lstOpps[0].id);

		SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Opportunity2__c'		    => lstOpps[0].id,
            'SalesManagerValidationFlag__c' => false     
		} ,true); 
        
        oQuote.SalesManagerValidationFlag__c = true;
        update oQuote;
        
        Test.startTest();
        SBQQQuoteTriggerHandler.afterInsert(new List<SBQQ__Quote__c>{oQuote});
        SBQQQuoteTriggerHandler.afterUpdate(new List<SBQQ__Quote__c>{oQuote}, new map<Id,SBQQ__Quote__c>{oQuote.id => oQuote});
        SBQQQuoteTriggerHandler.beforeInsert(new List<SBQQ__Quote__c>{oQuote});
        SBQQQuoteTriggerHandler.beforeUpdate(new List<SBQQ__Quote__c>{oQuote}, new map<Id,SBQQ__Quote__c>{oQuote.id => oQuote});
        SBQQQuoteTriggerHandler.dontRunTrigger();
        Test.stopTest();

    }
    /*
     * @Method          :   beforeInsert
     * @Author          :   Andres Oliva <andres.oliva@cognizant.com>
     * @Created         :   09/08/2019
     * @Description     :   Test trigger in the before insert process.==> This trigger created a task with the subject  "Call customer with Quote with 2 days from created" 
     */		
  
    @isTest static void TestInsertQuotes() {
        // Test data setup

        List<Account>       lstAccts    =   TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity>   lstOpps     =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'9', 75);
        recordType objRecortypeQuote =   [  SELECT DeveloperName,
                                                    Id 
                                            FROM    RecordType 
                                            WHERE   SobjectType = 'SBQQ__Quote__C' 
                                                    AND DeveloperName = 'OPV_Quote'];
        Test.startTest();
            SBQQ__Quote__C objQuote =   new SBQQ__Quote__C();
            objQuote.SBQQ__Opportunity2__c  =   lstOpps[0].id;            
            objQuote.SBQQ__Account__c       =   lstAccts[0].id;
            objQuote.recordtypeId           =   objRecortypeQuote.Id;
            objQuote.SBQQ__Status__c        =   '2';
            insert objQuote;
        
        Test.stopTest();
        system.debug('\n quote after before trigger @@@@@ ' +  objQuote );
        system.debug('task created' + [SELECT ID,Type,Subject FROM task WHERE whatId=:objQuote.SBQQ__Opportunity2__c]);
        system.assertEquals( system.Label.AutomaticContactTaskSubjectQuote, [SELECT Subject FROM task WHERE whatId=:objQuote.SBQQ__Opportunity2__c].Subject);
    }
      /*
     * @Method          :   TestupdateQuotesStautusChange
     * @Author          :   Andres Oliva <andres.oliva@cognizant.com>
     * @Created         :   09/08/2019
     * @Description     :   Test trigger in the before Update process.==> This trigger created a task with the subject  "Call customer with Quote with 2 days from created" 
     */		

    @isTest static void TestupdateQuotesStautusChange() {
        // Test data setup
        // Test data setup
        SBQQQuoteTriggerHandler.runTrigger();
        List<Account>       lstAccts    =   TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity>   lstOpps     =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'9', 75);
        recordType objRecortypeQuote =   [  SELECT DeveloperName,
                                                    Id 
                                            FROM    RecordType 
                                            WHERE   SobjectType = 'SBQQ__Quote__C' 
                                                    AND DeveloperName = 'OPV_Quote'];
     
        SBQQ__Quote__C objQuote =   new SBQQ__Quote__C();
        objQuote.SBQQ__Opportunity2__c  =   lstOpps[0].id;            
        objQuote.SBQQ__Account__c       =   lstAccts[0].id;
        objQuote.recordtypeId           =   objRecortypeQuote.Id;
        objQuote.SBQQ__Status__c        =   '1';
        objQuote.SalesManagerValidationFlag__c   =false; 
        insert objQuote;
        
        Test.startTest();            
            objQuote.SBQQ__Status__c                   =   '2';
            objQuote.SalesManagerValidationFlag__c     =   true;
            update  objQuote;
        Test.stopTest();
        system.debug('\n quote after before trigger @@@@@ ' +  objQuote );
        list<task> lstTask = [SELECT ID,Type,Subject FROM task WHERE whatId=:objQuote.SBQQ__Opportunity2__c];
        system.assertEquals( 0, lstTask.size() );
    }


    /*
    * @Method          :   TestNoTaskCreated
    * @Author          :   Andres Oliva <andres.oliva@cognizant.com>
    * @Created         :   09/08/2019
    * @Description     :   This method verify no task creation in quote trigger 
    */		

    @isTest static void TestNoTaskCreated()
    {
        

        List<Account>       lstAccts    =   TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity>   lstOpps     =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'9', 75);
        system.debug('\n opportunity test record @@@' + lstOpps); 
        recordType objRecortypeQuote =   [  SELECT DeveloperName,
                                                    Id 
                                            FROM    RecordType 
                                            WHERE   SobjectType = 'SBQQ__Quote__C' 
                                                    AND DeveloperName = 'OPVOrderFormVN'];
     
        Test.startTest();  
            SBQQ__Quote__C objQuote =   new SBQQ__Quote__C();
            objQuote.SBQQ__Opportunity2__c  =   lstOpps[0].id;            
            objQuote.SBQQ__Account__c       =   lstAccts[0].id;
            objQuote.recordtypeId           =   objRecortypeQuote.Id;
            objQuote.SBQQ__Status__c        =   '1';
            objQuote.SalesManagerValidationFlag__c   =false;  
            insert objQuote;      
            objQuote.SBQQ__Status__c                   =   '2';
          //  objQuote.SalesManagerValidationFlag__c     =   true;
            update  objQuote;
        Test.stopTest();
        system.debug('\n quote after before trigger @@@@@ ' +  objQuote );
        list< task > lstTask = [SELECT ID,Type,Subject FROM task WHERE whatId=:objQuote.SBQQ__Opportunity2__c];
        system.assertEquals( 0,lstTask.size()); // Task no created.   
    }

     /*
    * @Method          :   triggerRun
    * @Author          :   Andres Oliva <andres.oliva@cognizant.com>
    * @Created         :   09/08/2019
    * @Description     :   This method verify when trigger must run
    */	
    @isTest static void testTriggerDontRun()
    {
        SBQQQuoteTriggerHandler.dontRunTrigger();  // Flat to setup trigger to not run.
        List<Account>       lstAccts    =   TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity>   lstOpps     =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'9', 75);
        recordType objRecortypeQuote =   [  SELECT DeveloperName,
                                                    Id 
                                            FROM    RecordType 
                                            WHERE   SobjectType = 'SBQQ__Quote__C' 
                                                    AND DeveloperName = 'OPV_Quote'];
     
        SBQQ__Quote__C objQuote =   new SBQQ__Quote__C();
        objQuote.SBQQ__Opportunity2__c  =   lstOpps[0].id;            
        objQuote.SBQQ__Account__c       =   lstAccts[0].id;
        objQuote.recordtypeId           =   objRecortypeQuote.Id;
        objQuote.SBQQ__Status__c        =   '1';
        objQuote.SalesManagerValidationFlag__c   =false; 
        insert objQuote;
        
        Test.startTest();            
            objQuote.SBQQ__Status__c                   =   '2';
            objQuote.SalesManagerValidationFlag__c     =   true;
            update  objQuote;
        Test.stopTest();
        system.debug('\n quote after before trigger @@@@@ ' +  objQuote );
        list< task > lstTask = [SELECT ID,Type,Subject FROM task WHERE whatId=:objQuote.SBQQ__Opportunity2__c];
        system.assertEquals( 0,lstTask.size()); // Task no created.   
    }

}