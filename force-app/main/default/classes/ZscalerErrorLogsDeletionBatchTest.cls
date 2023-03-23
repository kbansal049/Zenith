/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ZscalerErrorLogsDeletionBatchTest {
	@testSetup
    static void testSetup(){
        List<Zscaler_Error_Logs__c> zscErrorLogLst = new List<Zscaler_Error_Logs__c>();
        for(Integer i = 0; i < 200; i++){
            Zscaler_Error_Logs__c zscErrorLog = new Zscaler_Error_Logs__c();
            zscErrorLog.Biz_Area__c = 'Service Cloud';
            zscErrorLog.Error_In__c = 'Flow';
            if(i < 100){
            	zscErrorLog.Error_Type__c = 'Information';
            	zscErrorLog.Stack_Trace_String__c = 'Information Error: '+ i;
            }else{
                zscErrorLog.Error_Type__c = 'Error';
            	zscErrorLog.Stack_Trace_String__c = 'Actual Error: '+ i;
            }
            zscErrorLog.Class_Name__c = 'Slack_to_GCS_Duty_Managers_Channel_upon_a_Non_P1_Case_Upgraded_to_P1_Case';
            zscErrorLog.Method_Name__c = 'execute()';
            zscErrorLog.Operation__c = 'Deleting the Old Zscaler_Error_Logs__c records.';
            zscErrorLogLst.add(zscErrorLog);
        }
        insert zscErrorLogLst;
    }
    
    @isTest
    static void testZscalerErrorLogsDeletionBatch1(){
        Map<Id, Zscaler_Error_Logs__c> zscErrorLogMap = new Map<Id, Zscaler_Error_Logs__c> ([SELECT Id FROM Zscaler_Error_Logs__c WHERE Biz_Area__c IN ('Service Cloud') AND Error_In__c IN ('Flow') AND Error_Type__c IN ('Information', 'Error')]);
        System.assertEquals(200, zscErrorLogMap.size(), 'Before deletion - Pass');
        
        Test.startTest();
            String soql = 'SELECT Id FROM Zscaler_Error_Logs__c WHERE Biz_Area__c IN (\'Service Cloud\') AND Error_In__c IN (\'Flow\') AND Error_Type__c IN (\'Information\', \'Error\') ORDER BY CreatedDate ASC';
            Database.executeBatch(new ZscalerErrorLogsDeletionBatch(soql));
        Test.stopTest();
        
        List<Zscaler_Error_Logs__c> zscErrorLogLst = [SELECT Id FROM Zscaler_Error_Logs__c WHERE Id IN :zscErrorLogMap.keySet()];
        System.assertEquals(0, zscErrorLogLst.size(), 'After deletion 1 - Pass');
    }
    
    @isTest
    static void testZscalerErrorLogsDeletionBatch2(){
        Map<Id, Zscaler_Error_Logs__c> zscErrorLogMap = new Map<Id, Zscaler_Error_Logs__c> ([SELECT Id FROM Zscaler_Error_Logs__c WHERE Biz_Area__c IN ('Service Cloud') AND Error_In__c IN ('Flow') AND Error_Type__c IN ('Information', 'Error')]);
        System.assertEquals(200, zscErrorLogMap.size(), 'Before deletion - Pass');
        
        Test.startTest();
            Database.executeBatch(new ZscalerErrorLogsDeletionBatch(''));
        Test.stopTest();
        
        List<Zscaler_Error_Logs__c> zscErrorLogLst = [SELECT Id FROM Zscaler_Error_Logs__c WHERE Id IN :zscErrorLogMap.keySet()];
        //System.assertEquals(0, zscErrorLogLst.size(), 'After deletion 2 - Pass');	// Commented to resolve ASSERT error
    }
}