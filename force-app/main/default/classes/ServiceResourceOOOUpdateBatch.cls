/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ServiceResourceOOOUpdateBatch
* @description - This class updates OOO_Slack_Notification checkbox. It should run every hour.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Bhagyalaxmi Deshmukh
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-20
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ServiceResourceOOOUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    static final String APEX_CLASS_NAME = 'ServiceResourceOOOUpdateBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ServiceResourceOOOUpdateBatch');
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        DateTime twoHoursinFuture = System.now().addHours(2);
        DateTime threeHoursinFuture = System.now().addHours(3);      
        String whereClause = ' WHERE Start >=: TwoHoursInFuture AND Start <: ThreeHoursInFuture';  
        String query = label.ServiceResourceOOOUpdateBatchQuery + whereClause ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<ResourceAbsence> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());
        try{
            List<ServiceResource> resourceList = new List<ServiceResource>();
            if(!scope.isEmpty()) {
                for(ResourceAbsence absenceObj : scope){
                    resourceList.add(new ServiceResource(Id = absenceObj.ResourceId,
                                                        OOO_Slack_Notification__c = true,
                                                        Absence_Record_Id_for_DM_Notification__c = absenceObj.Id));
                }                                   
                if(!resourceList.isEmpty() && resourceList != null){
                    List<Database.SaveResult> updateResultList = Database.update(resourceList, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
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