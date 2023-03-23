public class AnnualBreakdownYWSUtilQueueable implements System.Queueable {
        
    public Set<Id> quoteIdSet {get;set;}
    
    public AnnualBreakdownYWSUtilQueueable(Set<Id> quoteIDs){
        quoteIdSet = new Set<Id>();
        quoteIdSet = quoteIDs;
        system.debug('Quote IDs >>>>>' + quoteIdSet);
    }
    
    public void execute(QueueableContext context){
        AnnualBreakdownYWSUtil.generateAnnualBreakdownYWS(quoteIdSet);
    }
}