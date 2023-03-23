@isTest
public class CaseTriggerHelperTest {
    final static String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    final static String CASE_ESCALATION_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);
    final static String CASE_SALES_OPS_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SALES_OPS_RECORD_TYPE_NAME);
    final static String CASE_DSAT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_DSAT_TICKET_RECORD_TYPE_NAME);
    final static String CASE_EXPERIENCE_PROJECT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_EXPERIENCE_PROJECT_RECORD_TYPE_NAME);
    final static Id ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
    final static Id SLA_PROCESS_ID = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name = 'Defcon Escalations Entitlement Process' ORDER BY LastModifiedDate DESC LIMIT 1].Id;

    static String caseTZStr = 'Pacific/Chatham';
    static String userTZSIDKeyStr = 'America/Sao_Paulo';
    static String userLanguageLocaleKeyStr = 'en_US';
    static String userEmailEncodingKeyStr = 'UTF-8';
    static String testEmailStr = 'test@test.com';
    static String testEmail1Str = 'test1@t1.com';
    static String testEmail2Str = 'test2@t2.com';
    static String phoneStr = 'Phone';
    static String gmtStr = 'GMT';
    static String l2aStr = 'L2A';
    static String testFNameStr = 'TestFName';

    static String caseQueryFieldsStr = 'Id, Subject, AccountId, Case_source__c, Case_Type__c, RecordTypeId, OwnerId, Status, Priority, ContactId, ParentId, Product_New__c, Customer_Temperature__c';
    static String supportCaseWhereClauseStr = ' Subject = \'' + GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '\'';
    static String escalationCaseWhereClauseStr = ' Subject = \'' + GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT + '\'';
    static String salesOpsCaseWhereClauseStr = ' Subject = \'' + GCSCommonConstants.TEST_SALES_OPS_CASE_SUBJECT + '\'';
    static String orderByClauseCase = null;
    static Integer limitClauseCase = null;

    static String acctQueryFieldsStr = 'Id, Domain__c, X3rd_TAM_Name__c, TAM_Name_New__c, Secondary_TAM_Name__c';
    static String acctwhereClauseAccStr = ' Name = \'' + GCSCommonConstants.TEST_ACCOUNT_NAME + '\'';
    static String orderByClauseAcc = null;
    static Integer limitClauseAcc = null;

    static String userQueryFieldsStr = 'Id, Email';
    static String userWhereClauseStr = ' Email = \'' + GCSCommonConstants.TEST_USER_EMAIL + '\'';
    static String orderByClauseUser = null;
    static Integer limitClauseUser = null;
    static String idName = 'Id, Name';
    
    @testSetup
    static void setupTestData(){
        List<User> userList = new List<User>();
        User ur = GCSTestDataFactory.createUser('2xyz@xyz.com', 'test12', testFNameStr, 'ttest12', '2xyz@xyz.com.test', userTZSIDKeyStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        userList.add(ur);
        
        User ur2 = GCSTestDataFactory.createUser('3xyz@xyz.com', 'test22', 'test2', 'ttest22', '3xyz@xyz.com.test', userTZSIDKeyStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        userList.add(ur2);
        insert userList;

        User ur3 = GCSTestDataFactory.createUser('4xyz@xyz.com', 'test32', 'test3', 'ttest32', '4xyz@xyz.com.test', gmtStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        ur3.Service_Level__c = 'L1';
        insert ur3;

        Test.setCreatedDate(userList[0].Id,System.now().adddays(-2));
        Test.setCreatedDate(userList[1].Id,System.now().adddays(-2));

        TriggerHandler.bypass('AccountTriggerHandler');
        Account acct = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME, 'Customer', ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct.TAM_Name_New__c = userList[0].Id;
        acct.Secondary_TAM_Name__c = userList[1].Id;
        acct.X3rd_TAM_Name__c = ur3.Id;
        acct.Customer_s_Support_Alias__c = 'test@abc.com';
        insert acct;
		
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acct1 = GCSTestDataFactory.createAccount('Test Account for GCS', 'Customer', ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct1.TAM_Name_New__c = userList[1].Id;
        acct1.Secondary_TAM_Name__c = userList[0].Id;
        acct1.X3rd_TAM_Name__c = ur2.Id;
        acct1.Customer_s_Support_Alias__c = 'test@abc.com';
        insert acct1;

        Contact con = GCSTestDataFactory.createContact('Contact', testFNameStr, acct.Id, testEmailStr);
        insert con;
        
        Entitlement entitle1 = new Entitlement();
        entitle1.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle1.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        entitle1.StartDate = date.today();
        entitle1.slaProcessId = SLA_PROCESS_ID;
        insert entitle1;

        List<Case>caseList = new List<Case>();
        Case csSupport = GCSTestDataFactory.createCase('Test Support Case', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        csSupport.Internal_CC_List__c = 'a@gmail.com;b@gmail.com';
        csSupport.Escalation_Reason__c = 'Test Escalation';
        csSupport.Escalation_Category__c = 'Unsatisfied with current support';
        csSupport.EntitlementId = entitle1.Id;
        csSupport.Escalated_By__c = UserInfo.getUserId();
        insert csSupport;
        
        Case cs1 = GCSTestDataFactory.createCase('Test Support Case1', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs2 = GCSTestDataFactory.createCase('Test Support Case2', GCSCommonConstants.CASE_PRODUCT_CSPM, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_URGENT,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_CATEGORIZATION,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs3 = GCSTestDataFactory.createCase('Test Support Case3', GCSCommonConstants.CASE_PRODUCT_ZWS, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,'Provisioning',caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs4 = GCSTestDataFactory.createCase('Test Support Case4', GCSCommonConstants.CASE_PRODUCT_ZSCALER_DECEPTION, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,'Provisioning',caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs5 = GCSTestDataFactory.createCase('Test Support Case5', GCSCommonConstants.CASE_PRODUCT_CLOUD_CONNECTOR, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROVISIONING,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs6 = GCSTestDataFactory.createCase('Test Support Case6', GCSCommonConstants.CASE_PRODUCT_ZPC, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_CATEGORIZATION,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs7 = GCSTestDataFactory.createCase('Test Support Case7', GCSCommonConstants.CASE_PRODUCT_CLOUD_CONNECTOR, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_CATEGORIZATION,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        Case cs8 = GCSTestDataFactory.createCase('Test Support Case8', GCSCommonConstants.CASE_TYPE_CATEGORIZATION, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_SITEREVIEW,GCSCommonConstants.CASE_TYPE_CATEGORIZATION,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur3.Id,con.Id);
        cs8.case_source__c = 'GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION';
        
        Case cs10 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT, GCSCommonConstants.CASE_TYPE_CATEGORIZATION, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_SITEREVIEW,GCSCommonConstants.CASE_TYPE_CATEGORIZATION,caseTZStr, phoneStr,CASE_ESCALATION_RT_ID,ur.Id,con.Id);
        cs10.Case_Escalated_per_Defcon_Process__c = true;
        cs10.Status = GCSCommonConstants.CASE_STATUS_NEW;
        cs10.Escalation_Reason__c = 'Test Escalation';
        cs10.Escalation_Category__c = 'Unsatisfied with current support';
        cs10.ParentId = csSupport.Id;
        cs10.EntitlementId = entitle1.Id;
        cs10.Escalated_By__c = UserInfo.getUserId();
        cs10.defcon_Level__c = '1';
        cs10.Next_update_Due__c = Datetime.now().addDays(-2);
        cs10.Escalation_Level__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1;
        cs10.Auto_Esc_SLA_Violated__c = 'Level 0';
        cs10.Root_Cause_for_DEFCON__c = 'Unavoidable';
        cs10.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        cs10.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
        cs10.Case_Escalated_per_Defcon_Process__c = true;
        
        caseList.add(cs1);
        caseList.add(cs2);
        caseList.add(cs3);
        caseList.add(cs4);
        caseList.add(cs5);
        caseList.add(cs6);
        caseList.add(cs7);
        caseList.add(cs8);
        cs8.zscaler_org_id__c = 'no cloud - site review';
        
        TriggerHandler.bypass('CaseTriggerHandler');
        insert caseList;
        insert cs10;
        TriggerHandler.clearBypass('CaseTriggerHandler');
        
        Cap_Request__c newCapReq = new Cap_Request__c(Account__c = acct.id,Prioritized_Case_Routing__c = true);
        TriggerHandler.bypass('CAPRequestTriggerHandler');
        insert newCapReq;

        TriggerHandler.clearBypass('CAPRequestTriggerHandler');
        Case csSalesOps = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SALES_OPS_CASE_SUBJECT, 'ZPA', GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_SALES_OPS_RT_ID,ur.Id,con.Id);
        insert csSalesOps;
        
        Account_Extension__c actExtn = GCSTestDataFactory.createAccountExtension(acct.Id);
        actExtn.X4th_TAM_Name__c = userList[0].Id;
        insert actExtn;

        Action_Plan__c ap = GCSTestDataFactory.createActionPlan(csSupport.Id);
        insert ap;

        List<ServiceResource> srList = new List<ServiceResource>();
        ServiceResource newSr = TestDatafactory_Zscaler.insertServiceResource('SR-1', userList[0].Id, 10, 1, 5, 0, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_FRONTLINE);
        newSr.Out_of_Office__c = false;
        newSr.isActive = true;
        newSr.Daily_Quota__c = 1;
        srList.add(newSr);

        ServiceResource newSr2 = TestDatafactory_Zscaler.insertServiceResource('SR-2', userList[1].Id, 10, 1, 5, 0, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_FRONTLINE);
        newSr2.Out_of_Office__c = false;
        newSr2.isActive = true;
        newSr2.Daily_Quota__c = 1;
        srList.add(newSr2);

        ServiceResource newSr3 = TestDatafactory_Zscaler.insertServiceResource('SR-3', ur3.Id, 10, 1, 5, 0, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_FRONTLINE);
        newSr3.Out_of_Office__c = false;
        newSr3.isActive = true;
        newSr3.Daily_Quota__c = 1;
        srList.add(newSr3);
        update srList;

        Test.setCreatedDate(srList[0].Id,System.now().adddays(-2));
        Test.setCreatedDate(srList[1].Id,System.now().adddays(-2));
        Timezone_Region_Mapping__c regionMap = new Timezone_Region_Mapping__c(name=gmtStr,Timezone__c=gmtStr,Region__c='EMEA');
        insert regionMap;

        Timezone_Region_Mapping__c regionMap2 = new Timezone_Region_Mapping__c(name=userTZSIDKeyStr,Timezone__c=userTZSIDKeyStr,Region__c='PST');
        insert regionMap2;

        Case_Quota_Management__c cs = GCSTestDataFactory.createCQM(2, 10, 3, 15, 'Quota_Met;Overflow', '', 'CS;TAM', GCSCommonConstants.AMERICA_LA_TIME_ZONE, 0 , 7, 16, 19, 'Sun', 'Fri');
        cs.SetupOwnerId = UserInfo.getOrganizationId();
        insert cs;

        Primary_Secondary_Escalation_Support_Map__c newPrimSecSupport = new Primary_Secondary_Escalation_Support_Map__c(name = 'Japan', Region_Support__c = 'Japan');
        insert newPrimSecSupport;

        Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
        DateTime currentTimePst1 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        DateTime currentTimePst2 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(8);
        
        OperatingHours oh = new OperatingHours();
        oh.name = 'Test oh';
        oh.TimeZone = GCSCommonConstants.AMERICA_LA_TIME_ZONE;
        insert oh;

        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Zscaler Service Territory';
        st.IsActive = true;
        st.OperatingHoursId = oh.id;
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = newSr.id;
        stm.ServiceTerritoryId = st.id;
        stm.OperatingHoursId = oh.id;
        stm.EffectiveStartDate = currentTimePst1.addDays(-2);
        stm.EffectiveEndDate = currentTimePst2.addDays(30);
        insert stm;

        List<Primary_Secondary_Escalation_Support_Map__c> trlst = new List<Primary_Secondary_Escalation_Support_Map__c>();
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('Centracomm', '','Centracomm',''));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('CS', '', 'CS', ''));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L1', '', 'L1',''));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L1Escalation', 'L3Escalated', 'L2Escalated','L2AEscalated'));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L2', '', 'L2', 'L2-Placeholder'));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap(l2aStr, '', l2aStr, 'L2'));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L2AEscalation', '', 'L3Escalated','L3'));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L2Escalation','L3Escalated','L2AEscalated', l2aStr));
        trlst.add(GCSTestDataFactory.getPrimarySecondaryEscMap('L3', '', 'L3', l2aStr));
        insert trlst;
    }
    
    @isTest
    static void testConvertIntegrationCasesToSupport(){
        String queryFields = 'Id, Subject, Case_Source__c, Case_Type__c, RecordTypeId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).case_source__c=GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION;
        update csList;

        CaseTriggerHelper.convertIntegrationCasestoSupport(csList);
    }
    
    @isTest
    static void testAssignAccountForSupportCase(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.assignAccountforSupportCase(csList);
    }
    
    @isTest
    static void testAssignEntitlementToCase(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.assignEntitlementtoCase(csList);
        CaseTriggerHelper.assignEntitlementtoCase(null);
    }
    
    @isTest
    static void testMakeCaseDescriptionToComment(){
        String queryFields = 'id,subject,CaseNumber,case_source__c,Case_Type__c,RecordTypeId,Description';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case cs = GCSTestDataFactory.createCase('Test Experience Case', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROBLEM, caseTZStr, phoneStr, CASE_SUPPORT_RT_ID, UserInfo.getUserId(), null);
        insert cs;

        csList.get(0).Description = 'Updated Test Description - 0';
        cs.Description = 'Updated Test Description - 1';
        csList.add(cs);
        update csList;

        CaseTriggerHelper.makeCaseDescriptionToComment(csList);
        CaseTriggerHelper.makeCaseDescriptionToComment(null);
    }
    
    @isTest
    static void testAssignCustomerScoreParameters(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description,Priority,Case_Priority_Score__c,DEFCON_Score__c,Defcon_Level__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Defcon_Level__c = '4';
        update csList;

        CaseTriggerHelper.assignCustomerScoreParameters(csList);
    }
    
    @isTest
    static void testAddDefaultProductOnSFDCSupportCases(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description';
        List<Case> csList = CaseSelector.getCases(queryFields, salesOpsCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.addDefaultProductOnSFDCSupportCases(csList);
    }
    
    @isTest
    static void testAssignStatusStartDate(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description,Status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.assignStatusStartDate(csList);
    }
    
    @isTest
    static void testCreateContactUnderAccount(){
        String queryFieldsAcc = 'id,Domain__c';
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Domain__c = 'zscaler.com';
        update accList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Origin = 'Sitereview';
        csList.get(0).Case_Type__c = GCSCommonConstants.CASE_TYPE_CATEGORIZATION;
        csList.get(0).Priority = 'Low (P4)';
        csList.get(0).Case_Created_By_Email__c = 'test@zscaler.com';
        csList.get(0).contactId = null;
        update csList;

        CaseTriggerHelper.createContactUnderAccount(csList);
        CaseTriggerHelper.createContactUnderAccount(null);
    }
    
    @isTest
    static void testUpdateSEonCase(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Sales_Engineer__c = userList.get(0).Id;
        update accList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description,Account_SE_id__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        update csList;

        CaseTriggerHelper.updateSEonCase(csList);
    }
    
    @isTest
    static void testUpdateTAMEmail(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        List<Account_Extension__c> accExtn = [SELECT id,X4th_TAM_Name__c, X4th_TAM_Name__r.Email FROM Account_Extension__c LIMIT 1];
        
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).X3rd_TAM_Name__c = userList.get(0).Id;
        accList.get(0).TAM_Name_New__c = userList.get(0).Id;
        accList.get(0).Secondary_TAM_Name__c = userList.get(0).Id;
        update accList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description,Account_SE_id__c,X3_TAM_Email__c,Primary_TAM_Email__c,Secondary_TAM_Email__c,Primary_TAM_Emailformula__c, Secondary_TAM_EmailFormula__c,Account_Extension__r.X4th_TAM_Name__c,Account_Extension__r.X4th_TAM_Name__r.email  ';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        accExtn[0].X4th_TAM_Name__c = userList[0].Id;
        update accExtn;

        csList.get(0).Account_Extension__c = accExtn.get(0).Id;
        csList.get(0).AccountId = accList.get(0).Id;
        CaseTriggerHelper.updateTAMemail(csList);
        CaseTriggerHelper.updateTAMemail(null);
    }
    
    @isTest
    static void testUpdateCustomerSupportAlias(){
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Customer_s_Support_Alias__c = testEmailStr;
        update accList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Description,Customer_Support_Email_Formula__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        update csList;

        CaseTriggerHelper.updateCustomerSupportAlias(csList);
        csList[0].Case_Type__c = GCSCommonConstants.CASE_TYPE_QUESTION;
        update csList[0];
        CaseTriggerHelper.updateCustomerSupportAlias(csList);
    }
    
    @isTest
    static void testFillTAMDetails(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).X3rd_TAM_Name__c = userList.get(0).Id;
        accList.get(0).TAM_Name_New__c = userList.get(0).Id;
        accList.get(0).Secondary_TAM_Name__c = userList.get(0).Id;
        update accList;

        String queryFields = 'id,subject,RecordTypeId,AccountId,Original_Primary_TAM__c,Original_Secondary_TAM__c,Original_Third_TAM__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        csList.get(0).AccountId = accList.get(0).Id;
        update csList;

        CaseTriggerHelper.fillTAMDetails(csList);
        CaseTriggerHelper.fillTAMDetails(null);
    }
    
    @isTest
    static void testUpdateCSMOnCase(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);

        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
        accList.get(0).CSM_Name_New__c = userList.get(0).Id;
        update accList;

        String queryFields = 'id,subject,RecordTypeId,AccountId,CSM_Email__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        update csList;

        CaseTriggerHelper.updateCSMonCase(csList);
        CaseTriggerHelper.updateCSMonCase(null);
    }
    
    @isTest
    static void testSetRequestType(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        userList[0].email = testEmail1Str;
        update userList[0];
        
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE Email = :testEmailStr];
        lstContact[0].Email = testEmail2Str;
        update lstContact[0];
        
        String queryFields = 'id,subject,RecordTypeId,AccountId,CSM_Email__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        String teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
        List<CaseTeamMember>csTeamMemberList = new List<CaseTeamMember>();
        CaseTeamMember ct = new CaseTeamMember(parentid=csList[0].id, memberid=Userinfo.getuserid(), teamroleid=teamRoleId);
        user usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        CaseTeamMember ct2 = new CaseTeamMember(parentid=csList[0].id, memberid=usr.Id, teamroleid=teamRoleId);
        CsTeamMemberList.add(ct);
        csTeamMemberList.add(ct2);
        insert CsTeamMemberList;

        csList.get(0).Resolution_State__c='Resolved';
        csList.get(0).Origin='Sitereview';
        csList.get(0).Priority = 'Low (P4)';
        csList.get(0).Description='URL : wetransfer.com , Comment : We need this site to send files - Email to notify: lena.dumontet@siemensgamesa.com (Url 1 out of 1)';
        csList.get(0).Case_Type__c=GCSCommonConstants.CASE_TYPE_CATEGORIZATION;
        csList.get(0).Current_Category__c = testFNameStr;
        csList.get(0).Suggested_Category__c = testFNameStr;
        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_NEW;
        csList.get(0).Case_Created_By_Email__c='devtest@devtest.com';
        csList.get(0).Internal_CC_List__c = testEmail1Str;
        csList.get(0).Customer_CC_List__c = testEmail2Str;
        
        CaseTriggerHelper.setRequestType(csList);
        CaseTriggerHelper.setRequestType(null);
        
        CaseTriggerHelper.createCaseTeam(cslist);
        CaseTriggerHelper.createCaseTeam(null);
    }
    
    @isTest
    static void testUpdateNOCSubject(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_UpdateNOCSubject');
        
        String queryFields = 'id,subject,Priority,AccountId,Origin,RecordTypeId,Requestor_s_Email__c,Case_Created_By_Email__C';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Priority = 'Low (P4)';
        csList.get(0).Origin = 'Email';
        csList.get(0).Case_Created_By_Email__c = 'znocalerts@zscaler.com';
        update csList;

        CaseTriggerHelper.updateNOCSubject(csList,null);
    }
    
    @isTest
    static void testUpdateExtentison(){
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,Priority,AccountId,Origin,RecordTypeId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,case>oldCaseMap = new Map<Id,Case>();
        CaseTriggerHelper.updateExtentison(csList,null);
        CaseTriggerHelper.updateExtentison(null,oldCaseMap);
    }
    
    @isTest
    static void testCheckActionPlanIsCloseForCase(){
        String queryFields = 'id,subject,Priority,AccountId,Origin,RecordTypeId,Status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        update csList;

        List<Action_Plan__c> apList = [SELECT id,Status__c FROM Action_Plan__c LIMIT 1];
        apList.get(0).Case__c = csList.get(0).Id;
        apList.get(0).Status__c = GCSCommonConstants.CASE_STATUS_NEW;
        update apList;

        Map<Id,case>oldCaseMap = new Map<Id,Case>();
        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList[0].id;
        oldCaseMap.put(ccClone.Id,ccClone);
        csList[0].status = GCSCommonConstants.CASE_STATUS_CLOSED_DUPLICATE ;
        update csList[0];
        
        CaseTriggerHelper.checkActionPlanIsCloseForCase(csList,null);
        CaseTriggerHelper.checkActionPlanIsCloseForCase(null,oldCaseMap);
        CaseTriggerHelper.updateCustomerScroceCard(null,oldCaseMap);
    }
    
    @isTest
    static void testCCToCaseTeamafterInsert(){
        String queryFields = 'id,subject,Priority,AccountId,Origin,RecordTypeId,Customer_CC_List__c,Internal_CC_List__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Customer_CC_List__c = 'test@customer.com';
        update csList;

        CaseTriggerHelper.cctoCaseTeamafterInsert(csList);
        csList.get(0).Internal_CC_List__c = null;
        csList.get(0).Customer_CC_List__c = 'test@customer.com';
        CaseTriggerHelper.cctoCaseTeamafterInsert(csList);
    }
    
    @isTest
    static void testCheckTAMReassignment(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFieldsAcc = 'Id, Domain__c, X3rd_TAM_Name__c, TAM_Name_New__c, Secondary_TAM_Name__c, Skip_TAM_Reassignments__c';
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Case_Escalation_Notification_Recipients__c = testEmailStr;
        accList.get(0).X3rd_TAM_Name__c = userList.get(0).Id;
        accList.get(0).TAM_Name_New__c = userList.get(0).Id;
        accList.get(0).Secondary_TAM_Name__c = userList.get(0).Id;
        accList.get(0).Skip_TAM_Reassignments__c = true;
        update accList;

        String queryFields = 'id,subject,OwnerId,Priority,AccountId,Origin,RecordTypeId,Case_Type__c,CaseNumber,Next_TAM_Date__c,Product_New__c,Is_TAM_Account__c,Follow_Up_SLA_Violated__c,Response_SLA_Violated__c,Next_update_Due__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        csList.get(0).Next_TAM_Date__c = null;
        update csList;

        CaseTriggerHelper.checkTAMReassignment(csList,null);
        CaseTriggerHelper.checkTAMReassignment(null,null);
    }
    
    @isTest
    static void testRemoveDefonAutomationReason(){
        List<String> removeReasonStrList = new List<String>{'Lev 0','Lev 1','Lev 2'};
        String remainingReasonStr = CaseTriggerHelper.removeDefonAutomationReason(removeReasonStrList,'Lev 0');
        System.assert(remainingReasonStr != null, GCSCommonConstants.APEX_TEST_PASS);
    }
    
    @isTest
    static void testAddDefonAutomationReason(){
        String returnValue = CaseTriggerHelper.addDefonAutomationReason('Lev 0','Lev 1');
        System.assert(returnValue != null, GCSCommonConstants.APEX_TEST_PASS);
    }
    
    @isTest
    static void testSendEscalationEmail(){
        String queryFieldsAcc = 'Id, Domain__c, Case_Escalation_Notification_Recipients__c, X3rd_TAM_Name__c, TAM_Name_New__c, Secondary_TAM_Name__c, Skip_TAM_Reassignments__c';
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Case_Escalation_Notification_Recipients__c = testEmailStr;
        update accList;

        String queryFields = 'id,subject,OwnerId,IsEscalated,Owner.Email,Priority,AccountId,Origin,RecordTypeId,Case_Type__c,CaseNumber,Next_TAM_Date__c,Is_TAM_Account__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        csList[0].isEscalated = true;
        
        Case obj1 = csList.get(0).clone();
        obj1.Id = csList[0].Id;
        obj1.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        CaseTriggerHelper.sendEscalationEmail(csList,oldMap);
        CaseTriggerHelper.sendEscalationEmail(csList,null);
    }
    
    @isTest
    static void testValidateExcludePartnerCaseAssignment(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFieldsAcc = 'Id, Domain__c, Exclude_Partner_Support__c';
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        accList.get(0).Exclude_Partner_Support__c = true;
        update accList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Exclude_Partner_Support__c,OwnerId,IsClosed';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList.get(0).Id;
        ccClone.OwnerId = Label.Handoff_Queue_Id;
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.validateExcludePartnerCaseAssignment(csList, oldCaseMap);
        CaseTriggerHelper.validateExcludePartnerCaseAssignment(null, oldCaseMap);
    }
    
    @isTest
    static void testValidateAndUpdateCustomerCCList(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_CollaboratorEmailList');
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Internal_CC_List__c = testEmail1Str;
        csList.get(0).Customer_CC_List__c = testEmail2Str;
        update csList;

        Case ccClone = csList.get(0).clone();
        ccClone.Internal_CC_List__c = 'test3@t3.com';
        ccClone.Customer_CC_List__c = 'test4@t4.com';
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        oldCaseMap.put(ccClone.Id, ccClone);
        CaseTriggerHelper.validateAndUpdateCustomerCCList(csList, null);
        CaseTriggerHelper.validateAndUpdateCustomerCCList(csList, oldCaseMap);
    }
    
    @isTest
    static void testSendEmailToTamManagerForOOO(){
        User objUser = [SELECT Id From User where Email = '3xyz@xyz.com'];
        insert GCSTestDataFactory.createTriggersSwitch('Execute_TAM_Owner_OOO_Mail');
        
        String queryFieldsUser = 'Id, Email, ManagerId';
        List<User> userList = UserSelector.getUsers(queryFieldsUser, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        userList[0].Out_Of_office__c = true;
        userList[0].start_Date__c = Date.today();
        userList[0].returning_Date__c = Date.today().addDays(10);
        userList[0].ManagerId = objUser.Id;
        update userList[0];
        
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        csList.get(0).Case_Type__c = GCSCommonConstants.CASE_TYPE_QUESTION;
        csList.get(0).Status = 'Customer Note Added';
        csList.get(0).OwnerId =userList[0].Id;

        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList.get(0).Id;
        ccClone.Case_Type__c = GCSCommonConstants.CASE_TYPE_QUESTION;
        ccClone.Status = GCSCommonConstants.CASE_STATUS_NEW;
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.sendEmailToTamManagerForOOO(csList, oldCaseMap);
        CaseTriggerHelper.sendEmailToTamManagerForOOO(csList, null);
    }
    
    @isTest
    static void testSyncBusinessAnalystWithCR(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_Sync_CaseBA_With_CR');
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Business_Analyst__c';
        List<Case> csList = CaseSelector.getCases(queryFields, salesOpsCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Tracker_Change_Request__c cr = new Tracker_Change_Request__c(Assignee__c = UserInfo.getUserId(), Reporter__c = UserInfo.getUserId(), Summary__c = testFNameStr, Business_Analyst__c = UserInfo.getUserId(), Case__c = csList.get(0).Id, Stage__c = GCSCommonConstants.CASE_STATUS_NEW, parent_Request__c = null);
        insert cr;

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        csList.get(0).Business_Analyst__c = userList.get(0).Id;
        
        Case ccClone = csList.get(0).clone();
        ccClone.subject = csList.get(0).subject;
        ccClone.Id = csList.get(0).Id;
        ccClone.Business_Analyst__c = userinfo.getUserId();
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.syncBusinessAnalystWithCR(csList, oldCaseMap);
        CaseTriggerHelper.syncBusinessAnalystWithCR(csList, null);
    }
    
    @isTest
    static void testUpdateManualRoutingOfCase(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        csList.get(0).Original_Case_Assigned_Date_Time__c = null;
        
        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList.get(0).Id;
        ccClone.Ownerid = Label.Support_Queue_Id;
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.updateManualRoutingOfCase(csList, oldCaseMap);
        CaseTriggerHelper.updateManualRoutingOfCase(csList, null);
    }
    
    @isTest
    static void testCloseMilestonesonCaseClosure(){
        insert GCSTestDataFactory.createTriggersSwitch('CloseMilestonesonCaseClose');
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Status,IsClosed';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        update csList;

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList[0].id;
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.closeMilestonesonCaseClosure(csList, oldCaseMap);
    }
    
    @isTest
    static void testGetFeedbackSurveyCreation(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_Get_Feedback');
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Status,IsClosed';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Case_Type__c = GCSCommonConstants.CASE_TYPE_QUESTION;
        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        update csList;
    }
    
    @isTest
    static void testAssignNewStartDateforStatus(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        csList.get(0).Status_Start_Date__c = system.now();
        csList.get(0).Manual_SLA_Timestamp__c = null;
        CaseTriggerHelper.assignNewStartDateforStatus(csList, oldCaseMap);
    }
    
    @isTest
    static void testEscalationNotesCreation(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_Escalation_Notes_Creation');
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).Escalation_Resolution_Notes__c = 'Testing';
        update csList.get(0);
        CaseTriggerHelper.escalationNotesCreation(csList, oldCaseMap);
    }
    
    @isTest
    static void testEscalationHistoryCreation(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_Escalation_History_Creation');
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Status,IsClosed';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Case_Notes_History__c cnh = new Case_Notes_History__c(Case__c = csList.get(0).Id,Case_Escalation_History__c = null);
        insert cnh;

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        update csList.get(0);
        CaseTriggerHelper.escalationHistoryCreation(csList, oldCaseMap);
        CaseTriggerHelper.escalationHistoryCreation(null, oldCaseMap);
    }
    
    @isTest
    static void testManualSLAChange(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Manual_SLA_Timestamp__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        csList.get(0).Manual_SLA_Timestamp__c  = system.now();

        Case obj1 = csList.get(0).clone();
        obj1.Id = csList[0].Id;
        obj1.Manual_SLA_Timestamp__c  = system.now().addDays(-5);
        oldCaseMap.put(obj1.Id, obj1);
        CaseTriggerHelper.manualSLAChange(csList, oldCaseMap);
        CaseTriggerHelper.manualSLAChange(csList, null);
    }
    
    @isTest
    static void testCCtoCaseTeamafterUpdate(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Internal_CC_List__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).Internal_CC_List__c = testEmail1Str;
        csList.get(0).Customer_CC_List__c = testEmail2Str;
        update csList;

        CaseTriggerHelper.cctoCaseTeamafterUpdate(csList, oldCaseMap);
    }
    
    @isTest
    static void testUpdateTAMWeeklyDateTime(){
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Status,AccountId,ClosedDate';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).AccountId = accList.get(0).Id;
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        Case ccClone = csList.get(0).clone();
        ccClone.Id = csList[0].id;
        oldCaseMap.put(ccClone.Id,ccClone);
        csList.get(0).recordTypeID = System.Label.CaseRT_Weekly_Meeting;
        CaseTriggerHelper.updateTAMWeeklyDateTime(csList, oldCaseMap);
        CaseTriggerHelper.updateTAMWeeklyDateTime(null, oldCaseMap);
    }
    
    @isTest
    static void testUpdateDailyQuota(){
        List<ServiceResource>srlist = [SELECT id, daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c,
                                                     RelatedRecordId, Timezone__c, Type__c, Overflow_Cases__c, Overflow_Cases_Weekly__c
                                                     FROM ServiceResource limit 10];
        
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,case_Owner_is_TAM__c,Case_TAM_Assignment__c,OwnerId,status';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList[0].case_Owner_is_TAM__c = false;
        csList[0].OwnerId = userinfo.getUserId();
        CaseTriggerHelper.updateDailyQuota(csList, oldCaseMap);

        csList[0].Case_Owner_is_TAM__c = true;
        csList[0].Case_Tam_Assignment__c = 'Auto Assignment';
        srlist[0].RelatedRecordId = csList[0].OwnerId;
        srlist[0].daily_quota__c = 0;
        srlist[0].backlog__c = 2;
        srlist[0].type__c = GCSCommonConstants.SERVICE_RESOURCE_TYPE_FRONTLINE;
        update srlist[0];

        CaseTriggerHelper.updateDailyQuota(csList, oldCaseMap);
        srlist[0].daily_quota__c = 0;
        srlist[0].backlog__c = 0;
        update srlist[0];

        CaseTriggerHelper.updateDailyQuota(csList, oldCaseMap);
        srlist[0].daily_quota__c = 5;
        srlist[0].backlog__c = 0;
        srlist[0].weekly_quota__c = 2;
        update srlist[0];

        CaseTriggerHelper.updateDailyQuota(csList, oldCaseMap);
        CaseTriggerHelper.updateDailyQuota(csList, null);
        CaseTriggerHelper.updateDailyQuota(null, oldCaseMap);
        caseTriggerHelper.updateDefconStatusAsResolvedUponParentCaseIsClosed(csList,null);
    }
    
    @isTest
    static void testUpdateResolutionState(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Resolution_State__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        csList.get(0).Resolution_State__c = GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_WORKAROUND_PROVIDED;
        
        Case obj1 = csList.get(0).clone();
        obj1.Id = csList[0].Id;
        obj1.Resolution_State__c = GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_NOT_RESOLVED;
        oldCaseMap.put(obj1.Id, obj1);
        CaseTriggerHelper.updateResolutionState(csList, oldCaseMap);
        csList.get(0).Resolution_State__c = GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_NOT_RESOLVED;
        oldCaseMap.values().clear();

        Case obj2 = csList.get(0).clone();
        obj2.Id = csList[0].Id;
        obj2.Resolution_State__c = GCSCommonConstants.CASE_CASE_RESOLUTION_STATE_WORKAROUND_PROVIDED;
        oldCaseMap.put(obj2.Id, obj2);
        CaseTriggerHelper.updateResolutionState(csList, oldCaseMap);
    }
    
    @isTest
    static void testUpdateDetailsOnMasterCase(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Master_Case__c,OwnerId,ContactId';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Case newCase = GCSTestDataFactory.createCase('Test Support Child', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,csList[0].OwnerId,csList[0].contactId);
        insert newCase;
        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList[0].Master_Case__c = newCase.Id;
        CaseTriggerHelper.updateDetailsOnMasterCase(csList, oldCaseMap);
        csList[0].Master_Case__c = null;

        Case ccClone = new Case();
        ccClone.Id = csList[0].Id;
        ccClone.Master_Case__c = newCase.Id;
        oldCaseMap.values().clear();
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.updateDetailsOnMasterCase(csList, oldCaseMap);
        CaseTriggerHelper.checkIfWeekend('Asia/Kolkata');
        CaseTriggerHelper.checkIfWeekend(userTZSIDKeyStr);
    }
    
    @isTest
    static void testCreateTAMNotesHistory(){
        String queryFields = 'Id, Subject, Case_source__c, Case_Type__c, RecordTypeId, TAM_Meeting_Notes__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList[0].TAM_Meeting_Notes__c = 'New Meeting Notes';
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        Case ccClone = new Case();
        ccClone.Id = csList[0].Id;
        ccClone.TAM_Meeting_Notes__c = 'OldMeetingNotes';
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.createTAMNotesHistory(csList, oldCaseMap);
        CaseTriggerHelper.createTAMNotesHistory(null, oldCaseMap);
    }
    
    @isTest
    static void testUpdateCustomerScroceCard(){
        insert GCSTestDataFactory.createTriggersSwitch('Executed_CustomerScroceCard');
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Status,AccountId,Priority,Escalated__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).AccountId = accList.get(0).Id;
        csList.get(0).Priority = 'Urgent';
        csList.get(0).Escalated__c = true;
        update csList;

        CaseTriggerHelper.UpdateCustomerScroceCard(csList, oldCaseMap);
    }
    
    @isTest
    static void testUpdatePriorOwnerofCase(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Prior_Owner__c,Original_Case_Assigned_Date_Time__c,Product_New__c,Customer_Segment__c,Reassignment_Counter__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).OwnerID = UserInfo.getUserId();
        csList.get(0).Original_Case_Assigned_Date_Time__c = System.now();
        csList.get(0).Reassignment_Counter__c = 1;
        
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        Case ccClone = new Case();
        ccClone.Id = csList[0].Id;
        ccClone.OwnerId = Label.Handoff_Queue_Id;
        oldCaseMap.put(ccClone.Id,ccClone);
        CaseTriggerHelper.updatePriorOwnerofCase(csList, null);
        CaseTriggerHelper.updatePriorOwnerofCase(csList, oldCaseMap);
        CaseTriggerHelper.sendReassignmentThresholdEmail(oldCaseMap);
    }
    
    @isTest
    static void testChangeAccountofSupportCase(){
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId,IsClosed';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id, Case> oldCaseMap = new Map<Id, Case>(csList);
        csList.get(0).AccountId = accList.get(0).Id;
        CaseTriggerHelper.changeAccountofSupportCase(csList, oldCaseMap);
        CaseTriggerHelper.getFeedbackSurveyCreation(csList, null);
        CaseTriggerHelper.getFeedbackSurveyCreation(null, oldCaseMap);
    }
    
    @isTest
    static void testEscalateCase(){
        insert GCSTestDataFactory.createTriggersSwitch('Execute_Case_Escalation');
        String queryFieldsAcc = idName;
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,HandOff_Cases__c,AccountId,Preferred_Contact_Time_Zone__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).HandOff_Cases__c = true;
        csList.get(0).AccountId = accList.get(0).Id;
        update csList;
        
        CaseTriggerHelper.escalateCase(csList, oldCaseMap);
        CaseTriggerHelper.escalateCase(csList, null);
    }
    
    @isTest
    static void testUpdatePrioritySupportOfCase(){
        String queryFieldsAcc = idName;
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId,Priority,Product_New__c,Priority_Support__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).Case_Type__c = GCSCommonConstants.CASE_TYPE_QUESTION;
        csList.get(0).AccountId = accList.get(0).Id;
        csList.get(0).Priority = 'Urgent';
        csList.get(0).Product_New__c = GCSCOMMONCONSTANTS.CASE_PRODUCT_ZCC;
        update csList;

        CaseTriggerHelper.updatePrioritySupportOfCase(csList, oldCaseMap);
        CaseTriggerHelper.updatePrioritySupportOfCase(null, oldCaseMap);
    }
    
    @isTest
    static void testCaseHandoffAssignment(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,TAM_Reassignment__c,Product_New__c,Status,Priority,Automated_Trigger_Reason__c,Defcon_Level__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).TAM_Reassignment__c = true;
        csList.get(0).Product_New__c = GCSCOMMONCONSTANTS.CASE_PRODUCT_ZCC;
        csList.get(0).Status = GCSCommonConstants.CASE_STATUS_CUSTOMER_NOTE_ADDED;
        csList.get(0).Priority = GCSCommonConstants.CASE_PRIORITY_URGENT;
        csList.get(0).Automated_Trigger_Reason__c = GCSCommonConstants.CASE_AUTO_TRIGGER_REASON_CUST_NOTE_ADDED_P1_CASE;
        csList.get(0).Defcon_Level__c = '4';
        update csList;
        
        CaseTriggerHelper.caseHandoffAssignment(null, oldCaseMap);
    }
    
    @isTest
    static void testAssignCasesbySkillTamRouting(){
        List<User> userList = UserSelector.getUsers(userQueryFieldsStr, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        userList[0].Service_Level__c = 'L1';
        update userList[0];

        List<ServiceResource>srlist = [select id, RelatedRecordId, Daily_Quota__c, Weekly_Quota__c, backlog__c FROM ServiceResource limit 10];
        String queryFieldsAcc = idName;
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId, priority, Product_New__c,Origin,Is_TAM_Account__c,Case_Category__c,Owner_Service_Level__c,Primary_Support__c,Preferred_Contact_Time_Zone__c,zscaler_org_id__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).case_source__c = GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION;
        csList.get(0).AccountId = accList.get(0).Id;
        csList[0].priority = GCSCommonConstants.CASE_PRIORITY_HIGH;
        csList[0].Product_New__c = 'ZPA';
        update csList;

        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        srlist[0].backlog__c = -2;
        srList[0].daily_quota__c = -4;
        update srList[0];

        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        accList[0].TAM_Name_New__c = null;
        update accList[0];

        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        srlist[1].backlog__c = -2;
        srlist[1].daily_quota__c = -4;
        update srlist[1];

        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        srlist[2].backlog__c = -2;
        srlist[2].daily_quota__c = -4;
        update srlist[2];

        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        
        accList[0].Secondary_TAM_Name__c = null;
        update accList[0];
        
        CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        csList.get(0).case_source__c = GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION;
        csList.get(0).AccountId = null;
        csList.get(0).OwnerId = userList[0].id;

        Test.startTest();
            CaseTriggerHelper.assignCasesbySkill_TamRouting(csList);
        Test.stopTest();

        CaseTriggerHelper.assignCasesbySkill_TamRouting(null);
    }
    
    @isTest
    static void testSetAutoEscSLACumulativeTime(){
        User userManager = GCSTestDataFactory.createUser('12xyz@xyz.com', 'test112', 'test1', 'ttest112', '12xyz@xyz.com.test', gmtStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        userManager.Level__c = GCSCommonConstants.VP_USER_LEVEL;
        
        String queryFieldsUser = 'Id, Email, Is_Manager__c, ManagerId, Manager.Level__c,Manager.Profile.Name, Level__c';
        List<User> userList = UserSelector.getUsers(queryFieldsUser, userWhereClauseStr, orderByClauseUser, limitClauseUser);
        System.assert(userList != null, GCSCommonConstants.APEX_TEST_PASS);

        userList.get(0).ManagerId = userManager.ManagerId;
        update userList;

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,OwnerId,Auto_Esc_SLA_Violated__c,Escalation_Level__c,Defcon_Automation_Reason__c';
        List<Case> csList = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Case obj1 = csList.get(0).clone();
        obj1.Id = csList[0].Id;
        obj1.IsEscalated = false;
        obj1.OwnerId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_DEFCON_ESCALATION_QUEUE);
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        oldCaseMap.put(obj1.Id, obj1);
        
        csList.get(0).OwnerId = userinfo.getUserId();
        csList.get(0).Escalation_Level__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1;
        csList.get(0).Auto_Esc_SLA_Violated__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1;
        csList.get(0).Current_Status_Next_Plan_Of_Action__c = 'Current Status:test\n Next Plan Of Action:test\n Exec Summary:test\n Next Steps:test \n Last Update:'+DateTime.now();
        csList.get(0).Defcon_Automation_Reason__c = 'Ownership SLA Violated;Follow Up SLA Violated;Auto Esc Lev 0 Violated;Auto Esc Lev 1 Violated;Auto Esc Lev 2 Violated;';

        CaseTriggerHelper.setAutoEscSLACumulativeTime(csList,oldCaseMap);
        CaseTriggerHelper.setAutoEscSLACumulativeTime(csList,null);
        insert new Internal_Domains_Exclusion__c(SetupOwnerId=UserInfo.getOrganizationId(), Domains__c='zscaler,test');

        CaseTriggerHelper.checkEmailDomainsExclude(userinfo.getUserEmail(),new List<String>{testFNameStr,'','zscaler','test123'});
    }
    
    @isTest
    static void testResetMilestonesOnDefconUpdate(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,defcon_Level__c,status,Defcon_Automation_Reason__c,Follow_Up_SLA_Violated__c,Is_Follow_Up_SLA_Violated__c,Response_SLA_Violated__c,Next_update_Due__c';
        List<Case> csList = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        Case obj1 = csList.get(0).clone();
        obj1.Id = csList[0].Id;
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        oldCaseMap.put(obj1.Id, obj1);
        csList.get(0).defcon_Level__c = '4';
        csList.get(0).status = GCSCommonConstants.CASE_STATUS_RESOLVED;
        csList.get(0).Follow_Up_SLA_Violated__c  = true;
        csList.get(0).Response_SLA_Violated__c  = true;
        csList.get(0).Next_update_Due__c = Datetime.now();
        CaseTriggerHelper.resetMilestonesOnDefconUpdate(csList,oldCaseMap);
    }
    
    @isTest
    static void testSetPriorOwner(){
        String queryFields = 'id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId, Prior_Owner_Id__c, Case_Record_Type_Name__c, FRT_Violation_Warning__c,  Prior_Defcon_Level__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        
        Map<Id, Case> caseOldMap = new Map<Id, Case>();
        obj1.Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        obj1.FRT_Violation_Warning__c = false;
        obj1.Defcon_Level__c = '2';
        caseOldMap.put(obj1.Id, obj1);
        
        casesNew[0].OwnerId = System.Label.Defcon_Escalation_Queue;
        casesNew[0].FRT_Violation_Warning__c = true;
        casesNew[0].Defcon_Level__c = '3';
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.Support_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.ZPA_Support_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.ZPC_Support_Queue;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.ZWS_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.In_Country_USA_Support_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.In_Country_USA_Defcon_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
        obj1.OwnerId = System.Label.Defcon_Escalation_Queue;
        casesNew[0].OwnerId = System.Label.In_Country_USA_Defcon_Queue_Id;
        CaseTriggerHelper.setPriorOwner(casesNew, caseOldMap);
    }

    @isTest
    static void testReopenDefconCase(){
        String queryFields = 'id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case childCase = GCSTestDataFactory.createCase('Test Support Child', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_ESCALATION_RT_ID,casesNew[0].OwnerId,casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase;
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        Map<Id, Case> caseOldMap = new Map<Id, Case>();
        obj1.Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        caseOldMap.put(obj1.Id, obj1);
        CaseTriggerHelper.reopenDefconCase(casesNew, caseOldMap);
        CaseTriggerHelper.reopenDefconCase(casesNew, null);
    }
    
    @isTest
    static void testValidateDefconOwnerBeforeDefconOwnershipChange(){
        String queryFields = 'id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId';
        List<Case> casesNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);

        casesNew[0].OwnerId = userinfo.getUserId();
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.OwnerId = System.Label.ZPA_Support_Queue_Id;
        
        casesNew[0].RecordTypeId = CASE_ESCALATION_RT_ID;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        CaseTriggerHelper.validateDefconOwnerBeforeDefconOwnershipChange(casesNew, oldMap);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.validateDefconOwnerBeforeDefconOwnershipChange(casesNew, null);
    }
    
    @isTest
    static void testToggleAutoEscSLAOnDefcon(){
        String queryFields = 'id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case childCase = GCSTestDataFactory.createCase('Test Support Child 1', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_ESCALATION_RT_ID,casesNew[0].OwnerId,casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase;
        
        Case csSupport2 = GCSTestDataFactory.createCase('Test Support Case 2', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_SUPPORT_RT_ID, casesNew[0].OwnerId, casesNew[0].contactId);
        insert csSupport2;

        List<Case> casesNew2 = [SELECT id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId FROM Case where subject = 'Test Support Case 2'];
        Case childCase2 = GCSTestDataFactory.createCase('Test Support Child 2', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_ESCALATION_RT_ID,casesNew[0].OwnerId,casesNew[0].contactId);
        childCase2.ParentId = casesNew2[0].Id;
        childCase2.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase2;
        
        Case objOld = casesNew.get(0).clone();
        objOld.Id = casesNew[0].Id;
        objOld.OwnerId = System.Label.ZPA_Support_Queue_Id;
        objOld.Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        
        Case objOld2 = casesNew2.get(0).clone();
        objOld2.Id = casesNew2[0].Id;
        objOld2.OwnerId = System.Label.ZPA_Support_Queue_Id;
        
        casesNew2[0].Status = GCSCommonConstants.CASE_STATUS_AWAITING_FIX;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(objOld.Id, objOld);
        oldMap.put(objOld2.Id, objOld2);
        
        List<Case> lstNewCase = new List<Case>();
        lstNewCase.add(casesNew[0]);
        lstNewCase.add(casesNew2[0]);
        CaseTriggerHelper.toggleAutoEscSLAOnDefcon(lstNewCase, oldMap);
        CaseTriggerHelper.toggleAutoEscSLAOnDefcon(lstNewCase, null);
    }
    
    @isTest
    static void testInsertCaseRecordHistoryTracking(){ 
        String queryFields = 'id, subject,AccountId , case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, Priority, contactId';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.IsEscalated = false;
        casesNew[0].IsEscalated = true;
        casesNew[0].Priority = 'Medium';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        CaseTriggerHelper.insertCaseRecordHistoryTracking(casesNew, oldMap);
        CaseTriggerHelper.insertCaseRecordHistoryTracking(casesNew, null);
    }
    
    @isTest
    static void testAddEntitlementToDefconCases(){ 
        Account accObj = [SELECT Id FROM Account WHERE Name = :GCSCommonConstants.TEST_ACCOUNT_NAME LIMIT 1];
        Entitlement entitle = GCSTestDataFactory.createEntitlement('Defcon Escalation Entitlement (DO NOT DELETE)', accObj.Id, NULL, SLA_PROCESS_ID);
        insert entitle;

        String queryFields = 'id, subject,case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, contactId, Defcon_Level__c, Escalated_By__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        User ur = GCSTestDataFactory.createUser('22xyz@xyz.com', 'test122', testFNameStr, 'ttest122', '22xyz@xyz.com.test', gmtStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        ur.ManagerId = userinfo.getUserId();
        insert ur;
        
        casesNew[0].Defcon_Level__c = '5';
        casesNew[0].Escalated_By__c = ur.Id;
        casesNew[0].RecordTypeId = CASE_ESCALATION_RT_ID;
        CaseTriggerHelper.addEntitlementToDefconCases(casesNew);
        System.assert(casesNew[0].OwnerId == ur.ManagerId, GCSCommonConstants.APEX_TEST_PASS);

        CaseTriggerHelper.addEntitlementToDefconCases(null);
    }
    
    @isTest
    static void testUpdateCaseIntegration(){ 
        String queryFields = 'id, subject,AccountId , case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, Priority, contactId, Resolution_Type__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.IsEscalated = false;
        
        casesNew[0].External_Reference__c = testFNameStr;
        casesNew[0].origin = GCSCommonConstants.CASE_ORIGIN_API;
        casesNew[0].Resolution_Type__c = 'Other';
        casesNew[0].Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        casesNew[0].Product_New__c = GCSCommonConstants.CASE_PRODUCT_ZIA;
        
        EmailMessage emailMessage = GCSTestDataFactory.createEmailMessage('3', casesNew[0].Id, 'billing@acme.com', 'Billing Department', 'johnSmith@example.com', 'Hello', 'Hello World');
        insert emailMessage;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        Case_Integration__c ci = GCSTestDataFactory.createCaseIntegration('Not Started', 'INC123456', 'CI12345', 'CI545645', 'CI545646', 'Test Data Points', 'Test Communication', 'Open', testFNameStr, testFNameStr, '4', testFNameStr, 'INC_Zscaler', 'Siemens', 'Incident', casesNew[0].Id);
        insert ci;

        Case_Integration__c ci2 = GCSTestDataFactory.createCaseIntegration('Not Started', 'INC123457', 'CI12345', 'CI545645', 'CI545646', 'Test Data Points', 'Test Communication', 'Open', testFNameStr, testFNameStr, '4', testFNameStr, 'INC_Zscaler', 'Siemens', 'Complaint', casesNew[0].Id);
        insert ci2;
        
        CaseTriggerHelper.updateCaseIntegration(casesNew, oldMap);
        casesNew[0].status = GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER;
        casesNew[0].Resolution_Type__c = null;
        update casesNew[0];
        
        CaseTriggerHelper.updateCaseIntegration(casesNew, oldMap);
        casesNew[0].status = GCSCommonConstants.CASE_STATUS_RESEARCHING ;
        casesNew[0].Resolution_Type__c = null;
        update casesNew[0];
        
        CaseTriggerHelper.updateCaseIntegration(casesNew, oldMap);
        casesNew[0].status = GCSCommonConstants.CASE_STATUS_CUSTOMER_CALLBACK_SCHEDULED ;
        casesNew[0].Resolution_Type__c = null;
        update casesNew[0];
        
        CaseTriggerHelper.updateCaseIntegration(casesNew, oldMap);
        CaseTriggerHelper.updateCaseIntegration(casesNew, null);
    }
    
    @isTest
    static void testCaseStatusChangeManagement(){
        String queryFields = 'id, subject,AccountId , case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, Priority, contactId, Resolution_Type__c, Work_Item_Progress__c, Status_Start_Date__c, SRT_Violated_Time__c, Subsequent_Response_Breached__c, First_Response_Time_Violated__c,First_Response_Violated_Time__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Datetime myDateTime = datetime.now();
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.IsEscalated = false;
        obj1.Status = GCSCommonConstants.CASE_STATUS_NEW;
        obj1.Status_Start_Date__c = myDateTime.addDays(-3);
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        casesNew[0].SRT_Violated_Time__c = myDateTime.addDays(-2);
        casesNew[0].First_Response_Violated_Time__c = myDateTime.addDays(-2);
        casesNew[0].Status = GCSCommonConstants.CASE_STATUS_CLOSED;
        casesNew[0].Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_COMPLETED;

        User userObj = [SELECT Id FROM User WHERE Id  =: casesNew[0].OwnerId];
        System.runAs(userObj){
            CaseTriggerHelper.caseStatusChangeManagement(casesNew, oldMap);
            List<Case_Stage_History__c> lstCaseStage = [SELECT Id FROM Case_Stage_History__c];
            System.assert(!lstCaseStage.isEmpty(), GCSCommonConstants.APEX_TEST_PASS);
        }
        CaseTriggerHelper.caseStatusChangeManagement(casesNew, null);
    }
    
    @isTest
    static void testUpdatePendingCustomerTimestamp(){
        String queryFields = 'id, subject,AccountId , case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status, Priority, contactId, Resolution_Type__c, Work_Item_Progress__c, Status_Start_Date__c, SRT_Violated_Time__c, Subsequent_Response_Breached__c, First_Response_Time_Violated__c, First_Response_Violated_Time__c, Warm_Handoff__c,Product_New__c,Priority_Support__c,Preferred_Contact_Time_Zone__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case csSupport2 = GCSTestDataFactory.createCase('Test Support Case 22', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,
                                                        casesNew[0].RecordTypeId, casesNew[0].OwnerId, casesNew[0].contactId);
        insert csSupport2;

        Case csSupport3 = GCSTestDataFactory.createCase('Test Support Case 33', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,
                                                        casesNew[0].RecordTypeId, casesNew[0].OwnerId, casesNew[0].contactId);
        insert csSupport3;
        
        List<Case> casesNew2 = [SELECT id, subject,AccountId , case_source__c, Case_Type__c, RecordTypeId,OwnerId, Status,
                                Priority, contactId, Resolution_Type__c, Work_Item_Progress__c, Status_Start_Date__c,
                                SRT_Violated_Time__c, Subsequent_Response_Breached__c, First_Response_Time_Violated__c,
                                First_Response_Violated_Time__c, Warm_Handoff__c,Product_New__c,Priority_Support__c,Preferred_Contact_Time_Zone__c FROM Case where subject = 'Test Support Case 22' OR subject = 'Test Support Case 33'];
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.IsEscalated = false;
        
        Case obj2 = casesNew2.get(1).clone();
        obj2.Id = casesNew2[0].Id;
        obj2.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        oldMap.put(obj2.Id, obj2);
        
        casesNew[0].Status = GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER;
        casesNew[0].Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_COMPLETED;
        casesNew[0].Case_Type__c = GCSCommonConstants.CASE_TYPE_PROBLEM;
        casesNew[0].Warm_Handoff__c = true;
        casesNew[0].Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_IN_PROGRESS;
        casesNew[0].Priority_Support__c = 'P1';
        
        casesNew2[0].Status = GCSCommonConstants.CASE_STATUS_PENDING_FIX_VERIFICATION;
        casesNew2[0].Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_COMPLETED;
        casesNew2[0].Case_Type__c = GCSCommonConstants.CASE_TYPE_PROVISIONING;
        casesNew2[0].Warm_Handoff__c = true;
        casesNew2[0].Work_Item_Progress__c = GCSCommonConstants.CASE_WORK_ITEM_PROGRESS_IN_PROGRESS;
        casesNew2[0].Priority_Support__c = 'P1';

        List<Case> lstCase = new List<Case>();
        lstCase.add(casesNew[0]);
        lstCase.add(casesNew2[0]);
        lstCase.add(csSupport2);
        CaseTriggerHelper.updatePendingCustomerTimestamp(lstCase, oldMap);
        casesNew[0].accountId = null;
        casesNew2[0].accountId = null;
        lstCase.add(casesNew[0]);
        lstCase.add(casesNew2[0]);
        CaseTriggerHelper.updatePendingCustomerTimestamp(lstCase, oldMap);
        CaseTriggerHelper.updatePendingCustomerTimestamp(lstCase, null);
    }
    
    @isTest
    static void testUpdateParentFieldsOnDefcon(){
        List<Case> casesNew = CaseSelector.getCases(caseQueryFieldsStr, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Contact con = GCSTestDataFactory.createContact('Contact 2','Test 2',casesNew[0].AccountId,'test2@test.com');
        insert con;
        
        Case childCase = GCSTestDataFactory.createCase('Test Support Child', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr,CASE_ESCALATION_RT_ID,casesNew[0].OwnerId,casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase;
        
        Case obj1 = casesNew.get(0).clone();
        obj1.Id = casesNew[0].Id;
        obj1.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        casesNew[0].Status = GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER;
        casesNew[0].ContactId = con.Id;
        
        CaseTriggerHelper.updateParentFieldsOnDefcon(casesNew, oldMap);
        CaseTriggerHelper.updateParentFieldsOnDefcon(casesNew, null);
    }
    
    @isTest
    static void testSetDefaultNextPlanOfActionTemplateFields(){
        List<Case> casesNew = CaseSelector.getCases(caseQueryFieldsStr, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case childCase = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr, CASE_ESCALATION_RT_ID, casesNew[0].OwnerId, casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase;
        
        String queryFields = 'id, subject, AccountId , case_source__c, Case_Type__c, RecordTypeId, OwnerId, Status,Priority, contactId, ParentId, Product_New__c, Customer_Temperature__c, Current_Status_Next_Plan_Of_Action__c,LastModifiedDate';
        orderByClauseCase = null;
        limitClauseCase = null;
        List<Case> casesESCNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesESCNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case obj1 = casesESCNew.get(0).clone();
        obj1.Id = casesESCNew[0].Id;
        obj1.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        casesESCNew[0].Current_Status_Next_Plan_Of_Action__c = 'Action:\n Exec Summary \n Last Update: test data';
        CaseTriggerHelper.setDefaultNextPlanOfActionTemplateFields( casesESCNew, oldMap);
        casesESCNew[0].Current_Status_Next_Plan_Of_Action__c = 'Test Data';
        CaseTriggerHelper.setDefaultNextPlanOfActionTemplateFields( casesESCNew, oldMap);
        System.assert(casesESCNew[0].Current_Status_Next_Plan_Of_Action__c.Contains('Last Update:') , GCSCommonConstants.APEX_TEST_PASS);
        CaseTriggerHelper.setDefaultNextPlanOfActionTemplateFields( null, oldMap);
    }
    
    @isTest
    static void testSetDefconNextUpdateDue(){
        List<Case> casesNew = CaseSelector.getCases(caseQueryFieldsStr, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case childCase = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr, CASE_ESCALATION_RT_ID, casesNew[0].OwnerId, casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        insert childCase;
        
        String queryFields = 'id, subject, AccountId , case_source__c, Case_Type__c, RecordTypeId, OwnerId, Status, Priority, contactId, ParentId, Product_New__c, Customer_Temperature__c, Current_Status_Next_Plan_Of_Action__c, Defcon_Level__c, LastModifiedDate, Next_Update_Due__c,Defcon_Automation_Reason__c';
        orderByClauseCase = null;
        limitClauseCase = null;
        List<Case> casesESCNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesESCNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case obj1 = casesESCNew.get(0).clone();
        obj1.Id = casesESCNew[0].Id;
        obj1.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        casesESCNew[0].Defcon_Level__c = '4';
        CaseTriggerHelper.setDefconNextUpdateDue( casesESCNew, oldMap);
        casesESCNew[0].Next_Update_Due__c = System.now();
        CaseTriggerHelper.setDefconNextUpdateDue( casesESCNew, oldMap);
        obj1.Defcon_Level__c = '4';
        obj1.OwnerId = null;
        CaseTriggerHelper.setDefconNextUpdateDue( casesESCNew, oldMap);
        casesESCNew[0].Next_Update_Due__c = null;
        casesESCNew[0].Status = GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER;
        CaseTriggerHelper.setDefconNextUpdateDue( casesESCNew, oldMap);
        System.assert(casesESCNew[0].Status != GCSCommonConstants.CASE_STATUS_PENDING_CUSTOMER , GCSCommonConstants.APEX_TEST_PASS);
        CaseTriggerHelper.setDefconNextUpdateDue( null, oldMap);
    }
    
    @isTest
    static void testSendDefconNextPlanOfActionChangeEmail(){
        List<Case> casesNew = CaseSelector.getCases(caseQueryFieldsStr, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);
        
        Case childCase = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr, CASE_ESCALATION_RT_ID, casesNew[0].OwnerId, casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        childCase.Escalated_By__c = userinfo.getUserId();
        insert childCase;
        
        String queryFields = 'id, subject, AccountId , case_source__c, Case_Type__c, RecordTypeId, Case_Record_Type_Name__c, OwnerId, Status,Priority, contactId, ParentId, Product_New__c, Customer_Temperature__c, Current_Status_Next_Plan_Of_Action__c, Defcon_Level__c,LastModifiedDate, Next_Update_Due__c,Defcon_Automation_Reason__c';
        orderByClauseCase = null;
        limitClauseCase = null;
        List<Case> casesESCNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        Case obj1 = casesESCNew.get(0).clone();
        obj1.Id = casesESCNew[0].Id;
        obj1.IsEscalated = false;
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        
        casesESCNew[0].Current_Status_Next_Plan_Of_Action__c = 'Action:\n Exec Summary \n Last Update: test data';
        CaseTriggerHelper.sendDefconNextPlanOfActionChangeEmail(casesESCNew, oldMap);
        CaseTriggerHelper.sendDefconNextPlanOfActionChangeEmail(casesESCNew, null);
        System.assert(casesESCNew != null, GCSCommonConstants.APEX_TEST_PASS);
    }
    
    @isTest
    static void testCreateSurvey(){
        List<String> listOfDomainsToExclude = new List<String>();
        String queryFields = 'id, subject, Account_Extension__c, Case_Category__c, Case_Sub_Category__c, ContactEmail, AccountId, Contact_Name__c, Case_Owner_Manager__c, case_source__c, Case_Type__c, RecordTypeId, OwnerId, Status, Priority, contactId, ParentId, Product_New__c,Customer_Temperature__c';
        List<Case> casesNew = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);

        Map<Id, User> mapOfUserDetails = new  Map<Id, User>([SELECT Id FROM USER where Id=:casesNew[0].OwnerId LIMIT 1]);
        Survey__c surveyObj = CaseTriggerHelper.createSurvey(casesNew[0], listOfDomainsToExclude, mapOfUserDetails, true);
        System.assert(surveyObj.Account__c == casesNew[0].accountId, GCSCommonConstants.APEX_TEST_PASS);
    }
    
    @isTest
    static void testCompleteDefconMilestones(){
        List<Case> casesNew = CaseSelector.getCases(caseQueryFieldsStr, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(casesNew != null, GCSCommonConstants.APEX_TEST_PASS);

        Entitlement entitle = GCSTestDataFactory.createEntitlement('Defcon Escalations Entitlement Process', casesNew[0].AccountId, System.today(), SLA_PROCESS_ID);
        insert entitle;

        Case childCase = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_ESCALATION_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION,GCSCommonConstants.CASE_TYPE_PROBLEM,caseTZStr, phoneStr, CASE_ESCALATION_RT_ID, casesNew[0].OwnerId, casesNew[0].contactId);
        childCase.ParentId = casesNew[0].Id;
        childCase.Case_Escalated_per_Defcon_Process__c = true;
        childCase.Escalated_By__c = userinfo.getUserId();
        childCase.Escalation_Level__c = 'Level 0';
        childCase.Status = 'Needs Follow Up';
        childCase.EntitlementId = entitle.Id;
        childCase.Defcon_Level__c = '1';
        childCase.Auto_Esc_SLA_Level_0_Cumulative_Time__c  = 120;
        insert childCase;
        
        String queryFields = 'id, subject, AccountId , case_source__c, Case_Type__c, RecordTypeId, Case_Record_Type_Name__c, OwnerId, Status,Priority, contactId, ParentId, Product_New__c, Customer_Temperature__c, Current_Status_Next_Plan_Of_Action__c, Defcon_Level__c,LastModifiedDate, Next_Update_Due__c,Defcon_Automation_Reason__c';
        orderByClauseCase = null;
        limitClauseCase = null;
        List<Case> casesESCNew = CaseSelector.getCases(queryFields, escalationCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        Case obj1 = casesESCNew.get(0).clone();
        obj1.Id = casesESCNew[0].Id;
        obj1.IsEscalated = false;
        obj1.OwnerId = GCSCommonUtility.getCaseQueueId(GCSCommonConstants.Q_DEV_NAME_DEFCON_ESCALATION_QUEUE);
        obj1.Defcon_Automation_Reason__c = 'Defcon Level Changed;';
        obj1.Escalation_Level__c = 'Level 0';
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(obj1.Id, obj1);
        casesESCNew[0].Defcon_Automation_Reason__c = 'Ownership SLA Violated;Follow Up SLA Violated;Auto Esc Lev 0 Violated;Auto Esc Lev 1 Violated;Auto Esc Lev 2 Violated;';
        casesESCNew[0].Escalation_Level__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_1;
        CaseTriggerHelper.completeDefconMilestones(casesESCNew, oldMap);
        CaseTriggerHelper.completeDefconMilestones(casesESCNew, null);
    }
    
    @isTest
    static void testIsUSAIncountrySupportOfferingCase(){
        String queryFieldsAcc = idName+ ', Support_Type__c, Support_Offering__c';
        String whereClauseAcc = ' name  = \'' + GCSCommonConstants.TEST_ACCOUNT_NAME + '\'';
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, whereClauseAcc, orderByClauseAcc, limitClauseAcc);

        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId,Priority,Product_New__c,Priority_Support__c';
        
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Case_Type__c = GCSCommonConstants.CASE_TYPE_PROBLEM;
        csList.get(0).AccountId = accList.get(0).Id;
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        Account objAcc = accList.get(0);
        objAcc.Support_Type__c = GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY;
        objAcc.Support_Offering__c = 'Premium Support Plus;United States';
        oldAccMap.put(accList.get(0).Id,accList.get(0));
        CaseTriggerHelper.isUSAIncountrySupportOfferingCase(csList.get(0), oldAccMap);
    }
    
    @isTest
    static void caseOwnerOOOValidation_Test() {
        String queryFieldsAcc = idName;
        List<Account> accList = AccountSelector.getAccounts(queryFieldsAcc, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);

        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,AccountId,Priority,Product_New__c,Priority_Support__c';
        List<Case> csList = CaseSelector.getCases(queryFields, supportCaseWhereClauseStr, orderByClauseCase, limitClauseCase);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        User ur = GCSTestDataFactory.createUser('22xyz@xyz.com', 'test122', testFNameStr, 'ttest122', '22xyz@xyz.com.test', gmtStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        ur.ManagerId = userinfo.getUserId();
        insert ur;
        
        List<ServiceResource> srList = new List<ServiceResource>();
        ServiceResource newSr2 = TestDatafactory_Zscaler.insertServiceResource('SR-2', ur.Id, 10, 1, 5, 0, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_FRONTLINE);
        newSr2.Out_of_Office__c = false;
        newSr2.isActive = true;
        newSr2.Daily_Quota__c = 1;
        srList.add(newSr2);
        update srList;
        
        //Map<Id,Case> oldCaseMap = new Map<Id,Case>(csList);
        csList.get(0).OwnerId = ur.Id;
        csList.get(0).AccountId = accList.get(0).Id;
        csList.get(0).Priority = 'Urgent';
        csList.get(0).Product_New__c = GCSCOMMONCONSTANTS.CASE_PRODUCT_ZCC;
        update csList;
    }
}