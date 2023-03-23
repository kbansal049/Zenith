@isTest
private class EventTriggerHandlerTests {
    
    @TestSetup
    static void makeData(){
        List<Triggers_Switch__c> testTriggerSwitchList = new List<Triggers_Switch__c>();
        Set<String> triggerSwitchesNamesSet = new Set<String> {'Execute_Event_Trigger', 'Execute_Meeting_Tech_Teaming_Partner', 'Execute_UpdateRelatedToField', 
            'Execute_UpdateTargetCustomerNumber', 'updateCheckbox', 'Execute_Meeting_Tech_Teaming_Partner', 'Execute_UpdateRelatedToField', 'Execute_UpdateTargetCustomerNumber', 
            'updateAccountQBRDate'};
        for (String triggerSwitchName : triggerSwitchesNamesSet) {
            Triggers_Switch__c testTriggerSwitchRecord = new Triggers_Switch__c(
                Name = triggerSwitchName,
                Execute__c = true,
                Object_Name__c = 'Event'
            );
            testTriggerSwitchList.add(testTriggerSwitchRecord);
        }
        insert testTriggerSwitchList;
    }

    @isTest
    static void testBeforeInsert() {
        Contact testContact = new Contact(LastName = 'Test Contact 1');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testContact;
        }

        Event testEvent = new Event(Subject = 'Test Event', Type = 'Test Type', DurationInMinutes = 10, ActivityDateTime = System.now(), whoId = testContact.Id);
        User currentUser = [SELECT Id, TimeZoneSidKey, ProfileId, EmailEncodingKey, LocaleSidKey, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];

        UserRole testUserRole = new UserRole(Name = 'Test LDR');
        insert testUserRole;

        User testRunningUser = new User(LastName = 'Test User', Email = 'test@test.com', UserRoleId = testUserRole.Id, UserName = 'TestUserName.Test.user.name@test.com', Alias = 'TestA', 
            TimeZoneSidKey = currentUser.TimeZoneSidKey, ProfileId = currentUser.ProfileId, EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testRunningUser;

        System.runAs(testRunningUser) {
            Test.startTest();
                insert testEvent;

                testEvent.Type = 'Demo Type';
                update testEvent;
            Test.stopTest();
        }

        Event resultEvent = [SELECT Id, Type, Activity_Type__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];
        System.assertEquals(testEvent.Type, resultEvent.Type, 'The Activity Type should be same as Type');
        
    }

    @isTest
    static void testAfterDelete() {
        Event testEvent = new Event(Subject = 'Test Event', Type = 'Test Type', DurationInMinutes = 10, ActivityDateTime = System.now());
        insert testEvent;

        Test.startTest();
            delete testEvent;
        Test.stopTest();
    }
}