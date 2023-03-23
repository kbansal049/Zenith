/*****************************************************************************************
Name: TestDataFactory_SalesTerritory
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Purpose:
--------
1. Test Data Factory Class For Creating Test Sales Territory Records.
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Digvijay Singh       10/02/2023      IBA-6527      Added method to create Sales Terriotry records.
******************************************************************************************/

@isTest
public class TestDataFactory_SalesTerritory {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to prepare test Sales Territory records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestSalesTerritoryRecords .
    * @param    NAME : String geo                   : Geo of Sales Territory .
    * @param    NAME : Integer numberOfRecords      : Number of records to prepare .
    * @return   TYPE : List<PatchTeam__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<PatchTeam__c> prepareTestSalesTerritoryRecords(String geo, Integer numberOfRecords) {
        List<PatchTeam__c> testSalesTerritoriesList = new List<PatchTeam__c>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            PatchTeam__c testSalesTerritory = new PatchTeam__c();
            testSalesTerritory.Name = 'Test Sales Territory ' + count;
            testSalesTerritory.Theater__c = geo;

            testSalesTerritoriesList.add(testSalesTerritory);
        }
        return testSalesTerritoriesList;
    }

}