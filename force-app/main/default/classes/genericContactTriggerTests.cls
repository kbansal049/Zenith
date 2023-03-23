/**
 * @description       : 
 * @author            : zscaler.com
 * @group             : 
 * @last modified on  : 12-21-2022
 * @last modified by  : zscaler.com
**/
@isTest
private class genericContactTriggerTests {

    private static final String DISQUALIFIED_STRING = 'Disqualified';

    @testSetup 
    static void dataPrep(){
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        insert acc;

        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = acc.id, Cloud_Type__c = 'ZIA');
        insert ci;

        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = System.today() + 30;
        camp.IsActive = true;
        insert camp;

        List<PatchTeam__c> territoryList = new List<PatchTeam__c> ();
        
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        territory.Territory_Type__c='Major';
        territoryList.add(territory);

        territory =  new PatchTeam__c();
        territory.Theater__c = 'EMEA';
        territory.Region__c = 'NEUR';
        territory.Area__c = 'Benelux';
        territory.Territory_Type__c='Enterprise';
        territoryList.add(territory);

        insert territoryList;

        Skip_Triggers_User_Based__c skp = new Skip_Triggers_User_Based__c();
        skp.SetupOwnerId = UserInfo.getUserId();
        skp.Object_s_to_skip__c = 'Deal_Reg__c';
        insert skp;

        List<ZscalerSetting__c> zSettings = new List<ZscalerSetting__c>();
        zSettings.add(new ZscalerSetting__c(Name='DealRegCampaign', Value__c=camp.Id));
        insert zSettings;
        
        List<Contact> ContactList= new List<Contact>();
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1',Qualification_Status__c = DISQUALIFIED_STRING, Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send', Last_Opened_Date__c=Date.today().addDays(-1), ZCloudID_Org_IDs__c=ci.Id, ZPA_Interactive_Prospect__c=true, ZB2B_Interactive_Prospect__c=true, MQL_Date__c=Date.today().addDays(-1), Service_Owner__c=true);
        ContactList.add(con);
        
        Contact con1= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send', Last_Opened_Date__c=Date.today().addDays(-1), ZCloudID_Org_IDs__c=ci.Id, ZPA_Interactive_Prospect__c=true, ZB2B_Interactive_Prospect__c=true, MQL_Date__c=Date.today().addDays(-1), Service_Owner__c=true);
        ContactList.add(con1);
        
        insert ContactList;

        List<Deal_Reg__c> dealRegList = new List<Deal_Reg__c>();
        Deal_Reg__c dealReg1 = new Deal_Reg__c();
        dealReg1.End_Customer_Contact_Name__c = 'Test';
        dealReg1.End_Customer_Contact_Last_Name__c= 'Test';
        dealReg1.End_Customer_Country__c = 'US';
        dealReg1.End_Customer_Domain__c = 'abcd.com';
        dealReg1.End_Customer_Email__c  = 'Test@abcde.com';
        dealReg1.End_Customer_Name__c = 'ABC Inc';
        dealReg1.End_Customer_Phone__c = '123456789';
        dealReg1.End_Customer_State__c = 'US';
        dealReg1.DS_Review_Status__c = 'Pending Review';
        dealReg1.Estimated_Amount__c = 1234567;
        dealReg1.Expected_Close_Date__c = System.today() + 30;
        dealReg1.Market_Segment__c = 'SMB';
        dealReg1.Number_of_Users__c = 1234567;
        dealReg1.Partner_Account__c = acc.Id;
        dealReg1.Partner_Company_Name__c = 'Test partner';
        dealReg1.Partner_Contact_Email__c = 'Test@partner.com';
        dealReg1.Partner_Contact_Name__c = 'Test';
        dealReg1.Partner_Contact_Last_Name__c  = 'Partner';
        dealReg1.Partner_Country__c  = 'US';
        dealReg1.Partner_Domain__c  = 'partner.com';
        dealReg1.Source__c = 'Deal Reg';
        dealReg1.Status__c = 'Submitted';
        dealReg1.Contact__c = con.Id;
        dealRegList.add(dealReg1);

        insert dealRegList;

        Task t1 = new Task(WhoId = contactList[0].id);
        insert t1;
        Task t2 = new Task(WhoId = contactList[1].id);
        insert t2;
    }

    @IsTest
    static void testMethod1(){
        List<Contact> contactList = [SELECT Id, AccountId, ZCloudID_Org_IDs__c FROM Contact];
        Map<id,contact> contactMap = new Map<id,contact>();
        Contact con = contactList[0];
        con.Outreach_Status__c ='Connected';
        con.Qualification_Status__c='';
        update con;
        contactMap.put(con.id, con);
        
        List<Zscaler_Cloud_ID_Contact__c> zCloudContactList = [SELECT Id FROM Zscaler_Cloud_ID_Contact__c WHERE Contact__c=:con.Id];

        delete zCloudContactList;
        delete con;
    }

    @IsTest
    static void testMethod2(){
        List<Contact> contactList = [select id from contact];
        
        Contact con1 = contactList[1];
        con1.Contact_Lead_Status__c ='Marketing Qualified: Sales Untouched';
        con1.Outreach_Status__c ='Added to Sequence';
        con1.Qualification_Status__c = DISQUALIFIED_STRING;
        update con1;
    }
    
    @isTest
    static void funnelStageAutomationInsertTest(){
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        insert acc;
        
        List<Contact> ContactList= new List<Contact>();
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contact_Lead_Status__c = DISQUALIFIED_STRING);
        ContactList.add(con);
        
        insert ContactList;        
    }
    
    @isTest
    static void funnelStageAutomationUpdateTest(){
        List<Contact> contactList = [select Id,AccountId,Contact_Lead_Status__c from contact];
        Contact con = contactList[0];
        con.Contact_Lead_Status__c = DISQUALIFIED_STRING;
        update con;
    }

    @isTest
    static void zCloudIDContactInsertTest(){
        List<Contact> contactList = [SELECT Id, AccountId, Contact_Lead_Status__c FROM Contact];
        contactList[0].Contacts_that_matter__c = true;
        contactList[0].Send_CIO_Report__c ='Send delayed';
        contactList[0].Last_Opened_Date__c = Date.today();
        contactList[0].Qualifying_SDR__c = UserInfo.getUserId();
        contactList[0].Request_to_Sync_to_PRM__c = 'Yes';
        contactList[0].Territory__c = [SELECT Id FROM PatchTeam__c LIMIT 1].Id;
        contactList[0].Budget_Authority__c = true;
        contactList[0].MQL_Date__c=Date.today();
        update contactList;
    }

    @isTest
    static void dealRegValidationTest(){
        Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, AccountId, Contact_Lead_Status__c FROM Contact]);
        ContactTriggerHelper.dealRegValidation(contMap);
        ContactTriggerHelper.ZCloudIDContactDelete(contMap.values());
        ContactTriggerHelper.insertFunnelStageAutomation(contMap.values());
    }
    
    @isTest
    static void testChangeContactOwnership() {
        List<Contact> contactList = [SELECT Id, AccountId, OwnerId, ZCloudID_Org_IDs__c FROM Contact LIMIT 1];
        Contact oldAccount = contactList[0].clone(true, true, true, true);
        
        Account testAccount = new Account (Name = 'Test Account');
        TriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
        contactList[0].AccountId = testAccount.Id;
        Test.startTest();
        ContactTriggerHelper.changeContactOwnership(contactList, new Map<Id, Contact> {oldAccount.Id => oldAccount});
        Test.stopTest();
        
        Account queriedTestAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(queriedTestAccount.OwnerId, contactList[0].OwnerId, 'Owner Id should be updated');
    }

}