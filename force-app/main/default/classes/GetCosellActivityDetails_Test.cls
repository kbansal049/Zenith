@istest
public class GetCosellActivityDetails_Test {
    @testSetup
    static void testData(){
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;

        Contact con = new contact(lastname = 'abhi', email ='testemail123@tzscaler.com', accountid = acc.Id);
        insert con;

        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.partner__c = acc.Id;
        rec.partner_contact__c = con.Id;
        insert rec;
        
    }
    
    static testMethod void myUnitTest1() {
        Cosell_Activities__c cosell = [Select id, partner__c, partner_contact__c from Cosell_Activities__c where partner__r.name = 'Test Account' limit 1];
        
        RestRequest req = new RestRequest(); 
        
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/GetCosellActivityDetails'; 
        RestContext.request = req; 
        RestContext.request.params.put('partner_acc_id', cosell.partner__c);
        RestContext.request.params.put('partnercontactId', cosell.partner_contact__c);
        RestContext.request.params.put('partnerrole', 'Manager');
        RestContext.request.params.put('pagenumber', '1' );
        RestContext.request.params.put('limit', '10');
        
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        GetCosellActivityDetails.getCosellActivity();
        Test.stopTest();
    }
}