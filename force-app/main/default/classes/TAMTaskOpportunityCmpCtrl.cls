/**
 * Name: TAMTaskOpportunityCmpCtrl
 * Description: Controller class for TAMTaskOpportunityCmp LWC
 * Test Class: TAMTaskOpportunityCmpCtrlTest
 * Initial Author: Hitesh Sachdeva
 * Story : IBA-2844
 */
public with sharing class TAMTaskOpportunityCmpCtrl {
    public TAMTaskOpportunityCmpCtrl() {}

    @AuraEnabled
    public static List<Task> getTaskRequestData(String whatId) {
        if(String.isNotBlank(WhatId)) {
            return new List<Task>([SELECT Subject,ActivityDate,Status,Description FROM Task where Subject LIKE 'PRJ#%' and WhatId =:whatId]);
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunityRequestData(String accountId) {
        if(String.isNotBlank(AccountId)) {
            return new List<Opportunity>([SELECT Opportunity_Number__c,Name,X3_Why__c,CreatedDate FROM Opportunity where X3_Why__c !=null and AccountId = :accountId]);
        }
        else {
            return null;
        }
    }
}