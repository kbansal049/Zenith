// Created by Harish for CR 1141
@isTest
private class AccountTotalUniqueClientUsersTest {
    static testmethod void run(){
        TriggerHandler.bypass('AccountTriggerHnadler');
        Account a = new Account(Name = 'TestAccount',ZApp_Registered_Devices__c = 111);
        insert a;
        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = a.id,Cloud_Type__c = 'ZIA');
        insert ci;
        BWC_Data__c bw = new BWC_Data__c(Cloud_ID__c= ci.Id,Total_Unique_Users__c = 101,Type__c = 'ZIA');
        insert bw;
        Test.startTest();
        AccountTotalUniqueClientUsersBatch ld = new AccountTotalUniqueClientUsersBatch(new set<id>{a.Id});
        database.executeBatch(ld);
        System.schedule('AccountTotalUniqueClientUsersSch','0 0 13 * * ?', new AccountTotalUniqueClientUsersSch());
        Test.stopTest();
    }
}