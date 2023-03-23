public with sharing class ServiceQualityAuditLWCCtrl {
    
    @AuraEnabled
    public static List<Survey__c> getSurveyRecords(String recordId) {
        return [SELECT id,Name,Audit_Engineer_Name__c,Audit_For_Engineer__r.Name,Engineer_s_Case_Work_Audit_Score__c FROM Survey__c WHERE Case__c =: recordId AND RecordType.DeveloperName = 'Service_Quality_Audit'];
    }

    @AuraEnabled
    public static List<Survey__c> getTAMAuditRecords(String recordId) {
        return [SELECT id,Name,Audit_Engineer_Name__c,Audit_For_Engineer__r.Name,TAM_Weekly_Audit_Score__c FROM Survey__c WHERE TAM_Meeting__c =: recordId AND RecordType.DeveloperName = 'TAM_Meeting_Audit'];
    }
}