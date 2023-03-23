/**
 * Name: TAMCAPRequestCmpCtrl
 * Description: Controller class for TamCAPRequestCmp LWC
 * Test Class: TAMCAPRequestCMPCtrlTest
 * Initial Author: Chetan Pednekar 
 */
public with sharing class TAMCAPRequestCmpCtrl {
    public TAMCAPRequestCmpCtrl() {}

    @AuraEnabled
    public static List<CAP_Request__c> getCAPRequestData(Id recordId) {
        System.debug('Record Id '+ recordId);
        if(String.isNotBlank(recordId)) {
            return new List<CAP_Request__c>([SELECT Id,Name,CAP_Level__c,CAP_Manager_Name__c,Status__c FROM CAP_Request__c where Status__c not in ('Closed') and Account__c = :recordId]);
        }
        else {
            return null;
        }
    }
}