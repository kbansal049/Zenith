@isTest
public class CaseCreationFromWebFormsIntegrationTest {
    public static testMethod void test() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        req.requestURI = '/createCaseServiceSf/';
        req.httpMethod = 'POST';
        String str = '{\"Assignment_Group__c\": \"123456\",\"Created_By_First_Name__c\": \"test\", \"Created_Timestamp__c\": \"2022-06-16T08:03:19.000000+00:00\"}';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        CaseCreationFromWebFormsIntegration.createCaseService();
        test.stopTest();
    }
}