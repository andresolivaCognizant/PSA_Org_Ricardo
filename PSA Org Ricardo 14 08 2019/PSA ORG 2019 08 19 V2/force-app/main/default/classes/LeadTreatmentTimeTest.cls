/**
 * Salesforce
 * @author              Antoine Audollent
 * Project:             PSA - Customer First
 * Description:         Unit tests to cover class LeadTreatmentTime
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-05-10      Antoine Audollent       Class creation.
 *                                                              Code coverage: % (minimum)
 *                      19/06/2019      Pedro Párraga           Edit.
 */
@IsTest
private class LeadTreatmentTimeTest {

    @isTest
    static void setTreatmentDueDate_test_01(){
        List<String> lstActivities   =   new List<String>{'VN'};
        List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);          
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstContsA ,'Salesman','Partner','Manager');
        Insert lstUsers;

             Lead lea = new Lead(
                    FirstName                   = 'First Name 003',
                    Salutation                  =  '1',
                    LastName                    = 'LastName 003',
                    Street                      = 'Calle Test 372',
                    City                        = 'Madrid',
                    Country                     = 'España', 
                    PostalCode                  = '28012',
                    Latitude                    =  39.9691,
                    Longitude                   = -4.8237,
                    Phone                       = '915001000',
                    DestinationPOSCode__c       = '1237771',
                    Company                     = 'DEALER TEST COMPANY_0031',
                    PSABrand__c                 = 'AP',
                    Email                       = 'test@leadexample.com',
                    LeadCountry__c              = 'ES',
                    LeadRequestType__c          = '1',
                    IdReservationVD__c          = '12345323X',
                    Status                      = 'New',
                    OwnerId                     = lstUsers[0].Id,
                    RecordTypeId                = PAD.getObjRecordType('Lead','B2B'),
                    NationalId__c               = '13408448V'

            );

            insert lea;           

        List<Lead> lstLeads = new List<Lead>();
        lstLeads.add(lea);

        Test.startTest();
            LeadTreatmentTime.setTreatmentDueDate(lstLeads);
        Test.stopTest();
    }   
}