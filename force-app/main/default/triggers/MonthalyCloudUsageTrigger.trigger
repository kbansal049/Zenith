//Added before Insert, before Update by Varun for CR754 -
trigger MonthalyCloudUsageTrigger on BWC_Data__c (before Insert, before Update,after Insert, after Update, after Delete) {
    
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    
    if(tsmap.containsKey('Execute_Monthly_Cloud_Usage_Roll_UP') &&
       tsmap.get('Execute_Monthly_Cloud_Usage_Roll_UP').Object_Name__c == 'BWC_Data__c'  &&
       tsmap.get('Execute_Monthly_Cloud_Usage_Roll_UP').Execute__c)
    {
        new MonthalyCloudUsageTriggerHandler().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
    }
}