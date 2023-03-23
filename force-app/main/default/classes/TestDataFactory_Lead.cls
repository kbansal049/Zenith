/*****************************************************************************************
Name: TestDataFactory_Lead
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Data Factory Class For Creating Test Leads.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Digvijay Singh       10/02/2023      IBA-6527      Created class and added method to prepare test leads
******************************************************************************************/
@isTest
public with sharing class TestDataFactory_Lead {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to prepare test Lead records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestLeads .
    * @param    NAME : String leadStatus            : Lead Status .
    * @param    NAME : String noOfEmployeed         : Employee Range like 0-99.
    * @param    Name : String email                 : Lead Email.
    * @param    Name : String leadSource            : Lead Source.
    * @param    NAME : Integer numberOfRecords      : Number of records to prepare.
    * @return   TYPE : List<Lead>                   : List of prepared lead records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Lead> prepareTestLeads(String leadStatus, String noOfEmployees, String email, String leadSource, Integer noOfRecords) {
        List<Lead> testLeadsList = new List<Lead>();
        for (Integer count = 1; count <= noOfRecords; count++) {
            Lead testLead = new Lead();
            testLead.FirstName = 'Test';
            testLead.LastName = 'Lead ' + count;
            testLead.Email = email;
            testLead.Status = leadStatus;
            testLead.Phone = '9876543210';
            testLead.Company = 'Test Company';
            testLead.No_Employees_Users__c = noOfEmployees;
            testLead.LeadSource = leadSource;

            testLeadsList.add(testLead);
        }
        return testLeadsList;
    }
}