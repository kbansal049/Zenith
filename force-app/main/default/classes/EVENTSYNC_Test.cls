@IsTest
public class EVENTSYNC_Test {
    
    @IsTest
    static void EVENTSYNC_Test() {
        Id testUserId = [SELECT Id FROM User LIMIT 1].Id;
        //CR: 1078 - Changes Start
        String internalPartcipants = 'nstowe@zscaler.com, nstowe+test@zscaler.com';

        //test events
        List<Event> testEvents = new List<Event>();
        Event testEvent_pos = new Event(inspire1__AssignedTo__c = testUserId, DurationInMinutes = 80, ActivityDateTime = DateTime.now());
        Event testEvent_neg = new Event(WhatId = '001L000001ZIEa4IAa', inspire1__AssignedTo__c = testUserId, DurationInMinutes = 80, ActivityDateTime = DateTime.now()); //using a bad id to trigger insert fail
        testEvents.add(testEvent_pos);
        testEvents.add(testEvent_neg);

        EVENTSYNC.doPost(testEvents, internalPartcipants);
        //CR: 1078 - Changes End
    }

}