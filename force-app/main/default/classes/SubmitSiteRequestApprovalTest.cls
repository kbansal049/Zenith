@isTest
private class SubmitSiteRequestApprovalTest {
    @isTest static void testSubmitForApproval() {
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true);
        insert EquiReq;
        EquiReq.Is_Site_Request_Approval_Sent__c=true;
        update EquiReq;

        Test.setCurrentPage(Page.SubmitSiteRequestApproval);
        ApexPages.currentPage().getParameters().put('Id', EquiReq.Id);
        SubmitSiteRequestApproval ctrlr = new SubmitSiteRequestApproval();
        ctrlr.submitForApproval();
        Test.stopTest();
    }
}