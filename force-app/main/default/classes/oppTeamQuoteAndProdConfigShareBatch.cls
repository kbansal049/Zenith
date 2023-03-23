public class oppTeamQuoteAndProdConfigShareBatch implements Database.Batchable<SObject>,Database.Stateful {
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('oppTeamQuoteAndProdConfigShareBatch');
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callStart();
        String  shareStatus = 'Ready To Share';
        return Database.getQueryLocator('Select Id, Opportunity_Id__c, Status__c from Opportunity_Share__c Where Status__c =: shareStatus');
    }
    
    public void execute(Database.BatchableContext context, Opportunity_Share__c[] oppShareRecords) {
        this.zscalerBatchFrameWorkObj.callExecute(oppShareRecords[0]?.Id, oppShareRecords.size());
        quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(oppShareRecords);
    }
    
    public void finish(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callFinish(context);
        List<Opportunity_Share__c> openSharings = [Select Id from Opportunity_Share__c where Status__c = 'Ready To Share' LIMIT 1];
        if(!openSharings.isEmpty()){
            Database.executeBatch(new oppTeamQuoteAndProdConfigShareBatch(), 10);
        }
    }
}