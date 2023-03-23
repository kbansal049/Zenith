//Class Added by Varun - CR 1824 
//Updated by Karthik - CR# 4664 to introduce two additional test methods
@isTest
public class StageAgeCalculationTest {
    
    @TestSetup
    private static void createTestData(){
        
        Profile coreSalesProfile= [Select Id from profile where Name='Core Sales']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User coreSalesUser=new User(firstname = 'Core Sales', 
                                    lastName = 'User', 
                                    email = uniqueName + '@test' + orgId + '.org', 
                                    Username = uniqueName + '@test' + orgId + '.org', 
                                    EmailEncodingKey = 'ISO-8859-1', 
                                    Alias = uniqueName.substring(18, 23), 
                                    TimeZoneSidKey = 'America/Los_Angeles', 
                                    LocaleSidKey = 'en_US', 
                                    LanguageLocaleKey = 'en_US', 
                                    ProfileId = coreSalesProfile.Id
                                   ); 
        
        
        insert coreSalesUser;

        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
		Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        insert acc;

		opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test');
        insert opp; 
        
        opportunity oppStage3 = new opportunity(Name = 'Test opportunity Stage 3', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test');
        insert oppStage3; 
        Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(oppStage3.Id, yesterday);
    }
    
    @isTest static void testStageAgeCalculation()
    {
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);
        trlst.add(tr1);
        insert trlst;
        Test.startTest();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
      	opp.StageName= Label.Stage_4_Economic_Buyer_Signoff;
        opp.Validation_Stage__c= '2 - Configuration in Progress';
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        update opp;
        Test.stopTest();
    }
    @isTest static void testStageAgeCalculation1()
    {
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);
        trlst.add(tr1);
        insert trlst;
        Test.startTest();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
      	opp.StageName= Label.Stage_2_Qualified_Budgeted;
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        update opp;
        Test.stopTest();
    }

    @isTest static void testStageAgeCalculation2()
    {
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true);
        trlst.add(tr1);
        insert trlst;
        Test.startTest();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
      	opp.StageName= Label.Stage_5A_Opportunity;
        TriggerUtility.updateInsertStageAgeReset();
        TriggerUtility.SkipOppTriggerReset();
        update opp;
        Test.stopTest();
    }
    
    @isTest static void testStageAgeCalculation3()
    {       
        Test.startTest();
        Opportunity oppStage3 = [SELECT Id,StageName,Stage_Date_Change__c,Stage_Last_Age__c
                                 FROM Opportunity WHERE Name = 'Test opportunity Stage 3'];
        oppStage3.StageName = '3 - Sponsorship';
        update oppStage3;
        System.debug('oppStage3 - ' + oppStage3);
        StageAgeCalculation.methodForTestClassCoverage();
        Test.stopTest();
    }
    
      
}