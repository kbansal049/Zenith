@isTest
private class SpeakersTriggerHandlerTest {
    
    private static Id cxoSpeakerRecordTypeId = Schema.SObjectType.Speakers__c.getRecordTypeInfosByName().get(ZSL2OConstants.CXO_SPEAKER_RECORD_TYPE_NAME).getRecordTypeId();
    private static Id speakerRecordTypeId = Schema.SObjectType.Speakers__c.getRecordTypeInfosByName().get(ZSL2OConstants.SPEAKER_RECORD_TYPE_NAME).getRecordTypeId();

    @testSetup
    static void prepareTestData() {
        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'System Admin', ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR, ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS);
        insert testSystemAdminUser;

        User testCoordinatorUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'Coordinator User', ZScalarConstants.PROFILE_CORE_SALES, 
            ZScalarConstants.ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION);
        insert testCoordinatorUser;

        ZSL2OTestDataFactory.assignPermissionSet(testCoordinatorUser.Id, ZSL2OConstants.PERMISSION_SET_NAME_SPEAKER_BUREAU_COORDINATOR);

        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('CampaignTriggerHandler');
        
        System.runAs(testSystemAdminUser) {
            List<Contact> testContactList = ZSL2OTestDataFactory.preareTestContacts(null, 1);
            insert testContactList;
    
            List<Account> testAccountList = ZSL2OTestDataFactory.prepareTestAccounts(ZSL2OConstants.ACCOUNT_TYPE_PROSPECT, testContactList[0].Id, null, null, null, 2);
            insert testAccountList;
    
            testContactList[0].AccountId = testAccountList[0].Id;
            update testContactList;
    
            List<Campaign> testCampaignList = ZSL2OTestDataFactory.prepareTestCampaigns(ZSL2OConstants.FISCAL_YEAR_FY_22, 1000, 1);
            insert testCampaignList;
        }

        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('CampaignTriggerHandler');
    }

    @isTest 
    static void testWhenRatedByProvidedForNotAttendedStatusForInsert() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, null, null, 
            UserInfo.getName(), cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Exception expectedException = null;

            Test.startTest();
            try {
                insert testSpeakersList;
            } catch (Exception ex) {
                expectedException = ex;
            }
            Test.stopTest();

            System.assertNotEquals(null, expectedException, 'Rated By Exception is expected');
            System.assert(expectedException.getMessage().contains(ZSL2OConstants.SPEAKERS_SPEAKER_RATING_NOT_ALLOWED_ERROR_MESSAGE), 
                'Error should be thrown for Invalid Speaker Rating.');
        }
    }

    @isTest 
    static void testWhenRatedByProvidedAndTechSavvyNotProvidedForAttendedStatusForInsert() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, ZSL2OConstants.STATUS_ATTENDED, 
            null, null, UserInfo.getName(), cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Exception expectedException = null;

            Test.startTest();
            try {
                insert testSpeakersList;
            } catch (Exception ex) {
                expectedException = ex;
            }
            Test.stopTest();

            System.assertNotEquals(null, expectedException, 'Mandatory Fields are missing exception is expected');
            System.assert(expectedException.getMessage().contains(ZSL2OConstants.SPEAKERS_FILL_MANDATORY_FIELDS_WHEN_RATING_THE_SPEAKER_ERROR_MESSAGE), 
                'Error should be thrown for Invalid Speaker Rating.');
        }
    }

    @isTest 
    static void testIfSpeakersAccountNameIsPopulatedForInsert() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, null, null, 
            null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Test.startTest();
            insert testSpeakersList;
            Test.stopTest();

            Speakers__c resultSpeaker = [SELECT Id, Speakers_Account_Name__c FROM Speakers__c WHERE Id = :testSpeakersList[0].Id];
            System.assertEquals(testContact.Account.Name, resultSpeaker.Speakers_Account_Name__c, 'Speaker\'s Account Name should be same as CXO Speaker\'s Account Name');
        }
    }

    @isTest 
    static void testIfCXOSpeakersSpeakerStatusIsSetToAttendedForInsert() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, ZSL2OConstants.STATUS_ATTENDED, 
            null, null, null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Test.startTest();
            insert testSpeakersList;
            Test.stopTest();

            Contact resultContact = [SELECT Id, Speaker_Status__c FROM Contact WHERE Id = :testContact.Id];
            System.assertEquals(ZSL2OConstants.STATUS_ATTENDED, resultContact.Speaker_Status__c, 'CXO Speaker\'s Speaker Status should be Attended');
        }
    }

    @isTest 
    static void testWhenRatedByProvidedForNotAttendedStatusForUpdate() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, null, null, 
            null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Exception expectedException = null;

            Test.startTest();
            try {
                insert testSpeakersList;

                testSpeakersList[0].Rated_By__c = UserInfo.getName();
                update testSpeakersList;
            } catch (Exception ex) {
                expectedException = ex;
            }
            Test.stopTest();

            System.assertNotEquals(null, expectedException, 'Rated By Exception is expected');
            System.assert(expectedException.getMessage().contains(ZSL2OConstants.SPEAKERS_SPEAKER_RATING_NOT_ALLOWED_ERROR_MESSAGE), 
                'Error should be thrown for Invalid Speaker Rating.');
        }
    }

    @isTest 
    static void testWhenRatedByProvidedAndTechSavvyNotProvidedForAttendedStatusForUpdate() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, ZSL2OConstants.STATUS_ATTENDED, 
            null, null, null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Exception expectedException = null;

            Test.startTest();
            try {
                insert testSpeakersList;

                testSpeakersList[0].Rated_By__c = UserInfo.getName();
                update testSpeakersList;
            } catch (Exception ex) {
                expectedException = ex;
                
            }
            Test.stopTest();
            
            System.assertNotEquals(null, expectedException, 'Mandatory Fields are missing exception is expected');
            System.assert(expectedException.getMessage().contains(ZSL2OConstants.SPEAKERS_FILL_MANDATORY_FIELDS_WHEN_RATING_THE_SPEAKER_ERROR_MESSAGE), 
                'Error should be thrown for Invalid Speaker Rating.');
        }
    }

    @isTest 
    static void testIfSpeakersAccountNameIsPopulatedForUpdate() {
        TriggerHandler.bypass('AccountTriggerHandler');

        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name, AccountId FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2' AND HeadOfIT__c = :testContact.Id LIMIT 1];
        String initialAccountName = testContact.AccountId != null ? testContact.Account.Name : null;
        
        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, null, null, 
            null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Test.startTest();
            insert testSpeakersList;

            testSpeakersList[0].Status__c = ZSL2OConstants.STATUS_ATTENDED;
            update testSpeakersList;

            testContact.AccountId = testAccount.Id;
            update testContact;

            Test.stopTest();

            Speakers__c resultSpeaker = [SELECT Id, Speakers_Account_Name__c FROM Speakers__c WHERE Id = :testSpeakersList[0].Id];
            System.assertEquals(initialAccountName, resultSpeaker.Speakers_Account_Name__c, 'Speaker\'s Account Name should be same as CXO Speaker\'s Account Name');
        }
    }

    @isTest 
    static void testIfCXOSpeakersSpeakerStatusIsSetToAttendedForUpdate() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];
        
        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, null, null, 
            null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Test.startTest();
            insert testSpeakersList;

            testSpeakersList[0].Status__c = ZSL2OConstants.STATUS_ATTENDED;
            update testSpeakersList;
            Test.stopTest();

            Contact resultContact = [SELECT Id, Speaker_Status__c FROM Contact WHERE Id = :testContact.Id];
            System.assertEquals(ZSL2OConstants.STATUS_ATTENDED, resultContact.Speaker_Status__c, 'CXO Speaker\'s Speaker Status should be Attended');

            
        }
    }

    @isTest 
    static void testIfCXOSpeakersSpeakerStatusIsSetToNullForUpdate() {
        User testCoordinatorUser = [SELECT Id FROM User WHERE Name = 'Test Coordinator User' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, ZSL2OConstants.STATUS_ATTENDED, 
            null, null, null, cxoSpeakerRecordTypeId, 1);

        System.runAs(testCoordinatorUser) {
            Test.startTest();
            insert testSpeakersList;

            testSpeakersList[0].Status__c = null;
            update testSpeakersList;
            Test.stopTest();
            
            Contact resultContact = [SELECT Id, Speaker_Status__c FROM Contact WHERE Id = :testContact.Id];
            System.assertEquals(null, resultContact.Speaker_Status__c, 'CXO Speaker\'s Speaker Status should be Attended');
        }
    }

    @isTest 
    static void testIfSpeakerStatusIsNoneByDefaultForInsert() {
        User testSystemAdminUser = [SELECT Id FROM User WHERE Name = 'Test System Admin' LIMIT 1];
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Contact testContact = [SELECT Id, Account.Name FROM Contact WHERE Name = 'Test Contact 1' AND CTM_Contact__c = true LIMIT 1];

        List<Speakers__c> testSpeakersList = ZSL2OTestDataFactory.prepareTestSpeakers(testCampaign.Id, testContact.Id, null, 
            null, null, null, speakerRecordTypeId, 1);

        System.runAs(testSystemAdminUser) {
            Test.startTest();
            insert testSpeakersList;
            Test.stopTest();
            
            Speakers__c resultSpeaker = [SELECT Id, Status__c FROM Speakers__c WHERE Id = :testSpeakersList[0].Id];
            System.assert(String.isBlank(resultSpeaker.Status__c), 'Speaker Status should be blank');
        }
    }
}