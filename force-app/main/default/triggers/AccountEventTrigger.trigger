/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountEventTrigger
* @description    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Nagesh
* @modifiedBy     
* @maintainedBy   Nagesh
* @version        1.0
* @created        2021-11-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change. .
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger AccountEventTrigger on Account_Event__e (after insert) {

    AccountEventTriggerHandler.process(Trigger.new);

}