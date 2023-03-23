@isTest
public class AccountSyncToJIRABatchTest {
    
    @isTest 
    static void testAccountExtSynctoJIRA(){
        Triggerhandler.bypass('AccountTriggerHandler');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        accExt.Sync_To_JIRA__c='Sync to JIRA Failed';
        update accExt;
        
        Test.startTest();
        
        Database.executeBatch(new AccountSyncToJIRABatch(), 200);
        
        Test.stopTest();
    }
     @isTest 
    static void testAccountExtSynctoJIRA2(){
        Triggerhandler.bypass('AccountTriggerHandler');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        accExt.Sync_To_JIRA__c='Sync to JIRA Failed';
        update accExt;
        
        Test.startTest();
        String query = 'Select id,Sync_To_JIRA__c from Account_Extension__c where id = \''+accExt.id+'\'';
        Database.executeBatch(new AccountSyncToJIRABatch(query), 200);
        
        Test.stopTest();
    }
}