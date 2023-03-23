@isTest
private class ZDXTenantDetailsServiceTest {

    @testSetup static void setup(){
        Account Acc = new Account(Name = 'Test', TAM_Name_New__c = UserInfo.getUserId());
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        Insert Acc;
        AccountTeamMember atm = new AccountTeamMember(AccountId = Acc.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Technical Account Manager');
        insert atm;
        
        Zscaler_Cloud_ID__c ZscalerCloudId = new Zscaler_Cloud_ID__c();
        ZscalerCloudId.Name = 'ZDX-Test';
        ZscalerCloudId.Account__c = Acc.Id;
        ZscalerCloudId.Zscaler_Cloud_Domain__c = 'Test';
        Insert ZscalerCloudId;
    }
    
    private static testMethod void test() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        req.requestURI = '/getZDXTenantDetails/';
        req.httpMethod = 'GET';
        req.requestBody = null;
        
        RestContext.request = new RestRequest();
        RestContext.request.params.put('tenantId', 'ZDX-Test');
        
        ZDXTenantDetailsService.getTenantDetails();
        test.stopTest();
    }
}