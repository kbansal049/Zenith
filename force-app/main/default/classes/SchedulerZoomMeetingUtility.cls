/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* SchedulerZoomMeetingUtility
* @description - This class works as Zoom API invoker
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-31
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class SchedulerZoomMeetingUtility {
    static final String APEX_CLASS_NAME = 'SchedulerZoomMeetingUtility';
    
    @InvocableMethod(label='Get Zoom Meeting URL For Meeting' description='API callout for getting the meeting URL')
    public static List<String> getZoomMeetingUrl(List<String> inputParameters){
        final String METHOD_NAME = 'getZoomMeetingUrl';
        String zoomUrl = GCSCommonConstants.EMPTY_STRING;
        try{
            if(!inputParameters.isEmpty()){
                List<String> inputParametersForZoomAPI = new List<String>();
                inputParametersForZoomAPI = inputParameters[0].split(',');

                String startTimeOfMeeting = inputParametersForZoomAPI[3].replace(' ', 'T');
                String path = '/users/' + inputParametersForZoomAPI[0] + '/meetings';

                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Scheduler_Zoom_Integration' + path);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', '*/*');
                req.setHeader('Accept-Encoding', 'gzip, deflate, br');

                //String reqBody = '{"topic":"' + 'Test Subject from Flow' + '","duration":"'+'60' + '", "type":"2"}';
                String reqBody = '{"topic":"' + inputParametersForZoomAPI[1] + '", "duration":"' + inputParametersForZoomAPI[2] + '", "type":"2", "start_time":"' + startTimeOfMeeting + '"}';
                req.setBody(reqBody);
                System.debug('111 ===>> req val is: '+req);

                HTTPResponse res = new Http().send(req);
                System.debug('222(A) ===>> res val is: '+res);
                JSONParser parser = JSON.createParser(res.getBody());
                while(parser.nextToken() != null){
                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'join_url'){
                        parser.nextToken();
                        zoomUrl = parser.getText();
                        break;
                    }
                }
                System.debug('333 ===>> zoomUrl val is: '+zoomUrl);
            }
        }catch(Exception ex){
            zoomUrl = 'Error';
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
        return new List<String>{zoomUrl};
    }
}