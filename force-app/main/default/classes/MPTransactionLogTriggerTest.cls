/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   11-24-2021   Mayank B.     Initial Version CR# 3606
*/
@IsTest(SeeAllData=false)
public class MPTransactionLogTriggerTest{

    @TestSetup static void setup() {

        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'System',
                          lastname='Admin',
                          Alias='sysAdmin',
                          email = 'test'+System.now().getTime()+'@zscaler.com',
                          username= 'test'+System.now().getTime()+'@zscaler.com',
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.TAM_Email__c = 'abc@abc.com';
        acc.BillingCity = 'Test city';
        acc.BillingCountry = 'Test country';
        acc.BillingStreet = 'Test street';
        insert acc;
        
        opportunity oppty= new opportunity();
        oppty.Name = 'Testopportunity';
        oppty.Primary_Quote_Exception__c  = true; 
        oppty.AccountId = acc.Id;
        oppty.StageName = '6 - Closed Won';
        oppty.CloseDate = system.Today()+30;
        oppty.Netsuite_Sales_Order_Number__c = 'TestOrder';
        oppty.Offer_Id__c = '12345';
        insert oppty;

    }

    @IsTest static void testTransactionLog(){

        Test.startTest();
        AWS_Transaction_Log__c tran = new AWS_Transaction_Log__c();
        tran.Offer_Id__c = '12345';
        tran.Transaction_JSON__c = '{"X90_Day_Renewal_Quote__c": "Estimate #R126846","Amount_USD__c": "41853.42"}';
        insert tran;

        Opportunity opp = [Select id, Offer_Id__c from Opportunity where Offer_Id__c = '12345' limit 1];
        AWS_Transaction_Log__c tr = [Select id, Opportunity__c from AWS_Transaction_Log__c where Offer_Id__c = '12345' limit 1];

        System.assertEquals(opp.id, tr.Opportunity__c, 'Correct Opportunity is not tagged to Marketplace Transaction Log');

        tran.Offer_Id__c = '123';
        update tran;
        
        tr = [Select id, Opportunity__c from AWS_Transaction_Log__c where Offer_Id__c = '123' limit 1];
        System.assertEquals(null, tr.Opportunity__c, 'Correct Opportunity is not tagged to Marketplace Transaction Log');

        Test.stopTest();
        


    }

}