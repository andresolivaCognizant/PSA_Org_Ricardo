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
@IsTest( seeAllData = false )
public class FlowSendEmailInvokableTest{
    
    
  @testSetup static void setupCommonData(){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test AC';
        validEmailTemplate.DeveloperName = 'TestFSEI';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Subject = 'Test Subject';
        
        
        insert validEmailTemplate;
    }

  @isTest( seeAllData = false )
  static void testflowSendEmailUseCase1(){
      
      
    Account acc = new Account();
    acc.name = 'New Account Name' + datetime.now();
    acc.description = 'New Account Description' + datetime.now();
    insert acc;

    Contact con = new Contact();
    con.firstName = 'New Contact First';
    con.lastName = 'New Contact Last' + datetime.now();
    con.email = 'hello@example.com';
    con.phone = '4805551212';
    con.title = 'New Contact Title' + datetime.now();
    con.accountId = acc.id;
    insert con;

    WorkOrder wo = new WorkOrder();
    wo.subject ='New Work Order Subject' + datetime.now();
    wo.description = 'New Work Order Description' + datetime.now();
    wo.accountId = acc.id;
    wo.contactId = con.id;
    //wo.workTypeId = '08qf4000000QMi0AAG';
    insert wo;

    ServiceAppointment sa = new ServiceAppointment();
    sa.parentRecordId = wo.id;
    sa.earliestStartTime = datetime.now();
    sa.dueDate = datetime.now() + 30;
    sa.Status = 'Open';
    insert sa;

    

    String saId = sa.Id + ';';

    FlowSendEmailInvokable.PostRequest requests = new FlowSendEmailInvokable.PostRequest();
    requests.notificationName 	= 'Test';
    requests.ownerBrand 		= 'AC'; 
    requests.ownerId 			= UserInfo.getUserId();
    requests.serviceApp			= saId;

    test.startTest();
    FlowSendEmailInvokable.flowSendEmail(new List<FlowSendEmailInvokable.PostRequest>{requests});
    test.stopTest();
  }
}