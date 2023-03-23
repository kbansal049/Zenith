/*****************************************************************************************
Name: TestDataFactory_PriceBook
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Price Book Entries.
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
public class TestDataFactory_PriceBook {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test Price Book Entry records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestPricebookEntries .
* @param    NAME : String pricebook2Id : Pricebook2Id .
* @param    NAME : String product2Id : Product2Id - Product lookup of the Test price book.
* @param    Name : Integer unitPrice : UnitPrice.
* @param    Name : Boolean isActive : IsActive.
* @param    NAME : Integer numberOfRecords        : Number of records to prepare .
* @return   TYPE : List<PricebookEntry> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<PricebookEntry> prepareTestPricebookEntries(String pricebook2Id, String product2Id, Integer unitPrice, Boolean isActive, Integer numberOfRecords) {
        
        List<PricebookEntry> testPriceBookEntriesList = new List<PricebookEntry>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            PricebookEntry testPriceBookEntry = new PricebookEntry();
            testPriceBookEntry.Pricebook2Id = pricebook2Id;
            testPriceBookEntry.Product2Id = product2Id;
            testPriceBookEntry.UnitPrice = unitPrice;
            testPriceBookEntry.IsActive = isActive;
            
            testPriceBookEntriesList.add(testPriceBookEntry);
        }
        
        return testPriceBookEntriesList;
    }
    
}