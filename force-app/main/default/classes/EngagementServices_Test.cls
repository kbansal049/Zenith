@istest
public class EngagementServices_Test {
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
        
        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.partner__c = acc.Id;
        insert rec;
        
        feeditem fi = new feeditem();
        fi.body = 'test feed';
        fi.parentId = rec.Id;
        fi.visibility = 'AllUsers';
        insert fi;
        
    }
    
    static testMethod void myUnitTest1() {
        Account acc = [Select Id from account limit 1];
        Cosell_Activities__c cosell = [Select id from Cosell_Activities__c where partner__r.name = 'Test Account' limit 1];
        
        RestRequest req = new RestRequest(); 
        
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/EngagementServices'; 
        RestContext.request = req; 
        RestContext.request.params.put('rootId', cosell.id);
        RestContext.request.params.put('limit', '5');
        RestContext.request.params.put('partner_acc_id',acc.id );
        RestContext.request.params.put('contactName', 'Abhhishek V');
        
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        EngagementServices.getEngagements();
        Test.stopTest();
    }
    @isTest static void testRegisterNewDeal() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = [Select Id from account limit 1];
        Cosell_Activities__c cosell = [Select id from Cosell_Activities__c where partner__r.name = 'Test Account' limit 1];
        
        
        //Create a new model
        EngagementServices.EngagementPostRequest model = new EngagementServices.EngagementPostRequest();
        model.rootId = cosell.id;
        model.feedbody = 'Customer';
        model.partner_acc_id = acc.Id;
        model.contactName = 'dfjfjj fjddfj';
        
        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        EngagementServices.createEngagement();
        Test.stopTest();
        
    }
    
    @isTest
    static void testEngagementServices(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = [Select Id from account limit 1];
        
        Contact con = new contact();
        con.LastName = 'Test';
        insert con;
        
        //Create a new model
        EngagementServices.EngagementPostRequest model = new EngagementServices.EngagementPostRequest();
        model.rootId = con.id;
        model.feedbody = 'Customer';
        model.partner_acc_id = acc.Id;
        model.contactName = 'dfjfjj fjddfj';
        
        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        EngagementServices.createEngagement();
        Test.stopTest();
        
    }
}