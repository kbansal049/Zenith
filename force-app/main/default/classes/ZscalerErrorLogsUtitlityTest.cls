/**
 * Name : ZscalerErrorLogsUtitlityTest
 * Added by : Ankit Bhatnagar
 * Description : Test Class of ZscalerErrorLogsUtitlity
 */

@isTest
public class ZscalerErrorLogsUtitlityTest {

    @isTest
    public static void throwNullPtrErrorMethod() {
        try{
            String s;
            s.toLowerCase(); 
        }
        catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs('MockThrowErrorClass', 'throwNullPtrErrorMethod', 'Apex', UserInfo.getUserId(), 
                                                'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }

    @isTest
    public static void throwAsyncErrorMethod() {
        try{
            throw new IllegalArgumentException('Test');
        }
        catch(Exception e){
            ZscalerErrorLogsUtility.insertlogsForAsync('MockThrowErrorClass', 'throwAsyncErrorMethod', 'Async Apex', UserInfo.getUserId(), 
            'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());   
        }
    }
}