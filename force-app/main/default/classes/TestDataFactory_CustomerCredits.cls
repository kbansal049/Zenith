/*****************************************************************************************
Name: TestDataFactory_CustomerCredits
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Customer Credits.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       19/01/2023      IBA-5447      Create Customer Credit record when early Engagement request is approved.
2.0                Harish Gowda N       19/01/2023      IBA-5449      After opportunity is closed won, update customer credit and Account.
3.0                Harish Gowda N       19/01/2023      IBA-5450      After opportunity is closed lost, update customer credit and Account.
4.0                Digvijay Singh       24/01/2023      IBA-6010      Added prepareTestTrainingCredits method to prepare Test Training Credits.
******************************************************************************************/
@isTest
public class TestDataFactory_CustomerCredits {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test PS Credit records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestPSCredits .
* @param    NAME : Opportunity opportunityObj : Used to get and calculate Opportunity Id and Opportunity Close Date and Credits Expiration Date .
* @param    NAME : String name : PS_Credit_Name__c .
* @param    NAME : OpportunityLineItem oppProductObj : Used to get and calculate the Credits Purchased and PS SKU  .
* @param    NAME : Integer numberOfRecords : Number of records to prepare .
* @return   TYPE : List<Professional_Services_Credits__c> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<Professional_Services_Credits__c> prepareTestPSCredits(List<Opportunity> opportunityObj, String name, List<OpportunityLineItem> oppProductObj, Integer numberOfRecords) {
        
        List<Professional_Services_Credits__c> testPSCreditsList = new List<Professional_Services_Credits__c>();
        
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Professional_Services_Credits__c testPSCredit = new Professional_Services_Credits__c();
            testPSCredit.PS_Credit_Name__c = 'name' + count;
            testPSCredit.Account__c = opportunityObj[0].AccountId;
            testPSCredit.Opportunity__c = opportunityObj[0].Id;
            testPSCredit.Opportunity_Close_Date__c = opportunityObj[0].CloseDate;
            testPSCredit.Credits_Expiration_Date__c = opportunityObj[0].CloseDate + 364;
            testPSCredit.Credits_Purchased__c = oppProductObj[0].Quantity ;
            testPSCredit.EE_Credit__c = true;
            testPSCredit.RecordTypeId = ZScalarConstants.PS_CREDIT_RECORDTYPEID;
            testPSCredit.PS_Credit_SKU__c = oppProductObj[0].ProductCode ;
            testPSCreditsList.add(testPSCredit);
        }
        
        return testPSCreditsList;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6010 : to prepare test Training Credit records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestTrainingCredits .
    * @param    NAME : Opportunity opportunityRecord                 : Used to get and calculate Opportunity Id, Opportunity Close Date and Credits Expiration Date .
    * @param    NAME : OpportunityLineItem opportunityProductRecord  : Used to get and calculate the Credits Purchased and PS SKU  .
    * @param    NAME : Integer numberOfRecords                       : Number of records to prepare .
    * @return   TYPE : List<Professional_Services_Credits__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Professional_Services_Credits__c> prepareTestTrainingCredits(Opportunity opportunityRecord, OpportunityLineItem opportunityProductRecord, Integer numberOfRecords) {
        
        List<Professional_Services_Credits__c> testPSCreditsList = new List<Professional_Services_Credits__c>();
        
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Professional_Services_Credits__c testPSCredit = new Professional_Services_Credits__c();
            testPSCredit.PS_Credit_Name__c = 'Test Training Credit' + count;
            testPSCredit.Account__c = opportunityRecord.AccountId;
            testPSCredit.Opportunity__c = opportunityRecord.Id;
            testPSCredit.Opportunity_Close_Date__c = opportunityRecord.CloseDate;
            testPSCredit.Credits_Expiration_Date__c = opportunityRecord.CloseDate + 364;
            testPSCredit.Credits_Purchased__c = opportunityProductRecord.Quantity ;
            testPSCredit.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            testPSCredit.PS_Credit_SKU__c = opportunityProductRecord.ProductCode;
            testPSCreditsList.add(testPSCredit);
        }
        
        return testPSCreditsList;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6010 : to prepare test Training Credit records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestTrainingCreditsWithCreditsPurchased .
    * @param    NAME : Opportunity opportunityRecord                 : Used to get and calculate Opportunity Id, Opportunity Close Date and Credits Expiration Date .
    * @param    NAME : Integer creditsPurchased                      : Number of Credits Purchased .
    * @param    NAME : Integer creditsRedeemed                       : Number of Credits Redeemed .
    * @param    NAME : String productCode                            : Product Code/ Product SKU .
    * @param    NAME : Boolean syncToSkilljar                        : Boolean flag to indicate whether the Credit should be synced to Skilljar .
    * @param    NAME : Integer numberOfRecords                       : Number of records to prepare .
    * @return   TYPE : List<Professional_Services_Credits__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Professional_Services_Credits__c> prepareTestTrainingCreditsForFedAccounts(Opportunity opportunityRecord, Integer creditsPurchased, 
        Integer creditsRedeemed, String productCode, Boolean syncToSkilljar, Integer numberOfRecords) {
        
        List<Professional_Services_Credits__c> testPSCreditsList = new List<Professional_Services_Credits__c>();
        
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Professional_Services_Credits__c testPSCredit = new Professional_Services_Credits__c();
            testPSCredit.PS_Credit_Name__c = 'Test Training Credit' + count;
            testPSCredit.Account__c = opportunityRecord.AccountId;
            testPSCredit.Opportunity__c = opportunityRecord.Id;
            testPSCredit.Opportunity_Close_Date__c = opportunityRecord.CloseDate;
            testPSCredit.Credits_Expiration_Date__c = opportunityRecord.CloseDate + 364;
            testPSCredit.Credits_Purchased__c = creditsPurchased;
            testPSCredit.Credits_Redeemed__c = creditsRedeemed;
            testPSCredit.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            testPSCredit.PS_Credit_SKU__c = productCode;
            testPSCredit.Sync_To_Skilljar__c = syncToSkilljar;
            testPSCreditsList.add(testPSCredit);
        }
        
        return testPSCreditsList;
    }
}