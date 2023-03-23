/**
 * @description       : This is the APEX Test class for AccountSelector
 * @author            : Ankit Bhatnagar
 * @last modified on  : 01-18-2023
 * @last modified by  : Ankit Bhatnagar
**/

@isTest
public class AccountSelectorTest {
    @isTest
    public static void testGetAccounts(){
        Set<String> accNames = new Set<String>();
        TriggerHandler.bypass('AccountTriggerHandler');
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'mytestemail@test.com', 'test', null, null, 5);
        accNames.add(account.name);
        
        String queryFields = 'Id, Name, CreatedDate';
        String whereClause = 'Name IN ' + GCSCommonUtility.getFormattedString(new List<String>(), accNames);
        String orderByClause = 'CreatedDate';
        Integer limitClause = null;
        
        List<Account> accList = null;
        accList = AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        accList = AccountSelector.getAccounts(queryFields, whereClause, orderByClause, 5);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
        
        accList = AccountSelector.getAccounts(queryFields, whereClause, orderByClause, -2);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
    }
}