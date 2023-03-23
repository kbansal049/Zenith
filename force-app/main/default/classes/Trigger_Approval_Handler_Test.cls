/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Trigger_Approval_Handler_Test {
    
    // - static variables
    static User adminUser;
    static Id approvalId;
    static String approved = 'Approved';
    @testSetup static void setup() {
        
        // Create account..
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        INSERT testAccts;    
        Test.startTest();
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = testAccts[0].Id;
        Opp.Amount = 123456;
        Opp.StageName = '5 - Procurement';
        INSERT Opp;
        String targetObject = 'SBQQ__Quote__c'; 
        
        List<Product2> prodList = SB_TestCPQDataUtility.createProduct(1,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year');
        INSERT prodList;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccts[0].Id, 
            SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
            SBQQ__Opportunity2__c = Opp.Id, 
            SBQQ__StartDate__c = system.today(),
            Pending_FullSku_approval__c = '{"ZIA-BUS-EDITION":"-35.99;138880.00"}',
            SBQQ__Primary__c=true);
        INSERT quote; 
        Quote_Extension__C quoteExt = [SELECT Id FROM Quote_Extension__C Where SBQQ_Quote__c =:quote.Id];
        quoteExt.Approved_FullSku__c = '{"ZIA-ESS-EDITION":"-35.99;138880.00"}';
        update quoteExt;
            
        List<SBQQ__QuoteLine__c> qlList = SB_TestCPQDataUtility.createQuoteLine(1, quote.Id, prodList[0].Id, system.today(), Date.today().addDays(400),1);
        INSERT qlList;
        
        
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
            
            // Create Approval Rule
            sbaa__ApprovalRule__c objRule = new sbaa__ApprovalRule__c();
            objRule.Name = 'Test Rule';
            objRule.sbaa__TargetObject__c = targetObject;
            objRule.Rule_Description__c = 'Test Class';
            objRule.PRE_SKU_Category__c = 'Test A1';
            insert objRule;
            
            sbaa__ApprovalRule__c objRule2 = new sbaa__ApprovalRule__c();
            objRule2.Name = 'Deep Discount Approval Rules for Full SKU';
            objRule2.sbaa__TargetObject__c = targetObject;
            objRule2.Rule_Description__c = 'Approval Rules for Full SKU';
            // objRule2.PRE_SKU_Category__c = 'Test A12';
            insert objRule2;      
            
            sbaa__ApprovalRule__c objRule3 = new sbaa__ApprovalRule__c();
            objRule3.Name = 'Deep discounting approval for Internal/Restricted/Pre-SKU';
            objRule3.sbaa__TargetObject__c = targetObject;
            objRule3.Rule_Description__c = 'Approval Rules for Full SKU';
            //objRule2.PRE_SKU_Category__c = 'Test A12';
            insert objRule3;    
            
            
            // Create Approver
            sbaa__Approver__c objApprover = new sbaa__Approver__c();
            objApprover.sbaa__User__c = adminUser.Id;
            objApprover.Name	 = 'Approver 1'; 
            INSERT objApprover;
            
            // Create Approval Chain
            sbaa__ApprovalChain__c objApprChain = new sbaa__ApprovalChain__c();
            objApprChain.sbaa__TargetObject__c = targetObject;
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
            objAppr.sbaa__RecordField__c	 = 'Quote__c';    
            objAppr.sbaa__Rule__c = objRule2.Id;
            INSERT objAppr;
            
            sbaa__Approval__c objAppr3 = new sbaa__Approval__c();
            objAppr3.sbaa__Status__c  = approved;
            objAppr3.Quote__c = quote.Id;
            objAppr3.sbaa__ApprovalStep__c = 1;
            objAppr3.sbaa__Approver__c = objApprover.Id;
            objAppr3.sbaa__AssignedTo__c = null;
            objAppr3.sbaa__AssignedGroupId__c = grp.Id;  
            objAppr3.sbaa__Rule__c = null;
            objAppr3.sbaa__ApprovalChain__c = objApprChain.Id;  
            objAppr3.sbaa__RecordField__c	 = 'Quote__c';    
            objAppr3.sbaa__Rule__c = objRule3.Id;
            INSERT objAppr3;
            
            
            sbaa__Approval__c objAppr2 = new sbaa__Approval__c();
            objAppr2.sbaa__Status__c  = 'Requested';
            objAppr2.Quote__c = quote.Id;
            objAppr2.sbaa__ApprovalStep__c = 1;
            objAppr2.sbaa__Approver__c = objApprover.Id;
            objAppr2.sbaa__AssignedTo__c = null;
            objAppr2.sbaa__AssignedGroupId__c = grp.Id;  
            objAppr2.sbaa__Rule__c = null;
            objAppr2.sbaa__ApprovalChain__c = objApprChain.Id;  
            objAppr2.sbaa__RecordField__c	 = 'Quote__c';    
            objAppr2.sbaa__Rule__c = objRule.Id;
            INSERT objAppr2;       
            approvalId = objAppr2.id;    
            
             
        } 
    }
    
    
    @isTest static void Test1(){
        Test.startTest(); 
        FetchApproverRecordController.itemsToApprove();
        Test.stopTest();
        
    }
    
    @isTest static void test2(){
        sbaa__Approval__c objApproval = [Select Id, Name, sbaa__Status__c from sbaa__Approval__c Limit 1];
        Test.startTest(); 
        objApproval.sbaa__Status__c = approved;
        update objApproval;
        Test.stopTest();
    }
    @isTest static void test3(){
       User u =[Select id from User where  lastName = 'Lastname1'and FirstName='Firstname1'];
        system.runAs(u){
            Test.startTest(); 
            SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c];
            system.debug(quotepending);
        List<sbaa__Approval__c> objApproval = [Select Id,Approval_Rule_Name__c, Name, sbaa__Status__c,Quote__c,Quote__r.Pending_FullSku_approval__c from sbaa__Approval__c where Approval_Rule_Name__c='Deep Discount Approval Rules for Full SKU'];
        system.debug('!!'+objApproval);
         /*SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c];
         quotepending.Pending_FullSku_approval__c = '{"ZIA-SANDBOX":"-3.7227214377406996;2337.00"}';
         update quotepending;
            system.debug('!!'+quotepending.Pending_FullSku_approval__c);*/
        
        for(sbaa__Approval__c objAppr : objApproval){
            
            // objApproval.Approval_Rule_Name__c = approvalId ;
            objAppr.sbaa__Status__c = approved;
        }
        objApproval[0].sbaa__Status__c =approved;
        update objApproval;
        //SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c where id =:objApproval[0].Quote__c];
        integer checkPending = 0;
        if(quotepending.Pending_FullSku_approval__c == null || quotepending.Pending_FullSku_approval__c == '{}'){
            checkPending = 1;
        }
        System.assertEquals(1, checkPending);
        Test.stopTest();
    }
    
    }
    @isTest static void test4(){
       User u =[Select id from User where  lastName = 'Lastname1'and FirstName='Firstname1'];
        system.runAs(u){
            Test.startTest(); 
        List<sbaa__Approval__c> objApproval = [Select Id,Approval_Rule_Name__c, Name, sbaa__Status__c,Quote__c,Quote__r.Pending_FullSku_approval__c,Quote__r.Quote_Extension__c,Quote__r.Quote_Extension__r.Approved_FullSku__c from sbaa__Approval__c where Approval_Rule_Name__c='Test Rule'];
        system.debug('!!'+objApproval);
         /*SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c];
         quotepending.Pending_FullSku_approval__c = '{"ZIA-SANDBOX":"-3.7227214377406996;2337.00"}';
         update quotepending;
            system.debug('!!'+quotepending.Pending_FullSku_approval__c);*/
        
        for(sbaa__Approval__c objAppr : objApproval){
            
            // objApproval.Approval_Rule_Name__c = approvalId ;
            objAppr.sbaa__Status__c = approved;
        }
        objApproval[0].sbaa__Status__c =approved;
        update objApproval;
        system.debug('@@'+objApproval);
        //SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c where id =:objApproval[0].Quote__c];
        Map<string, string> approvedFullSkus =  (Map<string,string>)JSON.deserializeStrict('{"ZIA-SANDBOX":"-3.7227214377406996;2337.00"}', Map<string,string>.class);
        Trigger_Approval_Handler.fullSkuApproval(objApproval[0],approvedFullSkus,null);
        Trigger_Approval_Handler.fullSkuApproval(objApproval[0],null,approvedFullSkus);
        Test.stopTest();
        SBQQ__Quote__c quotepending = [Select Id, Pending_FullSku_approval__c from SBQQ__Quote__c];
        system.assertEquals(quotepending.Pending_FullSku_approval__c,null);
        }
        
    }
    
    
    
    
    
}