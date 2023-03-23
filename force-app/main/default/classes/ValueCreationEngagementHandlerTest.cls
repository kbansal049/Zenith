/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ValueCreationEngagementHandlerTest
* @description    This is the Value Creation Engagement Handler test class called synchronously from 
                  genericVCEtrigger.
*				  All the methods needs to be called synchronously from the trigger should be called
* 				  from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-01-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-13      IBA-5937 Aman - Creation of the class for adding the logic to populate Overall BVA 
                  Score and Value creation stage change beforeInsert, beforeUpdate, afterInsert and 
                  afterUpdate.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@isTest
public class ValueCreationEngagementHandlerTest{

    //private constants
    private static final String VALUE_CREATION_ENGAGEMENT_RECORD_TYPE_NAME = 'Value_Creation_Engagement';
    private static final String OPPORTUNITY_NEW_BUSINESS_RECORD_TYPE_NAME = 'New_Business_Open';
    private static final String PERMISSION_SET_NAME_OPPORTUNITY_BYPASS_VALIDATION = 'Opportunity Bypass ValidationRules';

    private static Id valueCreationRecordTypeId = Schema.SObjectType.Value_Creation_Engagements__c
        .getRecordTypeInfosByDeveloperName()
        .get(VALUE_CREATION_ENGAGEMENT_RECORD_TYPE_NAME)
        .getRecordTypeId();

    private static Id opportunityRecordTypeId = Schema.SObjectType.Opportunity
        .getRecordTypeInfosByDeveloperName()
        .get(OPPORTUNITY_NEW_BUSINESS_RECORD_TYPE_NAME)
        .getRecordTypeId();
    
    @testSetup
    static void prepareTestData() {
        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'System Admin', ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR, ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS);
        insert testSystemAdminUser;

        User testSalesUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'Sales User', ZScalarConstants.PROFILE_CORE_SALES, 
            ZScalarConstants.ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION);
        insert testSalesUser;

        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        System.runAs(testSystemAdminUser) {
            List<Contact> testContactList = ZSL2OTestDataFactory.preareTestContacts(null, 1);
            insert testContactList;
    
            List<Account> testAccountList = ZSL2OTestDataFactory.prepareTestAccounts
            (
                'Prospect', 
                testContactList[0].Id, 
                null, 
                null, 
                null, 
                1
            );
            insert testAccountList;
    
            testContactList[0].AccountId = testAccountList[0].Id;
            update testContactList;
    
            List<Opportunity> testOpportunityList = ZSL2OTestDataFactory.prepareTestOpportunities
            (
                testAccountList[0].Id, 
                'Pipeline',
                '1 - Discovery & Qualification',
                opportunityRecordTypeId, 
                1
            );
            insert testOpportunityList;
        }

        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    @isTest
    static void testValueCreationRecordInsertSuccess(){
        User testSalesUser = [SELECT Id 
            FROM User 
            WHERE Name = 'Test Sales User' 
            LIMIT 1];
        Opportunity testOpportunity = [SELECT Id 
        FROM Opportunity 
        WHERE Name = 'Test Opportunity 1' 
        LIMIT 1];

        ZSL2OTestDataFactory.assignPermissionSet(testSalesUser.Id, PERMISSION_SET_NAME_OPPORTUNITY_BYPASS_VALIDATION);

        List<Value_Creation_Engagements__c> testVCEList = ZSL2OTestDataFactory.prepareTestValueCreationEngagments
            (
                testOpportunity.Id, 
                'Consulting',
                '1-Request Received',
                valueCreationRecordTypeId, 
                1
            );
        
        System.runAs(testSalesUser) {
            Test.startTest();
            insert testVCEList;
            Test.stopTest();
        }

        Value_Creation_Engagements__c resultVCERecord = [SELECT Id, 
            Overall_BVA_Score__c 
            FROM Value_Creation_Engagements__c 
            WHERE Id = :testVCEList[0].Id];
        System.assertEquals(resultVCERecord.Overall_BVA_Score__c, 0, 'BVA score should be zero');
    }

    @isTest
    static void testValueCreationRecordUpdateSuccess(){
        User testSalesUser = [SELECT Id 
            FROM User 
            WHERE Name = 'Test Sales User' 
            LIMIT 1];
        Opportunity testOpportunity = [SELECT Id 
        FROM Opportunity 
        WHERE Name = 'Test Opportunity 1' 
        LIMIT 1];

        ZSL2OTestDataFactory.assignPermissionSet(testSalesUser.Id, PERMISSION_SET_NAME_OPPORTUNITY_BYPASS_VALIDATION);

        List<Value_Creation_Engagements__c> testVCEList = ZSL2OTestDataFactory.prepareTestValueCreationEngagments
            (
                testOpportunity.Id, 
                'Consulting',
                '1-Request Received',
                valueCreationRecordTypeId, 
                1
            );
        
        System.runAs(testSalesUser) {
            Test.startTest();
            insert testVCEList;
            Value_Creation_Engagements__c insertedVCERecord = [SELECT Id, 
            Engagement_Type__c 
            FROM Value_Creation_Engagements__c 
            WHERE Id = :testVCEList[0].Id 
            LIMIT 1];
            insertedVCERecord.Engagement_Type__c = 'Realization';
            update insertedVCERecord;
            Test.stopTest();
        }

        Value_Creation_Engagements__c resultVCERecord = [SELECT Id, 
            Overall_BVA_Score__c 
            FROM Value_Creation_Engagements__c 
            WHERE Id = :testVCEList[0].Id];
        System.assertEquals(resultVCERecord.Overall_BVA_Score__c != 0, true, 'BVA score should not be zero');
    }

    @isTest
    static void testValueCreationInsertAndOpportunityException(){
        User testSalesUser = [SELECT Id 
            FROM User 
            WHERE Name = 'Test Sales User' 
            LIMIT 1];
        Opportunity testOpportunity = [SELECT Id 
        FROM Opportunity 
        WHERE Name = 'Test Opportunity 1' 
        LIMIT 1];

        List<Value_Creation_Engagements__c> testVCEList = ZSL2OTestDataFactory.prepareTestValueCreationEngagments
            (
                testOpportunity.Id, 
                'Realization',
                '1-Request Received',
                valueCreationRecordTypeId, 
                1
            );
        Exception expectedException = null;
        System.runAs(testSalesUser) {                
            Test.startTest();
            try {
                insert testVCEList;
            }
            catch (Exception ex) {
                expectedException = ex;
            }
            Test.stopTest();
        }

        System.assertNotEquals(null, expectedException, 'Opportunity validation rule exception is expected');
    }
}