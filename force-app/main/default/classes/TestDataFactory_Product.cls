/*****************************************************************************************
Name: TestDataFactory_Product
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Products.
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
public class TestDataFactory_Product {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test Product records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestProducts .
* @param    NAME : String name : Name .
* @param    NAME : String productCategorySubType : Product_Category_SubType__c of the Product .
* @param    NAME : Integer numberOfRecords        : Number of records to prepare .
* @return   TYPE : List<Product2> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<Product2> prepareTestProducts(String name, String productCategorySubType, Integer numberOfRecords) {
        
        List<Product2> testProductList = new List<Product2>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Product2 testProduct = new Product2();
            testProduct.Name = 'name' + count;
            testProduct.Product_Category_SubType__c = productCategorySubType;
            
            testProductList.add(testProduct);
        }
        
        return testProductList;
    }
    
}