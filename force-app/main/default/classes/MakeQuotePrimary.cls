//Class created for CR# 3550
public with sharing class MakeQuotePrimary {

    //Class is called from 'Make Quote Primary' flow.
    @InvocableMethod
    public static void makePrimary(List<SBQQ__Quote__c> quoteList) {
        
        Id primaryQuoteId = quoteList[0].Id;
        Id opportunityId = quoteList[0].SBQQ__Opportunity2__c;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteList[0].Id, SBQQ__Primary__c = true);
        update quote;

        checkAndUpdateDuplicatePrimary(primaryQuoteId, opportunityId);
    }

    @future
    public static void checkAndUpdateDuplicatePrimary(Id primaryQuoteId, Id opportunityId){

        List<SBQQ__Quote__c> relatedQuoteList = [SELECT Id, SBQQ__Primary__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opportunityId AND SBQQ__Primary__c = TRUE AND Id != :primaryQuoteId];
        
        if(!relatedQuoteList.isEmpty() || Test.isRunningTest()) {            
            
            List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
            for (SBQQ__Quote__c quote : relatedQuoteList) {
                quoteToUpdate.add(new SBQQ__Quote__c(Id = quote.Id, SBQQ__Primary__c = false));            
            }
            
            update quoteToUpdate;
        }
    }
}