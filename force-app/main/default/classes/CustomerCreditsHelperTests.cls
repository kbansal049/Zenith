/*****************************************************************************************
Name: CustomerCreditsHelperTests
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for CustomerCreditsHelper Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       10/08/2022      IBA-1932      Customer credits should be created only when the opportunity is closed won for first time.
******************************************************************************************/
@isTest
private class CustomerCreditsHelperTests {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was Prepare the Test Data required for the CustomerCreditsHelperTests test class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareTestData .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    @testSetup 
    static void prepareTestData() {
        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'System Admin', ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR, ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS);
        insert testSystemAdminUser;
        
        User testCoreSalesUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'Core Sales User', ZScalarConstants.PROFILE_CORE_SALES, 
                                                                      ZScalarConstants.ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION);
        insert testCoreSalesUser;
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('OpportunityLineTriggerHandler');
        TriggerHandler.bypass('PSCredit_PSCreditTriggerHandler');
        
        System.runAs(testSystemAdminUser) {
            List<Product2> testProductServices = TestDataFactory_Product.prepareTestProducts('Test Product', ZScalarConstants.SERVICES_STRING, 1);
            insert testProductServices;
            
            // Insert PS Credit related product
            List<Product2> testProductPSCredit = TestDataFactory_Product.prepareTestProducts('Test Product credit', ZScalarConstants.CREDIT_STRING, 1);
            insert testProductPSCredit;
            
            // Insert Training Credit related Product.
            List<Product2> testProductTrainingCredit = TestDataFactory_Product.prepareTestProducts('Test Product training', ZScalarConstants.TRAINING_CREDIT_STRING, 1);
            insert testProductTrainingCredit;
            
            Id testPriceBookId = Test.getStandardPricebookId();
            List<PricebookEntry> standardPrice = TestDataFactory_PriceBook.prepareTestPricebookEntries(testPriceBookId, testProductServices[0].Id, 1000, true, 1);
            insert standardPrice;
            
            List<PricebookEntry> trainingCreditStandardPrice = TestDataFactory_PriceBook.prepareTestPricebookEntries(testPriceBookId, testProductTrainingCredit[0].Id, 1000, true, 1);
            insert trainingCreditStandardPrice;
            
            List<PricebookEntry> psCreditStandardPrice = TestDataFactory_PriceBook.prepareTestPricebookEntries(testPriceBookId, testProductPSCredit[0].Id, 1000, true, 1);
            insert psCreditStandardPrice;
            
            List<Opportunity> testOpportunity = TestDataFactory_Opportunity.prepareTestOpportunities('Test Opportunity', '6 - Closed Won', Date.today(), testPriceBookId, '', 1);
            insert testOpportunity;
            
            List<Licenses__c> testLicense = TestDataFactory_License.prepareTestLicenses('Test License', 'Quantity', 'ZCES-EDU-CREDIT', 1);
            insert testLicense;
            
            List<Product_License__c> testProductLicense = TestDataFactory_ProductLicense.prepareTestProductLicenses('Training', testProductServices[0].Id, testLicense[0].Id, 1);
            insert testProductLicense;
            
            List<OpportunityLineItem> oppLineItem = TestDataFactory_OpportunityProducts.prepareTestOpportunityProducts(testOpportunity[0].Id, testProductServices[0].Id, 1, standardPrice[0].Id, 1);
            insert oppLineItem;
            
            List<OpportunityLineItem> oppLineItemPSCredit = TestDataFactory_OpportunityProducts.prepareTestOpportunityProducts(testOpportunity[0].Id, testProductPSCredit[0].Id, 100, psCreditStandardPrice[0].Id, 1);
            insert oppLineItemPSCredit;
            
            List<OpportunityLineItem> oppLineItemTrainingCredit = TestDataFactory_OpportunityProducts.prepareTestOpportunityProducts(testOpportunity[0].Id, testProductTrainingCredit[0].Id, 1, trainingCreditStandardPrice[0].Id, 1);
            insert oppLineItemTrainingCredit;
            
            List<Professional_Services_Credits__c> psCredit = TestDataFactory_CustomerCredits.prepareTestPSCredits(testOpportunity, 'Test PS Credit', oppLineItemPSCredit, 1) ;
            insert psCredit;
            
        }
        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        TriggerHandler.clearBypass('OpportunityLineTriggerHandler');
        TriggerHandler.clearBypass('PSCredit_PSCreditTriggerHandler');
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Creation of Early Engagement Credits.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/     
    @isTest
    static void testCreateEECredits() {
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        Test.startTest();
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = true;
        CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        List<Professional_Services_Credits__c> professionalServicesCreditsList = [SELECT Id, Credits_Purchased__c, EE_Credit__c
                                                                                  FROM Professional_Services_Credits__c 
                                                                                  WHERE Opportunity__c =: testOpportunity.Id];
        Test.stopTest();
        System.assertEquals(professionalServicesCreditsList[0].Credits_Purchased__c, 100);
        System.assertEquals(professionalServicesCreditsList[0].EE_Credit__c, true);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Creation of all Customer Credits.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    @isTest
    static void testCreateCustomerCredits() {
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        Test.startTest();
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = false;
        CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        List<Professional_Services_Credits__c> professionalServicesCreditsList = [SELECT Id, Credits_Purchased__c, EE_Credit__c
                                                                                  FROM Professional_Services_Credits__c 
                                                                                  WHERE Opportunity__c =: testOpportunity.Id];
        Test.stopTest();
        System.assertEquals(professionalServicesCreditsList[0].Credits_Purchased__c, 100);
        System.assertEquals(professionalServicesCreditsList[0].EE_Credit__c, true);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Updation of EE credits once the Opportunity is Closed - Won.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @isTest
    static void testUpdateEECredits() {
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        OpportunityLineItem psCreditOppProduct =  [Select Id, Name, Quantity, Product2.Product_Category_Subtype__c
                                                   FROM OpportunityLineItem
                                                   WHERE Product2.Product_Category_Subtype__c =: ZScalarConstants.CREDIT_STRING
                                                   AND OpportunityId =: testOpportunity.Id];
        Test.startTest();
        psCreditOppProduct.Quantity = 120;
        Update psCreditOppProduct;
        testOpportunity.Customer_Credit_Type__c = ZScalarConstants.PS_CREDIT_RECORDTYPENAME;
        Update testOpportunity;
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = false;
        CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        Test.stopTest();
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Updation of EE credits once the Opportunity is Closed - Lost.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    static void testOpportunityClosedLost() {
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        Test.startTest();
        testOpportunity.StageName = '7 - Closed Lost';
        testOpportunity.Customer_Credit_Type__c = ZScalarConstants.PS_CREDIT_RECORDTYPENAME;
        Update testOpportunity;
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = false;
        CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        List<Professional_Services_Credits__c> professionalServicesCreditsList = [SELECT Id, Credits_Purchased__c, EE_Credit__c
                                                                                  FROM Professional_Services_Credits__c 
                                                                                  WHERE Opportunity__c =: testOpportunity.Id];
        Test.stopTest();
        System.assertEquals(professionalServicesCreditsList[0].Credits_Purchased__c, 0);
        System.assertEquals(professionalServicesCreditsList[0].EE_Credit__c, false);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Creation of Early Engagement Credits as Core Sales User.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    static void testCreateEECreditsAsCSM() {
        User testCoreSalesUser = [SELECT Id FROM User WHERE Name = 'Test Core Sales User' LIMIT 1];
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        Test.startTest();
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = true;
        System.runAs(testCoreSalesUser) {
            CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        }
        List<Professional_Services_Credits__c> professionalServicesCreditsList = [SELECT Id, Credits_Purchased__c, EE_Credit__c
                                                                                  FROM Professional_Services_Credits__c 
                                                                                  WHERE Opportunity__c =: testOpportunity.Id];
        Test.stopTest();
        System.assertEquals(professionalServicesCreditsList[0].EE_Credit__c, false);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to test the Creation of Customer Credits as Core Sales User.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : testCreateEECredits .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/     
    @isTest
    static void testCreateCustomerCreditsAsCSM() {
        User testCoreSalesUser = [SELECT Id FROM User WHERE Name = 'Test Core Sales User' LIMIT 1];
        Opportunity testOpportunity = [SELECT Id, Customer_Credit_Type__c 
                                       FROM Opportunity 
                                       WHERE StageName = '6 - Closed Won' LIMIT 1];
        Test.startTest();
        CustomerCreditsHelper.methodInputs firstInput = new CustomerCreditsHelper.methodInputs();
        firstInput.opportunityId = testOpportunity.Id;
        firstInput.eeCredit = false;
        System.runAs(testCoreSalesUser) {
            CustomerCreditsHelper.createCustomerCredits(new List<CustomerCreditsHelper.methodInputs>{firstInput});
        }
        List<Professional_Services_Credits__c> professionalServicesCreditsList = [SELECT Id, Credits_Purchased__c, EE_Credit__c
                                                                                  FROM Professional_Services_Credits__c 
                                                                                  WHERE Opportunity__c =: testOpportunity.Id];
        Test.stopTest();
        System.assertEquals(professionalServicesCreditsList[0].Credits_Purchased__c, 100);
        System.assertEquals(professionalServicesCreditsList[0].EE_Credit__c, true);
    }
}