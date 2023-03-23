@isTest
public class SchedulerZoomMeetingUtilityTest {
    @isTest
    static void testGetZoomMeetingUrl(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<String> inputParameters1 = new List<String>();
        List<String> inputParameters2 = new List<String>();
        inputParameters1.add('adhole@zscaler.com,Test Subject,60,2024-03-01 12:02:00Z');
        inputParameters2.add('adhole@zscaler.com,60,2024-03-01 12:02:00Z');
        Test.startTest();
            SchedulerZoomMeetingUtility.getZoomMeetingUrl(inputParameters1);
            SchedulerZoomMeetingUtility.getZoomMeetingUrl(inputParameters2);
        Test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[{"join_url" : 21026, "name" : "testCustomer", "entityId" : "123", "type" : "customer"},'
                                + ' {"id": 4883, "name": "testCustomer1", "entityId" : "123", "type" : "customer"}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}