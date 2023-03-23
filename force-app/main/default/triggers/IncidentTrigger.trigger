/**
 * Name : IncidentTrigger
 * Description : Trigger on Incident sObject
 * Test Class : 
 * Initial Author : Ankit Bhatnagar
 */

trigger IncidentTrigger on Incident (before insert, after insert, before update, after update) {
    new IncidentTriggerHandler().run();
}