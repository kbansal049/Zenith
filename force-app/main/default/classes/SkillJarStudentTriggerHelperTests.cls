//Bikram 26th Aug - Adding a comment to create a new commit
@isTest
private class SkillJarStudentTriggerHelperTests {
    
    private static final Integer MAX_SKILLJAR_ID_LENGTH = 13;
    private static final String ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID = System.Label.ZS_Academy_Prefix_For_Skilljar_Id;
    private static final String TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX = '0ab';
    
    public class SkillJarStudentTriggerHelperTestsException extends Exception {
    }
    
    @TestSetup
    static void prepareTestData() {
        
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'abc.com';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        testAccount.BillingCountry = 'US';
        testAccount.BillingState = 'CA';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Integer numberOfStudents = 2;
        for (Integer count = 1; count <= numberOfStudents; count++) {
            // If even student, we are not using any prefix, skilljar like id will be generated
            final String ID_PREFIX = Math.mod(count, 2) == 0 ? TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX : ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID;
            String randomString = getRandomString(MAX_SKILLJAR_ID_LENGTH - ID_PREFIX.length());
            
            skilljar__Student__c student = new skilljar__Student__c();
            student.Name = 'Test Student ' + count;
            student.skilljar__First_Name__c = 'Test';
            student.skilljar__Last_Name__c = 'Student ' + count;
            student.skilljar__Email__c = 'SJSTHT' + count + '@test.com';
            student.skilljar__Obfuscated_Id__c = ID_PREFIX + randomString;
            student.Phone__c = '1234567890';
            
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
    static void testCleanupIncomingSkillJarStudentRecords() {
        String idPrefix = ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID + '%';
        skilljar__Student__c testStudent = [SELECT Id, Name, skilljar__First_Name__c, skilljar__Last_Name__c, 
                                            skilljar__Email__c,Phone__c,Title__c, Account__c,
                                            skilljar__Obfuscated_Id__c FROM skilljar__Student__c 
                                            WHERE skilljar__Obfuscated_Id__c LIKE :idPrefix  LIMIT 1];
        
        TriggerHandler.bypass('SkillJarStudentTriggerHandler');
        
        skilljar__Student__c testOOBStudent = new skilljar__Student__c();
        testOOBStudent.Name = testStudent.Name;
        testOOBStudent.skilljar__First_Name__c = testStudent.skilljar__First_Name__c;
        testOOBStudent.skilljar__Last_Name__c = testStudent.skilljar__Last_Name__c;
        testOOBStudent.skilljar__Email__c = testStudent.skilljar__Email__c;
        testOOBStudent.skilljar__Obfuscated_Id__c = TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX + 
            getRandomString(MAX_SKILLJAR_ID_LENGTH - TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX.length());
        insert testOOBStudent;
        
        TriggerHandler.clearBypass('SkillJarStudentTriggerhandler');
        
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        studentList.add(testStudent);
        studentList.add(testOOBStudent);
        
        Test.startTest();
        SkillJarStudentTriggerHelper.cleanupIncomingSkillJarStudentRecords(studentList);
        Test.stopTest();
    }
    
    @isTest
    static void testCleanupIncomingSkillJarStudentRecordsException() {
        Boolean isExceptionCaught = false;         
        String idPrefix = ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID + '%';
        skilljar__Student__c testStudent = [SELECT Id, Name, skilljar__First_Name__c, skilljar__Last_Name__c, 
                                            skilljar__Email__c,Phone__c, Title__c,Account__c,
                                            skilljar__Obfuscated_Id__c FROM skilljar__Student__c 
                                            WHERE skilljar__Obfuscated_Id__c LIKE :idPrefix  LIMIT 1];
        
        TriggerHandler.bypass('SkillJarStudentTriggerHandler');
        
        skilljar__Student__c testOOBStudent = new skilljar__Student__c();
        testOOBStudent.Name = testStudent.Name;
        testOOBStudent.skilljar__First_Name__c = testStudent.skilljar__First_Name__c;
        testOOBStudent.skilljar__Last_Name__c = testStudent.skilljar__Last_Name__c;
        testOOBStudent.skilljar__Email__c = testStudent.skilljar__Email__c;
        testOOBStudent.skilljar__Obfuscated_Id__c = TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX + 
            getRandomString(MAX_SKILLJAR_ID_LENGTH - TEST_OOB_SKILLJAR_STUDENT_ID_PREFIX.length());
        insert testOOBStudent;
        
        TriggerHandler.clearBypass('SkillJarStudentTriggerhandler');
        
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        studentList.add(testStudent);
        studentList.add(testOOBStudent);
        Test.startTest();        
        try {
            SkillJarStudentTriggerHelper.cleanupIncomingSkillJarStudentRecords(studentList);
        } catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('fail')) {//DML or Email Exception
                isExceptionCaught = true;
            }else if(ex.getMessage().containsIgnoreCase('List has no rows for assignment to SObject')){//Query Exception
                isExceptionCaught = true;
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInsertLog() {
        String idPrefix = ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID + '%';
        skilljar__Student__c testStudent = [SELECT Id, Name, skilljar__First_Name__c, skilljar__Last_Name__c, 
                                            skilljar__Email__c,Phone__c,Title__c,Account__c,
                                            skilljar__Obfuscated_Id__c,Is_Email_Verified__c FROM skilljar__Student__c 
                                            WHERE skilljar__Obfuscated_Id__c LIKE :idPrefix AND Is_Email_Verified__c = false LIMIT 1];
        
        Test.startTest();
        testStudent.Is_Email_Verified__c = true;
        update testStudent;
        ZSA_Integration_Log__c log = [SELECT Id FROM ZSA_Integration_Log__c WHERE Student__c =: testStudent.Id LIMIT 1];
        System.assertNotEquals(log, null,'Integration Log is missing for Student');
        Test.stopTest();
    }
    
    @isTest
    static void testSendWelcomeEmail()
    {
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        for(integer count=1;count<=2;count++)
        {
            skilljar__Student__c rec = [SELECT Name,skilljar__First_Name__c,skilljar__Last_Name__c,
                                        skilljar__Email__c,Phone__c,Title__c,Account__c,
                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c 
                                        FROM skilljar__Student__c WHERE NAME =: 'Test Student '+count];
            studentList.add(rec);
        }
        
        
        Test.startTest();
        SkillJarStudentTriggerHelper.sendWelcomeEmail(studentList);
        Test.stopTest();
        
    }
    
    //START Bikram 17th July 2022
    @isTest
    static void testSendWelcomeEmail_QueryException()
    {        
        
        Boolean isExceptionCaught = false;         
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c,Title__c ,
                                                        Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        
        Test.startTest();
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        delete con;  
        try {
            SkillJarStudentTriggerHelper.sendWelcomeEmail(studentRecordList);
        } catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('fail')) {//DML or Email Exception
                isExceptionCaught = true;
            }else if(ex.getMessage().containsIgnoreCase('List has no rows for assignment to SObject')){//Query Exception
                isExceptionCaught = true;
            }
        }
        Test.stopTest();  
        
    }
    
    @isTest
    static void testSendWelcomeEmail_EmailException()
    { 
        Boolean isExceptionCaught = false; 
        User minAccess = createMinAccessUser(true);
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                        Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        //System.runAs(minAccess) {
            Test.startTest();
            try {
                for(Integer i=0; i< 11; i++){
                    checkEmailLimit();
                    SkillJarStudentTriggerHelper.sendWelcomeEmail(studentRecordList);
                }
            } catch (Exception ex) {
                if (ex.getMessage().containsIgnoreCase('Email')) {//DML or Email Exception
                    isExceptionCaught = true;
                }else if(ex.getMessage().containsIgnoreCase('List has no rows for assignment to SObject')){//Query Exception
                    isExceptionCaught = true;
                }
            }
            Test.stopTest(); 
        //}
        
    }
    
    @isTest
    static void testVerifyNewStudentEmail_QueryException()
    {           
        Boolean isExceptionCaught = false;  
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c,Title__c ,
                                                        Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        
        Test.startTest();
        try {
            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            delete con; 
            SkillJarStudentTriggerHelper.verifyNewStudentEmail(studentRecordList);
        } catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('fail')) {//DML or Email Exception
                isExceptionCaught = true;
            }else if(ex.getMessage().containsIgnoreCase('List has no rows for assignment to SObject')){//Query Exception
                isExceptionCaught = true;
            }
        }
        Test.stopTest();          
    }
    
    @isTest
    static void testVerifyNewStudentEmail_EmailException()
    { 
        Boolean isExceptionCaught = false; 
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c,Title__c,
                                                        Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        studentRecordList[0].skilljar__Email__c = 'test@123.com';
        update studentRecordList;
        Test.startTest();
        try {
            SkillJarStudentTriggerHelper.verifyNewStudentEmail(studentRecordList);
        } catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('fail')) {//DML or Email Exception
                isExceptionCaught = true;
            }else if(ex.getMessage().containsIgnoreCase('List has no rows for assignment to SObject')){//Query Exception
                isExceptionCaught = true;
            }
        }
        Test.stopTest();  
        
    }
    
    public static void checkEmailLimit() {
        if(Limits.getEmailInvocations() >= Limits.getLimitEmailInvocations()){
            throw new SkillJarStudentTriggerHelperTestsException();
        }
    }
    
    public static User createMinAccessUser(Boolean doInsert) {
        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Customer Community User Profile'
        ]
            .Id;
        return createTestUser(profileId, doInsert);
    }
    
    public static User createTestUser(Id profileId, boolean doInsert) {
        Contact conObj = [SELECT Id FROM Contact LIMIT 1];
        User u = new User(
            profileId = profileId,
            LastName = 'last',
            Email = 'Testuser@test.example.com',
            Username = 'Testuser@test.example.com' + Crypto.getRandomInteger(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = conObj.Id
        );
        if (doInsert) {
            insert u;
        }
        return u;
    }
    //END Bikram 17th July 2022.
    
    //START Bikram 25th Aug 2022.
    @isTest
    static void testperformAccountMatchingWithDomain(){
         List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        TriggerHandler.bypass('AccountTriggerHandler');
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'test.com';
        testAccount.Type = 'Customer';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        insert testAccount;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        SkillJarStudentTriggerHelper.performAccountMatching(studentRecordList);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testperformAccountMatchingWithAdditionalDomain(){
         List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        TriggerHandler.bypass('AccountTriggerHandler');
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'abc.com';
        testAccount.Type = 'Customer';
        testAccount.Additional_Organization_Domains__c = 'test.com';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        insert testAccount;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        SkillJarStudentTriggerHelper.performAccountMatching(studentRecordList);
        Test.stopTest();
        
    }
    
    @isTest
    static void testperformAccountMatchingWithAdditionalDomainJumbledCase(){
         List<skilljar__Student__c> studentRecordList = [SELECT Id,Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        TriggerHandler.bypass('AccountTriggerHandler');
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'aBc.com';
        testAccount.Type = 'Customer';
        testAccount.Additional_Organization_Domains__c = 'tESt.com';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        insert testAccount;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        studentRecordList = [SELECT Name,Id,Account__c FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        system.assertNotEquals(0, studentRecordList.size(),'Student Record Not Found');
        studentRecordList[0].Is_Email_Verified__c = true;
        update studentRecordList;
        SkillJar__Student__c stud = [SELECT Name,Id,Account__c FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        system.assertEquals(testAccount.Id, stud.Account__c, 'Account Id populated on Student do not match');
        Test.stopTest();
        
    }
    
    @isTest
    static void testperformAccountMatchingWithAdditionalDomainUpperCase(){
         List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        TriggerHandler.bypass('AccountTriggerHandler');
        Account testAccount = new account();
        testAccount.Name = 'Test Data';
        testAccount.Domain__c = 'ABC.com';
        testAccount.Type = 'Customer';
        testAccount.Additional_Organization_Domains__c = 'TEST.com';
        testAccount.Partner_Type__c = 'Partner-Reseller';
        testAccount.Sales_Engineer__c = UserInfo.getUserId();
        insert testAccount;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
         Test.startTest();
        studentRecordList = [SELECT Name,Id,Account__c FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        system.assertNotEquals(0, studentRecordList.size(),'Student Record Not Found');
        studentRecordList[0].Is_Email_Verified__c = true;
        update studentRecordList;
        SkillJar__Student__c stud = [SELECT Name,Id,Account__c FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        system.assertEquals(testAccount.Id, stud.Account__c, 'Account Id populated on Student do not match');
        Test.stopTest();        
    }
    
    @isTest
    static void testinvokeWelcomeEmail(){
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Test.startTest();
        SkillJarStudentFlowHandler.invokeWelcomeEmail(studentRecordList);
        Test.stopTest();
    }
    
     @isTest
    static void testinvokeVerificationEmail(){
        List<skilljar__Student__c> studentRecordList = [SELECT Name,skilljar__First_Name__c,
                                                        skilljar__Last_Name__c,skilljar__Email__c,Phone__c,
                                                        Okta_Activation_Link__c,skilljar__Obfuscated_Id__c ,Title__c,
                                                         Account__c
                                                        FROM skilljar__Student__c 
                                                        WHERE NAME =: 'Test Student 1'];
        Test.startTest();
        SkillJarStudentTriggerHandler.invokeVerificationEmail(studentRecordList);
        Test.stopTest();
    }
    
    //END Bikram 25th Aug 2022
}