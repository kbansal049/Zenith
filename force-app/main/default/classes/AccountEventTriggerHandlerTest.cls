@isTest
public with sharing class AccountEventTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Account newAccountRecord = new Account();

        newAccountRecord.Name = 'Test Platform Event Account';
        newAccountRecord.Type = 'Customer';
        newAccountRecord.BillingCountry = 'BillingCountry';
        newAccountRecord.BillingState = 'BillingState';
        newAccountRecord.BillingPostalCode = '101010';
        newAccountRecord.Domain__c = 'domain';
        newAccountRecord.Industry = 'Other';
        newAccountRecord.Market_Segment__c = 'Enterprise';

        insert newAccountRecord;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = newAccountRecord.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test',
                                          Created_from_Lead__c = TRUE);
        insert opp; 
    }

    @isTest
    private static void testAccountPlatformEvent() {
        Id accId = [Select Id From Account Where Name='Test Platform Event Account'].Id;
        Account_Event__e accEvt = new Account_Event__e(Record_Id__c=accId, Event_Type__c='LinkAccountToPatch');
        Test.startTest();
          EventBus.publish(accEvt);
        Test.stopTest();

    }
}