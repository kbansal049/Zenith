/**
 * @description       : This is the APEX Test class for CaseSelector
 * @author            : Ankit Bhatnagar
 * @last modified on  : 01-18-2023
 * @last modified by  : Ankit Bhatnagar
**/

@isTest
public class CaseSelectorTest {
    @isTest
    public static void testGetCases(){
        Set<String> accNames = new Set<String>();
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'mytestemail@test.com', 'test', null, null, 5);
        accNames.add(account.name);
        
        final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
        Case cs = TestDatafactory_Zscaler.insertCase('New', 'Test Subject', 'Test Description', account.Id, null, account.Id, CASE_SUPPORT_RT_ID);
        
        String queryFields = 'Id, Account_Name__c, Priority, Status, IsEscalated, CreatedDate';
        String whereClause = 'Account_Name__c IN ' + GCSCommonUtility.getFormattedString(new List<String>(),accNames) 
                                + ' AND (Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_PROBLEM 
                                    + '\' OR Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_QUESTION 
                                    + '\' OR Case_Type__c = \'' + GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                                + '\') AND Status !=\''+ GCSCommonConstants.CASE_STATUS_CLOSED 
                                + '\'';
        String orderByClause = 'CreatedDate';
        Integer limitClause = null;
        
        List<Case> csList = null;
        csList = CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        csList = CaseSelector.getCases(queryFields, whereClause, orderByClause, 5);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        csList = CaseSelector.getCases(queryFields, whereClause, orderByClause, -2);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);
    }
}