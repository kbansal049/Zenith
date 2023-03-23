/*****************************************************************************************
Name: BatchJobMonitoringHelper
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Purpose:
--------
1. Apex Helper to create batch job monitoring records.
------------------------------------------------------------------------------------------
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Akash Thakur         30/06/22        CR#5023
2.0				   Viral       
******************************************************************************************/ 
public class BatchJobMonitoringHelper {
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of CR#5023 : to create job monitoring record this method called from differ batch classes
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : insertBatchJobMonitoring .
    * @param    NAME : String className, Integer noOfRecordsProcessed, String jobID, dateTime startTime
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */ 
    public static void insertBatchJobMonitoring( String className, Integer noOfRecordsProcessed, String jobID, dateTime startTime)
    {
        Batch_Job_Monitoring__c batchJobMonitoringRec = new Batch_Job_Monitoring__c();
        batchJobMonitoringRec.JobId__c = jobID;
        batchJobMonitoringRec.Start_Time__c =startTime;
        batchJobMonitoringRec.End_Time__c = datetime.now();
        batchJobMonitoringRec.Apex_Class_Name__c = className;
        batchJobMonitoringRec.No_Of_Records_Processed__c = noOfRecordsProcessed;
        
        try{
            insert batchJobMonitoringRec;
        }catch(Exception e){ 
            ZscalerErrorLogsUtility.insertlogsForAsync('BatchJobMonitoringHelper', 'insertBatchJobMonitoring', 'Async Apex',userInfo.getUserId(), 'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    public static void insertBatchJobMonitoring( String className, Integer noOfRecordsProcessed, String jobID, dateTime startTime , String batchObjectName , dateTime actualExecutionTime)
    {
        Batch_Job_Monitoring__c batchJobMonitoringRec = new Batch_Job_Monitoring__c();
        batchJobMonitoringRec.JobId__c = jobID;
        batchJobMonitoringRec.Start_Time__c =startTime;
        batchJobMonitoringRec.End_Time__c = datetime.now();
        batchJobMonitoringRec.Apex_Class_Name__c = className;
        batchJobMonitoringRec.No_Of_Records_Processed__c = noOfRecordsProcessed;
        batchJobMonitoringRec.Batch_on_Object__c = batchObjectName;
        batchJobMonitoringRec.Actual_Execution_Time__c = actualExecutionTime;
        
        
        try{
            insert batchJobMonitoringRec;
        }catch(Exception e){ 
            ZscalerErrorLogsUtility.insertlogsForAsync('BatchJobMonitoringHelper', 'insertBatchJobMonitoring', 'Async Apex',userInfo.getUserId(), 'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    
    
    
    public static void insertBatchJobMonitoring(String batchObjectName, Integer noOfRecordsProcessed, Id jobId,
                                                dateTime startTime, 
                                                dateTime actualExecutionTime)
    {
        try{
            
            //View the total Records processed.
            System.debug('--insertBatchJobMonitoring--called---');
            AsyncApexJob job = [SELECT Id,
                                CronTriggerId,CompletedDate,
                                ApexClassId,ApexClass.Name,MethodName,
                                JobType,ExtendedStatus,
                                JobItemsProcessed,
                                TotalJobItems, NumberOfErrors,
                                Status,CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :jobId];
            
            Batch_Job_Monitoring__c batchJobMonitoringRec = new Batch_Job_Monitoring__c();
            batchJobMonitoringRec.Apex_Class_Name__c = job.ApexClass.Name;
            batchJobMonitoringRec.ApexClassId__c = job.ApexClassId;
            batchJobMonitoringRec.JobType__c = job.JobType;
            batchJobMonitoringRec.CronTriggerId__c = job.CronTriggerId;
            batchJobMonitoringRec.ExtendedStatus__c = job.ExtendedStatus;
            
            batchJobMonitoringRec.TotalJobItems__c = job.TotalJobItems;
            batchJobMonitoringRec.JobItemsProcessed__c = job.JobItemsProcessed;
            batchJobMonitoringRec.NumberOfErrors__c = job.NumberOfErrors;
                
            batchJobMonitoringRec.Batch_on_Object__c = batchObjectName;
            batchJobMonitoringRec.JobId__c = jobId;
            batchJobMonitoringRec.Start_Time__c = startTime;
            batchJobMonitoringRec.End_Time__c = job.CompletedDate;
            
            batchJobMonitoringRec.No_Of_Records_Processed__c = noOfRecordsProcessed;
            batchJobMonitoringRec.Actual_Execution_Time__c = actualExecutionTime;
            insert batchJobMonitoringRec;
        }
        catch(Exception e){ 
            System.debug('--exception--ex--'+e.getMessage());
            System.debug('--exception--ex--'+e.getLineNumber());
            ZscalerErrorLogsUtility.insertlogsForAsync('BatchJobMonitoringHelper', 'insertBatchJobMonitoring',
                                                       'Async Apex',userInfo.getUserId(), 'DevOps',
                                                       e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    public static void insertBatchJobMonitoring(String batchObjectName, Id jobId,
                                                dateTime startTime, 
                                                dateTime actualExecutionTime)
    {
        try{
            
            //View the total Records processed.
            System.debug('--insertBatchJobMonitoring--queueable--called---');
            AsyncApexJob job = [SELECT Id,
                                CronTriggerId,CompletedDate,
                                ApexClassId,ApexClass.Name,MethodName,
                                JobType,ExtendedStatus,
                                JobItemsProcessed,
                                TotalJobItems, NumberOfErrors,
                                Status,CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :jobId];
            
            Batch_Job_Monitoring__c batchJobMonitoringRec = new Batch_Job_Monitoring__c();
            batchJobMonitoringRec.Apex_Class_Name__c = job.ApexClass.Name;
            batchJobMonitoringRec.ApexClassId__c = job.ApexClassId;
            batchJobMonitoringRec.JobType__c = job.JobType;
            batchJobMonitoringRec.CronTriggerId__c = job.CronTriggerId;
            batchJobMonitoringRec.ExtendedStatus__c = job.ExtendedStatus;
            
            batchJobMonitoringRec.TotalJobItems__c = job.TotalJobItems;
            batchJobMonitoringRec.JobItemsProcessed__c = job.JobItemsProcessed;
            batchJobMonitoringRec.NumberOfErrors__c = job.NumberOfErrors;
                
            batchJobMonitoringRec.Batch_on_Object__c = batchObjectName;
            batchJobMonitoringRec.JobId__c = jobId;
            batchJobMonitoringRec.Start_Time__c = startTime;
            batchJobMonitoringRec.End_Time__c = job.CompletedDate;
            
            batchJobMonitoringRec.Actual_Execution_Time__c = actualExecutionTime;
            insert batchJobMonitoringRec;
        }
        catch(Exception e){ 
            ZscalerErrorLogsUtility.insertlogsForAsync('BatchJobMonitoringHelper', 'insertBatchJobMonitoring',
                                                       'Async Apex',userInfo.getUserId(), 'DevOps',
                                                       e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
}