/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* StudentCreationFormCtrl
* @description      This is a controller class for StudentCreationForm LWC.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-06
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public without sharing class StudentCreationFormCtrl {

    @AuraEnabled
    public static List<CheckForDuplicateStudentWrapper> checkForDuplicates(String studentEmail){
        try {
            List<CheckForDuplicateStudentWrapper> checkForDuplicateStudentWrapperList = new List<CheckForDuplicateStudentWrapper>();
            if(String.isNotBlank(studentEmail)){
                for(skilljar__Student__c studentRecord : [SELECT Id,Name,Is_Email_Verified__c,skilljar__Obfuscated_Id__c,
                Skilljar_group_ID__c                                         
                FROM skilljar__Student__c
                WHERE skilljar__Email__c = : studentEmail])
                {
                    CheckForDuplicateStudentWrapper checkForDuplicateStudentWrapperObj = new CheckForDuplicateStudentWrapper();
                    checkForDuplicateStudentWrapperObj.isDuplicate = TRUE;
                    checkForDuplicateStudentWrapperObj.isEmailVerified = studentRecord.Is_Email_Verified__c;
                    checkForDuplicateStudentWrapperObj.studentRecord = studentRecord;

                    checkForDuplicateStudentWrapperList.add(checkForDuplicateStudentWrapperObj);
                }
            }

            return checkForDuplicateStudentWrapperList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateExistingStudentRecord(skilljar__Student__c studentRecord){
        try {
            studentRecord.Email_Verification_Expiration_Time__c = 
                System.now().addHours(Integer.valueOf(Label.ZS_Academy_EmailExpirationTime_InHours));
            update studentRecord;
            List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
            studentList.add(studentRecord);
            SkillJarStudentTriggerHelper.verifyNewStudentEmail(studentList);
            return TRUE;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + studentRecord);
        }
    }

    public class CheckForDuplicateStudentWrapper{
        @AuraEnabled public Boolean isDuplicate;
        @AuraEnabled public Boolean isEmailVerified;
        @AuraEnabled public skilljar__Student__c studentRecord;
    }
    //Added by Ayush Kangar as part of IBA-4398 - Start
    @AuraEnabled(Cacheable = true)
    public static String StudentRegistrationSuccessMsg(){ SkillJar_Setting__mdt temp = [select Student_Registration_Success_Msg__c from SkillJar_Setting__mdt];
        return temp.Student_Registration_Success_Msg__c;
      }
    //Added by Ayush Kangar as part of IBA-4398 - End
}