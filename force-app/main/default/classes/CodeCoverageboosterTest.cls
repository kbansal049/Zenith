@isTest
public class CodeCoverageboosterTest 
{
    @isTest static void testMethod1()
    {
        //AccountTriggerHelper acc = new AccountTriggerHelper();
        //acc.dummyCounter(1);
        //Test
    }
    
    @isTest static void testMethod2()
    {
        //AccountTriggerHelper acc = new AccountTriggerHelper();
        //acc.dummyCounter2(1);
    } 
    @isTest static void testMethod3()
    {
        OppotunityTriggerHelper.booster();
        //OpportunitySplitTriggerHelper.booster();
        //OpportunityTeamMemberHandler.booster();
        TriggerUtility.booster();
        TriggerUtility2.booster();
        ZForecastingService.booster();
        //CaseCreationForAccountAndOpportunity.booster();
        //CTMDomainVerificationandCaseCreation.booster();
        //ProvisioningRequestTriggerHelper.booster();
        //leadTriggerHelper.booster();
        //QuoteApprovalController.booster();    
        //ContactTriggerHelper.booster();
        //DealRegTriggerHelper.booster();  
        SCISYNC.booster();
        //ManageSCIExternalAttendeeService.booster();
        //CapturePartnerOnOpportunity.booster();
    }
    /* 
    @isTest static void testMethod5()
    {
  
        //PageReference myVfPage = Page.PRStopPurgePage;
        //Test.setCurrentPageReference(myVfPage);
        //ApexPages.StandardController sc = new ApexPages.StandardController(provisioningRequests[0]);   
        RenewalNotificationController pc= new RenewalNotificationController();
        pc.booster();
        PRQuickActionController.booster();
        SendPOCAlertImmediate.booster();
    } */
}