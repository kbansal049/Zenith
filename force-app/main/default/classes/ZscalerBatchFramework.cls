public virtual class ZscalerBatchFramework {
    
    Public String batchName;
    Public String batchObjectName;
    
    public Integer noOfRecordsProcessed;
    
    public dateTime startTime;
    public dateTime actualExecutionTime;
    
    public ZscalerBatchFramework(String className){
        this.batchName = className;
        this.startTime = datetime.now();
        this.noOfRecordsProcessed = 0;
    }
    
    public void callStart(){
        this.actualExecutionTime = datetime.now();
    }
    public void callExecute(String objectName, Integer size){
        this.noOfRecordsProcessed = this.noOfRecordsProcessed + size;
        this.batchObjectName =  objectName;
    }
    public void callExecute(Id recordId, Integer size){
        this.noOfRecordsProcessed = this.noOfRecordsProcessed + size;
        this.batchObjectName =  recordId?.getSObjectType().getDescribe().getLabel();
    }
    public void callFinish(Database.BatchableContext bc){
        BatchJobMonitoringHelper.insertBatchJobMonitoring(batchObjectName,noOfRecordsProcessed,bc.getJobId(),startTime,actualExecutionTime);
    }
    
    
    public void callFinish(QueueableContext qc){
        BatchJobMonitoringHelper.insertBatchJobMonitoring(batchObjectName,qc.getJobId(),startTime,actualExecutionTime);
    }
}