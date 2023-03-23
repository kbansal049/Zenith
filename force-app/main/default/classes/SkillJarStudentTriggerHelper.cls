/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarStudentTriggerHelper
* @description      This is the SkillJar Student Trigger helper class called synchronously 
from SkillJarStudentTriggerHandler.
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

*1.0                Karthik Pullagurla	13/12/2022      IBA-5630     Additional Code Check to handle in Sandbox environments.
*2.0                Bikram Behera	    04/02/2023      IBA-6051     Tag students registered from website to the correct account in SFDC
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class SkillJarStudentTriggerHelper {
    
    private static final String ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID = System.Label.ZS_Academy_Prefix_For_Skilljar_Id;
    private static final List<String> ACCOUNT_TYPE_LIST = new List<String> {'Partner', 'Customer', 'Prospect'};//IBA-6051
    private static final String CLASS_NAME = 'SkillJarStudentTriggerHelper';
    private static final String CONTACT_TRIGGER_HANDLER = 'ContactTriggerHandler';
    
    @TestVisible
    private static Exception circuitBreaker;
    
    public static Boolean isSandbox {
        get {
            if(isSandbox == null){
               String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();  
                if(!String.isEmpty(sandboxName) && !Test.isRunningTest()){ 
                    isSandbox = true;
                }else{
                    isSandbox = false;
                } 
            }
            return isSandbox;
        }
        set;}
    
    /**
     * @description Custom exception class
     */
    public class SkillJarStudentTriggerHelperException extends Exception {
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1169 : to send welcome email from SFDC with the 
    *                                                     updated Okta Activation link.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : sendWelcomeEmail .
    * @param    NAME : List<skilljar__Student__c> newStudentWelcomeList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void sendWelcomeEmail(List<skilljar__Student__c> newStudentWelcomeList){
        
        Contact conIdAsTargetObjId = new Contact();
        try{
            //IBA-6051 START - To set the setTargetObjectId, then delete this after sending the email.
            //As we are using the email template we have to use setTargetObjectId, 
            //which can only be a Contact or Lead or User            
            conIdAsTargetObjId.LastName = 'Test Contact to send email';
            conIdAsTargetObjId.email = 'testContactToSendEmail@yopmail.com';
            TriggerHandler.byPass(CONTACT_TRIGGER_HANDLER);
            insert conIdAsTargetObjId;
            TriggerHandler.clearByPass(CONTACT_TRIGGER_HANDLER);
            //IBA-6051 END
            EmailTemplate welcomeEmailTemplateRecord = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                                        FROM EmailTemplate 
                                                        WHERE DeveloperName =: ZScalarConstants.SKILLJAR_STUDENT_WELCOME_EMAIL_TEMPLATE];
            
            OrgWideEmailAddress[] fromAddress = [select Id from OrgWideEmailAddress where Address =: Label.ZS_Academy_Noreply_Email_Address];
            
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            
            for(skilljar__Student__c studentRecord : newStudentWelcomeList){
                
                Messaging.SingleEmailMessage emailMessageObj = new Messaging.SingleEmailMessage();
                String uniqueLink = studentRecord.Okta_Activation_Link__c;
                String htmlBody = welcomeEmailTemplateRecord.HtmlValue;
                //Replace the record detail link {!skilljar__Student__c.Link} in email template with unique URL
                htmlBody = htmlBody.replace('{!skilljar__Student__c.Okta_Activation_Link__c}', uniqueLink);
                //IBA-6051 START
                if(studentRecord.skilljar__Contact__c != NULL){
                    emailMessageObj.setTargetObjectId(studentRecord.skilljar__Contact__c);
                }else if(studentRecord.skilljar__Lead__c != NULL){
                    emailMessageObj.setTargetObjectId(studentRecord.skilljar__Lead__c);
                }else{
                    emailMessageObj.setTargetObjectId(conIdAsTargetObjId.Id);
                    emailMessageObj.setWhatId(studentRecord.Id);
                }
                //IBA-6051 END
                emailMessageObj.setTemplateId(welcomeEmailTemplateRecord.Id);
                emailMessageObj.setOrgWideEmailAddressId(fromAddress.get(0).Id);
                emailMessageObj.setSubject(String.isBlank(welcomeEmailTemplateRecord.Subject) ? 'Welcome to Zscaler Academy!' : welcomeEmailTemplateRecord.Subject);
                emailMessageObj.setHtmlBody(htmlBody);
                emailMessageObj.setToAddresses(new List<String>{studentRecord.skilljar__Email__c});
                emailMessageObj.setTreatBodiesAsTemplate(TRUE);
                emailMessageObj.setTreatTargetObjectAsRecipient(FALSE);
                emailMessageList.add(emailMessageObj);
            }
            //TODO - As we are creating an activity record on emailSend,
			//Task trigger fires and a queuable class gets called "UpdateTaskSDRFieldsbasedOnLeadAndCont" from TaskTriggerHelper,
			//Can we skip the Task Trigger ?
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
            //IBA-6051 - Codescan - Removed Debug Statement, and modified empty if statements
            if (!results[0].success) {
                ZscalerErrorLogsUtility.insertlogs(CLASS_NAME,'sendWelcomeEmail',L2O_Constants.ErrorLog.ERROR_IN,
                                                   UserInfo.getUserId(),L2O_Constants.ErrorLog.BIZ_AREA,
                                                   results[0].errors[0].message,results[0].errors[0].message,'Email Send Failed');
            }
            //IBA-6051 START - Delete the dummy contact used in setTargetObjectId 
            TriggerHandler.byPass(CONTACT_TRIGGER_HANDLER);
            delete conIdAsTargetObjId;
            TriggerHandler.ClearByPass(CONTACT_TRIGGER_HANDLER);
            //IBA-6051 START
        }catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs(CLASS_NAME,'sendWelcomeEmail',L2O_Constants.ErrorLog.ERROR_IN,UserInfo.getUserId(),
                                               L2O_Constants.ErrorLog.BIZ_AREA,e.getStackTraceString(),e.getMessage(),e.getTypeName());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1076 : to send an email when a new student record is created.
    *													to very the email address/domain using a unique link.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : verifyNewStudentEmail .
    * @param    NAME : List<skilljar__Student__c> newStudentList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */    
    public static void verifyNewStudentEmail(List<skilljar__Student__c> newStudentList){
        
        Contact conIdAsTargetObjId = new Contact();
        try{
            //IBA-6051 START - To set the setTargetObjectId, then delete this after sending the email.
            //As we are using the email template we have to use setTargetObjectId, 
            //which can only be a Contact or Lead or User            
            conIdAsTargetObjId.LastName = 'Test Contact to send email';
            conIdAsTargetObjId.email = 'testContactToSendEmail@yopmail.com';
            TriggerHandler.byPass(CONTACT_TRIGGER_HANDLER);
            insert conIdAsTargetObjId;
            TriggerHandler.clearByPass(CONTACT_TRIGGER_HANDLER);
            //IBA-6051 STOP
            Site site = [SELECT Id FROM Site WHERE UrlPathPrefix =: Label.ZS_Academy_Community_UrlPathPrefix LIMIT 1];        
            String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            EmailTemplate emailTemplateRecord = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: Label.ZS_Academy_Email_Verification_Template];
            
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            
            for(skilljar__Student__c studentRecord : newStudentList){
                
                String encodedCipherText = PerformEncryptionDecryption.performEncryption(String.valueOf(studentRecord.id), 
                    Label.ZS_Academy_InitializationVector_For_Encrypt_Decrypt,Label.ZS_Academy_Key_For_Encrypt_Decrypt);
                String encryptedStudentId = EncodingUtil.URLEncode(encodedCipherText,'UTF-8');
                Messaging.SingleEmailMessage emailMessageObj = new Messaging.SingleEmailMessage();                
                String uniqueLink = 
                    communityUrl +
                    '/s/' +
                    Label.ZS_Academy_Community_Page_For_Email_Verification +
                    '?studentrecordid=' +
                    encryptedStudentId;
                String htmlBody = emailTemplateRecord.HtmlValue;
                //Replace the record detail link {!skilljar__Student__c.Link} in email template with unique URL
                htmlBody = htmlBody.replace('{!skilljar__Student__c.Link}', uniqueLink);
                emailMessageObj.setTargetObjectId(conIdAsTargetObjId.Id);
                emailMessageObj.setWhatId(studentRecord.Id);
                emailMessageObj.setTemplateId(emailTemplateRecord.Id);
                emailMessageObj.setSubject(String.isBlank(emailTemplateRecord.Subject) ? 'Zscaler Email Verification' : emailTemplateRecord.Subject);
                emailMessageObj.setHtmlBody(htmlBody);
                //emailMessageObj.setPlainTextBody(plainTextBody);
                emailMessageObj.setToAddresses(new List<String>{studentRecord.skilljar__Email__c});
                emailMessageObj.setTreatBodiesAsTemplate(TRUE);
                emailMessageObj.setTreatTargetObjectAsRecipient(FALSE);
                emailMessageList.add(emailMessageObj);                
            }
            //TODO - As we are creating an activity record on emailSend,
			//Task trigger fires and a queuable class gets called "UpdateTaskSDRFieldsbasedOnLeadAndCont",
			//Can we skip the Task Trigger ?
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
            //IBA-6051 - Codescan - Removed Debug Statement, and modified empty if statements
            if (!results[0].success) {
                ZscalerErrorLogsUtility.insertlogs(CLASS_NAME,'verifyNewStudentEmail',L2O_Constants.ErrorLog.ERROR_IN,
                                                   UserInfo.getUserId(),L2O_Constants.ErrorLog.BIZ_AREA,
                                                   results[0].errors[0].message,results[0].errors[0].message,'Email Send Failed');
            }
            //IBA-6051 START - Delete the dummy contact used in setTargetObjectId 
            TriggerHandler.byPass(CONTACT_TRIGGER_HANDLER);
            delete conIdAsTargetObjId;
            TriggerHandler.ClearByPass(CONTACT_TRIGGER_HANDLER);
            //IBA-6051 START
        }catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs(CLASS_NAME,'verifyNewStudentEmail',L2O_Constants.ErrorLog.ERROR_IN, 
                                               UserInfo.getUserId(),L2O_Constants.ErrorLog.BIZ_AREA,e.getStackTraceString(), 
                                               e.getMessage(),e.getTypeName());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1171 :   to cleanup the student records coming from 
                                                            SkillJar out of the box functionality.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : cleanupIncomingSkillJarStudentRecords
    * @param    NAME : List<skilljar__Student__c> studentList
    * @return   TYPE : void
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void cleanupIncomingSkillJarStudentRecords(List<skilljar__Student__c> studentList) {
        try {
            List<skilljar__Student__c> outOfBoxSkillJarStudentList = filterOutOfBoxSkillJarStudents(studentList);
            Map<String, skilljar__Student__c> emailIdToOOBSkillJarStudentMap = new Map<String, skilljar__Student__c>();
    
            for (skilljar__Student__c student : outOfBoxSkillJarStudentList) {
                emailIdToOOBSkillJarStudentMap.put(student.skilljar__Email__c, student);
            }
    
            List<skilljar__Student__c> studentsToUpdateList = new List<skilljar__Student__c>();
            List<skilljar__Student__c> studentsToDeleteList = new List<skilljar__Student__c>();
    
            List<skilljar__Student__c> originalSkillJarStudentList = getOriginalSkillJarStudentsByEmail(emailIdToOOBSkillJarStudentMap.keySet());
            for (skilljar__Student__c originalStudentRecord : originalSkillJarStudentList) {
                
                if (emailIdToOOBSkillJarStudentMap.containsKey(originalStudentRecord.skilljar__Email__c)) {
                    
                    skilljar__Student__c outOfBoxStudentRecord = emailIdToOOBSkillJarStudentMap.get(originalStudentRecord.skilljar__Email__c);
                    originalStudentRecord.skilljar__Obfuscated_Id__c = outOfBoxStudentRecord.skilljar__Obfuscated_Id__c;
                    studentsToUpdateList.add(originalStudentRecord);
    
                    // We cannot delete the Trigger.New records so creating one new record and adding that to the list
                    skilljar__Student__c outOfBoxStudentRecordToDelete = new skilljar__Student__c(Id = outOfBoxStudentRecord.Id);
                    studentsToDeleteList.add(outOfBoxStudentRecordToDelete);
                }
            }
    
            if (!studentsToDeleteList.isEmpty()) {
                delete studentsToDeleteList;
    
                TriggerHandler.bypass('SkillJarStudentTriggerHandler');
                update studentsToUpdateList;
            }
        } catch (Exception e) {
            ZscalerErrorLogsUtility.insertLogs(CLASS_NAME, 'afterInsert',L2O_Constants.ErrorLog.ERROR_IN,UserInfo.getUserId(),
                                               L2O_Constants.ErrorLog.BIZ_AREA, e.getStackTraceString(), e.getMessage(),e.getTypeName());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1171 :   to filter the Student records created by 
                                                            SkillJar's Out of the Box functionality.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method       NAME : filterOutOfBoxSkillJarStudents
    * @param        NAME : List<skilljar__Student__c> studentList
    * @return       TYPE : List<skilljar__Student__c> : filtered SkillJar's Out of the Box Student records.
    * @exception    TYPE : IllegalArgumentException : throw exception if studentList is null.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<skilljar__Student__c> filterOutOfBoxSkillJarStudents(List<skilljar__Student__c> studentList) {
        if (studentList == null) {
            throw new IllegalArgumentException('Parameter studentList should not be null');
        }
        
        List<skilljar__Student__c> outOfBoxSkillJarStudentList = new List<skilljar__Student__c>();
        for (skilljar__Student__c student : studentList) {
            if (!student.skilljar__Obfuscated_Id__c.startsWith(ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID))  {
                outOfBoxSkillJarStudentList.add(student);
            }
        }

        return outOfBoxSkillJarStudentList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1171 :   to get the original student records created
                                                            through ZScaler website's student form
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : verifyNewStudentEmail .
    * @param    NAME : List<skilljar__Student__c> newStudentList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<skilljar__Student__c> getOriginalSkillJarStudentsByEmail(Set<String> emailIdList) {
        List<skilljar__Student__c> studentList = new List<skilljar__Student__c>();
        String originalStudentSkillJarIdExpression = ZS_ACADEMY_PREFIX_FOR_SKILLJAR_ID + '%';
        if (emailIdList != null && !emailIdList.isEmpty()) {
            studentList = [SELECT Id, skilljar__Obfuscated_Id__c, skilljar__Email__c FROM skilljar__Student__c 
                WHERE skilljar__Email__c IN :emailIdList AND skilljar__Obfuscated_Id__c LIKE :originalStudentSkillJarIdExpression];
        }
        return studentList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1137 :   to get the map of Contact Email to 
                                                            Corresponding Contact.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getContactsByEmail .
    * @param    NAME : Set<String> emailIdSet : Set of Contact email ids .
    * @return   TYPE :  .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Contact> getContactsByEmail(Set<String> emailIdSet) {
        List<Contact> contactList = new List<Contact>();
        if (!emailIdSet.isEmpty()) {
            contactList = [SELECT Id, Email, AccountId, Account.Type FROM Contact WHERE Email IN :emailIdSet ORDER BY CreatedDate ASC];
        }
        return contactList;
    }

    public static List<Account> getAccountsByDomainAndSubdomain(Set<String> domainNamesSet, Set<String> subdomainExpressionSet) {
        List<Account> accountList = new List<Account>();
        if (!domainNamesSet.isEmpty() || !subdomainExpressionSet.isEmpty()) {
            accountList = [SELECT Id, Domain__c, Additional_Organization_Domains__c, Type FROM Account WHERE (Domain__c IN :domainNamesSet OR Additional_Organization_Domains__c LIKE :subdomainExpressionSet)
				AND Type IN :ACCOUNT_TYPE_LIST ORDER BY CreatedDate ASC];//IBA-6051 changed to ACCOUNT_TYPE_LIST from  changed to accountTypeSet
        }
        return accountList;
    }

    public static List<Lead> getLeadsByEmail(Set<String> emailIdSet) {
        List<Lead> leadList = new List<Lead>();
        if (!emailIdSet.isEmpty()) {
            leadList = [SELECT Id, Email, LeanData__Reporting_Matched_Account__c, LeanData__Reporting_Matched_Account__r.Type FROM Lead WHERE Email IN :emailIdSet ORDER BY CreatedDate ASC];
        }
        return leadList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1137 :   to assign the Contact, Account and Lead 
                                                            matching process when an student record 
                                                            is created
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method       NAME : performContactAccountAndLeadMatchingProcess .
    * @param        NAME : List<skilljar__Student__c> studentList .
    * @return       TYPE : void .
    * @exception    TYPE : IllegalArgumentException : throw exception if studentList is null.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void performContactAccountAndLeadMatchingProcess(List<skilljar__Student__c> studentList) {
        if (studentList == null) {
            throw new IllegalArgumentException('Parameter studentList should not be null');
        }
        if (!studentList.isEmpty()) {
            List<skilljar__Student__c> remainingStudentListContactMatchingProcess = performContactMatching(studentList);
            List<skilljar__Student__c> remainingStudentListAccountMatchingProcess = performAccountMatching(remainingStudentListContactMatchingProcess);
            List<skilljar__Student__c> remainingStudentListLeadMatchingProcess = performLeadMatching(remainingStudentListAccountMatchingProcess);
            updateFinalRemainingStudents(remainingStudentListLeadMatchingProcess);
        }
    }

    public static List<skilljar__Student__c> performContactMatching(List<skilljar__Student__c> studentList) {
        Set<String> emailIdSet = new Set<String>();
        for (skilljar__Student__c student : studentList) {
            emailIdSet.add(student.skilljar__Email__c?.toLowerCase());
        }
        
        List<Contact> contactList = getContactsByEmail(emailIdSet);
        Map<String, Contact> emailIdToContactMap = new Map<String, Contact>();
        for (Contact currentContact : contactList) {
            if (!emailIdToContactMap.containsKey(currentContact.Email?.toLowerCase())) {
                emailIdToContactMap.put(currentContact.Email?.toLowerCase(), currentContact);
            }
            //IBA-6051 START
            //Add else-if logic to check the order of precedence and assign the correct Contact
            ///so that in next iteration Account is tagged based on order of precedence
            else if (emailIdToContactMap.containsKey(currentContact.Email?.toLowerCase()) && 
                     ACCOUNT_TYPE_LIST.indexOf(emailIdToContactMap.get(currentContact.Email?.toLowerCase()).Account.Type) > 
                     ACCOUNT_TYPE_LIST.indexOf(currentContact.Account.Type)) {
                emailIdToContactMap.put(currentContact.Email?.toLowerCase(), currentContact);
            }
            //IBA-6051 END
        }
        for (skilljar__Student__c student : studentList) {
            if (emailIdToContactMap.containsKey(student.skilljar__Email__c?.toLowerCase())) {
                student.skilljar__Contact__c = emailIdToContactMap.get(student.skilljar__Email__c?.toLowerCase()).Id;
                student.Account__c = emailIdToContactMap.get(student.skilljar__Email__c?.toLowerCase()).AccountId;
                student.Account_Type__c = emailIdToContactMap.get(student.skilljar__Email__c?.toLowerCase()).AccountId != null ? 
                    emailIdToContactMap.get(student.skilljar__Email__c?.toLowerCase()).Account.Type : null;
            }
        }
        return studentList;//IBA-6051 - Return studentList, as we have to check for account type in next filter as well 
    }

    public static List<skilljar__Student__c> performAccountMatching(List<skilljar__Student__c> studentList) {
        Set<String> emailDomainSet = new Set<String>();
        for (skilljar__Student__c student : studentList) {
            if (String.isNotBlank(student.skilljar__Email__c)) {
                // getting the email domain
                String emailDomain = student.skilljar__Email__c.split('@')[1]?.toLowerCase();
                emailDomainSet.add(emailDomain);
            }
        }
        if (!emailDomainSet.isEmpty()) {
            Set<String> emailSubDomainExpressionSet = new Set<String>();
            for (String emailDomain : emailDomainSet) {
                emailSubDomainExpressionSet.add('%' + emailDomain + '%');
            }
            List<Account> accountList = getAccountsByDomainAndSubdomain(emailDomainSet, emailSubDomainExpressionSet);
            Map<String, Account> emailDomainToAccountMap = new Map<String, Account>();
            Map<String, Account> emailSubdomainToAccountMap = new Map<String, Account>();
            for (Account currentAccount : accountList) {
                if (String.isNotBlank(currentAccount.Domain__c) && !emailDomainToAccountMap.containsKey(currentAccount.Domain__c?.toLowerCase())) {
                    emailDomainToAccountMap.put(currentAccount.Domain__c?.toLowerCase(), currentAccount);
                }
                //IBA-6051 START
                //Add else-if logic to check the order of precedence and assign the correct Account
                //so that in next iteration Account is tagged based on order of precedence
                else if (emailDomainToAccountMap.containsKey(currentAccount.Domain__c?.toLowerCase()) && 
                     ACCOUNT_TYPE_LIST.indexOf(emailDomainToAccountMap.get(currentAccount.Domain__c?.toLowerCase()).Type) > 
                     ACCOUNT_TYPE_LIST.indexOf(currentAccount.Type)) {
                        emailDomainToAccountMap.put(currentAccount.Domain__c?.toLowerCase(), currentAccount);
                }
                //IBA-6051 END
                if (String.isNotBlank(currentAccount.Additional_Organization_Domains__c)) {
                    for (String subdomain : currentAccount.Additional_Organization_Domains__c.split(',')) {
                        String trimmedSubdomain = subdomain.trim()?.toLowerCase();
                        if (!emailSubdomainToAccountMap.containsKey(trimmedSubdomain)) {
                            emailSubdomainToAccountMap.put(trimmedSubdomain, currentAccount);
                        }                        
                        //IBA-6051 START
                        //Add else-if logic to check the order of precedence and assign the correct Account
                        //so that in next iteration Account is tagged based on order of precedence
                        else if (emailSubdomainToAccountMap.containsKey(trimmedSubdomain) && 
                                ACCOUNT_TYPE_LIST.indexOf(emailSubdomainToAccountMap.get(trimmedSubdomain).Type) > 
                                ACCOUNT_TYPE_LIST.indexOf(currentAccount.Type)) {
                                    emailSubdomainToAccountMap.put(trimmedSubdomain, currentAccount);
                        }
                        //IBA-6051 END
                    }
                }
            }
            Map<Id, skilljar__Student__c> studentIdToStudentMap = new Map<Id, skilljar__Student__c>(studentList); 
            Map<Id, Contact> studentToContactMap = new Map<Id, Contact>();
            for (skilljar__Student__c student : studentList) {
                String emailDomain = student.skilljar__Email__c.split('@')[1]?.toLowerCase();
                if (emailDomainToAccountMap.containsKey(emailDomain)) {
                    student.Account__c = emailDomainToAccountMap.get(emailDomain).Id;
                    student.Account_Type__c = emailDomainToAccountMap.get(emailDomain).Type;

                    Contact newContact = new Contact();
                    newContact.FirstName = student.skilljar__First_Name__c;
                    newContact.LastName = student.skilljar__Last_Name__c;
                    newContact.Email = student.skilljar__Email__c;
                    newContact.Phone = student.Phone__c;
                    //newContact.MailingCountry = student.Country__c;
                    newContact.Title = student.Title__c;
                    newContact.AccountId = student.Account__c;
                    studentToContactMap.put(student.Id, newContact);
                } else if (emailSubdomainToAccountMap.containsKey(emailDomain)) {
                    student.Account__c = emailSubdomainToAccountMap.get(emailDomain).Id;
                    student.Account_Type__c = emailSubdomainToAccountMap.get(emailDomain).Type;

                    Contact newContact = new Contact();
                    newContact.FirstName = student.skilljar__First_Name__c;
                    newContact.LastName = student.skilljar__Last_Name__c;
                    newContact.Email = student.skilljar__Email__c;
                    newContact.Phone = student.Phone__c;
                    //newContact.MailingCountry = student.Country__c;
                    newContact.Title = student.Title__c;
                    newContact.AccountId = student.Account__c;
                    studentToContactMap.put(student.Id, newContact);
                }     
            }
            if (!studentToContactMap.isEmpty()) {
                insert studentToContactMap.values();

                for (String studentId : studentToContactMap.keySet()) {
                    skilljar__Student__c student = studentIdToStudentMap.get(studentId);
                    student.skilljar__Contact__c = studentToContactMap.get(studentId).Id;
                }
            }
        }
        return studentList;//IBA-6051 - Return studentList, as we have to check for account type in next filter as well 
    }

    public static List<skilljar__Student__c> performLeadMatching(List<skilljar__Student__c> studentList) {
        Set<String> emailIdSet = new Set<String>();
        for (skilljar__Student__c student : studentList) {
            emailIdSet.add(student.skilljar__Email__c?.toLowerCase());
        }
        
        List<Lead> leadList = getLeadsByEmail(emailIdSet);
        Map<String, Lead> emailIdToLeadMap = new Map<String, Lead>();
        for (Lead currentLead : leadList) {
            if (!emailIdToLeadMap.containsKey(currentLead.Email?.toLowerCase())) {
                emailIdToLeadMap.put(currentLead.Email?.toLowerCase(), currentLead);
            }
            //IBA-6051 START
            //Add else-if logic to check the order of precedence and assign the correct Account
            //so that in next iteration Account is tagged based on order of precedence
            else if (emailIdToLeadMap.containsKey(currentLead.Email?.toLowerCase()) && 
                     ACCOUNT_TYPE_LIST.indexOf(emailIdToLeadMap.get(currentLead.Email?.toLowerCase()).LeanData__Reporting_Matched_Account__r.Type) > 
                     ACCOUNT_TYPE_LIST.indexOf(currentLead.LeanData__Reporting_Matched_Account__r.Type)) {
                emailIdToLeadMap.put(currentLead.Email?.toLowerCase(), currentLead);
            }
            //IBA-6051 END
        }
        for (skilljar__Student__c student : studentList) {
            if (emailIdToLeadMap.containsKey(student.skilljar__Email__c?.toLowerCase())) {
                student.skilljar__Lead__c = emailIdToLeadMap.get(student.skilljar__Email__c?.toLowerCase()).Id;
                student.Account__c = emailIdToLeadMap.get(student.skilljar__Email__c?.toLowerCase()).LeanData__Reporting_Matched_Account__c;
                // IBA-1931 START
                student.Account_Type__c = student.Account__c != null ? 
                    emailIdToLeadMap.get(student.skilljar__Email__c?.toLowerCase()).LeanData__Reporting_Matched_Account__r.Type : 'Guest';
                // IBA-1931 END
            } 
        }
        return studentList;//IBA-6051 - Return studentList, as we have to check for account type in next filter as well 
    }

    public static void updateFinalRemainingStudents(List<skilljar__Student__c> studentList) {
        for (skilljar__Student__c student : studentList) {
            //IBA-6051 START - Check if Account__c is NULL then perform below logic
            if(student.Account__c == NULL){
                student.Account_Type__c = 'Guest';
            }  
            //IBA-6051 END          
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-1138 :   to get the original student records created
                                                            through ZScaler website's student form
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : insertLog .
    * @param    NAME : List<skilljar__Student__c> newStudentList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void insertLog(List<skilljar__Student__c> studentList, String process_Name) {
        List<ZSA_Integration_Log__c> logsToInsert = new List<ZSA_Integration_Log__c>();
        for(skilljar__Student__c stud: studentList){
            ZSA_Integration_Log__c log = new ZSA_Integration_Log__c();
            log.Student__c = stud.Id;
            log.Account__c = stud.Account__c;
            log.Contact__c = stud.skilljar__Contact__c;
            log.Email__c = stud.skilljar__Email__c;
            log.First_Name__c = stud.skilljar__First_Name__c;
            log.Last_Name__c = stud.skilljar__Last_Name__c;
            log.Status__c = 'In Progress';
            log.Process__c = process_Name;
            log.Account_Type__c	= stud.Account_Type__c;
            //IBA-1827-Start
            if(process_Name.equalsIgnoreCase('Student_Update')){
                log.Lead__c = stud.skilljar__Lead__c;
                log.Okta_ID__c = stud.Okta_ID__c;
            }
            //IBA-1827-End
            logsToInsert.add(log);
        }
        if(!logsToInsert.isEmpty()){
            List<FormulaRecalcResult> formulaResults = Formula.recalculateFormulas(logsToInsert);
            //IBA-6051 - Added debug to avoid Codescan Critical issue, Avoid unused local variables 'formulaResults'
            System.debug('formulaResults - ' + formulaResults);
            insert logsToInsert;
            if(!isSandbox){
            publishCalloutEvent(logsToInsert);
        }
        
    }
    
    }
    
    @InvocableMethod(label='Publish Callout Event' description='Publishes the platform event to workato')
  public static void publishCalloutEvent(List<ZSA_Integration_Log__c> logs){
      List<ZSA_Callout__e> eventsToPublish = new List<ZSA_Callout__e>();
      for(ZSA_Integration_Log__c log: logs){
           Request_Body obj = new Request_Body(log.First_Name__c,log.Last_Name__c,log.Email__c,
                                              log.Account__c,log.Contact__c,log.Id,log.Account_Type__c,log.lead__c,log.student__c,log.Okta_ID__c);
            String jsonFormattedString = JSON.serialize(obj);
        	ZSA_Callout__e calloutEvent = new ZSA_Callout__e(
           Process__c = log.Process__c,
           Request_Body__c=jsonFormattedString);
          eventsToPublish.add(calloutEvent);
      }
       
    // Call method to publish events
    List<Database.SaveResult> sr = EventBus.publish(eventsToPublish);
    // Inspect publishing result
    //IBA-6051 - Codescan - Removed Debug Statement, and modified empty if statements
      if (!sr[0].isSuccess()) {    
          for(Database.Error err : sr[0].getErrors()) {
              System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
          }
      } else {
          System.debug('Events published successfully ' + sr);
      }
 }

 /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method is used to set the Email_Verification_Expiration_Time__c field in GMT.
    * This value will be used later to expire the unique link used for email verfication process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : setEmailVerificationExpirationTime .
    * @param    NAME : List<skilljar__Student__c> studentList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setEmailVerificationExpirationTime(List<skilljar__Student__c> studentList) {
        for(skilljar__Student__c student : studentList){
            student.Email_Verification_Expiration_Time__c = System.now().addHours(Integer.valueOf(Label.ZS_Academy_EmailExpirationTime_InHours));
        }
    }
    
    
    public class Request_Body{
        public string f_Name;
        public string l_Name;
        public string emailId;
        public string accountId;
        public string contactId;
        public string integration_Log_Id;
        public string account_Type;
        public string leadId;
        public string studentId;
        public string oktaId;


        public Request_Body(String fName, String lName, String emailId, String accountId,
                           String contactId, String logId, String accType,String leadId,String studentId,String oktaId){
               this.f_Name = fName;
               this.l_Name = lName;
               this.emailId = emailId;
               this.accountId = accountId;
               this.contactId = contactId;
               this.integration_Log_Id = logId;
               this.account_Type = accType;
               this.leadId = leadId;
               this.studentId = studentId;
               this.oktaId = oktaId;
        }
    }
}