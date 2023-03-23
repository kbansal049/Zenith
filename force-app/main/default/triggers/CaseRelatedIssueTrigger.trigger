/**
 * Name : CaseRelatedIssueTrigger
 * Description : Trigger on CaseRelatedIssue sObject
 * Test Class : CaseRelatedIssueTriggerHandlerTest
 * Initial Author : Ankit Bhatnagar
 */

trigger CaseRelatedIssueTrigger on CaseRelatedIssue (before insert, after insert, before delete) {
    new CaseRelatedIssueTriggerHandler().run();
}