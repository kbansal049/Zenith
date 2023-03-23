trigger GCSProjectTrigger on GCS_Project__c (after update, after insert, before insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore)
    {
        GCSProjectTriggerHandler.beforeInsert(Trigger.New);       
    }
    
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        GCSProjectTriggerHandler.beforeUpdate(Trigger.New,Trigger.Oldmap);
    }   
}