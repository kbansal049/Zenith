@isTest
public class AccountTrafficAlertBannerControllerTest {
    @isTest 
    static void testFuntion(){
        Test.startTest();
        Database.executeBatch(new CustomerSummaryBatch('Select id from account'));
        Test.stopTest();
        AccountTrafficAlertBannerController.getAsyncApexJobDates();
    }
}