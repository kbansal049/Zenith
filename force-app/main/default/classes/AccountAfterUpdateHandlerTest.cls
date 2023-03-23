@isTest
private class AccountAfterUpdateHandlerTest{
    
    @testSetup
    static void data(){
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
       opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 200000,
                                          CloseDate = system.Today().addDays(+30),
                                          StageName = Label.Stage_2_Qualified_Budgeted,
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() , SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
    }    
    static testMethod void run(){
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            
        );
        insert u;
        
        test.startTest();
        Account a =[Select Id,Solution_Architect__c,Last_Architecture_Workshop_Date__c from Account where Name = 'Test Account' LIMIT 1];        
        a.Solution_Architect__c = u.Id;
        a.Last_Architecture_Workshop_Date__c = system.today().addDays(-200);
        update a;
        Opportunity o = [Select ID,Amount,StageName,Type,Flexible_Identifier__c from Opportunity limit 1];
		system.debug('### test opp'+o);
        AccountAfterUpdateHandler.conditionsMeet(o);
        test.stopTest();       
        
    }
    
}