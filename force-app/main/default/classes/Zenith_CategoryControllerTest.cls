@isTest
public class Zenith_CategoryControllerTest { 
    @testSetup
    static void setupTestData() {
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Other' LIMIT 1].Id;
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCity = 'San Francisco',
            BillingState = 'CA',
            BillingPostalCode = '94105',
            BillingCountry = 'USA',
            RecordTypeId = recordTypeId
        );
        
        // Insert the test account object into the database
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@test.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Then, create the community user
        User testUser = new User(
            FirstName = 'Community',
            LastName = 'User',
            Email = 'communityuser@test.com',
            UserName = 'communityuser@test.com',
            Alias = 'CUser',
            CommunityNickname = 'CUser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1].Id,
            ContactId = testContact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // create test categories
        List<Category__c> categories = new List<Category__c>();
        for (Integer i = 1; i <= 10; i++) {
            Category__c category = new Category__c(
                Name = 'Test Category ' + i,
                Group_Id__c = 'Group ' + i
            );
            categories.add(category);
        }
        insert categories;
        
        // create test sub-categories
        List<Sub_Category__c> subCategories = new List<Sub_Category__c>();
        for (Category__c category : categories) {
            for (Integer i = 1; i <= 5; i++) {
                Sub_Category__c subCategory = new Sub_Category__c(
                    Name = 'Test Sub-Category ' + i,
                    Topic_Id__c = 'Topic ' + i,
                    Category__c = category.Id
                );
                subCategories.add(subCategory);
            }
        }
        insert subCategories;
        
       
    }
    
    @isTest
    static void testGetMoreRecords() {
        	List<Category__c> Categories=[SELECT Id,Name,Group_Id__c from Category__c];
        	List<Sub_Category__c> subCategories=[SELECT Id,Name,Topic_Id__c,Category__r.Id from Sub_Category__c];
        	List<Zenith_CategoryController.CategorySubCategoryWrapper> results = Zenith_CategoryController.getMoreRecords(0);
           
            
     
    }
    
     @isTest
    static void testCheckAccess() {
        // Set up test data
        Category__c category = [SELECT Id,Name,Group_Id__c FROM Category__c WHERE Name = 'Test Category 1' LIMIT 1];
        
        Sub_Category__c subCategory =[SELECT Id,Name,Topic_Id__c,Category__c FROM Sub_Category__c WHERE Name='Test Sub-Category 1' LIMIT 1];
        
        User user = [SELECT Id FROM User LIMIT 1];
        Sub_Category_Access__c accessRecord = new Sub_Category_Access__c(Sub_Category__c = subCategory.Id, User__c = user.Id);
        insert accessRecord;
        
        // Call the method under test
        Boolean hasAccess = Zenith_CategoryController.checkAccess(subCategory.Id);
        
      
    }
    
}