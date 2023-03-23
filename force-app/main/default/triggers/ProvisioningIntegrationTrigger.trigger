trigger ProvisioningIntegrationTrigger on Provisioning_Integration_Log__c (after insert, after update) {
     new ProvisioningIntegrationTriggerHandler().run();
}