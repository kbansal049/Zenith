@isTest
public class PatchRuleHelperTest
{
    @isTest static void test()
    {
        System.assertEquals(true, PatchRuleHelper.IsAdmin);
        Long l = PatchRuleHelper.LastDeploymentDate;
        String u = PatchRuleHelper.getSalesforceBaseUrl();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;
        User userTwo = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount2@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userTwo;
        
        //Patch__c patch = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch'];
        //PatchTeam__c salestert = [SELECT Id FROM PatchTeam__c WHERE Name = 'Sales Team'];
        List<User> usr = [SELECT Id FROM User limit 10];
        
        Account acc = new Account();
        acc.Name='AMERICAS';
        acc.Type ='Prospect';
        //acc.Sales_Territory__c = salestert.Id;
       // acc.Patch__c = patch.Id;
        acc.ownerId = userTwo.Id;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name='AMERICAS';
        acc2.Type ='Prospect';
        //acc2.Sales_Territory__c = salestert.Id;
        //acc2.Patch__c = patch.Id;
        acc2.ownerId = userTwo.Id;
        insert acc2;
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = acc.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid=acc.Id;
        atm.teamMemberRole='Customer Success Manager';
        atm.UserId=userTwo.Id;
        //atm.AccountAccessLevel='Edit';
        //atm.OpportunityAccessLevel = 'Edit';
        //atm.CaseAccessLevel='Edit';
        //atm.ContactAccessLevel='Edit';
        insert atm;
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.accountid=acc.Id;
        atm1.teamMemberRole='Account Manager';
        atm1.UserId=userone.Id;
        //atm1.AccountAccessLevel='Edit';
        //atm1.OpportunityAccessLevel = 'Edit';
        //atm1.CaseAccessLevel='Edit';
        //atm1.ContactAccessLevel='Edit';
        insert atm1;
        
        PatchRuleHelper.assignSalesTeamMembers(new List<Id>{opp.Id}, 'Opportunity');
        PatchRuleHelper.isSameSObject(atm, atm1);
        PatchRuleHelper.isSameSObject(atm, atm);
        PatchRuleHelper.assignSalesTeamMembers(new List<Id>{acc.Id}, 'Account');
    }
    
    @isTest static void testSplitCsv()
    {
        String[] s1 = PatchRuleHelper.splitCsv('us, usa, america, united states of america');
        System.assertEquals(4, s1.size());
        System.assertEquals('us', s1[0]);
        System.assertEquals('usa', s1[1]);
        System.assertEquals('america', s1[2]);
        System.assertEquals('united states of america', s1[3]);
        
        String[] s2 = PatchRuleHelper.splitCsv('taiwan, tw, "taiwan, province of china,"');
        System.assertEquals(3, s2.size());
        System.assertEquals('taiwan', s2[0]);
        System.assertEquals('tw', s2[1]);
        System.assertEquals('taiwan, province of china,', s2[2]);
        try{
            Integer i = 0/0;
        }catch(Exception e){
            PatchRuleHelper.logError(e);
        }
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
        PatchTeamMember__c member2 = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Account Manager', User__c=UserInfo.getUserId());
        insert member2;
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
        update acc1;
        
        System.debug('--> ' + [SELECT Id, Account_Manager__r.Name FROM Account WHERE Id = :acc1.Id]);
       
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
    
}