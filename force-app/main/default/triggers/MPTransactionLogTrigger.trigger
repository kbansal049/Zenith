/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   11-23-2021   Mayank B.     Initial Version CR# 3605
*/
trigger MPTransactionLogTrigger on AWS_Transaction_Log__c (before insert, after insert, before update, after update, before delete, after delete) {
    new MPTransactionLogTriggerHandler().run();
}