/*****************************************************************************************
Name: TestDataFactory_ProductLicense
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Product Licenses.
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
public class TestDataFactory_ProductLicense {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test Product License records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestProductLicenses .
* @param    NAME : String provisioningLicense : Provisioning_License__c .
* @param    NAME : String productId : Product__c .
* @param    NAME : String licenseId : License__c .
* @param    NAME : Integer numberOfRecords        : Number of records to prepare .
* @return   TYPE : List<Product_License__c> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<Product_License__c> prepareTestProductLicenses(String provisioningLicense, String productId, String licenseId, Integer numberOfRecords) {
        
        List<Product_License__c> testProductLicenseList = new List<Product_License__c>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Product_License__c testProductLicense = new Product_License__c();
            testProductLicense.Provisioning_License__c = provisioningLicense;
            testProductLicense.Product__c = productId;
            testProductLicense.License__c = licenseId;
            
            testProductLicenseList.add(testProductLicense);
        }
        
        return testProductLicenseList;
    }
    
}