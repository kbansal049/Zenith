/*
 * Possible Values
 * iWeekDay - 	[0 - Every weekday] [ 1 - on Monday, 2 - on Tuesday to 7 - on Sunday]
 * iMonth - 	[0 - Every Month] 	[ {1-12} - on Nth Month]
 * iDay - 		[0 - Every Day] 	[ {1-31} - on Nth Day]
 * iHour - 		[0 - Every Hour]	[ {1-24} - on Nth Hour]
 * iMinute -	[0 - Every Minute]  [ {1-31} - on Nth Minute]
 */
@RestResource(urlMapping='/GenericApexScheduler/*')
global with sharing class GenericApexScheduler {
    
    private static Integer DEFAULT_BATCHSCOPE = 200;
    private static Integer DEFAULT_BATCHPRIORITY = 99;
    
    
    global class ApiRequest {
        global Integer iMinute; 
        global Integer iHour;
        global Integer iDay;
        global Integer iMonth;
        global Integer iWeekDay;
    }
    
    @HttpPost
    global static void scheduleApex() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Step1. Parse the Response            
        String reqBody = req.requestBody != null ? req.requestBody.toString() : null;
        System.debug('GenericApexScheduler--scheduleApex--reqBody--' + reqBody);
        if(reqBody == null)
            throw new IllegalArgumentException('Please ensure request body is correct');
        
        ApiRequest rq = (ApiRequest) System.JSON.deserialize(reqBody, ApiRequest.class);
        System.debug('GenericApexScheduler--scheduleApex--rq--' + rq);
        
        //Step2. Validate the Request
        if (rq.iMinute == null || (rq.iMinute < 0 || rq.iMinute > 59)) {
            throw new IllegalArgumentException('The iMinute parameter should have a value between 0 to 59');
        }
        
        if (rq.iHour == null || (rq.iHour < 0 || rq.iHour > 24)) {
            throw new IllegalArgumentException('The iHour parameter should have a value between 0 to 24');
        }
        
        if (rq.iDay == null || (rq.iDay < 0 || rq.iDay > 31)) {
            throw new IllegalArgumentException('The iDay parameter should have a value between 0 to 31');
        }
        
        if (rq.iMonth == null || (rq.iMonth < 0 || rq.iMonth > 12)) {
            throw new IllegalArgumentException('The iMonth parameter should have a value between 0 to 12');
        }
        
        if (rq.iWeekDay == null || (rq.iWeekDay < 0 || rq.iWeekDay > 7)) {
            throw new IllegalArgumentException('The iWeekDay parameter should have a value between 0 to 7');
        }
        
        Boolean isError = false;
        List<ApiResponse> apiResponseList = new List<ApiResponse>();
        List<Zscaler_Error_Logs__c> errorLogList = new List<Zscaler_Error_Logs__c>();
        List<Zscaler_Error_Logs__c> exceptionLogList = new List<Zscaler_Error_Logs__c>();
        
        
        List<Apex_Scheduler__c> apexSchedulerList = retriveSchedulesBasedOnInputs(rq);
        
        
        for (Apex_Scheduler__c apexScheduler : apexSchedulerList) {
            
            try {  
                
                System.debug('--GenericApexScheduler--apexScheduler--'+apexScheduler);
                
                //Currently we are not checking for currently running jobs we'll schedule the jobs as per Workato request
                Type classType = Type.forName(apexScheduler.Apex_Class_Name__c);
                
                //Run Batchable
                if (classType != null && (Database.Batchable<SObject>.class).isAssignableFrom(classType)) {
                    Database.Batchable<SObject> classInstance = (Database.Batchable<SObject>) classType.newInstance();
                    
                    Integer batchSize = apexScheduler.Batch_Size__c != null ? Integer.valueOf(apexScheduler.Batch_Size__c) : DEFAULT_BATCHSCOPE;
                    Integer batchPriority = apexScheduler.Priority__c != null ? Integer.valueOf(apexScheduler.Priority__c) : DEFAULT_BATCHPRIORITY;
                    
                    //Database.executeBatch(classInstance, batchSize);
                    Id jobId = AsyncApexFramework.submitBatch(classInstance,batchSize,batchPriority,apexScheduler.Allow_Retry__c);
                    AsyncApexFramework.flush();
                    
                }
                //Run Queueable
                else if (classType != null && (Queueable.class).isAssignableFrom(classType)) {
                    Queueable queueableClassInstance = (Queueable) classType.newInstance();
                    
                    Integer priority = apexScheduler.Priority__c != null ? Integer.valueOf(apexScheduler.Priority__c) : DEFAULT_BATCHPRIORITY;
                    
                    //System.enqueueJob(classInstance);
                    Id jobId = AsyncApexFramework.submitQueueable(queueableClassInstance,priority,apexScheduler.Allow_Retry__c);
                    AsyncApexFramework.flush();
                }
                else {
                    isError = true;
                    ApiResponse errorResponse = new ApiResponse();
                    errorResponse.className = apexScheduler.Name;
                    errorResponse.message = 'Error : Could not execute the batch job. Unknown or invalid class';
                    apiResponseList.add(errorResponse);
                    logApexError(errorLogList, apexScheduler);
                }
                
            } 
            catch(Exception e) {
                system.debug('--GenericApexScheduler--Exception-Message'+e.getMessage());
                system.debug('--GenericApexScheduler--Exception-LineNumber'+e.getLineNumber());
                system.debug('--GenericApexScheduler--Exception-LineNumber'+e.getStackTraceString());
                logException(exceptionLogList,e);
            }
        }
        
        if (isError) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serializePretty(apiResponseList));
            Database.insert(errorLogList, false);
        } else {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Success : Request for the Batch class(es) has successfully been invoked.');
        }
        
        //Log Exception
        if(!exceptionLogList.isEmpty())
            Database.insert(exceptionLogList, false);
        
        //Create Integration Log records
        createIntegrationLog(req, res);
    }
    
    @TestVisible
    private Static List<Apex_Scheduler__c> retriveSchedulesBasedOnInputs(ApiRequest rq)
    {        
        System.debug('--retriveSchedulesBasedOnInputs called--');   
        System.debug('--ApiRequest--'+rq);
        
        Set<Integer> months = setTheValidValues(rq.iMonth);
        Set<Integer> days = setTheValidValues(rq.iDay);
        Set<Integer> hours = setTheValidValues(rq.iHour);
        //For safety purpose we will not add trigger every minutues scenario
        Set<Integer> minutes = new Set<Integer>();
        minutes.add(rq.iMinute);
        Set<Integer> weekdays = setTheValidValues(rq.iWeekDay);
        
        System.debug('--months--'+months);
        System.debug('--days--'+months);
        System.debug('--hours--'+hours);
        System.debug('--minutes--'+minutes);
        System.debug('--weekdays--'+weekdays);
        
        List<Apex_Scheduler__c> apexSchedulerList = [SELECT Id,Name, Apex_Class_Name__c,
                                                     hour__c,minute__c,day__c,month__c,weekday__c,
                                                     Batch_Size__c,Priority__c,Allow_Retry__c,
                                                     is_Active__c FROM Apex_Scheduler__c
                                                     WHERE 
                                                     month__c in : months and
                                                     day__c in : days and
                                                     hour__c in : hours and
                                                     minute__c in : minutes and
                                                     weekday__c in : weekdays and
                                                     is_Active__c = true ];
        return apexSchedulerList;
    }
    
    @testVisible
    private Static Set<Integer> setTheValidValues(integer num){
        Set<Integer> validnumbs = new Set<Integer>();
        validnumbs.add(num);
        validnumbs.add(0); //0 is used to portarit * like Every Month, Every Hour, Every Day
        return validnumbs;
    }
    
    
    @TestVisible
    private static void createIntegrationLog(RestRequest req, RestResponse res) {
        Integration_Log__c log = new Integration_Log__c(
            Invoked_from__c = 'GenericApexScheduler',
            Type_Of_Operation__c = 'POST',
            Endpoint__c = 'services/Apex/GenericApexScheduler',
            Request__c = req.requestBody.tostring(),
            Response__c = res.responseBody.toString(),
            Response_Code__c = res.statusCode,
            Object_Name__c = 'Apex_Scheduler__c',
            Type__c = 'Log'
        );
        try {
            insert log;
        } catch (Exception ex) {
            System.debug('GenericApexScheduler--createIntegrationLog--' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    @TestVisible
    private static void logException(List<Zscaler_Error_Logs__c> errorLogList, Exception ex) {
        Zscaler_Error_Logs__c zsErrorRecord = new Zscaler_Error_Logs__c();
        zsErrorRecord.Class_Name__c = 'GenericApexScheduler';
        zsErrorRecord.Exception_info__c = ex.getMessage() + '\r\nLine: ' + ex.getLineNumber() + '\r\n\r\n' + ex.getStackTraceString();
        zsErrorRecord.Method_Name__c = 'GenericApexScheduler.scheduleApex';
        zsErrorRecord.Multiple_records_info__c = '';
        zsErrorRecord.Operation__c = 'Error occured in GenericApexScheduler Rest Service';
        zsErrorRecord.Record_Info__c = '';
        zsErrorRecord.User__c = String.valueOf(UserInfo.getUserId());
        errorLogList.add(zsErrorRecord);
    }
    
    @TestVisible
    private static void logApexError(List<Zscaler_Error_Logs__c> errorLogList, Apex_Scheduler__c apexScheduler){
        // Logging error
        Zscaler_Error_Logs__c zsErrorRecord = new Zscaler_Error_Logs__c();
        zsErrorRecord.Class_Name__c = 'GenericApexScheduler';
        zsErrorRecord.Exception_info__c = 'Could not execute the batch class ' + apexScheduler.Name + ', because either the class does not exist or does not implement the Database.Batchable<SObject> Interface';
        zsErrorRecord.Method_Name__c = 'GenericApexScheduler.scheduleApex';
        zsErrorRecord.Multiple_records_info__c = '';
        zsErrorRecord.Operation__c = 'Error occured in GenericApexScheduler Rest Service';
        zsErrorRecord.Record_Info__c = '';
        zsErrorRecord.User__c = String.valueOf(UserInfo.getUserId());
        errorLogList.add(zsErrorRecord);
    }

    global class ApiResponse {
        String className;
        String message;
    }

    global class ApiException extends Exception {}
}