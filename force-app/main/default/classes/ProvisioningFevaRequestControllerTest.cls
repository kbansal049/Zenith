@isTest(seeAllData = true)
public class ProvisioningFevaRequestControllerTest{
    
    @isTest static void test(){
        test.starttest();
        Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        
        
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Account acctTest = new Account(Name = 'Test Account');
        acctTest.Amber_Road_Status__c ='Test';
        insert acctTest;
        
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = '1 - Alignment',CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        insert testOppty;
        
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId);
        insert testPR;
        
        List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c, 
                                                              Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c,
                                                              Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c,
                                                              Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, 
                                                              Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Opportunity__c != null 
                                                              AND Account__c != null  
                                                              AND Account__r.Amber_Road_Status__c != 'Match' 
                                                              AND Account__r.Amber_Road_Status__c != 'Potential Match'
                                                              limit 1]; 
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +provisioningRequests[0].Id);
        Test.setCurrentPage(ref);
        ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
        con.initUserCreation();       
        con.initFevaProcess();
        FeVaUserCreationUtil.UpdateProvReq(provisioningRequests[0], 'Error');
        
        test.stoptest();
    }
    
    @isTest static void test1(){
        test.starttest();
        Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        
        
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Account acctTest = new Account(Name = 'Test Account');
        acctTest.Amber_Road_Status__c ='Test';
        insert acctTest;
        
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = '1 - Alignment',CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        insert testOppty;
        
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId);
        insert testPR;
        List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c,
                                                              Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c,
                                                              Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c,
                                                              Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, 
                                                              Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c 
                                                              where Opportunity__c != null 
                                                              AND Account__c != null  
                                                              AND Account__r.Amber_Road_Status__c != 'Match' 
                                                              AND Account__r.Amber_Road_Status__c != 'Potential Match'
                                                              limit 1]; 
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +provisioningRequests[0].Id);
        Test.setCurrentPage(ref);
        ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
        con.initUserCreationOld();
        FeVaUserCreationUtil.UpdateProvReq(provisioningRequests[0], 'Error');
        
        test.stoptest();
    }
}