@isTest
public class PSCredit_PSCreditTriggerTest {
 
    @isTest
    public static void testUpdateTotalPurchasedCreditsOnAccount(){
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        
        Professional_Services_Credits__c ps =new Professional_Services_Credits__c();
        ps.Credits_Purchased__c = 1000;
        ps.PS_Credit_Name__c = 'testpsCredit';
        ps.Account__c = acc.Id;
        ps.Opportunity_Close_Date__c = Date.today() + 20;
        ps.Credits_Redeemed__c = 500;
        ps.Credits_Expiration_Date__c = Date.today() + 2;
        
        Test.startTest();
        insert ps;
        Test.stopTest();
        
    }
    
}