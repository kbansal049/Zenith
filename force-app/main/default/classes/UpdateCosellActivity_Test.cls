@isTest
public class UpdateCosellActivity_Test {
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

        Contact con = new contact(lastname = 'abhi', email ='testemail123@tzscaler.com', accountid=acc.Id);
        insert con;

        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.partner__c = acc.Id;
        rec.partner_contact__c = con.Id;
        insert rec;
        
    }
    /**
     * Method to test the deal registration creation
     */
	@isTest static void testRegisterNewDeal() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Cosell_Activities__c cosell = [Select id, partner__c, partner_contact__c from Cosell_Activities__c where partner__r.name = 'Test Account' limit 1];
        //Create a new model
        UpdateCosellActivity.CosellPortalRequestModel model = new UpdateCosellActivity.CosellPortalRequestModel();
        model.csaId = cosell.Id;
        model.status = 'Accept';
        model.contactName = cosell.partner_contact__c;

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UpdateCosellActivity.updatecosell();
        Test.stopTest();

    }
	@isTest static void testRegisterNewDeal1() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Cosell_Activities__c cosell = [Select id, partner__c, partner_contact__c from Cosell_Activities__c where partner__r.name = 'Test Account' limit 1];
        //Create a new model
        UpdateCosellActivity.CosellPortalRequestModel model = new UpdateCosellActivity.CosellPortalRequestModel();
        model.csaId = cosell.Id;
        model.contactName = cosell.partner_contact__c;

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UpdateCosellActivity.updatecosell();
        Test.stopTest();

    }
}