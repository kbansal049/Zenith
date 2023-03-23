@isTest
public class genericFeedCommentTriggerTest {
    public static testMethod void genericFeedComment(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
         Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;
     
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(FirstName = 'Test',Lastname = 'Amit',AccountId = portalAccount1.Id,Email = 'test@test.com');
        insert contact1;
        
        Test.startTest();
        
        Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        User ur2 = new User(Email='dummy1@dummy.com77',ProfileId=profileId2.id,LastName='Lastname1',FirstName='Firstname1',
                           Alias='testf',Username='test11@asdf123444.com',TimeZoneSidKey='GMT',LanguageLocaleKey='en_US',
                           EmailEncodingKey='UTF-8',LocaleSidKey='en_US',service_Level__c='L1',IsPortalSelfRegistered=true,contactId = contact1.id);

        insert ur2;
        System.runAs ( ur2 ) {
			Account acct = new Account();
			acct.name = 'Test Account';
			acct.Type = 'Customer';
			acct.RecordTypeId = '01270000000EAFsAAO';
			acct.X3rd_TAM_Name__c = UserInfo.getUserId();
			acct.BillingCountry = 'xyz';
			acct.BillingCity = 'abc';
			acct.BillingStreet = 'asdsa';
			insert acct;
			Contact ct = new Contact();
			ct.LastName ='test';
			ct.Email ='test@test.com';
			insert ct;
			Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
			Case cs = new Case();
			cs.Status = 'New';
			cs.AccountId = acct.Id;
			cs.Subject = 'tetes sub';
			cs.RecordTypeId = RecordTypeIdCase;
			insert cs;
			FeedItem fi = new FeedItem();
			fi.ParentId = cs.Id;
			fi.Body = 'teste';
			insert fi;
			TriggerUtility.skipFRTandCustomerNote = false;
			FeedComment fc = new FeedComment();
			fc.FeedItemId = fi.Id;
			fc.CommentBody='test body';
			insert fc;
			//FeedCommentTriggerUtility.booster();
			System.debug('inserted by:-'+fc.InsertedById);
        }
        Test.stopTest();
    }
}