@istest
public class coSellActivityLWCHelper_Test {
    @testSetup
    static void testData(){
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;

        Contact con = new contact(lastname = 'abhi', email ='testemail123@tzscaler.com');
        insert con;
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment;
        insert Opp;
        
    }

    @IsTest
    static void test1(){
        Contact con = [Select Id, AccountId from contact limit 1];
        Opportunity opp = [Select Id from Opportunity limit 1];
        
        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.Activity__c = 'POV';
        rec.Status__c = Label.Cosell_Invited;
        rec.Opportunity__c = opp.Id;
        rec.Partner__c = con.AccountId;
        
        coSellActivityLWCHelper.createCosell(rec);

        coSellActivityLWCHelper.updateContact(rec, con.Id);
        coSellActivityLWCHelper.updateStatus(rec, Label.Cosell_Completed);
        coSellActivityLWCHelper.getCosellDetails(opp.Id);
        coSellActivityLWCHelper.getExistingPartners(opp.Id);

        Cosell_Activities__c rec1 = new Cosell_Activities__c();
        rec1.Activity__c = 'POV';
        rec1.Status__c = Label.Cosell_Invited;
        rec1.Opportunity__c = opp.Id;
        insert rec1;
        coSellActivityLWCHelper.getCosellDetails(opp.Id);
        rec1.Status__c = Label.Cosell_Accepted;
        upsert rec1;
        coSellActivityLWCHelper.getCosellDetails(opp.Id);
    }
    
    @IsTest
    static void test2(){
        Contact con = [Select Id, AccountId from contact limit 1];
        Opportunity opp = [Select Id from Opportunity limit 1];
        List<Cosell_Activities__c> cosellList = new List<Cosell_Activities__c>();
        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.Activity__c = 'AW/POV';
        rec.Status__c = Label.Cosell_Interested;
        rec.Opportunity__c = opp.Id;
        rec.Partner__c = con.AccountId;
        cosellList.add(rec);
        Cosell_Activities__c rec1 = new Cosell_Activities__c();
        rec1.Activity__c = 'Architecture Workshop';
        rec1.Status__c = Label.Cosell_Interested;
        rec1.Opportunity__c = opp.Id;
        cosellList.add(rec1);
        Cosell_Activities__c rec2 = new Cosell_Activities__c();
        rec2.Activity__c = 'POV';
        rec2.Status__c = Label.Cosell_Interested;
        rec2.Opportunity__c = opp.Id;
        cosellList.add(rec2);
        insert cosellList;
        coSellActivityLWCHelper.getCosellDetails(opp.Id);   
    }
}