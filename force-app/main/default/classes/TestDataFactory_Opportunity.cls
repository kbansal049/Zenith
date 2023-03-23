/*****************************************************************************************
Name: TestDataFactory_Opportunity
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Opportunities.
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
public class TestDataFactory_Opportunity {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of JIRA ID IBA-5447 : to prepare test Opportunity records.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @method   NAME : prepareTestOpportunities .
* @param    NAME : String name : Name .
* @param    NAME : String stageName : StageName - Stage of the opportunity.
* @param    Name : Date closeDate : CloseDate.
* @param    Name : String priceBookId : Pricebook2Id.
* @param    Name : String customerCreditType : Customer_Credit_Type__c.
* @param    NAME : Integer numberOfRecords        : Number of records to prepare .
* @return   TYPE : List<Opportunity> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static List<Opportunity> prepareTestOpportunities(String name, String stageName, Date closeDate, String priceBookId, String customerCreditType, Integer numberOfRecords) {
        List<Opportunity> testOpportunityList = new List<Opportunity>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = name + count;
            testOpportunity.StageName = stageName;
            testOpportunity.CloseDate = closeDate;
            testOpportunity.Pricebook2Id = priceBookId;
            testOpportunity.Customer_Credit_Type__c = customerCreditType;
            
            testOpportunityList.add(testOpportunity);
        }
        return testOpportunityList;
    }
    
}