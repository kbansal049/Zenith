/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class FocusPartnerSalesTeamBatchTest {
    @isTest
    static void testFocusPartnerSalesTeamBatch(){
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Partner', null, null, null);
        TriggerHandler.clearBypass('AccountTriggerHandler');

        User ur = TestDatafactory_Zscaler.insertAdminUser('xyz_123@xyz.com', 'test123', 'test', 'test123', 'xyz_123@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        List<PatchTeam__c> lstPatchTeamsToInsert = New List<PatchTeam__c>();
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'US North Central';
        amerPatchTeam1.Region__c = 'US Central';
        amerPatchTeam1.Territory_Type__c = 'General Business';
        amerPatchTeam1.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam1);
        insert lstPatchTeamsToInsert;
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.Role__c = 'FP Regional Alliance Manager';
        ptm.PatchTeam__c = amerPatchTeam1.Id;
        ptm.User__c = ur.Id;
        insert ptm;

        Focus_Partner__c fp1 = new Focus_Partner__c();
        fp1.Comments__c = 'Test FP - 1';
        fp1.Sales_Territory__c = lstPatchTeamsToInsert[0].Id;
        fp1.RAM__c = UserInfo.getUserId();
        fp1.Partner_Account__c = acc.Id;
        
        TriggerHandler.bypass('FocusPartnerMasterTriggerHandler');
        insert fp1;
        TriggerHandler.clearBypass('FocusPartnerMasterTriggerHandler');

        Test.startTest();
            Database.executeBatch(new FocusPartnerSalesTeamBatch('SELECT Id, Sales_Territory__c, RAM__c, Partner_Account__c FROM Focus_Partner__c'));
        Test.StopTest();
        
        List<PatchTeamMember__c> ptmList = [SELECT Id, User__c, PatchTeam__c, Role__c FROM PatchTeamMember__c WHERE User__c = :fp1.RAM__c AND PatchTeam__c = :fp1.Sales_Territory__c];
        System.assertEquals(1, ptmList.size(), 'Pass');
    }
}