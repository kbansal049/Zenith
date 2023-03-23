/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class FocusPartnerOppSplitBatchTest {
    @isTest
    static void testFocusPartnerOppSplitBatch() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        List<User> users = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];

        PatchTeam__c salesTerritoty = new PatchTeam__c();
        salesTerritoty.District__c = 'AMERICAS';
        salesTerritoty.Theater__c = 'Americas';
        salesTerritoty.Region__c = 'AMERICAS';
        salesTerritoty.Territory__c = 'SF Bay Area 1';
        salesTerritoty.Name = 'Sales Team';
        salesTerritoty.Sales_Territory_Year__c = 'Current';
        insert salesTerritoty;
        
        Patch__c patch = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salesTerritoty.Id;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        PatchTeamMember__c salesTeamMem1 = new PatchTeamMember__c();
        salesTeamMem1.Role__c = 'Account Manager';
        salesTeamMem1.PatchTeam__c = salesTerritoty.Id;
        salesTeamMem1.User__c = users[0].Id;
        insert salesTeamMem1;
        
        PatchTeam__c pct2 = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        insert pct2;
        PatchTeamMember__c salesTeamMem2 = new PatchTeamMember__c();
        salesTeamMem2.Role__c = 'Channel Manager';
        salesTeamMem2.PatchTeam__c = pct2.Id;
        salesTeamMem2.User__c = users[1].Id;
        insert salesTeamMem2;
        
        Account acc = new Account(Name = 'Test Account', Type='Partner', Patch__c = patch.Id, Sales_Territory__c = salesTerritoty.Id);
        TriggerUtility.accSalesTeamExecuted();
        insert acc;
        
        List<Focus_Partner__c> focusPartnerList = new List<Focus_Partner__c>();
        Focus_Partner__c fp = new Focus_Partner__c(RAM__c = userinfo.getUserId(),Partner_Account__c = acc.Id,Sales_Territory__c=salesTerritoty.Id);
        focusPartnerList.add(fp);
        insert focusPartnerList;
        
        Opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1', Primary_Reseller_Partner__c = acc.Id,
                                          CloseDate = System.Today() + 30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c = 'Pipeline',
                                          AD_Forecast_Category_Lock__c = true, Next_Steps__c = 'testing');
        insert opp;

        OpportunitySplit oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = Users[0].Id, SE__c = Users[0].id);
        insert oppSplit;

        oppSplit.SE__c = Users[1].id;
        update oppSplit;

        Test.startTest();
        	Database.executeBatch(new FocusPartnerOppSplitBatch(''));
        	Database.executeBatch(new FocusPartnerOppSplitBatch('SELECT Id, OpportunityId, SplitOwnerId, Channel_Rep__c, Owner_Sales_Territory__c, Sales_Territory__c, Primary_Reseller__c, SE__c, Override_SE__c, Opportunity_Stage__c, CreatedDate FROM OpportunitySplit WHERE CreatedDate = THIS_YEAR ORDER BY CreatedDate ASC'));
        Test.stopTest();

        List<OpportunitySplit> oppSplitsList = [SELECT Id, OpportunityId, Owner_Sales_Territory__c, Channel_Rep__c FROM OpportunitySplit WHERE Id = :oppSplit.Id];
        System.assertEquals(1, oppSplitsList.size(), 'Pass');
        System.assert(oppSplitsList[0].Owner_Sales_Territory__c != null, 'Pass');
        System.assert(oppSplitsList[0].Channel_Rep__c != null, 'Pass');
    }
}