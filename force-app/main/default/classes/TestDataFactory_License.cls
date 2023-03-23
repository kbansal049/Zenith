/*****************************************************************************************
Name: TestDataFactory_License
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Licenses.
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
public class TestDataFactory_License {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test License records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestLicenses .
* @param    NAME : String name : Name .
* @param    NAME : String licenseBasedOn : License_Based_On__c .
* @param    NAME : String licenseCode : License_Code__c .
* @param    NAME : Integer numberOfRecords        : Number of records to prepare .
* @return   TYPE : List<Licenses__c> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<Licenses__c> prepareTestLicenses(String name, String licenseBasedOn, String licenseCode, Integer numberOfRecords) {
        
        List<Licenses__c> testLicenseList = new List<Licenses__c>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Licenses__c testLicense = new Licenses__c();
            testLicense.Name = 'name' + count;
            testLicense.License_Based_On__c = licenseBasedOn;
            testLicense.License_Code__c = licenseCode;
            
            testLicenseList.add(testLicense);
        }
        
        return testLicenseList;
    }
    
}