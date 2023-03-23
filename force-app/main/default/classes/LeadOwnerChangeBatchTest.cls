@isTest
public class LeadOwnerChangeBatchTest {
    
    static testmethod void run(){
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,LastName = 'Admin',FirstName = 'Marketo',
                          Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' + System.currentTimeMillis(),CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');  
        insert u;
        
        Lead l = new lead(Company = 'Testing Sample Co',lastName= 'testperfy',Last_Opened_Date__c= system.today().addDays(+2), Lead_Development__c = u.Id , Project_Role__c = 'Business Exec - CEO/CFO',Status = 'Pending Marketing Qualification',ownerid=u.Id);
        insert l;
        
        Test.startTest();
        
        LeadOwnerChangeBatch ld = new LeadOwnerChangeBatch(new set<id>());
        database.executeBatch(ld);
        System.schedule('LeadOwnerChangeSchedular','0 0 13 * * ?', new LeadOwnerChangeBatchSchd());
        Test.stopTest();
    }
    
}