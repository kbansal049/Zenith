trigger trg_ProvEventManual on Provisioning_Event_Manual__e (after Insert) {

    if(trigger.isInsert && trigger.isAfter){
        ProvEventManualTriggerHandler.ProvEventManualProcessing(Trigger.new);
    }
    

}