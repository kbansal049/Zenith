@isTest
private class OppArchitectEmailBatchTests {
    @testSetup
    static void data(){
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                 LastName = 'last',Email = 'max@bupa.com',Username = 'max@bupa.com',CompanyName = 'TEST');
        insert testuser ;
        
        Account account = new Account(Name = 'Test Account', Solution_Architect__c = UserInfo.getUserId(),Last_Architecture_Workshop_Date__c = system.today().addDays(-200) , Type = 'Prospect');
        insert account;
        
        Opportunity opp = new Opportunity( Name = 'Test opportunity', AccountId = account.Id,
                                          CloseDate = system.Today()+30, Amount = 200000, StageName = Label.Stage_2_Qualified_Budgeted,
                                          Type = 'New Business' , Flexible_Identifier__c = null,Architect__c =testuser.Id,
                                          Opportunity_Account_Manager__c = testuser.Id,SE_Name__c = testuser.Id);
        insert opp;
    }
    
    static testMethod void run(){
        
        EmailTemplate e = new EmailTemplate (developerName = 'Automated_Solution_Architect', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Automated Solution Architect');
        insert e;
        Opportunity o = [Select ID FROM Opportunity LIMIT 1 ];        
        
        OppArchitectEmailBatch b = new OppArchitectEmailBatch(new Set<Id>() );
        Database.executeBatch(b);
    }
    
    static testmethod void run2(){
        System.schedule('Email Architect Scheduler','20 30 8 10 2 ?', new OppArchitectEmailScheduler());
    }
    
}