/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ConvertFlowStringToCollection
* @description - This class works as Flow String to Collection converter
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-02-08
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ConvertFlowStringToCollection {
    @invocableMethod(label='Convert Comma-separated-values to String Collection')
    public static List<Response> execute (List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request curRequest : requests) {
            Response response = new Response();
            response.stringCollection = curRequest.csvString?.split(GCSCommonConstants.SEMI_COLON_STRING);
            responseList.add(response);
        }
        return responseList;
    }

    public class Request {
        @invocableVariable
        public String csvString;
    }

    public class Response {
        @invocableVariable
        public List<String> stringCollection;
    }
}