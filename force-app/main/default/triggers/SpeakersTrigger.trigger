/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SpeakersTrigger
* @description    This is the single Speakers Trigger where we call/control all Speakers related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-11-23
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Digvijay Singh
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-11-23      IBA-4849 Digvijay - Creation of the trigger for handling the automation logic during 
                  DML operations on Speakers records.                  
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger SpeakersTrigger on Speakers__c (before insert, 
                                        before update, 
                                        after insert, 
                                        after update) {
    
    new SpeakersTriggerHandler().run();
}