trigger trg_ProvEvent on Provisioning_Event__e (after insert) {
    if(trigger.isInsert && trigger.isAfter){
        ProvEventTriggerHandlerUpdated.ProvEventAPICallout(Trigger.new);
    }
}