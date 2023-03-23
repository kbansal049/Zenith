/*****************************************************************************************
Name: TestDataFactory_Account
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Account.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Ayush Kangar       25/01/2023      IBA-6050      
******************************************************************************************/
@isTest
public class TestDataFactory_Account {
    public static List<Account> createAccounts(Integer count, Boolean performDml)
    {
        List<Account> accounts = new List<Account>();
        for(Integer loopVar = 0; loopVar < count; loopVar++)
        {
            Account a = new Account();
            a.Name = 'ZS Account '+loopVar;
            a.BillingCity = 'California';
            a.BillingCountry = 'USA';
            a.NumberOfEmployees = 1001;
            a.Type = 'Customer';
            accounts.add(a);
        }
        if(performDml)
        {
            insert accounts;
        }
        return accounts;
    }
}