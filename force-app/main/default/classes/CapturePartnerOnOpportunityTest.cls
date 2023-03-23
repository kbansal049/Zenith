//Added by Raviraj for CR840
@isTest
public class CapturePartnerOnOpportunityTest {

    @isTest
    static void testData(){
        Set<Id> oppIdSet = new Set<Id>();
        
        Account acc= TestDataFactory_Zscaler.insertAccount('Test Account', null, null, null, null, null);
        Account acc1= TestDataFactory_Zscaler.insertAccount('Test Account1', null, null, null, null, null);
        Contact con = TestDataFactory_Zscaler.insertContact('Test', acc.Id, acc1.Id);
        Opportunity opp = new Opportunity(AccountId=acc.Id, contactId=con.Id, Name='Test Opportunity', Amount=5000, CloseDate= System.today(),ForecastCategoryName='Best Case', StageName='2 - Qualified & Budgeted',
                                          Proposed_Number_of_Users__c=5,Type='New Business', Product_Type__c='Web', Expected_Term_Months__c=5, LeadSource='Sales Generated', Partner_Account_Name__c=acc1.Id);
        insert opp;
        oppIdSet.add(opp.Id);
        
        OpportunityContactRole oppConRole = new OpportunityContactRole(ContactId=con.Id, OpportunityId=opp.Id,IsPrimary=true);
        insert oppConRole;
        
        CapturePartnerOnOpportunity c = new CapturePartnerOnOpportunity();
        test.startTest();
        	Partner p = CapturePartnerOnOpportunity.createOppPartner(opp);
        	CapturePartnerOnOpportunity.updateOpportunityPartner(oppIdSet);
        test.stopTest();
        system.assert(p.OpportunityId == opp.Id);        
    }
}