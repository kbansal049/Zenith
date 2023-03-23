/*****************************************************************************************
Name: QuipPSOnboardingDocumentEmailhelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for QuipPSOnboardingDocumentEmailhelper Apex Controller.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       16/09/2022      IBA-2128 - Email notification when Quip PS Onboarding Doc is generated.
******************************************************************************************/ 

@isTest
public class QuipPSOnboardingDocumentEmailhelperTest {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmailForStage4 .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void validatesendQuipOnboardingDocEmailForStage4() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        User standardUser = TestDatafactory_Zscaler.insertStandardUser('teststandarduser23@test.com','testlastname','testfirstname','test','teststandarduser23@test.com','GMT','en_US','UTF-8','en_US');
        
        User adminUser = TestDatafactory_Zscaler.insertAdminUser('testadminuser23@test.com','testlastname','testfirstname','test','testadminuser23@test.com','GMT','en_US','UTF-8','en_US');
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        account.CSM_Name_New__c = standardUser.Id;
        account.Solution_Architect__c = adminUser.Id;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, standardUser.Id, null, true);
        opptyList.add(opp);
        PS_Questionnaire__c psq = TestDatafactory_Zscaler.insertPSQuestionnaireforPSOnboarding(account.id,opp.id);
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmailForStage5 .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    static testMethod void validatesendQuipOnboardingDocEmailForStage5() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        User standardUser = TestDatafactory_Zscaler.insertStandardUser('teststandarduser230@test.com','testlastname','testfirstname','test','teststandarduser230@test.com','GMT','en_US','UTF-8','en_US');
        
        User adminUser = TestDatafactory_Zscaler.insertAdminUser('testadminuser230@test.com','testlastname','testfirstname','test','testadminuser230@test.com','GMT','en_US','UTF-8','en_US');
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        account.CSM_Name_New__c = standardUser.Id;
        account.Solution_Architect__c = adminUser.Id;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, '5 - Procurement', closeDate , null, null, null, null,null, null, null, null, standardUser.Id, null, true);
        opptyList.add(opp);
        PS_Questionnaire__c psq = TestDatafactory_Zscaler.insertPSQuestionnaireforPSOnboarding(account.id,opp.id);
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmail .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void validatesendQuipOnboardingDocEmail() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        opptyList.add(opp);
        
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmailException .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void validatesendQuipOnboardingDocEmailException() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        Update account;
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        opptyList.add(opp);
        
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmailForStage5A .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    static testMethod void validatesendQuipOnboardingDocEmailForStage5A() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        User standardUser = TestDatafactory_Zscaler.insertStandardUser('teststandarduser231@test.com','testlastname','testfirstname','test','teststandarduser231@test.com','GMT','en_US','UTF-8','en_US');
        
        User adminUser = TestDatafactory_Zscaler.insertAdminUser('testadminuser231@test.com','testlastname','testfirstname','test','testadminuser231@test.com','GMT','en_US','UTF-8','en_US');
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        account.CSM_Name_New__c = standardUser.Id;
        account.Solution_Architect__c = adminUser.Id;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, '5A - Submitted for Order Review', closeDate , null, null, null, null,null, null, null, null, standardUser.Id, null, true);
        opptyList.add(opp);
        
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : Test Class for QuipPSOnboardingDocumentEmailhelper Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : validatesendQuipOnboardingDocEmailForStage5B .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/      
    static testMethod void validatesendQuipOnboardingDocEmailForStage5B() {
        
        List<Opportunity> opptyList = New List<Opportunity>();
        
        User standardUser = TestDatafactory_Zscaler.insertStandardUser('teststandarduser232@test.com','testlastname','testfirstname','test','teststandarduser232@test.com','GMT','en_US','UTF-8','en_US');
        
        User adminUser = TestDatafactory_Zscaler.insertAdminUser('testadminuser232@test.com','testlastname','testfirstname','test','testadminuser232@test.com','GMT','en_US','UTF-8','en_US');
        
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.Total_Redeemed_credits__c = 0;
        account.CSM_Name_New__c = standardUser.Id;
        account.Solution_Architect__c = adminUser.Id;
        Update account;
        
        Contact contact = TestDatafactory_Zscaler.insertContact('Contact last Name', account.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, '5B - In Process with Finance', closeDate , null, null, null, null,null, null, null, null, standardUser.Id, null, true);
        opptyList.add(opp);
        
        Test.startTest();
        QuipPSOnboardingDocumentEmailhelper.sendQuipOnboardingDocEmail(opptyList);
        Test.stopTest();
        
    }
}