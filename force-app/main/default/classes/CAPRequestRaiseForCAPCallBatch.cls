/**
 * Name : CAPRequestRaiseForCAPCallBatch
 * Description : Handler class for CAPRequestTrigger
 * Test Class : CAPReqRaiseForCAPCallBatchTest
 * Initial Author : Bhagyalaxmi Deshmukh
 * Scheduled to Run : On Every Tuesday @11:30 PM PST.ss
 */
public class CAPRequestRaiseForCAPCallBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String APEX_CLASS_NAME = 'CAPRequestRaiseForCAPCallBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CAPRequestRaiseForCAPCallBatch');

    Integer noOfRecordsProcessed = GCSCommonConstants.INTEGER_0;
    dateTime startTime = datetime.now();
    dateTime actualExecutionTime;
    List<String> errorRecordId = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        actualExecutionTime = datetime.now();
        return Database.getQueryLocator([SELECT Id, Raise_for_CAP_Call__c, Review_Requestor__c, 
                                            CAP_Call_Justification__c, Last_Current_Status_Update__c 
                                            FROM CAP_Request__c 
                                            WHERE Raise_for_CAP_Call__c = false]);
    }

    public void execute(Database.BatchableContext context, List<CAP_Request__c> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());
        noOfRecordsProcessed = noOfRecordsProcessed + scope.Size();        
        List<CAP_Request__c> capToUpdateList = new List<CAP_Request__c>();
        DateTime lastUpdate;
        Long millseconds;
        Long seconds;
        Integer min;
        Integer hour;

        try{
            String capReviewRequestorId = [SELECT Id, Name FROM User WHERE Name = :Label.CAP_Review_Requestor LIMIT 1].Id;
            
            for(CAP_Request__c cap : scope){
               lastUpdate = cap.Last_Current_Status_Update__c;     
                if(lastUpdate != null){
                    DateTime dTimeNow = System.now();
                    Date dateToday = date.newinstance(dTimeNow.year(), dTimeNow.month(), dTimeNow.day());
                    Date dateLastUpdate = date.newinstance(lastUpdate.year(), lastUpdate.month(), lastUpdate.day());
                    
                    //Check if 'Last 'field label' Update' is in past, if yes then continue with logic.
                    if(dateLastUpdate < dateToday 
                        && dateLastUpdate != dateToday){
                        seconds = dTimeNow.getTime() - lastUpdate.getTime();
                        millseconds = seconds/1000;
                        min = Integer.valueof(millseconds / 60);
                        hour = min / 60;
                        
                        //If 'Last 'field label' Update' field is more than 7 days then update CAP details.
                        if(168 < hour){
                            cap.Raise_for_CAP_Call__c = True;
                            cap.Review_Requestor__c = capReviewRequestorId;                            
                            cap.CAP_Call_Justification__c = Label.CAP_Raise_Call_Reason;
                            capToUpdateList.add(cap);                            
                        }
                    }                                                                                                    
                }                    
            }
            if(!capToUpdateList.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(capToUpdateList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }Catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }        
    }

    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
}