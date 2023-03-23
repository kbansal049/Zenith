/**
 * Name : TAMEngagementTrigger
 * Description : Trigger on TAM Engagement sObject
 * Test Class : 
 * Initial Author : Ankit Bhatnagar
 */
trigger TAMEngagementTrigger on TAM_Engagement__c (before insert, after insert, after update, before update) {
    new TAMEngagementTriggerHandler().run();
}