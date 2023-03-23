@isTest
public class Approval_Reassignment_HandlerTest {
    
    // - static variables
  static User adminUser;
    
    @testSetup static void setup() {
      
        // Create account..
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        INSERT testAccts;    
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = testAccts[0].Id;
        Opp.Amount = 123456;
        Opp.StageName = '5 - Procurement';
        INSERT Opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccts[0].Id, 
            SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
            SBQQ__Opportunity2__c = Opp.Id, 
            SBQQ__StartDate__c = system.today(),
            SBQQ__Primary__c=true);
        Test.startTest();
        INSERT quote; 
         
         // Create User..
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User adminUser = new User(LastName = 'Lastname1',
                                  FirstName='Firstname1',
                                  Alias = uniqueName.substring(18, 23),
                                  Email = uniqueName + '@test' + orgId + '.org',
                                  Username = uniqueName + '@test' + orgId + '.org',
                                  ProfileId = profileId.Id,
                                  TimeZoneSidKey = 'GMT',
                                  LanguageLocaleKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8',
                                  LocaleSidKey = 'en_US'
                                 );
        INSERT adminUser;
        
       System.runAs(adminUser) {
           // Create Public Group..
            Group grp = new Group();
            grp.name = 'Test Group1';
            grp.Type = 'Regular'; 
            Insert grp; 
     
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = adminUser.Id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
           // Create Approver
           sbaa__Approver__c objApprover = new sbaa__Approver__c();
           objApprover.sbaa__User__c = adminUser.Id;
           objApprover.Name   = 'AMS DD Approval'; 
           INSERT objApprover;
            
           // Create Approval Chain
           sbaa__ApprovalChain__c objApprChain = new sbaa__ApprovalChain__c();
           objApprChain.sbaa__TargetObject__c = 'SBQQ__Quote__c';
           objApprChain.Name = 'Approval Chain 1'; 
           INSERT objApprChain;
           Test.stopTest();
           // Create Approval 
           sbaa__Approval__c objAppr = new sbaa__Approval__c();
           objAppr.sbaa__Status__c  = 'Requested';
           objAppr.Quote__c = quote.Id;
           objAppr.sbaa__ApprovalStep__c = 1;
           objAppr.sbaa__Approver__c = objApprover.Id;
           objAppr.sbaa__AssignedTo__c = null;
           objAppr.sbaa__AssignedGroupId__c = grp.Id;  
           objAppr.sbaa__Rule__c = null;
           objAppr.sbaa__ApprovalChain__c = objApprChain.Id;  
           objAppr.sbaa__RecordField__c   = 'Quote__c';    
           
           INSERT objAppr;
               
           sbaa__Approval__c objAppr2 = new sbaa__Approval__c();
           objAppr2.sbaa__Status__c  = 'Assigned';
           objAppr2.Quote__c = quote.Id;
           objAppr2.sbaa__ApprovalStep__c = 2;
           objAppr2.sbaa__Approver__c = objApprover.Id;
           objAppr2.sbaa__AssignedTo__c = null;
           objAppr2.sbaa__AssignedGroupId__c = grp.Id;  
           objAppr2.sbaa__Rule__c = null;
           objAppr2.sbaa__ApprovalChain__c = objApprChain.Id;  
           objAppr2.sbaa__RecordField__c = 'Quote__c';        
               
           INSERT objAppr2;  
       }
        
  }
    
    
    @isTest static void Test1(){
        Test.startTest(); 
          sbaa__Approval__c objApproval = [Select Id, Name from sbaa__Approval__c Limit 1];
            SBQQ__Quote__c objQuote = [Select Id, Name from SBQQ__Quote__c Limit 1];
        
            Approval_Reassignment_Handler objApprReassign = new Approval_Reassignment_Handler();
          Approval_Reassignment_Handler.reassignApprovalInput testWrap = new Approval_Reassignment_Handler.reassignApprovalInput();
            testWrap.approvalId = objApproval.Id;
            testWrap.quoteId = objQuote.Id;
        
          List<Approval_Reassignment_Handler.reassignApprovalInput> reassignApprList = new List<Approval_Reassignment_Handler.reassignApprovalInput>();
          reassignApprList.add(testWrap);

            Approval_Reassignment_Handler.reassignApproval(reassignApprList);
        
        Test.stopTest();
        
    }
    

}