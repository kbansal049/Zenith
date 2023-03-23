/**
 * @description       : This is the APEX Test class for GCSCommonUtility
 * @author            : Ankit Bhatnagar
 * @last modified on  : 01-18-2023
 * @last modified by  : Ankit Bhatnagar
**/

@isTest
public class GCSCommonUtilityTest {
    final static String APEX_CLASS_NAME = 'GCSCommonUtilityTest';

    //Test Method
    @isTest
    public static void testAllGCSCommonUtilityMethods(){
    	final String METHOD_NAME = 'testAllGCSCommonUtilityMethods';
        final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
        System.assert(CASE_SUPPORT_RT_ID != null, GCSCommonConstants.APEX_TEST_PASS);
        
        final String SURVEY_RT_ID = GCSCommonUtility.getSurveyRecordTypeId(GCSCommonConstants.CSAT_SURVEY_RECORD_TYPE_NAME);
        System.assert(SURVEY_RT_ID != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Account acct = TestDatafactory_Zscaler.insertAccount('Test Account', 'mytestemail@test.com', 'test', null, null, 5);
        Contact con = TestDatafactory_Zscaler.insertContact('Test Contact', acct.Id, null);
        
        Case cs = TestDatafactory_Zscaler.insertCase('New', 'Test Subject', 'Test Description', acct.Id, null, acct.Id, CASE_SUPPORT_RT_ID);

        Entitlement defconEntitle = new Entitlement();
        defconEntitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        defconEntitle.AccountId = [SELECT id FROM Account].Id;        
        defconEntitle.StartDate = date.today();   
        defconEntitle.SlaProcessId = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name = 'Defcon Escalations Entitlement Process' Order by LastModifiedDate desc LIMIT 1].Id;
        insert defconEntitle;
        
        final String CASE_DEFCON_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);
        Case defconCase = new Case();
        defconCase.Subject = 'Defcon raised for ' + cs.CaseNumber;
        defconCase.Case_Escalated_per_Defcon_Process__c = true;
        defconCase.Status = 'New';
        defconCase.Escalation_Reason__c = 'Test Escalation';
        defconCase.Escalation_Category__c = 'Unsatisfied with current support';
        defconCase.ParentId = cs.Id;
        defconCase.EntitlementId = defconEntitle.Id;
        defconCase.Escalated_By__c = UserInfo.getUserId();
        defconCase.Defcon_Level__c = '4';
        defconCase.Escalation_Level__c = 'Level 0';
        defconCase.RecordTypeId = CASE_DEFCON_RT_ID;
        defconCase.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        defconCase.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        insert defconCase;
        
        List<FieldSetMember> fm = GCSCommonUtility.getCaseFieldSet(GCSCommonConstants.CASE_ESCALATION_HISTORY_CREATION_FIELDSET_NAME);
        System.assert(fm != null, GCSCommonConstants.APEX_TEST_PASS);
        
        EmailTemplate emailTemplate = GCSCommonUtility.getEmailTemplate(new List<String>{GCSCommonConstants.DEFCON_CURRENT_STATUS_NEXT_PLAN_UPD_EMAIL_TEMPLATE}).get(GCSCommonConstants.INTEGER_0);
        System.assert(emailTemplate != null, GCSCommonConstants.APEX_TEST_PASS);
        
        FeedItem feedItem = GCSCommonUtility.prepareFeedItem(cs.Id, cs.Description, 'AllUsers', true, false);
        System.assert(feedItem != null, GCSCommonConstants.APEX_TEST_PASS);
        
		feedItem = GCSCommonUtility.prepareFeedItem(cs.Id, cs.Description, 'AllUsers', true, true);
        System.assert(feedItem != null, GCSCommonConstants.APEX_TEST_PASS);
        
        String formattedStr = GCSCommonUtility.getFormattedString(new List<Id>{cs.Id, defconCase.Id}, new Set<Id>());
        System.assert(String.isNotBlank(formattedStr) == true, GCSCommonConstants.APEX_TEST_PASS);
        
        formattedStr = GCSCommonUtility.getFormattedString(new List<Id>(), new Set<Id>{cs.Id, defconCase.Id});
        System.assert(String.isNotBlank(formattedStr) == true, GCSCommonConstants.APEX_TEST_PASS);
        
        Boolean isSBX = GCSCommonUtility.isSandbox();
        if(GCSCommonUtility.isSandbox()) {
        	System.assert(isSBX == true, 'Yes, Current org is a Sandbox - Pass');
        }else{
        	System.assert(isSBX == false, 'Yes, Current org is a Production - Pass');
        }
        
        //Intentionally assigning the wrong object id to raise an upsert error
        cs.AccountId = con.Id;
        List<Database.SaveResult> saveResultList = Database.update(new List<Case>{cs}, false);
        GCSCommonUtility.logDBInsertOrUpdateError(saveResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.COMMA_STRING);
        
        Case cs1 = new Case();
        cs1.Status = 'New';
        cs1.Subject = 'Test Subject - 2';
        cs1.Description = 'Test Description - 2';
        cs1.AccountId = con.Id;
        cs1.Account_of_Support_Case__c = null;
        cs1.Legacy_Account__c = acct.Id;
        cs1.RecordTypeId = CASE_SUPPORT_RT_ID;
        
        cs.Subject = 'Test Subject - 1';
        List<Database.UpsertResult> upsertResultList = Database.upsert(new List<Case>{cs, cs1}, false);
        GCSCommonUtility.logDBUpsertError(upsertResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.COMMA_STRING);
        
        try{
            Database.delete(cs, false);

            //Intentionally trying to delete secon time to raise an delete error
            List<Database.DeleteResult> deleteResultList = Database.delete(new List<Case>{cs}, false);
            GCSCommonUtility.logDBDeleteError(deleteResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.COMMA_STRING);
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
        OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
        Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(emailTemplate.Id, con.Id, false, owea.Id);
        System.assert(mail != null, GCSCommonConstants.APEX_TEST_PASS);
        
        List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail1 = GCSCommonUtility.prepareEmailMessage(emailTemplate.Id, con.Id, false, owea.Id);
        mail1.setWhatId(cs.Id);
        mail1.setToAddresses(new List<String>{GCSCommonConstants.ZS_SUPPORT_EMAIL_ID});
        mailLst.add(mail1);
        try{
            List<Messaging.SendEmailResult> sendEmailResultList = Messaging.sendEmail(mailLst);
            GCSCommonUtility.logSendEmailError(sendEmailResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.COMMA_STRING);
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
        
        String queueId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_SUPPORT_QUEUE);
        System.assert(queueId != null, GCSCommonConstants.APEX_TEST_PASS);

		queueId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.EMPTY_STRING);
        System.assert(queueId == GCSCommonConstants.EMPTY_STRING, GCSCommonConstants.APEX_TEST_PASS);
        
        List<String> mlsCaseIdsList = new List<String>{cs.Id};
        List<String> mlsNamesList = new List<String>{
            GCSCommonConstants.CASE_MILESTONE_OWNERSHIP_SLA, 
            GCSCommonConstants.CASE_MILESTONE_FOLLOW_UP_SLA};
        List<CaseMilestone> caseMilestoneList = GCSCommonUtility.getCaseMilestones(mlsCaseIdsList, mlsNamesList);
        System.assert(caseMilestoneList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        caseMilestoneList = GCSCommonUtility.getCaseMilestones(mlsCaseIdsList, new List<String>());
        System.assert(caseMilestoneList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        caseMilestoneList = GCSCommonUtility.getCaseMilestones(new List<String>(), mlsNamesList);
        System.assert(caseMilestoneList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        String queryFields = 'Id, Account_Name__c, Priority, Status, CreatedDate';
        String whereClause = 'Account_Name__c IN ' + GCSCommonUtility.getFormattedString(new List<String>{acct.Name}, new Set<String>()) 
                                + ' AND (Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_PROBLEM 
                                    + '\' OR Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_QUESTION 
                                    + '\' OR Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                + '\') AND Status !=\''+ GCSCommonConstants.CASE_STATUS_CLOSED 
                                + '\'';
        String orderByClause = 'CreatedDate';
        Integer limitClause = null;
        
        List<SObject> sObjList = GCSCommonUtility.getSObjectRecords(GCSCommonConstants.CASE_STRING, queryFields, whereClause, orderByClause, limitClause);
        System.assert(sObjList != null, GCSCommonConstants.APEX_TEST_PASS);
    }
}