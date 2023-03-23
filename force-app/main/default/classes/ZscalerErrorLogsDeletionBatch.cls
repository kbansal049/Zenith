/**
 * @description       : This Apex batch used to delete the Zscaler_Error_Logs__c error log record meeting the given criteria.
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ZscalerErrorLogsDeletionBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ZscalerErrorLogsDeletionBatch');
	String query;
	public ZscalerErrorLogsDeletionBatch(String query){
        if(String.isNotBlank(query)){
            this.query = query;
        }else{
            //this.query = 'SELECT Id, Biz_Area__c, Error_In__c, Error_Type__c, Class_Name__c, Operation__c, Stack_Trace_String__c, LastModifiedDate, LastModifiedBy.Name, CreatedDate, CreatedBy.Name FROM Zscaler_Error_Logs__c WHERE Biz_Area__c IN (\'Service Cloud\') AND Error_In__c IN (\'Apex\', \'Async Apex\', \'Flow\') AND ((Error_Type__c = \'Information\' AND CreatedDate <= LAST_WEEK) OR (Error_Type__c = \'Error\' AND CreatedDate <= LAST_N_MONTHS : 3)) ORDER BY CreatedDate ASC';  
            this.query = 'SELECT Id FROM Zscaler_Error_Logs__c WHERE Biz_Area__c IN (\'Service Cloud\') AND Error_In__c IN (\'Apex\', \'Async Apex\', \'Flow\') AND ((Error_Type__c = \'Information\' AND CreatedDate <= LAST_WEEK) OR (Error_Type__c = \'Error\' AND CreatedDate <= LAST_N_MONTHS : 3)) ORDER BY CreatedDate ASC';  
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        this.query += (Test.isRunningTest() ? ' LIMIT 200' : '');
        return Database.getQueryLocator(this.query);
    }
    
    public void execute(Database.BatchableContext bc, List<Zscaler_Error_Logs__c> zscErrorLogLst){
        try{
            this.zb.callExecute(zscErrorLogLst[0]?.Id, zscErrorLogLst.size());
            if(!zscErrorLogLst.isEmpty()){
                List<Database.DeleteResult> deleteResultList = Database.delete(zscErrorLogLst);
                List<Database.EmptyRecycleBinResult> emptyRecycleBinResultList = Database.emptyRecycleBin(zscErrorLogLst);
            }
        }catch(Exception ex){
            System.debug('In ZscalerErrorLogsDeletionBatch.execute(), Exception val is: '+ex);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        System.debug('Successfully ran the ZscalerErrorLogsDeletionBatch ...!!');
    }
}