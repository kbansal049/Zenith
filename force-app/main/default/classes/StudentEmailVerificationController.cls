/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* StudentEmailVerificationController
* @description      This is the controller for "studentEmailVerification" LWC.
					Without Sharing because we are updating from a Guest User context.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public without sharing class StudentEmailVerificationController {
    
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-1076 : to verify the email address of a new student record, 
* 													by making the Is_Email_Verified__c checkbox to TRUE.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : updateIsEmailVerifiedField .
* @param    NAME : String studentRecordId .
* @return   TYPE : Boolean .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled
    public static String updateIsEmailVerifiedField(String studentRecordId){
        try{
            String returnString = 'UPDATE_FAIL';
            if(String.isNotBlank(studentRecordId)){
                String decryptedStudentId = PerformEncryptionDecryption.performDecryption(studentRecordId,
                    Label.ZS_Academy_InitializationVector_For_Encrypt_Decrypt,Label.ZS_Academy_Key_For_Encrypt_Decrypt);
                skilljar__Student__c studentRecordToUpdate = [SELECT Id,Is_Email_Verified__c,Email_Verification_Expiration_Time__c 
                                                    FROM skilljar__Student__c 
                                                    WHERE Id = : decryptedStudentId 
                                                    LIMIT 1];
                if(System.now() > studentRecordToUpdate.Email_Verification_Expiration_Time__c)
                {
                    returnString = 'EMAIL_LINK_EXPIRED';
                } else if (System.now() < studentRecordToUpdate.Email_Verification_Expiration_Time__c && 
                                studentRecordToUpdate.Is_Email_Verified__c == FALSE)
                { 
                    studentRecordToUpdate.Is_Email_Verified__c = TRUE;
                    update studentRecordToUpdate;
                    returnString = 'UPDATE_SUCCESS';
                } else if (System.now() < studentRecordToUpdate.Email_Verification_Expiration_Time__c && 
                                studentRecordToUpdate.Is_Email_Verified__c == TRUE)
                {
                    returnString = 'UPDATE_SUCCESS';
                } else {
                    returnString = 'UPDATE_FAIL';
                }    
            }
            return returnString;
        }catch(Exception e){
            System.debug('Exception - '+ e.getTypeName() + e.getMessage() + e.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogs('StudentEmailVerificationController', 
                                               'updateIsEmailVerifiedField', 
                                               'Apex', 
                                               UserInfo.getUserId(),
                                               'Sales cloud', 
                                               e.getStackTraceString(), 
                                               e.getMessage(), 
                                               e.getTypeName());
            return 'UPDATE_FAIL';       
        }       
    }

    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to resend verification email, if the email link is expired.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : resendVerificationEmail .
* @param    NAME : String studentRecordId .
* @return   TYPE : Boolean .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@AuraEnabled
public static String resendVerificationEmail(String studentRecordId){
    try{
        String returnString = 'UPDATE_FAIL';
        if(String.isNotBlank(studentRecordId)){
            String decryptedStudentId = PerformEncryptionDecryption.performDecryption(studentRecordId,
                Label.ZS_Academy_InitializationVector_For_Encrypt_Decrypt,Label.ZS_Academy_Key_For_Encrypt_Decrypt);
            skilljar__Student__c studentRecordToUpdate = [SELECT Id,Is_Email_Verified__c,Email_Verification_Expiration_Time__c,
                                                skilljar__Email__c
                                                FROM skilljar__Student__c 
                                                WHERE Id = : decryptedStudentId 
                                                LIMIT 1];
            if(studentRecordToUpdate != NULL && 
                System.now() > studentRecordToUpdate.Email_Verification_Expiration_Time__c)
            {
                studentRecordToUpdate.Email_Verification_Expiration_Time__c = 
                System.now().addHours(Integer.valueOf(Label.ZS_Academy_EmailExpirationTime_InHours));
                update studentRecordToUpdate;
                List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
                studentList.add(studentRecordToUpdate);
                SkillJarStudentTriggerHelper.verifyNewStudentEmail(studentList);
                returnString = 'UPDATE_SUCCESS';
            }   
        }
        return returnString;
    }catch(Exception e){
        System.debug('Exception - '+ e.getTypeName() + e.getMessage() + e.getStackTraceString());
        ZscalerErrorLogsUtility.insertlogs('StudentEmailVerificationController', 
                                           'updateIsEmailVerifiedField', 
                                           'Apex', 
                                           UserInfo.getUserId(),
                                           'Sales cloud', 
                                           e.getStackTraceString(), 
                                           e.getMessage(), 
                                           e.getTypeName());
        return 'UPDATE_FAIL';       
    }       
}

}