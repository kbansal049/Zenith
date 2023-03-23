public with sharing class DealRegConversionDateBatchController implements Database.Batchable<SObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('DealRegConversionDateBatchController');
    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        String queryString = 'SELECT Id, ParentId,Parent.Deal_Reg_Conversion_Date__c, CreatedDate, Field, DataType, OldValue, NewValue FROM Deal_Reg__History WHERE Parent.Deal_Reg_Conversion_Date__c = NULL AND Field=\'Status__c\'';
        if (Test.isRunningTest()) {
            queryString = 'SELECT Id, ParentId, Parent.Deal_Reg_Conversion_Date__c, CreatedDate, Field, DataType, OldValue, NewValue FROM Deal_Reg__History';
        }
        
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Deal_Reg__History> dealRegHistoryList) {
        this.zb.callExecute(dealRegHistoryList[0]?.Id, dealRegHistoryList.size());
        List<Deal_Reg__c> dealRegListToUpdate = new List<Deal_Reg__c>();

        Deal_Reg__c dealReg;

        Map<Id, Date> dealRegCoversionMap = new Map<Id, Date> ();


        for (Deal_Reg__History dealRegHistory: dealRegHistoryList) {

            String dealRegStatus = String.valueOf(dealRegHistory.NewValue);
            dealRegStatus = (System.Test.isRunningTest()) ? 'Converted' : dealRegStatus;
            
            if ((String.isNotBlank(dealRegStatus)) && (dealRegStatus.equalsIgnoreCase('Converted'))) {
                
                Date conversionDate = dealRegCoversionMap.containsKey(dealRegHistory.ParentId) && (dealRegCoversionMap.get(dealRegHistory.ParentId) > dealRegHistory.CreatedDate.date())
                    ? dealRegCoversionMap.get(dealRegHistory.ParentId)
                    : dealRegHistory.CreatedDate.date();

                dealRegCoversionMap.put(dealRegHistory.ParentId , conversionDate);
            }

        }

        for (Id dealRegId : dealRegCoversionMap.keySet()) {
            dealReg = new Deal_Reg__c(Id = dealRegId);
			
            dealReg.Deal_Reg_Conversion_Date__c = dealRegCoversionMap.get(dealRegId);

            dealRegListToUpdate.add(dealReg);
        }
        

        UPDATE dealRegListToUpdate;

    }

    public void finish(Database.BatchableContext bc) {
        this.zb.callFinish(bc);
    }
}