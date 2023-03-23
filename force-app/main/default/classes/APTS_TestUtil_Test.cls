/*************************************************************************************************************************
 @Name: APTS_TestUtil_Test
 @Author: Anay Bhande
 @Created Date: 20/12/2016
 @Descripton: Test Class for APTS_TestUtil
 @Used By:
*************************************************************************************************************************/
@isTest
public class APTS_TestUtil_Test {
    static testMethod void testUtility() {
        Test.startTest();
        Account acc = APTS_TestUtil.createAccount();
		APTS_TestUtil.createOpportunity(acc.id, '');
        APTS_TestUtil.createProducts(10);
        Test.stopTest();
    }
}