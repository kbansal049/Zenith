/************************************************************************************************************************************
 * Name: generateYWSforRenewals 
 * Description: Generate Year wise splits for Renewals
************************************************************************************************************************************/ 
global class generateYWSforRenewals implements Database.Batchable<SObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('generateYWSforRenewals');

    private List<String> listContractIds = new List<String>();
    
    global generateYWSforRenewals (List<String> listContracts){
        this.listContractIds= listContracts;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        return Database.getQueryLocator(
            //The conditions for the records for which renewals are to be created
            'SELECT id,SBQQ__Opportunity2__r.SBQQ__RenewedContract__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.SBQQ__RenewedContract__c IN: listContractIds  '
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        //SB_YearWiseSplitUtil.generateYearWiseSplitForProposals(scope); 
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c quote : scope) {
            quoteIds.add(quote.Id);
        }
        AnnualBreakdownYWSUtil.generateAnnualBreakdownYWS(quoteIds); 
    }
  
    global void finish(Database.BatchableContext bc){
       this.zb.callFinish(bc);
    }
    
}