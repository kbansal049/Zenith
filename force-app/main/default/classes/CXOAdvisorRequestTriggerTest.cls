@isTest
public class CXOAdvisorRequestTriggerTest {
    
    @testSetup  static void setupdata(){
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_CXOAdvisorRequest_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Populate_CXO_Advisor', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
    }
    
    @IsTest
    static void test1(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(LastName = 'Moldenhauer',
                                FirstName='Brad',
                                Alias = 'tUAcc',
                                Email = 'test1.test@test.com',
                                Username = 'test1.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US',
                              	full_name__c = 'Brad Moldenhauer'
                               );
		insert user1;
        User user2 = new User(LastName = 'Shelton',
                                FirstName='Dan',
                                Alias = 'tUAcc',
                                Email = 'test2.test@test.com',
                                Username = 'test2.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US',
                              	full_name__c = 'Dan Shelton'
                               );
		insert user2;
        //Create account
       CTO_CISO_Transformation_Team_Member__c a = new CTO_CISO_Transformation_Team_Member__c();
        a.Area__c = 'AMERICAS';
        a.Linked_CISO_Team_Member__c = user1.id;
        a.type__c = 'Field CISO';
        insert a;
        CTO_CISO_Transformation_Team_Member__c b = new CTO_CISO_Transformation_Team_Member__c();
        b.region__c = 'AMERICAS';
        b.Linked_CTO_Team_Member__c = user2.id;
        b.type__c = 'Field CTO';
        insert b;
        
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Area__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;      
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Partner' Limit 1]; 
        Account Account1 = new Account(
            Name = 'TestAccount',
            recordTypeId=rt.id
        );
        Database.insert(Account1);
        Account_Extension__c actExtension =new Account_Extension__c();
        actExtension.Account__c = Account1.id;
        actExtension.Field_CISO__c = user1.id;
        actExtension.Field_CTO__c = user2.id;
        insert actExtension;
        Account Account2 = new Account(
            Name = 'TestAccount2',
            recordTypeId=rt.id
        );
        Database.insert(Account2);
        Account_Extension__c actExtension2 =new Account_Extension__c();
        actExtension2.Account__c = Account2.id;
        actExtension.Field_CTO__c = user2.id;
        actExtension.Field_CISO__c = user1.id;
        insert actExtension2;
        Account1.Sales_Territory__c = salestert.Id;
        Account1.Patch__c = patch.Id;
        update Account1;
        Account2.Sales_Territory__c = salestert.Id;
        Account2.Patch__c = patch.Id;
        update Account2;
        //Create Opportunity
        opportunity opp = new opportunity( Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = Account1.Id, 
                                          StageName = label.Stage_1_Alignment, 
                                          CloseDate = Date.newInstance(system.today().Year(), 2, 1));
        Database.insert(opp);
        //Create CXO_Advisor_Request__c
        Id recordId = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosByDeveloperName().get('Field_CTO').getRecordTypeId();
        system.debug('--'+recordId);
        CXO_Advisor_Request__c cxo = new CXO_Advisor_Request__c(
            CXO_Request_Status__c = '4 - Completed', 
            Opportunity__c = opp.Id,
            Account_Name__c= Account1.id,
        RecordTypeId = recordId);
        Database.insert(cxo);
        Id recordId1 = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosByDeveloperName().get('Field_CISO').getRecordTypeId();
         CXO_Advisor_Request__c cxo1 = new CXO_Advisor_Request__c(
            CXO_Request_Status__c = '4 - Completed', 
            Opportunity__c = opp.Id,
            Account_Name__c= Account1.id,
        RecordTypeId = recordId1);
        Database.insert(cxo1);
        opportunity opp1 = [select CXO_Sourced__c, CXO_Advisor__c from Opportunity where id =:opp.id];
        cxo.Account_Name__c= Account2.id;
        update cxo;
    }
    
}