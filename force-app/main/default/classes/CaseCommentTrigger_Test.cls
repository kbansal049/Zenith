@istest
public class CaseCommentTrigger_Test {
    @IsTest
    static void test1(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        //Added by Swathi: CR#1058 Start 
        Profile profileId1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User ur = new User(Email='dummy1@dummy.com77',ProfileId=profileId1.id,LastName='Lastname1',FirstName='Firstname1',
                           Alias='testf',Username='test11@asdf123444.com',TimeZoneSidKey='GMT',LanguageLocaleKey='en_US',
                           EmailEncodingKey='UTF-8',LocaleSidKey='en_US',service_Level__c='L1');
        insert ur;
        //Added by Swathi: CR#1058 End
        Test.startTest();
        //Modified by Swathi: CR#1058
        System.runAs(ur){
            Casecomment cc1 = new Casecomment(parentId = cs.Id);
            cc1.CommentBody = 'abcd';
            cc1.isPublished = true;
            insert cc1;
			//CaseCommentTriggerUtility.booster();
        }
        Test.stopTest();
        
    }
    /*@IsTest
    static void test2(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        System.runAs(ur){
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
            TriggerUtility.SkipCaseTriggerExecuted();
            insert cs;
            Test.startTest();
            Casecomment cc1 = new Casecomment(parentId = cs.Id);
            cc1.CommentBody = 'abcd';
            cc1.isPublished = true;
            insert cc1;
        }
        Test.stopTest();
        
    }*/
	//Added by Swathi: CR#1058 Start
    @IsTest
    static void test2(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        
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
            Casecomment cc1 = new Casecomment(parentId = cs.Id);
            cc1.CommentBody = 'abcd';
            cc1.isPublished = true;
            //insert cc1;
            try{
            insert cc1;
            }catch(Exception ex){
            
        }
            System.debug('Ur2');
        }
        Test.stopTest();
        
    }
	//Added by Swathi: CR#1058 End
}