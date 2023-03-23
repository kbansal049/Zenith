@isTest
public class TERRITORYSYNC_Test {
// This test method cover the exception when sales territory attached to a account gets deleted and do database.error gets executed
    static testMethod void testFedSalesTerritory4() {
        
        // Create test user 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount1@test.com',
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
        // Create territory 
        PatchTeam__c ter1 = new PatchTeam__c(name ='Fed-05');
        insert ter1;  
        ter1.Account_Manager__c = userOne.Id;
        ter1.Channel_Manager__c = userTwo.Id;
       

        PatchTeam__c ter2 = new PatchTeam__c(name ='Fed-05');
        insert ter2;   
        ter2.Account_Manager__c = userOne.Id;
        ter2.Channel_Manager__c = userTwo.Id;
        // Create Account,Oppportunities,accountteam and oppportunity team that get updated
        List<Account> fedAccounts = new List<Account>();
        List<Opportunity> fedOpportunities = new List<Opportunity>();       
        Map<String, Account> fedAccountswithTerritoryInfo = new Map<String, Account>();
        Map<String, Opportunity> fedOpportunityswithTerritoryInfo = new Map<String, Opportunity>();
        List<AccountTeamMember> fedTeams=new List<AccountTeamMember>();
        List<OpportunityTeamMember> listOtm=new List<OpportunityTeamMember>();            
        Account acc = new Account(Name = 'accname' , Sales_Territory__c = ter1.id, Is_Federal_Account_Sync__c = true);
        Account acc1 = new Account( Name = 'accname1', Sales_Territory__c = ter2.id , Is_Federal_Account_Sync__c = true );
        fedAccounts.add(acc);
        fedAccounts.add(acc1);
        insert fedAccounts;
        fedAccountswithTerritoryInfo.put(acc.id, acc);
        fedAccountswithTerritoryInfo.put(acc1.id, acc1);       
        Opportunity opp = new Opportunity(name='opp', stagename = Label.Stage_1_Alignment , closedate = date.today(),accountId = acc.Id, Is_Federal_Opportunity_Sync__c = true);
        Opportunity opp1 = new Opportunity(name='opp1', stagename = Label.Stage_1_Alignment , closedate = date.today(),accountId = acc1.Id, Is_Federal_Opportunity_Sync__c = true);
        fedOpportunities.add(opp);
        fedOpportunities.add(opp1);
        insert fedOpportunities;     
        fedOpportunityswithTerritoryInfo.put(opp.id, opp);
        fedOpportunityswithTerritoryInfo.put(opp1.id, opp1);      
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid=acc.id;
        atm.teamMemberRole='Sales Engineer';
        atm.UserId=userOne.Id;
        atm.AccountAccessLevel='Read/Write';
        atm.OpportunityAccessLevel = 'Read/Write';
        atm.CaseAccessLevel='Read/Write';
        fedTeams.add(atm);       
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.Opportunityid=opp.id;
        otm.teamMemberRole='Sales Engineer';
        otm.UserId=userOne.Id;
        listOtm.add(otm);
        
        Test.startTest();
        try{
            Map<String,String> result = TERRITORYSYNC.doGet();
            System.debug(result);
        }catch(Exception ex){
            System.debug('in catch' + ex.getMessage());            
        }
        Test.stopTest();
    }
 
}