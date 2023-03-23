@isTest
public class FocusPartnerMasterTriggerTest {
    @isTest
    static void test1(){
     //   Account acc1 = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Partner', null, null, null);
        Account acc = new Account();
        acc.Name = 'Test Account 2';
        acc.Type = 'Partner';
        acc.Program_Type__c = 'Reseller';
        insert acc;
        User u = TestDatafactory_Zscaler.insertAdminUser('xyz_123@xyz.com', 'test123', 'test', 'test123', 'xyz_123@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        List<PatchTeam__c> lstPatchTeamsToInsert = New List<PatchTeam__c>();
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'US North Central';
        amerPatchTeam1.Region__c = 'US Central';
        amerPatchTeam1.Territory_Type__c = 'General Business';
        amerPatchTeam1.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam1);
        insert lstPatchTeamsToInsert;
                
        Test.startTest();
            Focus_Partner__c fp1 = new Focus_Partner__c();
            fp1.Comments__c = 'Test';
            fp1.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp1.RAM__c = Userinfo.getUserId();
            fp1.Partner_Account__c = acc.Id;
            insert fp1;
            
            Focus_Partner__c fp2 = new Focus_Partner__c();
            fp2.Comments__c = 'Test';
            fp2.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp2.RAM__c = Userinfo.getUserId();
        
            fp2.Partner_Account__c = acc.Id;
            insert fp2;
            
        	Set<id> inactiveUserId = new Set<id>();
        	inactiveUserId.add(Userinfo.getUserId());
        	FocusPartnerMasterTriggerHelper.replaceInactiveUserWithManagerAsRam(inactiveUserId);
        
            fp1.Comments__c = 'Test111';
            fp1.RAM__c = u.Id;
            update fp1;
        	
            
            delete fp1;
		Test.stopTest();        
    }
    
    @istest 
    static void test2(){
        User u = TestDatafactory_Zscaler.insertAdminUser('xyz_1234@xyz.com', 'test1234', 'test4', 'test1234', 'xyz_1234@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User u1 = TestDatafactory_Zscaler.insertAdminUser('xyz_345@xyz.com', 'test345', 'test45', 'test345', 'xyz_12345@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');

        u.ManagerId = u1.Id; 
        
        Set<ID> salesTerritoryIdSet = new Set<ID>();
    Map<Id, Focus_Partner__c> oldRAMIdMap = new Map<Id, Focus_Partner__c>();
    Map<ID, Focus_Partner__c> newMap = new Map<ID, Focus_Partner__c>();
    Map<ID, Focus_Partner__c> oldMap = new Map<ID, Focus_Partner__c>();

        List<PatchTeam__c> lstPatchTeamsToInsert = New List<PatchTeam__c>();
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'US North Central';
        amerPatchTeam1.Region__c = 'US Central';
        amerPatchTeam1.Territory_Type__c = 'General Business';
        amerPatchTeam1.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam1);
        insert lstPatchTeamsToInsert;
        
                    
            Focus_Partner__c fp1 = new Focus_Partner__c();
            fp1.Comments__c = 'Test';
            fp1.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp1.RAM__c = u.id;
            insert fp1;
        Focus_Partner__c fp2 = new Focus_Partner__c();
            fp2.Comments__c = 'Test';
            fp2.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp2.RAM__c = u1.id;
            insert fp2;
        Focus_Partner__c fp3 = new Focus_Partner__c();
            fp3.Comments__c = 'Test';
            fp3.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp3.RAM__c = u.id;
            insert fp3;
        Focus_Partner__c fp4 = new Focus_Partner__c();
            fp4.Comments__c = 'Test';
            fp4.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
            fp4.RAM__c = u1.id;
            insert fp4;
        salesTerritoryIdSet.add(fp1.Sales_Territory__c);
        newMap.put(fp1.Id,fp1);
        oldRAMIdMap.put(u1.id,fp1); 
        oldMap.put(fp2.Id,fp2);
        	u.isActive = false;
        	Set<id> inactiveUserId = new Set<id>();
        	inactiveUserId.add(u.id);
        Test.startTest();
        ID jobID = System.enqueueJob(new updateSalesTeamMemberQueueable(salesTerritoryIdSet, oldRAMIdMap, newMap, newMap));
            System.debug('jobID'+jobID);
                ID jobID1 = System.enqueueJob(new updateSalesTeamMemberQueueable(salesTerritoryIdSet, oldRAMIdMap, newMap, oldMap));

        	FocusPartnerMasterTriggerHelper.replaceInactiveUserWithManagerAsRam(inactiveUserId);
        Test.stopTest();
    }
}