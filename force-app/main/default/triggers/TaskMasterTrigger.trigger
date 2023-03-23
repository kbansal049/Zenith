/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TaskMasterTrigger
* @description    This is the single Task Trigger where we call/control all Task related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-03-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger TaskMasterTrigger on Task (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {

    new TaskTriggerHandler().run();
}