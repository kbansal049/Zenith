public with sharing class QuoteExtController {
    public Id quoteId{get;set;}
    public Boolean isCustomScheduleNotAvailable{get;set;}
    public Boolean customScheduleLessThanTCV{get;set;}
    public Boolean isPreview{get;set;}
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        isPreview = false;
    }
    public PageReference onSubmit() {
        if (quoteId != null) {
            Boolean isError = validateBillingSchedule(quoteId);
            if(isError){
                return null;
            }else{
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                return new PageReference('/' + quoteId);
            }
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference onPreview() {
        if (quoteId != null) {
            Boolean isError = validateBillingSchedule(quoteId);
            if(isError){
                return null;
            }else{
                isPreview = true;
                return null;
            }
        }
        return null;
    }
    public Boolean validateBillingSchedule(Id quoteId){
        SBQQ__Quote__c quote = [Select Id, TCV__c,SBQQ__BillingFrequency__c from SBQQ__Quote__c where Id = :quoteId];
        Boolean showError = false;
        if(quote.SBQQ__BillingFrequency__c == 'Custom Schedule'){                     
            AggregateResult[] groupedBilledSchedule = [Select Quote__c, sum(Amount__c) TotalAmount from Billing_Schedule__c where Quote__c=: quoteId group by Quote__c];          
            Decimal diffAmount;
            if(!groupedBilledSchedule.isEmpty()){
                diffAmount = (Decimal)groupedBilledSchedule[0].get('TotalAmount') - quote.TCV__c;
            }
            system.debug('differ '+diffAmount);
            if(groupedBilledSchedule.isEmpty())
            {
                isCustomScheduleNotAvailable = true;
                showError = true;
            }
            else if(!(groupedBilledSchedule.isEmpty()) && (diffAmount > 0.99 || diffAmount < -0.99))
            {
                customScheduleLessThanTCV = true;
                showError = true;
            }
        }
        return showError ;
        
    }
    public Pagereference onCancel(){
        return new PageReference('/' + quoteId);
    }
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
}