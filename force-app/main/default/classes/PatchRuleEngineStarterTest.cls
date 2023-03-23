@isTest
public class PatchRuleEngineStarterTest
{
    @isTest
    static void testLeadAssign1()
    {   
        PatchFieldMapping__c mappingl = new PatchFieldMapping__c(Name='l1', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mappingl;
        PatchFieldMapping__c mappinga = new PatchFieldMapping__c(Name='a1', Object__c='Account', Type__c='Field', Field__c='BillingCountry', Value__c='Country');
        insert mappinga;
        PatchFieldMapping__c mappingo = new PatchFieldMapping__c(Name='o1', Object__c='Opportunity', Type__c='Field', Field__c='Account.BillingCountry', Value__c='Country');
        insert mappingo;
        
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> { ld.Id });
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        starter.start();
       // starter.booster();
        starter.assignPatch(ld, p, object2Role2Mapping);
        
        PatchRuleEngineStarter.EmptyEngine emptyEngine = new PatchRuleEngineStarter.EmptyEngine();
        PatchDataModel.MatchTarget t = new PatchDataModel.MatchTarget(ld);
        PatchDataModel.PatchInfo info = emptyEngine.match(t);
        PatchRuleEngineStarter.InnerJob innerJob = new PatchRuleEngineStarter.InnerJob(new List<Id> { ld.Id });
        innerJob.execute(null);
    } 
    
   //Added by Swathi CR#1451: Starts
   
    @isTest
    static void testAccountAssign()
    {   
        PatchFieldMapping__c mappinga = new PatchFieldMapping__c(Name='a1', Object__c='Account', Type__c='Field', Field__c='BillingCountry', Value__c='Country');
        insert mappinga;
        PatchFieldMapping__c mappingb = new PatchFieldMapping__c(Name='b1', Object__c='Account', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingb;
        PatchFieldMapping__c mappingc = new PatchFieldMapping__c(Name='c1', Object__c='Opportunity', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingc;
        PatchFieldMapping__c mappingo = new PatchFieldMapping__c(Name='o1', Object__c='Opportunity', Type__c='Field', Field__c='Account.BillingCountry', Value__c='Country');
        insert mappingo;
		
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        PatchMatchList__c ml = new PatchMatchList__c(PatchCriteriaRule__c=rule.Id, Name='acme');
        insert ml;
        
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1, PatchTeam__c=team.Id);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        
        Account acc1 =new Account(Name='acme acc');
        Insert acc1;
        acc1.Patch__c = patch.Id;
        acc1.PatchLocked__c = true;
        update acc1;
       
        list<opportunity> opplist = new list<opportunity>();
       opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp1);
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp2);
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp3);
        opportunity opp4 = new opportunity(Name = 'Test opportunity4', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp4);
        opportunity opp5 = new opportunity(Name = 'Test opportunity5', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp5);
        opportunity opp6 = new opportunity(Name = 'Test opportunity6', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp6);
        opportunity opp7 = new opportunity(Name = 'Test opportunity7', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp7);
        opportunity opp8 = new opportunity(Name = 'Test opportunity8', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp8);
        opportunity opp9 = new opportunity(Name = 'Test opportunity9', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp9);
        opportunity opp10 = new opportunity(Name = 'Test opportunity10', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        opplist.add(opp10);
        insert opplist;
        
        
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> {acc1.Id, opp1.Id, patch.Id, patch1.Id});
        starter.start();
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        starter.assignPatch(acc1, p, object2Role2Mapping);
        starter.assignPatch(opp1, p, object2Role2Mapping);
    }

    @isTest
    static void testOppAssign()
    {   
        PatchFieldMapping__c mappinga = new PatchFieldMapping__c(Name='a1', Object__c='Account', Type__c='Field', Field__c='BillingCountry', Value__c='Country');
        insert mappinga;
        PatchFieldMapping__c mappingb = new PatchFieldMapping__c(Name='b1', Object__c='Account', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingb;
        PatchFieldMapping__c mappingc = new PatchFieldMapping__c(Name='c1', Object__c='Opportunity', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingc;
        PatchFieldMapping__c mappingo = new PatchFieldMapping__c(Name='o1', Object__c='Opportunity', Type__c='Field', Field__c='Account.BillingCountry', Value__c='Country');
        insert mappingo;
        
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        PatchMatchList__c ml = new PatchMatchList__c(PatchCriteriaRule__c=rule.Id, Name='acme');
        insert ml;
        
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1, PatchTeam__c=team.Id);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        
        Account acc1 =new Account(Name='acme acc');
        Insert acc1;
        acc1.Patch__c = patch.Id;
        acc1.PatchLocked__c = true;
        update acc1;
       
       opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc1.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp1;
        
        
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> {opp1.Id, patch.Id, patch1.Id});
        starter.start();
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        starter.assignPatch(opp1, p, object2Role2Mapping);
        starter.failedToRealign(new List<sObject> {acc1});
    }
    
    @isTest
    static void testLeadAssign()
    {   
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        PatchMatchList__c ml = new PatchMatchList__c(PatchCriteriaRule__c=rule.Id, Name='acme');
        insert ml;
        
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1, PatchTeam__c=team.Id);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Lead ld = new Lead(LastName='acme', Company='acme',Patch__c = patch.Id);
        insert ld;
        
        //LeadShare ls = new LeadShare(LeadAccessLevel = 'edit',LeadId = ld.id,UserOrGroupId = cs.CRM_User__c);
        //update ld;
        list<LeadShare> shares = [select id, Lead.FirstName from LeadShare where LeadId=:ld.id];
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> {ld.id, patch.Id, patch1.Id});
        starter.start();
        SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        starter.assignPatch(ld, p, object2Role2Mapping);
    }
    
    @isTest
    static void testAssign()
    {   
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        
        List<Patch__c> patchlist = new List<Patch__c>();
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1, PatchTeam__c=team.Id);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        PatchRuleEngineStarter.InnerJob ad1 = new PatchRuleEngineStarter.InnerJob (new List<Id> {patch1.Id});
        Test.startTest();
        System.enqueueJob(ad1);
        Test.stopTest();    
    }
	//Added by Swathi CR#1451: Ends

    @isTest
    static void testPatchRuleHelper()
    {
        Boolean isAdmin = PatchRuleHelper.IsAdmin;
        String NamespaceClassPrefix = PatchRuleHelper.NamespaceClassPrefix;
        Long LastDeploymentDate = PatchRuleHelper.LastDeploymentDate;
        PatchRuleHelper.getSObject(null);
        PatchRuleHelper.splitCsv('acme,ac "me');
        PatchRuleHelper.getSalesforceBaseUrl();
        PatchRuleHelper.logError('error');
    }

    @isTest
    static void testPatchDataModel()
    {
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        PatchDataModel.PatchInfo patchInfo = new PatchDataModel.PatchInfo(patch);
        patchInfo.getSObject();
        patchInfo.deepClone();
        PatchDataModel.RuleInfo ruleInfo = new PatchDataModel.RuleInfo(rule);
        ruleInfo.getSObject(patch.Id);
        ruleInfo.deepClone();
    }
    
}