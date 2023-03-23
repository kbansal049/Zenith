/*****************************************************************************************
Name: createNewMADRecordControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for createNewMADRecordController Apex Class
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        08/23/2022      IBA-2042    M&A is a big-bet use case for FY23 to significantly increment towards the $5B target - Test class
******************************************************************************************/ 
@isTest
public class createNewMADRecordControllerTest {
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2042: Test Class for createNewMADRecordController Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : fetchAccountRelatedToOppTest.
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void fetchAccountRelatedToOppTest() {
        Account eachAcc = new Account(Name = 'Test Account',TAM_Email__c = 'test@test.com',Type= 'Customer',Industry = 'Education',NumberOfEmployees = 5,Global_2000_Rank__c=150,Fortune_500__c=false,Market_Segment__c='Major');
        TriggerHandler.bypass('AccountTriggerHandler'); 
        insert eachAcc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = eachAcc.Id, StageName = Label.Stage_1_Alignment, CloseDate = system.Today()+30);
        TriggerHandler.bypass('OpportunityTriggerHandler'); 
        insert opp;
        M_A_D_Details__c newMadRecord = new M_A_D_Details__c(Name = 'TestMadRecord',Stage__c = 'Lead level 0: No Action/ Interaction started',Firm_Type__c='Private Equity Firm',Opportunity__c = opp.id,Transaction_Approach__c='Integration');
        newMadRecord.Sales_Effort__c = 'Sales Leading';
        newMadRecord.Source__c = 'MADS / ADV / GSI';
        newMadRecord.Firm_Type__c = 'Private Equity Firm';
        newMadRecord.Opportunity__c = opp.Id;
        newMadRecord.Transaction_Perspective__c = 'Investor';
        newMadRecord.Engaged_with_M_A_Partner__c = 'No';
        newMadRecord.Source__c = 'ZS - Other';
        newMadRecord.Sales_Effort__c = 'MADS leading';
        newMadRecord.Transaction_Approach__c = 'Integration';    
        insert newMadRecord;
        Test.startTest();
        createNewMADRecordController.fetchFieldCustomMetadata();
        createNewMADRecordController.fetchAccountRelatedToOpp(opp.Id);
        Test.stopTest();
        
    }
}