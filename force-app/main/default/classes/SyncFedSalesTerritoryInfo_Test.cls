@istest
public class SyncFedSalesTerritoryInfo_Test{   
    
    // This test method covers the use case that all sales territory info gets migrated to comm 
    static testMethod void testFedSalesTerritory1() {       
        // Create test users 
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
        // Create sales territory
        PatchTeam__c ter1 = new PatchTeam__c(name ='Fed-05');
        insert ter1;
        PatchTeam__c ter2 = new PatchTeam__c(name ='Fed-05');
        insert ter2;
        
        // Create Account,Oppportunities,accountteam and oppportunity team that get updated
        List<Account> fedAccounts = new List<Account>();
        List<Opportunity> fedOpportunities = new List<Opportunity>();
        Map<String, Account> fedAccountswithTerritoryInfo = new Map<String, Account>();
        Map<String, Opportunity> fedOpportunityswithTerritoryInfo = new Map<String, Opportunity>();
        List<AccountTeamMember> fedTeams=new List<AccountTeamMember>();
        List<OpportunityTeamMember> listOtm=new List<OpportunityTeamMember>();           
        Account acc = new Account(Name = 'accname' , Sales_Territory__c = ter1.id);
        Account acc1 = new Account( Name = 'accname1', Sales_Territory__c = ter2.id );
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
        atm.accountid=opp.Id;
        atm.teamMemberRole='Sales Engineer';
        atm.UserId=userTwo.Id;
        atm.AccountAccessLevel='Edit';
        atm.OpportunityAccessLevel = 'Edit';
        atm.CaseAccessLevel='Edit';
        atm.ContactAccessLevel='Edit';
        fedTeams.add(atm);       
        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.accountid=acc.Id;
        atm2.teamMemberRole='Account Manager';
        atm2.UserId=userOne.Id;
        atm2.AccountAccessLevel = 'Edit';
        atm2.OpportunityAccessLevel = 'Edit';
        atm2.CaseAccessLevel='Edit';
        atm2.ContactAccessLevel='Edit';
        fedTeams.add(atm2);     
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.accountid=acc.Id;
        atm1.teamMemberRole='Area Director';
        atm1.UserId=userOne.Id;
        atm.AccountAccessLevel = 'Edit';
        atm.OpportunityAccessLevel = 'Edit';
        atm.CaseAccessLevel='Edit';
        atm.ContactAccessLevel='Edit';
        fedTeams.add(atm1);      
        OpportunityTeamMember otm1 = new OpportunityTeamMember();
        otm1.Opportunityid=opp.Id;
        otm1.teamMemberRole='Sales Engineer';
        otm1.UserId=userOne.Id;
        listOtm.add(otm1);
        OpportunityTeamMember otm2 = new OpportunityTeamMember();
        otm2.Opportunityid=opp.Id;
        otm2.teamMemberRole='Account Manager';
        otm2.UserId=userTwo.Id;
        listOtm.add(otm2);
        OpportunityTeamMember otm3 = new OpportunityTeamMember();
        otm3.Opportunityid=acc.Id;
        otm3.teamMemberRole='Area Director';
        otm3.UserId=userTwo.Id;
        listOtm.add(otm3);
        
        Test.startTest();
        try{
            delete ter1;
            // Run the test
            String result = SyncFedSalesTerritoryInfo.doPost(fedAccountswithTerritoryInfo,fedOpportunityswithTerritoryInfo, fedTeams, listOtm, fedTeams, listOtm);
            System.debug(result);
            
            String  ac = [select id, Sales_Territory__c from Account where id= :acc.id].Sales_Territory__c;
            String ac1 = [select id, Sales_Territory__c from Account where id= :acc1.id].Sales_Territory__c;
            
            System.debug('ac.Sales_Territory__c:=' + ac + ' ' +  ac1 );
            // As to cover datbase.error we had to delete the sales territory
            System.assertEquals('Pass', result, 'Sales Territory did not get  updated');
            System.assertEquals(null, ac, 'Sales Territory did not get  updated');
            System.assertEquals(ter2.id, ac1, 'Sales Territory did not get  updated');
            
        }catch(Exception ex){
            System.debug('in catch' + ex.getMessage());
            
        }
        Test.stopTest();
    } 
    
    // This test method cover the exception when sales territory attached to a account gets deleted and do database.error gets executed
    static testMethod void testFedSalesTerritory4_Negative() {
        
        // Create test user 
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
        //Create Sales Territory
        PatchTeam__c ter1 = new PatchTeam__c(name ='Fed-05');
        insert ter1;
        PatchTeam__c ter2 = new PatchTeam__c(name ='Fed-05');
        insert ter2;
        // Create Account,Oppportunities,accountteam and oppportunity team that get updated
        List<Account> fedAccounts = new List<Account>();
        List<Opportunity> fedOpportunities = new List<Opportunity>();       
        Map<String, Account> fedAccountswithTerritoryInfo = new Map<String, Account>();
        Map<String, Opportunity> fedOpportunityswithTerritoryInfo = new Map<String, Opportunity>();
        List<AccountTeamMember> fedTeams=new List<AccountTeamMember>();
        List<OpportunityTeamMember> listOtm=new List<OpportunityTeamMember>();
        List<AccountTeamMember> listFedTeamsDelete=new List<AccountTeamMember>();
        List<OpportunityTeamMember> listFedOTeamsDelete=new List<OpportunityTeamMember>();
        Account acc = new Account(Name = 'accname' , Sales_Territory__c = ter1.id);
        Account acc1 = new Account( Name = 'accname1', Sales_Territory__c = ter2.id );
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
        fedTeams.add(atm);       
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.accountid=acc.id;
        atm1.teamMemberRole='Account Manager';
        atm1.UserId=userOne.Id;
        listFedTeamsDelete.add(atm1);
        insert   listFedTeamsDelete;     
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.Opportunityid=acc.id;
        otm.teamMemberRole='Sales Engineer';
        otm.UserId=userOne.Id;
        listOtm.add(otm);      
        OpportunityTeamMember otm1 = new OpportunityTeamMember();
        otm1.Opportunityid=opp.id;
        otm1.teamMemberRole='Account Manager';
        otm1.UserId=userOne.Id;
        listFedOTeamsDelete.add(otm1);
        insert   listFedOTeamsDelete;
        
        
        Test.startTest();
        try{
            // delete territory assigned to Account to kick off exception
            delete ter1;
            String result = SyncFedSalesTerritoryInfo.doPost(fedAccountswithTerritoryInfo,fedOpportunityswithTerritoryInfo, fedTeams, listOtm, listFedTeamsDelete,listFedOTeamsDelete );
            System.debug(result);
            
            String  ac = [select id, Sales_Territory__c from Account where id= :acc.id].Sales_Territory__c;
            String ac1 = [select id, Sales_Territory__c from Account where id= :acc1.id].Sales_Territory__c;
            
            System.debug('ac.Sales_Territory__c:=' + ac + ' ' +  ac1 );
            // As to cover datbase.error we had to delete the sales territory
            System.assertEquals('Pass', result, 'Sales Territory did not get  updated');
            System.assertEquals(null, ac, 'Sales Territory did not get  updated');
            System.assertEquals(ter2.id, ac1, 'Sales Territory did not get  updated');
            
        }catch(Exception ex){
            System.debug('in catch' + ex.getMessage());          
        }
        Test.stopTest();
    }
      
    // This test method cover the exception when no data come from Fed
    static testMethod void testFedSalesTerritory2_Negative() {
        
        Test.startTest();
        try{
            SyncFedSalesTerritoryInfo.doPost(null,null,null,null,null,null);           
        }catch(Exception ex){
            System.debug('in catch' +ex.getMessage());        
        }
        Test.stopTest();
    }
    
    
    // This test method cover the exception when sales territory attached to a account gets deleted and do database.error gets executed
    static testMethod void testFedSalesTerritory3_Postive() {
        
        // Create test user 
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
        // Create territory 
        PatchTeam__c ter1 = new PatchTeam__c(name ='Fed-05');
        insert ter1;       
        PatchTeam__c ter2 = new PatchTeam__c(name ='Fed-05');
        insert ter2;    
        // Create Account,Oppportunities,accountteam and oppportunity team that get updated
        List<Account> fedAccounts = new List<Account>();
        List<Opportunity> fedOpportunities = new List<Opportunity>();       
        Map<String, Account> fedAccountswithTerritoryInfo = new Map<String, Account>();
        Map<String, Opportunity> fedOpportunityswithTerritoryInfo = new Map<String, Opportunity>();
        List<AccountTeamMember> fedTeams=new List<AccountTeamMember>();
        List<OpportunityTeamMember> listOtm=new List<OpportunityTeamMember>();            
        Account acc = new Account(Name = 'accname' , Sales_Territory__c = ter1.id);
        Account acc1 = new Account( Name = 'accname1', Sales_Territory__c = ter2.id );
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
            delete ter1;
            String result = SyncFedSalesTerritoryInfo.doPost(fedAccountswithTerritoryInfo,fedOpportunityswithTerritoryInfo,FedTeams, listOtm, fedTeams,listOtm );
            System.debug(result);
            System.assertEquals('Pass', result, 'Sales Territory did not get  updated');
            
            String  ac = [select id, Sales_Territory__c from Account where id= :acc.id].Sales_Territory__c;
            String ac1 = [select id, Sales_Territory__c from Account where id= :acc1.id].Sales_Territory__c;
            
            System.debug('ac.Sales_Territory__c:=' + ac + ' ' +  ac1 );
            // As to cover datbase.error we had to delete the sales territory
            System.assertEquals(null, ac, 'Sales Territory did not get  updated');
            System.assertEquals(ter2.id, ac1, 'Sales Territory did not get  updated');
            
        }catch(Exception ex){
            System.debug('in catch' + ex.getMessage());            
        }
        Test.stopTest();
    }
 
}