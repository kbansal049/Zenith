@isTest
public class CreateDealRegistration_Test {
    
    /**
     * Method to test the deal registration creation
     */
    @isTest static void testRegisterNewDeal() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        //Create a new model
        DealRegistrationModel model = new DealRegistrationModel();
        model.customerCompanyName = 'TestCust1';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact1';
        model.customerContactEmail = 'customercontact1@testcust1.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner1'; 
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner1@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('10');
        model.dealDescription = 'Test deal1';
        model.estimatedAmount = Decimal.valueOf('100000.5');
        model.expectedCloseDate = Date.today();

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateDealRegistration.registerNewDeal();
        Test.stopTest();

        String response = res.responseBody.toString();
        CreateDealRegistration.DealRegistrationResponseModel responseModel = (CreateDealRegistration.DealRegistrationResponseModel)JSON.deserialize(response, CreateDealRegistration.DealRegistrationResponseModel.class);
    }
    /**
     * Method to test the deal registration creation
     */
    @isTest static void testRegisterNewDeal_fulldetails() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
        List<Account> acclst = [Select Id from Account limit 1];
        list<Contact> contact = [Select Id from Contact limit 1];
        //Create a new model
        CreateDealRegistration.DealRegistrationPortalModel model = new CreateDealRegistration.DealRegistrationPortalModel();
        model.customerCompanyName = 'TestCust1';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact1';
        model.customerContactEmail = 'customercontact1@testcust1.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner1';
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner1@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('10');
        model.dealDescription = 'Test deal1';
        model.estimatedAmount = Decimal.valueOf('100000.5');
        model.expectedCloseDate = Date.today();
        if(!acclst.isEmpty()){
            model.partnerAccountId = acclst[0].Id;
        }
        if(!contact.isEmpty()){
            model.partnerContactId = contact[0].Id;
        }

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateDealRegistration.registerNewDeal();
        Test.stopTest();

        String response = res.responseBody.toString();
        CreateDealRegistration.DealRegistrationResponseModel responseModel = (CreateDealRegistration.DealRegistrationResponseModel)JSON.deserialize(response, CreateDealRegistration.DealRegistrationResponseModel.class);
    }
}