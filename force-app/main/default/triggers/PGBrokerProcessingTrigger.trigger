trigger PGBrokerProcessingTrigger on Provisioning_Broker_Processing_Event__e (after insert) {
    
    PGBrokerProcessingEventHandler.process(trigger.new);

}