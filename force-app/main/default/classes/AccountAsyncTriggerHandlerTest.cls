@IsTest 
private class AccountAsyncTriggerHandlerTest {
    
    @TestSetup 
    private static void createTestData() {
        
    }
    
    @isTest
    private static void accountInsertUpdateAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        Test.getEventBus().deliver();
        
        acc.Name = 'Test Account UPDATED';
        update acc;
        Test.getEventBus().deliver();        
    }

}