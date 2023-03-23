/**
 * Name : ZscalerErrorLogsUtility
 * Created By : Ankit Bhatnagar
 * Description : Utility Class to log errors into Zscaler Error Log Object
 * */

public with sharing class ZscalerErrorLogsUtility {
    
    // This method is to be used to insert Logs when an Exception is caught in Sync Apex
    @future
    public static void insertLogs(  String className, String methodName, String errorIn, String UserId, 
                                    String BizArea, String stackTraceString, String info, String errorType){
        Zscaler_Error_Logs__c logs = new Zscaler_Error_Logs__c(
            Class_Name__c = className,
            Method_Name__c = methodName, 
            Error_in__c = errorIn, 
            User__c	= UserId,
            Biz_Area__c	= BizArea,
            Stack_Trace_String__c = stackTraceString,
            Exception_info__c = info,
            Error_Type__c = errorType
        );
        insert logs;
    }

    // This method is to be used to insert Logs when an Exception is caught in Async Apex
    public static void insertLogsForAsync(  String className, String methodName, String errorIn, String UserId, 
                                    String BizArea, String stackTraceString, String info, String errorType){
        Zscaler_Error_Logs__c logs = new Zscaler_Error_Logs__c(
            Class_Name__c = className,
            Method_Name__c = methodName, 
            Error_in__c = errorIn, 
            User__c	= UserId,
            Biz_Area__c	= BizArea,
            Stack_Trace_String__c = stackTraceString,
            Exception_info__c = info,
            Error_Type__c = errorType
        );
        insert logs;
    }
}