trigger NanologClusterTrigger on Nanolog_Cluster__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new NanologClusterTriggerHandler().run();
}