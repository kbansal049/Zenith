@isTest
private class AccountCloudUsageMonthlyTest {
	static testmethod void run(){
    	Account a = new Account(Name = 'TestAccount',Authenticated_Users_Deployed__c = 3322, Type = 'Customer');
        insert a;
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', a.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;
        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = a.id,Cloud_Type__c = 'ZIA');
    	insert ci;
    	BWC_Data__c bw = new BWC_Data__c(Cloud_ID__c= ci.Id,X90_Day_Trailing_Unique_Auth_Users__c = 3153,X31_Day_Trailing_Unique_Auth_Users__c=3053);
    	insert bw;
        Test.startTest();
    	AccountCloudUsageMonthlyBatch ld = new AccountCloudUsageMonthlyBatch(new set<id>());
        database.executeBatch(ld);
   		System.schedule('AccountCloudUsageSch','0 0 13 * * ?', new AccountCloudUsageMonthlySch());
        Test.stopTest();
 	 }
}