@isTest
public class BusinessHoursUtilsTest{
    
   @isTest static void createAndUpdateBusinessHourCustom() {
        Account objDealer                                           = new Account();
        objDealer.Country__c                                        = 'PL';
        objDealer.Name                                              = 'Dealer';
        objDealer.RecordTypeId                                      = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Account_DealerPartner' ).getRecordTypeId();
        insert objDealer;       

        Time timeAMStart = Time.newInstance(8, 0, 0, 0);
        Time timeBhAMEnd = Time.newInstance(14, 0, 0, 0);
        Time timeBhPMStart = Time.newInstance(15, 0, 0, 0);
        Time timeBhPMEnd = Time.newInstance(17, 0, 0, 0);
        Test.startTest();
            BusinessHour__c bh  = new BusinessHour__c(
                             Dealer__c = objDealer.Id,
                             MondayAMStartTime__c = timeAMStart, 
                             MondayAMEndTime__c = timeBhAMEnd,
                             MondayPMStartTime__c = timeBhPMStart,  
                             MondayPMEndTime__c = timeBhPMEnd,  

                             TuesdayAMStartTime__c = timeAMStart,   
                             TuesdayAMEndTime__c = timeBhAMEnd,     
                             TuesdayPMStartTime__c = timeBhPMStart,  
                             TuesdayPMEndTime__c = timeBhPMEnd,    

                             WednesdayAMStartTime__c = timeAMStart,
                             WednesdayAMEndTime__c = timeBhAMEnd,   
                             WednesdayPMStartTime__c = timeBhPMStart, 
                             WednesdayPMEndTime__c = timeBhPMEnd,   

                             ThursdayAMStartTime__c = timeAMStart,  
                             ThursdayAMEndTime__c = timeBhAMEnd,    
                             ThursdayPMStartTime__c = timeBhPMStart,  
                             ThursdayPMEndTime__c = timeBhPMEnd,    

                             FridayAMStartTime__c = timeAMStart,    
                             FridayAMEndTime__c = timeBhAMEnd,     
                             FridayPMStartTime__c = timeBhPMStart,    
                             FridayPMEndTime__c = timeBhPMEnd,      

                             SaturdayAMStartTime__c = timeAMStart,  
                             SaturdayAMEndTime__c = timeBhAMEnd,    
                             SaturdayPMStartTime__c = timeBhPMStart,  
                             SaturdayPMEndTime__c = timeBhPMEnd,    
                             
                             SundayAMStartTime__c = timeAMStart,    
                             SundayAMEndTime__c = timeBhAMEnd,      
                             SundayPMStartTime__c = timeBhPMStart,   
                             SundayPMEndTime__c  =  timeBhPMEnd  
                             );


            insert bh;
            bh.MondayAMStartTime__c = Time.newInstance(10, 0, 0, 0);
            update bh;
        Test.stopTest();
    }
}