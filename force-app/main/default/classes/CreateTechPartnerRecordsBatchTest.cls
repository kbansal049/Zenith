@istest
public class CreateTechPartnerRecordsBatchTest{
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
        

    }
    
    @isTest 
    static void CreateTechPartnerRecordsBatchTest1(){
        Account custAcc = [SELECT Id FROM Account WHERE Name = 'Test Customer Account'];
        Account techPartAcc = [SELECT Id FROM Account WHERE Name = 'Test Tech Partner Account'];
        Zscaler_Cloud_ID__c zCloudId = [SELECT Id FROM Zscaler_Cloud_ID__c WHERE Name='Zscloud.net-3926test1'];
        List<Tech_Partner_Usage_Placeholder__c> TPPlist = new List<Tech_Partner_Usage_Placeholder__c>();
        
        Test.startTest();
        Tech_Partner_Usage_Placeholder__c TPP1 = new Tech_Partner_Usage_Placeholder__c(Customer_Account__c=custAcc.id,Technology_Partner_Id__c=techPartAcc.id,Company_Id__c='3926test1',Cloud_Name__c='Zscloud.net-',Segment__c='Identity',Notes__c='test',Usage_Type__c='Solution');
        TPPlist.add(TPP1);
        
        insert TPPlist;
        
        CreateTechPartnerRecordsBatch btch= new CreateTechPartnerRecordsBatch();
        database.executebatch(btch);
        
        DeleteTechPartnerUsageRecordsBatch b1= new DeleteTechPartnerUsageRecordsBatch('Technology_Partner_Usage__c');
        database.executebatch(b1);
        
        DeleteTechPartnerUsageRecordsBatch b2= new DeleteTechPartnerUsageRecordsBatch('Tech_Partner_Usage_Placeholder__c');
        database.executebatch(b2);

        
        Test.stopTest();
    }
}