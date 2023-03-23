@isTest
private class LeadStatusUpdateTest {
    static testmethod void run(){
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'last',FirstName = 'Test',
                          Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' + System.currentTimeMillis(),CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');  
        insert u;
        
        Lead l = new lead(Company = 'Testing Sample Co',lastname= 'testperfy',status='Actively Engaged',Remarks__c = 'Replied: Not Interested', ownerid=u.Id);
        l.Outreach_Status__c='Connected';
        insert l;
        
        LeadStatusUpdateBatch ld = new LeadStatusUpdateBatch(new set<id>());
        database.executeBatch(ld);
    }
    static testmethod void run1(){
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'last',FirstName = 'Test',
                          Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' + System.currentTimeMillis(),CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');  
        insert u;
        
        Lead l = new lead(Company = 'Testing Sample Co',lastname= 'testperfy',status='Actively Engaged',Remarks__c = 'Replied: Not Interested', ownerid=u.Id);
        l.Outreach_Status__c='Connected';
        insert l;
        
        System.schedule('Schedule hourly Test job', '0 0 * * * ? 2029', new LeadStatusUpdateScheduler() );

    }
}