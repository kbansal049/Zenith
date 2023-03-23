trigger CustomOrderTrigger on Custom_Order__c (before insert, before update) {

     new CustomOrderTriggerHandler().run();

}