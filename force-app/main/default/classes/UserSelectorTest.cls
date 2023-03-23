/**
 * @description       : This is the APEX Test class for UserSelector
 * @author            : Ankit Bhatnagar
 * @last modified on  : 01-18-2023
 * @last modified by  : Ankit Bhatnagar
**/

@isTest
public class UserSelectorTest {
    @isTest
    public static void testGetUsers(){
        List<Id> listOfProfileId = Label.Partner_Engineer_Profile_Ids.split(GCSCommonConstants.COMMA_STRING);
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'mytestemail@test.com', 'test', null, null, 5);
        
        final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
        Case cs = TestDatafactory_Zscaler.insertCase('New', 'Test Subject', 'Test Description', account.Id, null, account.Id, CASE_SUPPORT_RT_ID);
        
        Set<Id> emptySet = new Set<Id>();
        Set<Id> caseOwnersSet = new Set<Id>();
        caseOwnersSet.add(cs.OwnerId);
        
        List<Id> emptyList = new List<Id>();
        List<Id> caseOwnersList = new List<Id>();
        caseOwnersList.add(cs.OwnerId);
        
        List<User> usersList = null;
        usersList = UserSelector.getUsers(caseOwnersList, listOfProfileId, null);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(caseOwnersList, emptyList, System.today());
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(caseOwnersList, emptyList, null);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(emptyList, listOfProfileId, null);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(emptyList, emptyList, null);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        System.assert(usersList.isEmpty(), GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(caseOwnersSet, true);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(caseOwnersSet, false);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        usersList = UserSelector.getUsers(emptySet, null);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        String queryFields = 'Id, Name, Email';
        String whereClause = 'Id IN ' + GCSCommonUtility.getFormattedString(new List<String>{UserInfo.getUserId()}, new Set<String>());
        String orderByClause = 'Name';
        Integer limitClause = null;
        
        usersList = UserSelector.getUsers(queryFields, whereClause, orderByClause, limitClause);
        System.assert(usersList != null, GCSCommonConstants.APEX_TEST_PASS);
    }
}