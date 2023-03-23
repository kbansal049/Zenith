@isTest
public class CreatePOCtrafficScheduleTest {
    
    
    @testSetup static void setup() {
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        ZscalerShiftLogin__c zsl = new ZscalerShiftLogin__c();
        zsl.Name = 'Sandbox';
        zsl.Password__c = '345345';
        zsl.Endpoint__c = 'https://test.com';
        zsl.Username__c = 'testUser';
        insert zsl;
        
        ZscalerShiftLogin__c zslProd = new ZscalerShiftLogin__c();
        zslProd.Name = 'Production';
        zslProd.Password__c = '345345';
        zslProd.Endpoint__c = 'https://test.com';
        zslProd.Username__c = 'testUser';
        insert zslProd;
        
        
        Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByDeveloperName().get('SHIFT_Evaluation').getRecordTypeId();
        //create test User
        
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        //Account
        Account acctTest = new Account(Name = 'Test Account',Sales_Engineer__c=testUser.id,Type='Prospect');
        insert acctTest;
        
        Contact con = new Contact(Lastname = 'Test',AccountId=acctTest.id);
        insert con;
        
        List<Opportunity> lstopp = new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity',SE_Name__c=testUser.id, StageName = label.Stage_1_Alignment,CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        lstopp.add(testOppty);
        // insert testOppty;
        Opportunity testOppty1 = new Opportunity(Name = 'Test Opportunity',SE_Name__c=testUser.id, StageName = label.Stage_6_Closed_Won,CloseDate = Date.today());
        testOppty1.AccountID = acctTest.Id;
        // insert testOppty1;
        lstopp.add(testOppty1);
        insert lstopp;
        
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acctTest.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;
        
        //create test PR
        List<Provisioning_Request__c> ListPR = new List<Provisioning_Request__c>();
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', 
                                                                     Org_ID_with_cloud__c = 'test',
                                                                     Preferred_Cloud__c = 'Zscaler.net', 
                                                                     Send_Initial_l__c = 'SE', SE__c = testUser.Id,
                                                                     Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId,Provisioning_Status__c='Requested');
        ListPR.add(testPR);
        Provisioning_Request__c testPR3 = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com',Org_ID_with_cloud__c = 'test', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty1.Id, RecordTypeId = recordTypeId,Provisioning_Status__c='Requested');
        ListPR.add(testPR3);
        Insert ListPR;
    }
    
    @IsTest 
    static void testdeception(){
        test.startTest();
        CreatePOCtrafficSchedule customerSummarySchedule = new CreatePOCtrafficSchedule();
        String cronExp1 = '0 0 23 * * ?';
        System.schedule('CreatePOCtrafficSchedule Test', cronExp1, customerSummarySchedule);
        test.stopTest();       
    }
}