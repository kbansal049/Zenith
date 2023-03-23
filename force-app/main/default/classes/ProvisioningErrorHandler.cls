public class ProvisioningErrorHandler {
    
    public static void exceptionHandler(string ClassName, String MethodName,Exception ex){
        Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
            Class_Name__c = ClassName,
            Method_Name__c = MethodName,
            Error_in__c = 'Apex',
            User__c  = UserInfo.getUserId(),
            Biz_Area__c  = 'Auto Provisioning',
            Exception_info__c = 'Exception occurred: ' + ex.getMessage() + ' ' + ex.getStackTraceString() +' line number ' + ex.getLineNumber()
          
        );
        insert logObj;
    }
      public static void databaseExceptionHandler(string ClassName, String MethodName,Database.Error err){
        Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
            Class_Name__c = ClassName,
            Method_Name__c = MethodName,
            Error_in__c = 'Apex',
            User__c  = UserInfo.getUserId(),
            Biz_Area__c  = 'Auto Provisioning',
           Exception_info__c = 'Exception occurred: ' + err.getMessage() + ' fields='+err.getFields()
        );
        insert logObj;
    }
}