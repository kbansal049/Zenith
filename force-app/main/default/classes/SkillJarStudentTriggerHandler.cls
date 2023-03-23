/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarStudentTriggerHandler
* @description      This is the SkillJar Student Trigger handler class called synchronously 
                    from SkillJarStudentMasterTrigger.
*				    All the methods needs to be called synchronously from the SkillJar Student Trigger
* 				    should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-04
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class SkillJarStudentTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {

        List<skilljar__Student__c> studentList = (List<skilljar__Student__c>) Trigger.New;
        SkillJarStudentTriggerHelper.setEmailVerificationExpirationTime(studentList);
        
    }

    public override void afterInsert() {
    
        List<skilljar__Student__c> studentList = (List<skilljar__Student__c>) Trigger.New;
        
        List<skilljar__Student__c> studentListToSendEmail = new List<skilljar__Student__c>();
        for(skilljar__Student__c student : studentList){
            //Trigger emails only for records created using student creation form
            //We are using a custom label prefix string in skilljarId to identify the records
            if(student.skilljar__Obfuscated_Id__c.contains(Label.ZS_Academy_Prefix_For_Skilljar_Id)){
                studentListToSendEmail.add(student);
            }
        }

        if(!studentListToSendEmail.isEmpty()){
            SkillJarStudentTriggerHelper.verifyNewStudentEmail(studentListToSendEmail);
        }
        SkillJarStudentTriggerHelper.cleanupIncomingSkillJarStudentRecords(studentList);
    }

    public override void beforeUpdate() {
        Map<Id,skilljar__Student__c> oldVersion = (Map<Id,skilljar__Student__c>)Trigger.oldMap;
        List<skilljar__Student__c> qualifiedRecords = new List<skilljar__Student__c>();
        for(skilljar__Student__c stud: (List<skilljar__Student__c>) Trigger.New){
            if(stud.Is_Email_Verified__c && oldVersion?.get(stud.Id).Is_Email_Verified__c != stud.Is_Email_Verified__c){
                qualifiedRecords.add(stud);
            } 
        }
        
        if(!qualifiedRecords.isEmpty()){
            SkillJarStudentTriggerHelper.performContactAccountAndLeadMatchingProcess(qualifiedRecords);
        }
    }

    public override void afterUpdate() {
		List<skilljar__Student__c> newStudentList = (List<skilljar__Student__c>)Trigger.New;
        Map<Id,skilljar__Student__c> oldStudentMap = (Map<Id,skilljar__Student__c> )Trigger.oldMap;
        List<skilljar__Student__c> studentListToSendWelcomeEmail = new List<skilljar__Student__c>();
        List<skilljar__Student__c> updatedStudentRecordsList = new List<skilljar__Student__c>();
		List<skilljar__Student__c> qualifiedRecords = new List<skilljar__Student__c>();
        for(skilljar__Student__c studentObj : newStudentList){
            if(studentObj.Okta_Activation_Link__c != oldStudentMap.get(studentObj.Id).Okta_Activation_Link__c){
                studentListToSendWelcomeEmail.add(studentObj);
            }
            if(studentObj.Is_Email_Verified__c && oldStudentMap?.get(studentObj.Id).Is_Email_Verified__c != studentObj.Is_Email_Verified__c){
                qualifiedRecords.add(studentObj);
            }
            //IBA-1827-Start
            else if((studentObj.skilljar__First_Name__c != oldStudentMap.get(studentObj.Id).skilljar__First_Name__c) ||
               (studentObj.skilljar__Last_Name__c != oldStudentMap.get(studentObj.Id).skilljar__Last_Name__c) ||
               (studentObj.Account__c != oldStudentMap.get(studentObj.Id).Account__c) ||
               (studentObj.skilljar__Contact__c != oldStudentMap.get(studentObj.Id).skilljar__Contact__c) ||
               (studentObj.skilljar__Lead__c != oldStudentMap.get(studentObj.Id).skilljar__Lead__c) ||
               (studentObj.Account_Type__c!= oldStudentMap.get(studentObj.Id).Account_Type__c) ){
                updatedStudentRecordsList.add(studentObj);
            } //IBA-1827-End
            
             
        }
        
        if(!studentListToSendWelcomeEmail.isEmpty()){
            SkillJarStudentTriggerHelper.sendWelcomeEmail(studentListToSendWelcomeEmail);
        }
        
        if(!qualifiedRecords.isEmpty()){
            SkillJarStudentTriggerHelper.insertLog(qualifiedRecords,'Student_Signup');
        }
        //IBA-1827-Start
        if(!updatedStudentRecordsList.isEmpty()){
            SkillJarStudentTriggerHelper.insertLog(updatedStudentRecordsList,'Student_Update');
        }//IBA-1827-End
    }

    public override void beforeDelete() {

    }

    public override void afterDelete() {

    }

    public override void afterUndelete() {

    }
    @InvocableMethod(label='Verify Student Email' description='Send Verification Email to Non Partner Students')
    public static void invokeVerificationEmail(List<skilljar__Student__c> students){
        SkillJarStudentTriggerHelper.verifyNewStudentEmail(students);
        
    }
    
}