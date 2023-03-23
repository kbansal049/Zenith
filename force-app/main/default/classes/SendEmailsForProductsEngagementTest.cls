@isTest
public class SendEmailsForProductsEngagementTest {
    @TestSetup
    private static void createTestData(){
        
        List<User> userList = TestDataFactory_User.createUsers(1,false,'Core Sales',
                                                                  'ZS','CoreSales User',
                                                                  'zscoresalesuser@test.com');
        insert userList;
        
        List<Account> accountList = TestDataFactory_Account.createAccounts(1,false);
        
        System.runAs(userList[0])
        {
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountList;
            TriggerHandler.clearBypass('AccountTriggerHandler');
            TestDataFactory_Contact.insertContact(1,True,accountList[0].Id);
        }
        Id testPriceBookId = Test.getStandardPricebookId();
        List<Product2> testProductServices = TestDataFactory_Product.prepareTestProducts('Test Product', ZScalarConstants.SERVICES_STRING, 1);
        insert testProductServices;
        
        List<Opportunity> testOpportunity = TestDataFactory_Opportunity.prepareTestOpportunities('Test Opportunity', '6 - Closed Won', Date.today(), testPriceBookId, '', 1);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        testOpportunity[0].AccountId = accountList[0].Id;
        insert testOpportunity;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');           
		
        List<Product_Engagement__c> ProductEngagementList = TestDataFactory_ProductEngagement.createProductEngagement(1,false,testOpportunity[0].Id);
        Insert ProductEngagementList;
    }
    
    @isTest
    static void test_sendEmailsToProductTeam(){
         List<Product_Engagement__c> engagementRecordList = [SELECT Id,CreatedBy.Email,Engagement_Type__c,Product__c,opportunity__r.Account.Name,
                                                            opportunity__r.Owner.Name,opportunity__r.Opportunity_Sales_Engineer__r.Name,opportunity__r.Geo_Account__c
                                                            FROM Product_Engagement__c LIMIT 1];
        List<Id> recordIds = new List<Id>();
        For(Product_Engagement__c pe : engagementRecordList){
            recordIds.add(pe.Id);
        }
        SendEmailsForProductsEngagement.sendEmailsToProductTeam(recordIds);
    }
}