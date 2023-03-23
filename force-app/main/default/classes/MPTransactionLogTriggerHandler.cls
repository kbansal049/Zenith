/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   11-23-2021   Mayank B.     Initial Version CR# 3605
*/

public class MPTransactionLogTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
       
        System.debug('Mayank, call came to AWSTransactionLogTriggerHandler');
       
        Map<String, AWS_Transaction_Log__c> offerIdToAWSRecordMap = new Map<String, AWS_Transaction_Log__c>();
       
        for(AWS_Transaction_Log__c awsTransactionLog : (List<AWS_Transaction_Log__c>) Trigger.new) {
            if(awsTransactionLog.Offer_Id__c != null){
                offerIdToAWSRecordMap.put(awsTransactionLog.Offer_Id__c, awsTransactionLog);
            }
        }
        if(!offerIdToAWSRecordMap.isEmpty()){
            MPTransactionLogTriggerClass.updateOpportunityBasedOnOfferID(offerIdToAWSRecordMap);
        }
    }

    public override void beforeUpdate() {
        System.debug('Mayank, call came to AWSTransactionLogTriggerHandler');
        //trigger.newMap, trigger.oldMap

        Map<String, AWS_Transaction_Log__c> offerIdToAWSRecordMap = new Map<String, AWS_Transaction_Log__c>();
       
        for(AWS_Transaction_Log__c awsTransactionLog : (List<AWS_Transaction_Log__c>) Trigger.new) {
            
            AWS_Transaction_Log__c newRecord = (AWS_Transaction_Log__c) Trigger.newMap.get(awsTransactionLog.id);
            AWS_Transaction_Log__c oldRecord = (AWS_Transaction_Log__c) Trigger.oldMap.get(awsTransactionLog.id);

            if(awsTransactionLog.Offer_Id__c != null && (newRecord.Offer_Id__c != oldRecord.Offer_Id__c) ){
                offerIdToAWSRecordMap.put(awsTransactionLog.Offer_Id__c, awsTransactionLog);
            }
        }
        if(!offerIdToAWSRecordMap.isEmpty()){
            MPTransactionLogTriggerClass.updateOpportunityBasedOnOfferID(offerIdToAWSRecordMap);
        }
    }
}