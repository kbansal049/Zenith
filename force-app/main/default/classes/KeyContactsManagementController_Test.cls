/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* KeyContactsManagementController_Test
* @description    This is the test class covering KeyContactsManagementController class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-02-20
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-13      IBA-6638 Aman - Key Contacts Component Controller Test Class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@isTest
public class KeyContactsManagementController_Test {
    @testSetup
    static void prepareTestData() {
        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser
        (
            'Test', 
            'System Admin', 
            ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR,
            ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS
        );
        insert testSystemAdminUser;

        User testSalesUser = ZSL2OTestDataFactory.prepareTestUser
        (
            'Test', 
            'Sales User', 
            ZScalarConstants.PROFILE_CORE_SALES, 
            ZScalarConstants.ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION
        );
        insert testSalesUser;

        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        
        System.runAs(testSystemAdminUser) {
            List<Account> testAccountList = ZSL2OTestDataFactory.prepareTestAccounts
            (
                'Prospect', 
                null, 
                null, 
                null, 
                null, 
                1
            );
            insert testAccountList;
    
            List<Contact> testContactList = ZSL2OTestDataFactory.preareTestContacts
            (
                testAccountList[0].Id,
                20
            );
            insert testContactList;
        }

        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('ContactTriggerHandler');
    }
    
    @isTest
    static void testGetContactWrapperMap(){
        User testSalesUser = [SELECT Id 
            FROM User 
            WHERE Name = 'Test Sales User' 
            LIMIT 1];

        Account accountRecord = 
        [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test Account 1' 
            LIMIT 1
        ];
        Map<Id, KeyContactsManagementController.ContactWrapper> contactWrapperMap = new Map<Id, KeyContactsManagementController.ContactWrapper>();
        System.runAs(testSalesUser) {
            Test.startTest();
            contactWrapperMap = KeyContactsManagementController.getContactWrapperMap(accountRecord.Id);
            Test.stopTest();
        }
        System.assertEquals(contactWrapperMap.size(), 20, 'Contact wrapper size mismatch');
    }

    @isTest
    static void testUpdateKeyContactsInformation(){
        User testSalesUser = [SELECT Id 
            FROM User 
            WHERE Name = 'Test Sales User' 
            LIMIT 1];

        Account accountRecord = 
        [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test Account 1' 
            LIMIT 1
        ];
        List<Contact> testContactList = [SELECT Id FROM Contact WHERE accountId =:accountRecord.Id LIMIT 4];
        System.runAs(testSalesUser) {
            Test.startTest();
            Map<String, String> accountDataMap = getAccountDataMap(accountRecord, testContactList);
            Set<Id> contactIds = new Set<Id>();
            for (Contact contactRecord :testContactList) {
                contactIds.add(contactRecord.Id);
            }
            KeyContactsManagementController.updateKeyContactsInformation
            (
                JSON.serialize(accountDataMap),
                JSON.serialize(contactIds),
                true
            );
            Test.stopTest();
        }
        Account updateAccountRecord = 
        [
            SELECT Id, HeadOfIT__c,
            HeadOfNetworking__c, HeadOfSecurity__c,
            Head_of_Architecture__c
            FROM Account 
            WHERE Id = :accountRecord.Id
            LIMIT 1
        ];
        System.assertEquals(updateAccountRecord.HeadOfIT__c != null, true, 'Head Of IT is not updated');
        System.assertEquals(updateAccountRecord.HeadOfNetworking__c != null, true, 'Head Of Networking is not updated');
        System.assertEquals(updateAccountRecord.HeadOfSecurity__c != null, true, 'Head Of Security is not updated');
        System.assertEquals(updateAccountRecord.Head_of_Architecture__c != null, true, 'Head Of Architecture is not updated');
    }

    private static Map<String, String> getAccountDataMap(Account accountRecord, List<Contact> contactList) {
        Map<String, String> accountDataMap = new Map<String, String>();
        accountDataMap.put('recordId', accountRecord.Id);
        accountDataMap.put('headOfIT', contactList[0].Id);
        accountDataMap.put('headOfNetworking', contactList[1].Id);
        accountDataMap.put('headOfSecurity', contactList[2].Id);
        accountDataMap.put('headOfArchitecture', contactList[3].Id);
        return accountDataMap;
    }
}