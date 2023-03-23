@isTest
public class DMLManagerTest {
    public static String accountName = 'updateTest';
    @isTest 
    public static void insertAsSystemTest(){
        Account accountRecord = new Account(Name='test');
        Test.startTest();
        DMLManager.insertAsSystem(accountRecord);
        Test.stopTest();
        system.assert(!DMLManager.recordIds.isEmpty());
    }
    @isTest 
    public static void updateAsSystemTest(){
        Account accountRecord = new Account(Name='test');
        DMLManager.insertAsSystem(accountRecord);
        accountRecord.Name =accountName;
        Test.startTest();
        DMLManager.updateAsSystem(accountRecord);
        Test.stopTest();
        Account accountTestRecord = [SELECT Id,Name FROM Account WHERE Id =: DMLManager.recordIds[0]];
        system.assertEquals(accountTestRecord.Name,accountName);
    }
    
    @isTest 
    public static void bulkUpdateAsSystemTest(){
        Account accountRecord = new Account(Name='test');
        DMLManager.insertAsSystem(accountRecord);
        accountRecord.Name =accountName;
        Test.startTest();
        DMLManager.updateAsSystem(new List<SObject>{accountRecord},'className');
        Test.stopTest();
        Account accountTestRecord = [SELECT Id,Name FROM Account WHERE Id =: DMLManager.recordIds[0]];
        system.assertEquals(accountTestRecord.Name,accountName);
    }
    
    @isTest 
    public static void dmlUpdateTest(){
        Account accountRecord = new Account(Name='test');
        DMLManager.insertAsSystem(accountRecord);
        accountRecord.Name =accountName;
        Test.startTest();
        new DMLManager.ErrorLogModel();
        DMLManager.dmlUpdate(new List<SObject>{accountRecord},'className');
        Test.stopTest();
        Account accountTestRecord = [SELECT Id,Name FROM Account WHERE Id =: DMLManager.recordIds[0]];
        system.assertEquals(accountTestRecord.Name,accountName);
    }
    
    @isTest 
    public static void bulkUpdateAsSystemTestWithClassName(){
        Account accountRecord = new Account(Name='test');
        DMLManager.insertAsSystem(accountRecord);
        accountRecord.Name =accountName;
        Test.startTest();
        DMLManager.updateAsSystem(new List<SObject>{accountRecord},'className');
        Test.stopTest();
        Account accountTestRecord = [SELECT Id,Name FROM Account WHERE Id =: DMLManager.recordIds[0]];
        system.assertEquals(accountTestRecord.Name,accountName);
    }
    
    @isTest 
    public static void upsertAsSystemTest(){
        Account accountRecord = new Account(Name='test');
        Account accountRecords = new Account(Name='test1');
        DMLManager.insertAsSystem(accountRecord);
        accountRecord.Name =accountName;
        Test.startTest();
        DMLManager.upsertAsSystem(new List<SObject>{accountRecords});
        DMLManager.upsertAsSystem(accountRecord);
        Test.stopTest();
        Account updatedAccount = [SELECT Id,Name FROM Account WHERE Id =: accountRecord.Id];
        List<Account> insertedAccount = [SELECT Id,Name FROM Account WHERE Name =: 'test1' LIMIT 1];
        system.assertEquals(updatedAccount.Name,accountName);
        system.assertEquals(insertedAccount.isEmpty(),false);
    }

    @isTest 
    public static void deleteAsSystemTest(){
        Account accountRecord = new Account(Name='testing108');
        DMLManager.insertAsSystem(accountRecord);
        List<Account> acList = [SELECT Id,Name FROM Account WHERE name =: 'testing108' LIMIT 1];
        system.assert(!acList.isEmpty());
        Test.startTest();
        DMLManager.deleteAsSystem(acList);
        Test.stopTest();
    }
    
    @isTest 
    public static void bulkDeleteAsSystemTest(){
        Account accountRecord = new Account(Name='testing108');
        DMLManager.insertAsSystem(accountRecord);
        List<Account> acList = [SELECT Id,Name FROM Account WHERE name =: 'testing108' LIMIT 1];
        system.assert(!acList.isEmpty());
        Test.startTest();
        DMLManager.deleteAsSystem(acList.get(0));
        Test.stopTest();
    }
}