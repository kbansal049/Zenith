/**
 * Name : TAMEngagementTriggerHandlerTest
 * Description : Test Class of TAMEngagementTriggerHandler
 */

@isTest
public class TAMEngagementTriggerHandlerTest {
    
    @isTest
    static void AccountDetailsUpdate_Test() {
        List<Account> accs = new List<Account>();
        accs.add(new Account(Name = 'Account 1'));
        accs.add(new Account(Name = 'Account 2'));
        insert accs;
        List<TAM_Engagement__c> engs = new List<TAM_Engagement__c>();
        engs.add(new TAM_Engagement__c(Account__c = accs.get(0).Id,Customer_s_Business_Objectives__c = 'Test1', Customer_Next_Steps__c = 'Test1', CS_Management_Notes__c = 'Test1'));
        engs.add(new TAM_Engagement__c( Account__c = accs.get(1).Id, Customer_s_Business_Objectives__c = 'Test2', Customer_Next_Steps__c = 'Test2', CS_Management_Notes__c = 'Test2'));
        engs.add(new TAM_Engagement__c( Account__c = accs.get(0).id, Customer_s_Business_Objectives__c = 'Test3', Customer_Next_Steps__c = 'Test3', CS_Management_Notes__c = 'Test3'));
        insert engs;
        for(TAM_Engagement__c eng : engs){ 
            eng.Customer_s_Business_Objectives__c = 'Test';
            eng.Customer_Next_Steps__c = 'Test';
            eng.CS_Management_Notes__c = 'Test';
        }
        update engs;
    }
}