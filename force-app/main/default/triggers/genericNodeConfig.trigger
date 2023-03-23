trigger genericNodeConfig on Node_Configuration__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    new NodeConfigurationTriggerHandler().run();
}