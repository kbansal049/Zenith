@isTest
public class CreateoktaUserCalloutMock  implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        String responseBody = null;
        
        //Get User List
        if(request.getEndpoint().contains('api/v1/users?limit=1&q=')){
            responseBody = '[{"id":"00ub0oNGTSWTBKOLGLNR","status":"ACTIVE","created":"2013-06-24T16:39:18.000Z","activated":"2013-06-24T16:39:19.000Z","statusChanged":"2013-06-24T16:39:19.000Z","lastLogin":"2013-06-24T17:39:19.000Z","lastUpdated":"2013-07-02T21:36:25.344Z","passwordChanged":"2013-07-02T21:36:25.344Z","profile":{"firstName":"Eric","lastName":"Judy","email":"eric.judy@example.com","secondEmail":"eric@example.org","login":"eric.judy@example.com","mobilePhone":"555-415-2011"},"credentials":{"password":[],"recovery_question":{"question":"The stars are projectors?"},"provider":{"type":"OKTA","name":"OKTA"}}}]';
        }
        //create User
        else if(request.getEndpoint().contains('api/v1/users?activate=true')){
        	responseBody = '{"id":"00ub0oNGTSWTBKOLGLNR","status":"STAGED","created":"2013-07-02T21:36:25.344Z","activated":null,"statusChanged":null,"lastLogin":null,"lastUpdated":"2013-07-02T21:36:25.344Z","passwordChanged":null}';
        }
        
        //Update User
        else{
            responseBody =  '{"id":"00ub0oNGTSWTBKOLGLNR","status":"STAGED","created":"2013-07-02T21:36:25.344Z","activated":null,"statusChanged":null,"lastLogin":null,"lastUpdated":"2013-07-02T21:36:25.344Z","passwordChanged":null}';    
        }
        if(responseBody != null){
            response.setBody(responseBody);
        }
        response.setStatusCode(200);
        return response; 
    }
    
}