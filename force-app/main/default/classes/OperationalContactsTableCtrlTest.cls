/**
 * Name : OperationalContactsTableCtrlTest
 * Description : Test Class of OperationalContactsTableCtrl
 */

@isTest
public class OperationalContactsTableCtrlTest {
    
    @testSetup
    static void setup() {
        List<TAM_Engagement__c> engagementList = new List<TAM_Engagement__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = acc.id);
        insert c;
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com', AccountId = acc.id, operational_contact__c = true);
        insert c2;
        engagementList.add(new TAM_Engagement__c(Account__c = acc.id, Product__c = 'ZIA',tam_engagement_Status__c='Work in Progress',stage__c = 'STAGE 1: Onboarding'));
        insert engagementList;
    }

    @isTest 
    static void getOperationalContacts_Test() {
        OperationalContactsTableCtrl cons = new OperationalContactsTableCtrl();
        List<TAM_Engagement__c> engagementList = new List<TAM_Engagement__c>([SELECT id,Account__c FROM TAM_Engagement__c]);
        System.assert(OperationalContactsTableCtrl.getOperationalContacts(engagementList.get(0).Id).size() > 0, 'Contacts not Found');
        System.assert(OperationalContactsTableCtrl.getOperationalContacts(engagementList.get(0).Account__c).size() > 0, 'Contacts not Found');
    }
    
    @isTest
    static void verifyContactParentAccount_Test() {
        List<TAM_Engagement__c> engagementList = new List<TAM_Engagement__c>([SELECT id,Account__c FROM TAM_Engagement__c]);
        OperationalContactsTableCtrl.verifyContactParentAccount(engagementList.get(0).Id,[SELECT id FROM Contact WHERE operational_contact__c = false LIMIT 1].id);
        Account acc = new Account(Name='Test Account2');
        insert acc;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'test3@test.com', AccountId = acc.id);
        insert c;
        OperationalContactsTableCtrl.verifyContactParentAccount(engagementList.get(0).Id,c.id);
        OperationalContactsTableCtrl.markUnmarkContactAsOperational(c.id, true);
        OperationalContactsTableCtrl.verifyContactParentAccount(engagementList.get(0).Id,c.id);
        OperationalContactsTableCtrl.markUnmarkContactAsOperational(c.id, false);
        OperationalContactsTableCtrl.verifyContactParentAccount(engagementList.get(0).Id,c.id);
    }
    
}