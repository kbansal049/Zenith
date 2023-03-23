/*****************************************************************************************
Name: TestDataFactory_OpportunityProducts
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Opportunity Products.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       19/01/2023      IBA-5447      Create Customer Credit record when early Engagement request is approved.
2.0                Harish Gowda N       19/01/2023      IBA-5449      After opportunity is closed won, update customer credit and Account.
3.0                Harish Gowda N       19/01/2023      IBA-5450      After opportunity is closed lost, update customer credit and Account.
******************************************************************************************/
@isTest
public class TestDataFactory_OpportunityProducts {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test Opportunity Product records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestOpportunityProducts .
* @param    NAME : String opportunityId : OpportunityId .
* @param    NAME : String productId : Product2Id .
* @param    NAME : Integer quantity : Quantity .
* @param    Name : String pricebookEntryId : PricebookEntryId .
* @param    NAME : Integer numberOfRecords : Number of records to prepare .
* @return   TYPE : List<OpportunityLineItem> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<OpportunityLineItem> prepareTestOpportunityProducts(String opportunityId, String productId, Integer quantity,String pricebookEntryId, Integer numberOfRecords) {
        
        List<OpportunityLineItem> testOpportunityProductsList = new List<OpportunityLineItem>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem();
            testOpportunityProduct.OpportunityId = opportunityId;
            testOpportunityProduct.Product2Id = productId;
            testOpportunityProduct.Quantity = quantity;
            testOpportunityProduct.PricebookEntryId = pricebookEntryId;
            
            testOpportunityProductsList.add(testOpportunityProduct);
        }
        
        return testOpportunityProductsList;
    }
    
}