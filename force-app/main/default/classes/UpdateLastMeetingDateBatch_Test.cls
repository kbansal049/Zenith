@isTest
private class UpdateLastMeetingDateBatch_Test { 
    
    
    private static @isTest void test()
    {
        Test.startTest();
        account myAccount = new account();
        myAccount.Name = 'test account';
        myAccount.Type = 'industry analyst';
        insert myAccount;
        
        Account_Extension__c acountExtension = new Account_Extension__c();
        acountExtension.Account__c = myAccount.id;
        database.insert(new list<Account_Extension__c>{acountExtension});
        
        account myAccount1 = new account();
        myAccount1.Name = 'test account1';
        myAccount1.Type = 'industry analyst';
        insert myAccount1;
        
        Account_Extension__c acountExtension1 = new Account_Extension__c();
        acountExtension1.Account__c = myAccount1.id;
        database.insert(new list<Account_Extension__c>{acountExtension1});
        
        Contact myContact = new Contact();
        myContact.LastName = 'test contact';
        myContact.Email = 'Test@gmail.com';
        myContact.AccountId = myAccount.id;
        insert myContact;
        
        Contact myContact1 = new Contact();
        myContact1.LastName = 'test contact1';
        myContact1.Email = 'Test1@gmail.com';
        myContact1.AccountId = myAccount.id;
        insert myContact1;
        
        dateTime dt = Datetime.now();
        event myEvent = new event();
        myEvent.Subject = 'test meeting with CSIO 1';
        myEvent.StartDateTime = dt.addDays(-1) ;
        myEvent.EndDateTime = dt;
        myEvent.Type = System.Label.Post_Sale_CISO_Security_Policy_Review;
        myEvent.WhoId = myContact1.id;
        myEvent.peopleai__MeetingStatus__c = 'Completed';
        insert myEvent;
        
        event myEvent1 = new event();
        myEvent1.Subject = 'test meeting with CSIO';
        myEvent1.StartDateTime = dt.addDays(-2) ;
        myEvent1.EndDateTime = dt;
        myEvent1.Type = System.Label.VO_Product_Directions_Meeting;
        myEvent1.WhoId = myContact.id;
        myEvent1.peopleai__MeetingStatus__c = 'Completed';
        insert myEvent1;
        
        
        
        String cronExp = '0 0 */6 * * ?'; //every 6 hours
        UpdateLastMeetingDateBatch ub = new UpdateLastMeetingDateBatch();
		Database.executeBatch(ub);
        System.Schedule('update last meeting',cronExp,ub);
        Test.stopTest();

    }
    
}