/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarStudentMasterTrigger
* @description      This is the single SkillJar Student Trigger where we call/control all SkillJar 
                    Student related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-07-04
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Author Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger SkillJarStudentMasterTrigger on skilljar__Student__c (before insert, 
    before update, 
    after insert, 
    after update, 
    before delete, 
    after delete, 
    after undelete) {
        
    new SkillJarStudentTriggerHandler().run();                      
}