@isTest
private class OpportunitySplitUpdaterBatchTest {
    
    static testmethod void run(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account a = new Account(Name = 'TestAccount');
        insert a;   
        
        Contact con = new Contact(FirstName = 'Test',LastName = 'Contact',Email = 'william@mblogistics.net',AccountId = a.Id,phone = '0552132545');
        insert con; 
        
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                 LastName = 'last',Email = 'max@bupa.com',Username = 'max@bupa.com',CompanyName = 'TEST');
        insert testuser;
        
        User testuser1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                  LastName = 'neeraj',Email = 'testing@bupa.com',Username = 'test@bupa.com',CompanyName = 'forceapozee');
        insert testuser1;
        
        Opportunity o = new Opportunity(Name='TestOpp',AccountId = a.id,OwnerId = testuser.Id,StageName = ZScalarConstants.Opp_STAGE_1,CloseDate=Date.today());     
        insert o;
        
        PatchTeam__c pt = new PatchTeam__c(Account_Manager__c = testuser.id,Channel_Manager__c = testuser.id , ZPA_Manager__c = testuser.id);
        pt.Sales_Territory_Year__c = 'Current';
        insert pt;
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.User__c = testuser.Id;
        ptm.PatchTeam__c = pt.Id;
        insert ptm;
        
        OpportunitySplit os = new OpportunitySplit(OpportunityId = o.id,SplitOwnerId = testuser1.id, Owner_Sales_Territory__c = pt.Id);
        insert os;
        
        OpportunitySplitUpdaterBatch ld = new OpportunitySplitUpdaterBatch(new set<id>());
        database.executeBatch(ld);
        
    }
    
    static testmethod void run1(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account a = new Account(Name = 'TestAccount');
        insert a;   
        
        
        Contact con = new Contact(FirstName = 'Test',LastName = 'Contact',Email = 'william@mblogistics.net',AccountId = a.Id,phone = '0552132545');
        insert con; 
        
        
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                 LastName = 'last',Email = 'max@bupa.com',Username = 'max@bupa.com',CompanyName = 'TEST');
        insert testuser;
        
        User testuser1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                  LastName = 'neeraj',Email = 'testing@bupa.com',Username = 'test@bupa.com',CompanyName = 'forceapozee');
        insert testuser1;
        
        Opportunity o = new Opportunity(Name='TestOpp',AccountId = a.id,OwnerId = testuser.Id,StageName = ZScalarConstants.Opp_STAGE_1,CloseDate=Date.today());     
        insert o;
        
        PatchTeam__c pt = new PatchTeam__c(Account_Manager__c = testuser.id,Channel_Manager__c = testuser.id , ZPA_Manager__c = testuser.id);
        insert pt;
        
        OpportunitySplit os = new OpportunitySplit(OpportunityId = o.id,SplitOwnerId = testuser1.id, Owner_Sales_Territory__c = pt.Id);
        
        insert os;
        
        String contriggerId = System.schedule('testscheduledApex',
                                              '0 0 0 3 9 ?' ,
                                              new OpportunitySplitUpdaterScheduler());
    }
}