/**
 * Name : CAPRequestTrigger
 * Description : Trigger on CAP Request sObject
 * Test Class : CAPRequestTriggerHandlerTest
 * Initial Author : Ankit Bhatnagar
 */

trigger CAPRequestTrigger on CAP_Request__c (before update, before insert, after insert, after update) {
    new CAPRequestTriggerHandler().run();
}