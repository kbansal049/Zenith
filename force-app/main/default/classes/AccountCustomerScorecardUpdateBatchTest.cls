@istest
public class AccountCustomerScorecardUpdateBatchTest {
    @testSetup static void setup() {
        Account acc =new Account(Name='acme acc');
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        insert acc;
        csc.Account__c =acc.id;
        insert csc;
    }  
    
    static testMethod void testmethod1(){
        Test.startTest();
        //AccountCustomerScorecardUpdateBatch obj = new AccountCustomerScorecardUpdateBatch();
        //Database.executeBatch(new AccountCustomerScorecardUpdateBatch(acclist), 1);
        Database.executeBatch(new AccountCustomerScorecardUpdateBatch('select Id,Customer_Scorecard__c,(select id,Name from Customer_Score_Card__r) from account') ,200);
        Test.stopTest();           
    }
}