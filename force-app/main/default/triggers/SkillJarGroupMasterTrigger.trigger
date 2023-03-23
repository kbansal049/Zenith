/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarGroupMasterTrigger
* @description      This is the single SkillJar Group Trigger where we call/control all SkillJar 
                    Group related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-07-25
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Author Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger SkillJarGroupMasterTrigger on skilljar__Group__c (before insert, 
    before update, 
    after insert, 
    after update, 
    before delete, 
    after delete, 
    after undelete) {
        
    new SkillJarGroupTriggerHandler().run();                      
}