@isTest
public class StudentEmailVerificationControllerTest {
    
    private static final Integer MAX_SKILLJAR_ID_LENGTH = 13;
    //private static final String ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID = System.Label.ZS_Academy_Prefix_For_Skilljar_Id;
    private static final String TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX = '0ab';
    
    @TestSetup
    Static void testData()
    {
        final String ID_PREFIX =  TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX;
        String randomString = getRandomString(MAX_SKILLJAR_ID_LENGTH - ID_PREFIX.length());
        
        skilljar__Student__c testStudent1 = new skilljar__Student__c();
        testStudent1.skilljar__First_Name__c = 'Test';
        testStudent1.skilljar__Last_Name__c = 'Student1';
        testStudent1.skilljar__Email__c = 'SJSTHT@test.com';
        testStudent1.Is_Email_Verified__c = true;
        testStudent1.Email_Verification_Expiration_Time__c = System.now();
        testStudent1.skilljar__Obfuscated_Id__c = ID_PREFIX + randomString;
        insert testStudent1;
    }
    
    static String getRandomString(Integer length) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String randomString = key.substring(0, length);
        return randomString;
    }
    
    @isTest
    public static void studentEmailVerificationTest()
    {
        
        skilljar__Student__c rec = [SELECT ID FROM skilljar__Student__c WHERE 
                                    skilljar__First_Name__c = 'Test' AND skilljar__Last_Name__c = 'Student1' Limit 1];
        String encryptedStudentId = PerformEncryptionDecryption.performEncryption(rec.id,
                    Label.ZS_Academy_InitializationVector_For_Encrypt_Decrypt,Label.ZS_Academy_Key_For_Encrypt_Decrypt);                                      
       
        StudentEmailVerificationController.updateIsEmailVerifiedField(encryptedStudentId);
        
        
    }
    
    /*@isTest
    public static void studentEmailVerification_NullTest()
    {
        String nullCheck;
        nullCheck = StudentEmailVerificationController.updateIsEmailVerifiedField(NULL);
        system.assertNotEquals(null,nullCheck);
    }*/
    
    @isTest
    public static void studentEmailVerification_ExceptionTest()
    {
		Test.startTest();
        String check = StudentEmailVerificationController.updateIsEmailVerifiedField('aKL4C000000GoIvfas');
        Test.stopTest();
        list<Zscaler_Error_Logs__c> logCheck = [select Class_Name__c from Zscaler_Error_Logs__c where Class_Name__c = 'StudentEmailVerificationController'];
        //system.assertEquals('List has no rows for assignment to SObject',e.getMessage());
        system.assertEquals(1,logCheck.size(),'error logs could not be created');     
    }
    
    @isTest
    public static void resendVerificationEmailTest()
    {
        
        skilljar__Student__c rec = [SELECT ID FROM skilljar__Student__c WHERE 
                                    skilljar__First_Name__c = 'Test' AND skilljar__Last_Name__c = 'Student1' Limit 1];
        rec.Email_Verification_Expiration_Time__c = Date.valueOf('2022-08-01 00:00:00');
    	update rec;
        String encryptedStudentId = PerformEncryptionDecryption.performEncryption(rec.id,
                    Label.ZS_Academy_InitializationVector_For_Encrypt_Decrypt,Label.ZS_Academy_Key_For_Encrypt_Decrypt);                                      
        
        StudentEmailVerificationController.resendVerificationEmail(encryptedStudentId);
        
    }
    
    @isTest
    public static void resendVerificationEmail_ExceptionTest()
    {
		Test.startTest();
        String check = StudentEmailVerificationController.resendVerificationEmail('aKL4C000000GoIvfas');
        Test.stopTest();
        list<Zscaler_Error_Logs__c> logCheck = [select Class_Name__c from Zscaler_Error_Logs__c where Class_Name__c = 'StudentEmailVerificationController'];
        system.assertEquals(1,logCheck.size(),'error logs could not be created');     
    }

}