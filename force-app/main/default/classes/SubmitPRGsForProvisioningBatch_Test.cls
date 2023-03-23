/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class SubmitPRGsForProvisioningBatch_Test {
    private static final Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();

    @testSetup
    static void testData() {
        Id ProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User').getRecordTypeId();
        
        List<PatchTeam__c> salesTerritoryList = new List<PatchTeam__c>();
        List<Patch__c> PatchList = new List<Patch__c>();
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        PatchTeam__c pt1 = new PatchTeam__c();
        pt1.Name = 'Sales1';
        pt1.Theater__c = 'APAC';
        pt1.District__c = 'APAC';
        pt1.Region__c = 'APAC';
        pt1.Territory__c = 'SF Bay Area 1';
        pt1.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt1);
        
        PatchTeam__c pt2 = new PatchTeam__c();
        pt2.Name = 'Sales2';
        pt2.Theater__c = 'EMEA';
        pt2.District__c = 'EMEA';
        pt2.Region__c = 'EMEA';
        pt2.Territory__c = 'SF Bay Area 1';
        pt2.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt2);
        
        PatchTeam__c pt3 = new PatchTeam__c();
        pt3.Name = 'Sales3';
        pt3.Theater__c = 'Americas';
        pt3.District__c = 'AMERICAS';
        pt3.Region__c = 'AMERICAS';
        pt3.Territory__c = 'SF Bay Area 1';
        pt3.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt3);
        
        insert salesTerritoryList;
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = pt1.Id ;
        patch1.PatchName__c = 'Test Patch1';
        PatchList.add(patch1);
        Patch__c patch2  = new Patch__c();
        patch2.Active__c = true;
        patch2.PatchTeam__c = pt2.Id ;
        patch2.PatchName__c = 'Test Patch2';
        PatchList.add(patch2);
        Patch__c patch3  = new Patch__c();
        patch3.Active__c = true;
        patch3.PatchTeam__c = pt3.Id ;
        patch3.PatchName__c = 'Test Patch3';
        PatchList.add(patch3);
        insert PatchList;
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc1.RecordTypeId = ProspectRecordTypeId;        
        }
        acc1.Sales_Territory__c = pt1.Id;
        acc1.Patch__c = patch1.Id;
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc2.RecordTypeId = ProspectRecordTypeId;        
        }
        acc2.Sales_Territory__c = pt2.Id;
        acc2.Patch__c = patch2.Id;
        accList.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'Test Account3';
        acc3.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc3.RecordTypeId = ProspectRecordTypeId;        
        }
        acc3.Sales_Territory__c = pt3.Id;
        acc3.Patch__c = patch3.Id;
        accList.add(acc3);
        
        insert accList;
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity1', AccountId = acc1.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business');
        oppList.add(opp1);
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc2.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business');
        oppList.add(opp2);
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc3.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business');
        oppList.add(opp3);
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppList;
        
        List<Provisioning_Group__c> testPGList = new List<Provisioning_Group__c>();

        Provisioning_Group__c originalProvisioningGroup = new Provisioning_Group__c();
        originalProvisioningGroup.Product_Line__c ='ZIA';
        originalProvisioningGroup.Organization_Domain__c = 'testOrg.com';
        originalProvisioningGroup.RecordTypeId = subsPGRecordTypeId;
        originalProvisioningGroup.PG_for_Subscription__c = true;
        originalProvisioningGroup.Status__c = 'Provisioned';
        originalProvisioningGroup.Sub_Status__c = 'Order Created';
        originalProvisioningGroup.Approval_Status__c = 'Approved';
        originalProvisioningGroup.Start_Date__c = Date.today().addDays(-20);
        originalProvisioningGroup.Opportunity__c = opp1.Id;
        insert originalProvisioningGroup;

        Provisioning_Group__c testPG1 = new Provisioning_Group__c();
        testPG1.Product_Line__c ='ZIA';
        testPG1.Organization_Domain__c = 'testOrg1.com';
        testPG1.RecordTypeId = subsPGRecordTypeId;
        testPG1.PG_for_Subscription__c = true;
        testPG1.Status__c = 'Waiting';
        testPG1.Sub_Status__c = 'Order Created';
        testPG1.Approval_Status__c = 'Approved';
        testPG1.Start_Date__c = Date.today().addDays(-10);
        testPG1.Original_Provisioning_Group__c = originalProvisioningGroup.Id;
        testPG1.Opportunity__c = opp1.Id;
        testPGList.add(testPG1);

        Provisioning_Group__c testPG2 = new Provisioning_Group__c();
        testPG2.Product_Line__c ='ZIA';
        testPG2.Organization_Domain__c = 'testOrg12.com';
        testPG2.RecordTypeId = subsPGRecordTypeId;
        testPG2.PG_for_Subscription__c = true;
        testPG2.Status__c = 'Waiting';
        testPG2.Sub_Status__c = 'Order Created';
        testPG2.Approval_Status__c = 'Approved';
        testPG2.Start_Date__c = Date.today().addDays(-10);
        testPG2.Opportunity__c = opp2.Id;
        testPGList.add(testPG2);
        
        Provisioning_Group__c testPG3= new Provisioning_Group__c();
        testPG3.Product_Line__c ='ZIA';
        testPG3.Organization_Domain__c = 'testOrg123.com';
        testPG3.RecordTypeId = subsPGRecordTypeId;
        testPG3.PG_for_Subscription__c = true;
        testPG3.Status__c = 'Waiting';
        testPG3.Sub_Status__c = 'Order Created';
        testPG3.Approval_Status__c = 'Approved';
        testPG3.Start_Date__c = Date.today().addDays(-10);
        testPG3.Opportunity__c = opp3.Id;
        testPGList.add(testPG3);

        insert testPGList;
    }

    @isTest
    static void testSubmitPRGsForProvisioningBatch() {
        Test.startTest();
            Database.executeBatch(new SubmitPRGsForProvisioningBatch());
        Test.stopTest();
        
        List<Provisioning_Group__c> resultProvisioningGroup = [SELECT Id, Status__c FROM Provisioning_Group__c WHERE Status__c = 'Requested'];        
    }

    @isTest
    static void testSubmitPRGsForProvisioningBatchThrowException() {
        Provisioning_Group__c testPG = [SELECT Id FROM Provisioning_Group__c LIMIT 1];

        String errorMessage = 'Error thrown';
        
        SubmitPRGsForProvisioningBatch batchInstance = new SubmitPRGsForProvisioningBatch();
        batchInstance.errorlst.add(testPG.Id + ' - ' + errorMessage);

        Test.startTest();
            Database.executeBatch(batchInstance);
        Test.stopTest();
    }
    
    @isTest
    static void testScheduleBatchClass() {
        Test.startTest();
            SubmitPRGsForProvisioningBatch provBatch = new SubmitPRGsForProvisioningBatch();
            String newExeTime = '0 0 3 * * ?';
            String jobId = System.schedule('Scheduler Test', newExeTime, provBatch);
        Test.stopTest();
    }
}