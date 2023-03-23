@isTest
private class TechPartnerUsageControllerTest {
    
    @TestSetup
    private static void createTestData(){
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='updateAccountExtension';
        zcs2.Deactivate_Component__c=false;
        insert zcs2;        
        
        ByPassTriggerForSpecifiedUser__c bypassForanUser = new ByPassTriggerForSpecifiedUser__c();
        bypassForanUser.name = 'CustomerSuccessstage';
        bypassForanUser.bypass_component__c=TRUE;
        bypassForanUser.User_Name__c = 'sbosco@zscaler.com';
        insert bypassForanUser;

        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
        List<PatchTeamMember__c> ptms = new List<PatchTeamMember__c>();
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.PatchTeam__c = territory.Id;
        ptm.Role__c = 'Account Manager';
        ptm.User__c = UserInfo.getUserId();
        ptms.add(ptm);
        
        PatchTeamMember__c ptm1 = new PatchTeamMember__c();
        ptm1.PatchTeam__c = territory.Id;
        ptm1.Role__c = 'Channel Manager';
        ptm1.User__c = UserInfo.getUserId();
        ptms.add(ptm1);
        
        PatchTeamMember__c ptm2 = new PatchTeamMember__c();
        ptm2.PatchTeam__c = territory.Id;
        ptm2.Role__c = 'Area Director';
        ptm2.User__c = UserInfo.getUserId();
        ptms.add(ptm2);
        
        PatchTeamMember__c ptm3 = new PatchTeamMember__c();
        ptm3.PatchTeam__c = territory.Id;
        ptm3.Role__c = 'Customer Advocate';
        ptm3.User__c = UserInfo.getUserId();
        ptms.add(ptm3);
        insert ptms;
        
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        
        insert ms;
        
        List<Account> accountToInsert = new List<Account>();
        Account account = new Account(Name = 'Test Customer Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        accountToInsert.add(account);
        
        Account accountTechPartner = new Account(Name = 'Test Tech Partner Account');
        accountTechPartner.CSM_Name_New__c = UserInfo.getUserId();
        accountTechPartner.type = 'Technology Partner'; 
        accountTechPartner.Sales_Territory__c = territory.id;
        accountTechPartner.Prospect_Type__c = 'Pipeline';
        accountTechPartner.NumberOfEmployees=400000;   
        accountTechPartner.No_of_Employees_Users__c='40000+';
        accountTechPartner.TAM_Name_New__c= UserInfo.getUserId();
        accountToInsert.add(accountTechPartner);
        
        insert accountToInsert;
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=accountToInsert[0].Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=accountToInsert[0].Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        List<Technology_Partner_Usage__c> techPartnerUsageListToInsert = new List<Technology_Partner_Usage__c>();
        Technology_Partner_Usage__c techPartnerRecord1 = new Technology_Partner_Usage__c();
        techPartnerRecord1.Account_Type__c = 'Customer';
        techPartnerRecord1.Customer_Account__c = accountToInsert[0].Id;
        techPartnerRecord1.Technology_Partner_Id__c = accountToInsert[1].Id;
        techPartnerRecord1.Segment__c = 'Network';
        techPartnerRecord1.Usage_Type__c = 'Solution';
        techPartnerRecord1.Cloud_Name__c = 'Zscloud.net';
        techPartnerRecord1.Company_Id__c = '3926test1';
        techPartnerRecord1.Is_Primary__c = TRUE;
        techPartnerUsageListToInsert.add(techPartnerRecord1);
        
        Technology_Partner_Usage__c techPartnerRecord2 = new Technology_Partner_Usage__c();
        techPartnerRecord2.Account_Type__c = 'Customer';
        //techPartnerRecord2.Customer_Account__c = accountToInsert[0].Id;
        techPartnerRecord2.Technology_Partner_Id__c = accountToInsert[1].Id;
        techPartnerRecord2.Segment__c = 'Network';
        techPartnerRecord2.Usage_Type__c = 'Solution';
        techPartnerRecord2.Org_ID__c = ZSClIDlist[0].Id;
        techPartnerRecord2.Is_Primary__c = TRUE;
        techPartnerUsageListToInsert.add(techPartnerRecord2);        
        
        Technology_Partner_Usage__c techPartnerRecord3 = new Technology_Partner_Usage__c();
        techPartnerRecord3.Account_Type__c = 'Customer';
        techPartnerRecord3.Customer_Account__c = accountToInsert[0].Id;
        //techPartnerRecord3.Technology_Partner_Id__c = accountToInsert[1].Id;
        techPartnerRecord3.Segment__c = 'Network';
        techPartnerRecord3.Usage_Type__c = 'Solution';
        techPartnerRecord3.Org_ID__c = ZSClIDlist[0].Id;
        techPartnerRecord3.Is_Primary__c = TRUE;
        techPartnerUsageListToInsert.add(techPartnerRecord3);      
        
        Technology_Partner_Usage__c techPartnerRecord4 = new Technology_Partner_Usage__c();
        techPartnerRecord4.Account_Type__c = 'Customer';
        techPartnerRecord4.Customer_Account__c = accountToInsert[0].Id;
        techPartnerRecord4.Technology_Partner_Id__c = accountToInsert[1].Id;
        techPartnerRecord4.Segment__c = 'Network';
        techPartnerRecord4.Usage_Type__c = 'Solution';
        techPartnerRecord4.Org_ID__c = ZSClIDlist[0].Id;
        techPartnerRecord4.Is_Primary__c = TRUE;
        techPartnerUsageListToInsert.add(techPartnerRecord4);
        
        Technology_Partner_Usage__c techPartnerRecord5 = new Technology_Partner_Usage__c();
        techPartnerRecord5.Account_Type__c = 'Customer';
        techPartnerRecord5.Customer_Account__c = accountToInsert[0].Id;
        techPartnerRecord5.Technology_Partner_Id__c = accountToInsert[1].Id;
        techPartnerRecord5.Segment__c = 'Network';
        techPartnerRecord5.Usage_Type__c = 'Solution';
        techPartnerRecord5.Org_ID__c = ZSClIDlist[0].Id;
        techPartnerRecord5.Is_Primary__c = TRUE;
        techPartnerUsageListToInsert.add(techPartnerRecord5);
        
        insert techPartnerUsageListToInsert;
    }
    
    @isTest 
    static void getTechnologyPartnerUsageRecordsTest(){
        Test.startTest();
        String recordIdCustAcc = [SELECT Id FROM Account WHERE Name = 'Test Customer Account'].Id;
        TechPartnerUsageController.getTechnologyPartnerUsageRecords(recordIdCustAcc);        
        Test.stopTest();
    }
    
    @isTest 
    static void getColumnDetailsTest(){
        Test.startTest();
        String fieldSetName = 'TechPartnerUsageLWC_DataTable';
        TechPartnerUsageController.getColumnDetails(fieldSetName);        
        Test.stopTest();
    }
    
    @isTest 
    static void getZSCloudDetailsTest(){
        Test.startTest();
        String recordIdCustAcc = [SELECT Id FROM Account WHERE Name = 'Test Customer Account'].Id;
        TechPartnerUsageController.getZSCloudDetails(recordIdCustAcc);      
        Test.stopTest();
    }
    
    @isTest 
    static void getTechPartnerRecordsToDeleteTest(){
        Test.startTest();
        Technology_Partner_Usage__c techPartnerRecord = [SELECT Id,Customer_Account__c,Technology_Partner_Id__c
                                                         FROM Technology_Partner_Usage__c LIMIT 1];
        String techPartnerUsageRecordStr = JSON.serialize(techPartnerRecord);
        TechPartnerUsageController.getTechPartnerRecordsToDelete(techPartnerUsageRecordStr);      
        Test.stopTest();
    }
    
    @isTest 
    static void deleteTechPartnerUsageRecordsTest(){
        Test.startTest();
        List<Technology_Partner_Usage__c> techPartnerRecord = [SELECT Id,Customer_Account__c,Technology_Partner_Id__c
                                                         FROM Technology_Partner_Usage__c LIMIT 2];
        String techPartnerUsageRecordStr = JSON.serialize(techPartnerRecord);
        TechPartnerUsageController.deleteTechPartnerUsageRecords(techPartnerUsageRecordStr);      
        Test.stopTest();
    }
    
    @isTest 
    static void updateTechPartnerUsageRecordsTest(){
        Test.startTest();
        List<Technology_Partner_Usage__c> techPartnerRecord = [SELECT Id,Customer_Account__c,Technology_Partner_Id__c
                                                         FROM Technology_Partner_Usage__c LIMIT 2];
        TechPartnerUsageController.updateTechPartnerUsageRecords(techPartnerRecord);      
        Test.stopTest();
    }
}