@isTest
private class LeadTriggerHandlerTest {
    private static Lead lead { get; set; }
    private static Patch__c patch { get; set; }  
    
    private static final String TEST_STRING = 'Test';

    @TestSetup
    static void makeData(){
        List<OnOffSwitch__c>  OnOfflist= new List<OnOffSwitch__c>();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateContactStatus';
        zcs1.Deactivate_Component__c=false;
        OnOfflist.add(zcs1);
        
        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='UpdateLeadLeadStage';
        zcs2.Deactivate_Component__c=false;
        OnOfflist.add(zcs2);
        
        OnOffSwitch__c zcs3= new OnOffSwitch__c();
        zcs3.name='updateLeadStageToSAL';
        zcs3.Deactivate_Component__c=false;
        OnOfflist.add(zcs3); 
        
        OnOffSwitch__c zcs4= new OnOffSwitch__c();
        zcs4.name='UpdateLeadStageToSQLBatch';
        zcs4.Deactivate_Component__c=false;
        OnOfflist.add(zcs4);
        insert OnOfflist;
    }

    @isTest
    private static void createTestData(){
        
        TriggerUtility.UpdatingMarketsegmentforLeadsetfalse();
        
        Catch_All_Territory_List__c leadCatcher = new Catch_All_Territory_List__c();
        leadCatcher.Name = 'Catch All - APAC';
        leadCatcher.Record_Id__c = 'a3470000000UE2XAAW';
        insert leadCatcher;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = TEST_STRING;
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.NumberOfEmployees = 20;
        le.LeadIQ__c = 'LeadiQ';
        le.ZPA_Interactive_Lead__c = TRUE;
        le.ZB2B_Interactive_Prospect__c = TRUE;
        insert le; 
        
        ZscalerSetting__c setting = new ZscalerSetting__c(Name='CampaginExceptions', Value__c='70170000000cGzmAAE');
        insert setting;
        
        List<OnOffSwitch__c>  OnOfflist= new List<OnOffSwitch__c>();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateContactStatus';
        zcs1.Deactivate_Component__c=false;
        OnOfflist.add(zcs1);
        
        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='UpdateLeadLeadStage';
        zcs2.Deactivate_Component__c=false;
        OnOfflist.add(zcs2);
        
        OnOffSwitch__c zcs3= new OnOffSwitch__c();
        zcs3.name='updateLeadStageToSAL';
        zcs3.Deactivate_Component__c=false;
        OnOfflist.add(zcs3); 
        
        OnOffSwitch__c zcs4= new OnOffSwitch__c();
        zcs4.name='UpdateLeadStageToSQLBatch';
        zcs4.Deactivate_Component__c=false;
        OnOfflist.add(zcs4);
        insert OnOfflist;
        
        Campaign leadCampaign = new Campaign(
            Name = 'Lead Campaign Test 1',
            IsActive = true
        );
        insert leadCampaign;
        
        Lead_Lifecycle_Campaigns__c orgDefaultSetting = new Lead_Lifecycle_Campaigns__c(SetupOwnerId=UserInfo.getOrganizationId(), Lead_Campaign_Id__c=leadCampaign.Id);
        insert orgDefaultSetting;
        
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_NORTH_CENTRAL;
        amerPatchTeam1.Region__c = L2O_Constants.SalesTerritoryObject.REGION_US_CENTRAL;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = L2O_Constants.SalesTerritoryObject.GEO_AMERICAS;
        insert amerPatchTeam1;
        
        patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = amerPatchTeam1.Id ;
        patch.PatchName__c = 'Test Patch 1';
        insert patch;
        
        lead = new Lead(FirstName = TEST_STRING, LeadSource = 'Marketing Campaign' , LastName = 'Lead', Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = '', MKTO71_Lead_Score__c = 0);
        insert lead;
    }
    
    @isTest 
    static void updateLeadTest()
    {
        Lead leInteractive = new Lead();
        leInteractive.Company = 'test Company Interactive False';
        leInteractive.FirstName = TEST_STRING;
        leInteractive.LastName = 'Name Interactive';
        leInteractive.Email = 'testInteractive@abc.com';
        leInteractive.NumberOfEmployees = 20;        
        leInteractive.ZPA_Interactive_Lead__c = FALSE;
        leInteractive.ZB2B_Interactive_Prospect__c = FALSE;
        insert leInteractive;
        
        Test.startTest();
        Lead leadRecordToUpdate = [SELECT Id,ZPA_Interactive_Lead__c,ZB2B_Interactive_Prospect__c
                                   FROM Lead 
                                   WHERE Company = 'test Company Interactive False' LIMIT 1];
        
        leadRecordToUpdate.ZPA_Interactive_Lead__c = TRUE;
        leadRecordToUpdate.ZB2B_Interactive_Prospect__c = TRUE;
        
        update leadRecordToUpdate;
        Test.stopTest();  
        
    }
    
    @isTest 
    static void deleteLeadTest()
    {
        Lead leToDelete = new Lead();
        leToDelete.Company = 'test Company To Delete';
        leToDelete.FirstName = TEST_STRING;
        leToDelete.LastName = 'Name Delete';
        leToDelete.Email = 'testDelete@abc.com';
        leToDelete.NumberOfEmployees = 20;
        insert leToDelete;
        
        Test.startTest();
        Lead leadRecord = [SELECT Id
                           FROM Lead 
                           WHERE Company = 'test Company To Delete' LIMIT 1];
        delete leadRecord;
        Test.stopTest();        
    }
    
    @isTest 
    static void testUpdateLeadLeadStage() {
        
        Lead leInteractive = new Lead();
        leInteractive.Company = 'test Company Interactive False';
        leInteractive.FirstName = TEST_STRING;
        leInteractive.LastName = 'Name Interactive';
        leInteractive.Email = 'testInteractive@abc.com';
        leInteractive.NumberOfEmployees = 20;        
        leInteractive.ZPA_Interactive_Lead__c = FALSE;
        leInteractive.ZB2B_Interactive_Prospect__c = FALSE;
        insert leInteractive;
        Test.startTest();
        Lead leadRecordToUpdate = [SELECT Id,MKTO71_Lead_Score__c
                                   FROM Lead 
                                   WHERE Company = 'test Company Interactive False' LIMIT 1];
        leadRecordToUpdate.MKTO71_Lead_Score__c = 10;
        update leadRecordToUpdate;
        UpdateLeadLeadStage.updateLeadLeadStage(new List<Id>{leadRecordToUpdate.Id});
        Test.stopTest();
    }

    @isTest
    static void testIs70PlusNotificationHavingGeoAmericas() {
        Campaign testCampaign = new Campaign(
            Name = 'Lead Campaign Test 2',
            IsActive = true
        );
        insert testCampaign;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_NORTH_CENTRAL;
        amerPatchTeam1.Region__c = L2O_Constants.SalesTerritoryObject.REGION_US_CENTRAL;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = L2O_Constants.SalesTerritoryObject.GEO_AMERICAS;
        insert amerPatchTeam1;
        
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test1.com';
        testLead.Most_Recent_Campaign2__c = testCampaign.Id;
        testLead.Territory__c = amerPatchTeam1.Id;
        testLead.FirstName = '70+';
        testLead.LastName = 'test lead 1';
        testLead.Company = 'test Company';

        Test.startTest();
            insert testLead;
            testLead.mkto71_Lead_Score__c = 90;
            update testLead;
        Test.stopTest();
        
        Lead resultLead = [SELECT Id, MQL__c FROM Lead WHERE FirstName = '70+' AND LastName = 'test lead 1' LIMIT 1];
        System.assertEquals(true, resultLead.MQL__c, 'MQL field should be true on lead.');
    }

    @isTest
    static void testIs70PlusNotificationHavingRegionAPJ() {
        Campaign testCampaign = new Campaign(
            Name = 'Lead Campaign Test 3',
            IsActive = true
        );
        insert testCampaign;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Region__c = 'APJ';
        amerPatchTeam1.Region__c = L2O_Constants.SalesTerritoryObject.REGION_US_CENTRAL;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'ENT ASEAN 1';
        insert amerPatchTeam1;
        
        Lead testLead = (Lead) JSON.deserialize('{"Region_T__c" : "APJ"}', Lead.class);
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test2.com';
        testLead.Most_Recent_Campaign2__c = testCampaign.Id;
        testLead.Territory__c = amerPatchTeam1.Id;
        testLead.FirstName = '70+';
        testLead.LastName = 'test lead 2';
        testLead.Company = 'test Company 1';

        Test.startTest();
            insert testLead;
            testLead.mkto71_Lead_Score__c = 90;
            update testLead;
        Test.stopTest();
        
        Lead resultLead = [SELECT Id, MQL__c FROM Lead WHERE FirstName = '70+' AND LastName = 'test lead 2' LIMIT 1];
        System.assertEquals(true, resultLead.MQL__c, 'MQL field should be true on lead.');
    }

    @isTest
    static void testIs70PlusNotificationHavingRegionEMEA() {
        Campaign testCampaign = new Campaign(
            Name = 'Lead Campaign Test 4',
            IsActive = true
        );
        insert testCampaign;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'ENT 1';
        insert amerPatchTeam1;
        
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test3.com';
        testLead.Most_Recent_Campaign2__c = testCampaign.Id;
        testLead.Territory__c = amerPatchTeam1.Id;
        testLead.FirstName = '70+';
        testLead.LastName = 'test lead 3';
        testLead.Company = 'test Company 2';

        Test.startTest();
            insert testLead;
            testLead.mkto71_Lead_Score__c = 90;
            update testLead;
        Test.stopTest();
        
        Lead resultLead = [SELECT Id, MQL__c FROM Lead WHERE FirstName = '70+' AND LastName = 'test lead 3' LIMIT 1];
        System.assertEquals(true, resultLead.MQL__c, 'MQL field should be true on lead.');
    }

    @isTest
    static void testTriggerMQLNotification() {
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_FEDERAL;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'ENT 1';
        insert amerPatchTeam1;

        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test4.com';
        testLead.FirstName = 'MQL';
        testLead.LastName = 'test lead 4';
        testLead.Company = 'test Company 3';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;
        testLead.Territory__c = amerPatchTeam1.Id;

        Test.startTest();
            insert testLead;
        Test.stopTest();
        
        Lead resultLead = [SELECT Id, MQL__c, Status, Remarks__c, Last_Notification_Date__c, Trigger_MQL_Notification__c, Deal_Reg_Convert_to_Contact__c, Federal_Change__c 
            FROM Lead WHERE FirstName = 'MQL' AND LastName = 'test lead 4' LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Last_Notification_Date__c, 'Last notification date should be ' + Date.today());
    }

    @isTest
    static void testOwnerUpdateMarketoUser() {
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_FEDERAL;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'Catch All - US';
        insert amerPatchTeam1;

        Patch__c newPatch = new Patch__c(PatchName__c = 'Test Patch 2', PatchTeam__c = amerPatchTeam1.Id);
        insert newPatch;

        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test5.com';
        testLead.FirstName = 'Marketo';
        testLead.LastName = 'test lead 5';
        testLead.Company = 'test Company 4';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;
        testLead.Territory__c = amerPatchTeam1.Id;
        testLead.Patch__c = newPatch.Id;
        
        User marketoUser = [SELECT Id, FirstName, LastName FROM User WHERE FirstName = 'Marketo' OR LastName = 'Marketo' LIMIT 1];

        System.runAs(marketoUser) {
            insert testLead;
        }

        Group ownerQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SDR_AMER' LIMIT 1];
        Lead resultLead = [SELECT Id, Owner.Name, OwnerId FROM Lead WHERE FirstName = 'Marketo' AND LastName = 'test lead 5' LIMIT 1];
        System.assertEquals(ownerQueue.Id, resultLead.OwnerId, 'Lead owner should be SDR AMER queue.');
    }

    @isTest
    static void testLeadStatusChangeFromRecycledToMarketing() {
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_FEDERAL;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'Catch All - US';
        insert amerPatchTeam1;

        Patch__c newPatch = new Patch__c(PatchName__c = 'Test Patch 3', PatchTeam__c = amerPatchTeam1.Id);
        insert newPatch;
        
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test6.com';
        testLead.FirstName = 'Marketo';
        testLead.LastName = 'test lead 6';
        testLead.Company = 'test Company 5';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = 'Recycled to Marketing';
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;

        insert testLead;

        User marketoUser = [SELECT Id, FirstName, LastName FROM User WHERE FirstName = 'Marketo' OR LastName = 'Marketo' LIMIT 1];

        Test.startTest();
            System.runAs(marketoUser) {
                testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
                testLead.Has_Meeting_test__c = true;
                testLead.Key_contact_validation__c = 'Not a Key Contact';
                testLead.Patch__c = newPatch.Id;
                testLead.Territory__c = amerPatchTeam1.Id;
                update testLead;
            }
        Test.stopTest();
    }

    @isTest
    static void testMQLConversion() {
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_FEDERAL;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'Catch All - US';
        insert amerPatchTeam1;

        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test7.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 7';
        testLead.Company = 'test Company 6';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = 'Recycled to Marketing';
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;
        testLead.Territory__c = amerPatchTeam1.Id;
        
        insert testLead;

        Test.startTest();
            testLead.mkto71_Lead_Score__c = 79;
            update testLead;
        Test.stopTest();

        Lead resultLead = [SELECT Id, MQL__c FROM Lead WHERE FirstName = :TEST_STRING AND LastName = 'test lead 7' LIMIT 1];
        System.assertEquals(true, resultLead.MQL__c, 'MQL should be true.');
    }

    @isTest 
    static void testOutreachStatusChangeToConnected() {
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test8.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 8';
        testLead.Company = 'test Company 7';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = 'Recycled to Marketing';
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;

        insert testLead;

        Test.startTest();
            testLead.Outreach_Status__c = 'Connected';
            update testLead;
        Test.stopTest();

        Lead resultLead = [SELECT Id, Status FROM Lead WHERE FirstName = :TEST_STRING AND LastName = 'test lead 8' LIMIT 1];
        System.assertEquals('SAL: Sales Connected Lead', resultLead.Status, 'Lead status should be SAL: Sales Connected Lead');
    }

    @isTest 
    static void testOutreachStatusChangeToContactAttempted() {
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test9.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 9';
        testLead.Company = 'test Company 8';
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        testLead.RingLead_DMS_Status__c = TEST_STRING;

        insert testLead;

        Test.startTest();
            testLead.Outreach_Status__c = 'Contact Attempted';
            testLead.RingLead_DMS_Status__c = '';
            testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;
            testLead.Trigger_MQL_Notification__c = true;
            update testLead;
        Test.stopTest();

        Lead resultLead = [SELECT Id, Status FROM Lead WHERE FirstName = :TEST_STRING AND LastName = 'test lead 9' LIMIT 1];
        System.assertEquals('SAL: Sales Pursuing Lead', resultLead.Status, 'Lead status should be SAL: Sales Pursuing Lead');
    }

    @isTest
    static void testAfterInsertMeetingAccepted() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test10.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 10';
        testLead.Company = 'test Company 9';
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        testLead.Kronologic_Status__c = 'Meeting Accepted';
        testLead.IsConverted = true;
        testLead.ConvertedAccountId = testAccount.Id;

        Test.startTest();
            insert testLead;
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdateMeetingAccepted() {
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test11.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 11';
        testLead.Company = 'test Company 10';
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        insert testLead;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_NORTH_CENTRAL;
        amerPatchTeam1.Region__c = L2O_Constants.SalesTerritoryObject.REGION_US_CENTRAL;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = L2O_Constants.SalesTerritoryObject.GEO_AMERICAS;
        insert amerPatchTeam1;

        testLead.Kronologic_Status__c = 'Meeting Accepted';
        testLead.Territory__c = amerPatchTeam1.Id;
        
        Test.startTest();
            update testLead;
        Test.stopTest();
    }

    @isTest
    static void testUpdateTaskAndEvent() {
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test12.com';
        testLead.FirstName = TEST_STRING;
        testLead.LastName = 'test lead 12';
        testLead.Company = 'test Company 11';
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        insert testLead;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_NORTH_CENTRAL;
        amerPatchTeam1.Region__c = L2O_Constants.SalesTerritoryObject.REGION_US_CENTRAL;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = L2O_Constants.SalesTerritoryObject.GEO_AMERICAS;
        insert amerPatchTeam1;
        
        Task testTask = new Task(Subject = 'Kronologic - Meeting Accepted', whoId = testLead.Id);
        insert testTask;

        Event testEvent = new Event(Subject = 'Test Event', Type = 'Test Type', DurationInMinutes = 10, ActivityDateTime = System.now(), whoId = testLead.Id);
        insert testEvent;

       testLead.Territory__c = amerPatchTeam1.Id;

        Test.startTest();
            update testLead;
        Test.stopTest();
    }

    @isTest
    static void testOwnerUpdateMarketoUserCatchAllAMSCommercial() {
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = L2O_Constants.SalesTerritoryObject.AREA_US_FEDERAL;
        amerPatchTeam1.Region__c = L2O_Constants.LeadObject.LEAD_AREA_EMEA;
        amerPatchTeam1.Territory_Type__c = L2O_Constants.SalesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS;
        amerPatchTeam1.Theater__c = '';
        amerPatchTeam1.Name = 'Catch All AMS Commercial';
        insert amerPatchTeam1;

        Patch__c newPatch = new Patch__c(PatchName__c = 'Test Patch 4', PatchTeam__c = amerPatchTeam1.Id);
        insert newPatch;

        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 70;
        testLead.Email = 'test@test13.com';
        testLead.FirstName = 'Marketo';
        testLead.LastName = 'test lead 13';
        testLead.Company = 'test Company 12';
        testLead.Trigger_MQL_Notification__c = true;
        testLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED;
        testLead.Deal_Reg_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_ACCEPTED;
        testLead.Territory__c = amerPatchTeam1.Id;
        testLead.Patch__c = newPatch.Id;
        
        User marketoUser = [SELECT Id, FirstName, LastName FROM User WHERE FirstName = 'Marketo' OR LastName = 'Marketo' LIMIT 1];

        System.runAs(marketoUser) {
            insert testLead;
        }

        Group ownerQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SDR_AMER' LIMIT 1];
        Lead resultLead = [SELECT Id, Owner.Name, OwnerId FROM Lead WHERE FirstName = 'Marketo' AND LastName = 'test lead 13' LIMIT 1];
        System.assertEquals(ownerQueue.Id, resultLead.OwnerId, 'Lead owner should be SDR AMER queue.');
    }
}