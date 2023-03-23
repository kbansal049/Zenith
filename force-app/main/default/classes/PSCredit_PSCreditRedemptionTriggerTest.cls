@isTest
public class PSCredit_PSCreditRedemptionTriggerTest {
 
    @isTest
    public static void testUpdatePSCreditRedemptionName(){
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        
        PS_Offering__c offering = new PS_Offering__c();
        offering.Credits__c = 54;
        offering.Offering_Details__c = 'Tunnels for up to 20 Sites and pair of VSE';
        offering.Name = 'TestPsOffering';
        offering.Suggested_Max__c = 4;
        insert offering;
        
        PS_Credit_Redemption__c creditRedemption = New PS_Credit_Redemption__c();
        creditRedemption.Account__c = acc.Id;
        creditRedemption.PS_Offering__c = offering.Id;
        creditRedemption.Units_Redeemed__c = 50;        
        
        Test.startTest();
        insert creditRedemption;
        Test.stopTest();
        
        PS_Credit_Redemption__c updatedCreditRedemption = [SELECT Id,PS_Credit_Redemption_Name__c from PS_Credit_Redemption__c LIMIT 1 ];
        system.assertEquals('Test Account-TestPsOffering-RF1', updatedCreditRedemption.PS_Credit_Redemption_Name__c);
    }
}