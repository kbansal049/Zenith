/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ConvertStringCollectionToCSV
* @description - This class works as String Collection To CSV converter
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-02-22
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ConvertStringCollectionToCSV {
    @invocableMethod(label='Convert String Collection to Comma-separated-values' )
    public static List<Response> execute (List<Request> requests){
        List<Response> responseList = new List<Response>();
        for (Request curRequest : requests) {
            Response response = new Response();
            List<String> stringCollection = curRequest.stringCollection;
            response.csvString = String.join(stringCollection, GCSCommonConstants.SEMI_COLON_STRING);
            responseList.add(response);
        }
        return responseList;
    }

    public class Request {
        @invocableVariable
        public List<String> stringCollection;
    }

    public class Response {
        @invocableVariable
        public String csvString;
    }
}