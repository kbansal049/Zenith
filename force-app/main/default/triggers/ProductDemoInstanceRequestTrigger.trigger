trigger ProductDemoInstanceRequestTrigger on Product_Demo_Instance_Request__c (after insert,after update,before insert,before update) {
    System.debug('---ProductDemoInstanceRequestTrigger--called--');
    new ProductDemoInstanceRequestTriggerHandler().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);    
}