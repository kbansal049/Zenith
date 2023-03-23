@isTest
public class UpdateContactPortalUserBatchTest {
    @IsTest
    static void test1(){
        //Create account
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Partner' Limit 1]; 
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            //OwnerId = portalAccountOwner1.Id,
            recordTypeId=rt.id
        );
        Database.insert(portalAccount1);
        
        //Create contact
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = 'test@test.com'
        );
        Database.insert(contact1);
        
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Customer Community User Profile%' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);
        Test.startTest();
        system.schedule('Test Contact Portal User Job', '0 0 0 * * ?', new UpdateContactPortalUserBatchScheduler());        
        Test.stopTest();        
        Contact userContact = [select id, portal_user__c from Contact where lastname = 'McTesty'];
        system.assert(userContact.portal_user__c = true);

        UpdateContactPortalUserBatch batch;
        batch = new UpdateContactPortalUserBatch('select id from Contact where Portal_User__c = true and id in (select contactid from User where isActive = true)', 'checkportaluser');
        batch.errorlst.add('Test Error');
        Database.executeBatch(batch,10);

    }


}