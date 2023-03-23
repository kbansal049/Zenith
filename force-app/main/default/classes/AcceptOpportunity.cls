public class AcceptOpportunity {
    @AuraEnabled  
    public static void acceptOpp(String recId) {
        List<Provisioning_Request__c> provUpdateList = new List<Provisioning_Request__c>();
        Id prRecordType = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByDeveloperName().get('Zscaler_cloud_in_Production').getRecordTypeId();
        //TriggerUtility.SkipAccTriggerExecuted();
        TriggerHandler.bypass('AccountTriggerHandler');
        Opportunity opp = [SELECT Id, StageName, SBQQ__Contracted__c FROM Opportunity WHERE Id =: recId];
        if(opp.StageName != '6 - Closed Won'){
            opp.StageName = '6 - Closed Won';    
        }
        opp.SBQQ__Contracted__c = TRUE;
        update opp;
        for(Provisioning_Request__c PR : [SELECT Id, Provisioning_Status__c FROM Provisioning_Request__c WHERE Opportunity__c =: recId]){
            PR.Provisioning_Status__c = 'Production';
            PR.RecordTypeId = prRecordType;
            provUpdateList.add(PR);    
        }
        if(!provUpdateList.isEmpty() && provUpdateList != NULL){
            update provUpdateList;    
        }
    }
}