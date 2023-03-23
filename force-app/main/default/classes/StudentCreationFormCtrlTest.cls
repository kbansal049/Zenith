@isTest
public class StudentCreationFormCtrlTest {
	
    private static final Integer MAX_SKILLJAR_ID_LENGTH = 13;
    //private static final String ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID = System.Label.ZS_Academy_Prefix_For_Skilljar_Id;
    private static final String TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX = '0ab';

    @TestSetup
    static void prepareTestData() {
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        
        Integer numberOfStudents = 2;
        for (Integer count = 1; count <= numberOfStudents; count++) {
            
            final String ID_PREFIX = TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX ;
            String randomString = getRandomString(MAX_SKILLJAR_ID_LENGTH - ID_PREFIX.length());
            
            skilljar__Student__c student = new skilljar__Student__c();
            student.Name = 'Test Student ' + count;
            student.skilljar__First_Name__c = 'Test';
            student.skilljar__Last_Name__c = 'Student ' + count;
            student.skilljar__Email__c = 'test'+ '@test.com';
            student.skilljar__Obfuscated_Id__c = ID_PREFIX + randomString;
            
            studentList.add(student);
        }
        
        if (!studentList.isEmpty()) {
            insert studentList;
        }
    }

    static String getRandomString(Integer length) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String randomString = key.substring(0, length);
        return randomString;
    }
    
    @isTest
    public static void checkForDuplicatesTest()
    {
        String studentEmail = 'test@test.com';
        //List<CheckForDuplicateStudentWrapper> resultList = new List<CheckForDuplicateStudentWrapper>();
        integer resultListSize;
        resultListSize = StudentCreationFormCtrl.checkForDuplicates(studentEmail).Size();
        system.assertEquals(2,resultListSize); 
    }
    
    @isTest
    public static void updateExistingStudentRecordTest()
    {
        skilljar__Student__c testStudent = [SELECT Name,skilljar__Email__c,
                                            skilljar__Obfuscated_Id__c FROM skilljar__Student__c WHERE NAME = 'Test Student 1'];
    	StudentCreationFormCtrl.updateExistingStudentRecord(testStudent);
        StudentCreationFormCtrl.StudentRegistrationSuccessMsg();
    }
}