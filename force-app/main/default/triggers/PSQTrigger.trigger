trigger PSQTrigger on PS_Questionnaire__c (after update, after insert, before insert, before update) {
    
    PSQTriggerHandler triggerHandler = new PSQTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore)
    {
        PSQTriggerHandler.beforeInsert(Trigger.New);       
    }
    
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        PSQTriggerHandler.afterUpdate(Trigger.New);
        
    }
    //IBA-4911 START
    if(trigger.isInsert && trigger.isAfter){
        triggerHandler.onAfterInsert(trigger.new);
    }
    //IBA-4911 END

}