/*****************************************************************************************
Name: PSCredit_UpdateCreditsOnAccountBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1.Apex Batch  for Professional_Services_Credits__c to update Total Purchased Credits
and Total Credits Redeeemed 
On Account if Credit Expiration Date is of yesterday.

Will runs once a day every midnight.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        27/05/2022      CR#4742      PS Credits Updation.
2.0                Karthik Pullagurla   10/17/2022      IBA-3842     Training Credits Rollup
******************************************************************************************/ 
global class PSCredit_UpdateCreditsOnAccountBatch implements Database.Batchable<sObject>,Schedulable, Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('PSCredit_UpdateCreditsOnAccountBatch');
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        Date yesterdayDate = Date.today().addDays(-1);  
        String query = 'SELECT Id, Name, Is_Redemption_Valid__c, Credits_Expiration_Date__c, Credits_Purchased__c, Credits_Redeemed__c, Credits_Remaining__c, Account__r.Total_Available_credits__c, Account__r.Total_Purchased_credits__c,Account__r.Total_Redeemed_credits__c FROM Professional_Services_Credits__c WHERE Credits_Expiration_Date__c =: yesterdayDate  ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Professional_Services_Credits__c> psCredits){
        try {
            this.zb.callExecute(psCredits[0]?.Id, psCredits.size());
            this.updateCreditsOnAccount(psCredits);    
        }catch(Exception ex) {
            ZscalerErrorLogsUtility.insertLogsForAsync('PSCredit_UpdateCreditsOnAccountBatch', 'updateCreditsOnAccount',
                                                       'Apex', UserInfo.getUserId(),
                                                       'Sales cloud', ex.getStackTraceString(), 
                                                       'Update Total Purchased And Redeemed Credits On Account: ' + ex.getMessage(), ex.getTypeName());
            
            throw ex;
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
    
    private void updateCreditsOnAccount(List<Professional_Services_Credits__c> psCredits) {
        
        Set<Id> accountIds = getAccountIds(psCredits);
        if(accountIds != null && !accountIds.isEmpty()) {
            
            Map<Id,AggregateResult> allPSCredits = getAggregrateResultTotalCredits(accountIds,ZScalarConstants.PS_CREDIT_RECORDTYPENAME);
            Map<Id,AggregateResult> expiredPSCredits = getAggregrateResultExpiredCredits(accountIds,ZScalarConstants.PS_CREDIT_RECORDTYPENAME);
            Map<Id,AggregateResult> allTrainingCredits = getAggregrateResultTotalCredits(accountIds,ZScalarConstants.TRAINING_CREDIT_RECORDTYPENAME);
            Map<Id,AggregateResult> expiredTrainingCredits = getAggregrateResultExpiredCredits(accountIds,ZScalarConstants.TRAINING_CREDIT_RECORDTYPENAME);
            Map<Id,Account_Extension__c> accountExts =  getAccountExtensions(accountIds);
            
            List<Account_Extension__c> accExtsToBeUpdated = new List<Account_Extension__c>();
            for(Id accId: accountIds){
                
                Account_Extension__c accExt = accountExts?.get(accId);
                
                if(accExt == null){
                    continue;
                }
                
                
                accExt.Total_Purchased_PS_Credits__c = Integer.valueOf(allPSCredits?.get(accId)?.get('purchasedCredit'));
                
                accExt.Total_Purchased_Training_Credits__c = Integer.valueOf(allTrainingCredits?.get(accId)?.get('purchasedCredit'));
                
                accExt.Total_Redeemed_PS_Credits__c = Integer.valueOf(allPSCredits?.get(accId)?.get('redeemedCredit'));
                
                accExt.Total_Redeemed_Training_Credits__c = Integer.valueOf(allTrainingCredits?.get(accId)?.get('redeemedCredit'));
                
                accExt.Total_Expired_PS_Credits__c = Integer.valueOf(expiredPSCredits?.get(accId)?.get('creditRemaining'));
                
                accExt.Total_Expired_Training_Credits__c = Integer.valueOf(expiredTrainingCredits?.get(accId)?.get('creditRemaining'));
                
                accExtsToBeUpdated.add(accExt);
                
            }
            
            if(!accExtsToBeUpdated.isEmpty()){
                Database.update(accExtsToBeUpdated,false);
            }
        }        
    }
    
    private Set<Id> getAccountIds(List<Professional_Services_Credits__c> psCredits) {
        
        Set<Id> accountIds = new Set<Id>();
        for(Professional_Services_Credits__c psCredit: psCredits){
            accountIds.add(psCredit.Account__c);
        }
        
        return accountIds;
    } 
    
    private Map<Id,AggregateResult> getAggregrateResultExpiredCredits(Set<Id> accountIds, String recTypeName) {
        
        Map<Id,AggregateResult> totalCreditPurchasedAndRedeemedByAccountId = new Map<Id,AggregateResult>();
        
        
        for(AggregateResult totalCreditPurchased: [SELECT SUM(Credits_Remaining__c)creditRemaining,
                                                   Account__c 
                                                   FROM Professional_Services_Credits__c 
                                                   WHERE Account__c IN :accountIds
                                                   AND RecordType.Name =: recTypeName
                                                   AND Is_Redemption_Valid__c = false
                                                   Group by Account__c])
        {
            totalCreditPurchasedAndRedeemedByAccountId.put((Id)totalCreditPurchased.get('Account__c'),totalCreditPurchased);
        }
        return totalCreditPurchasedAndRedeemedByAccountId;
    }
    
    private Map<Id,AggregateResult> getAggregrateResultTotalCredits(Set<Id> accountIds, String recTypeName) {
        
        Map<Id,AggregateResult> totalCreditPurchasedAndRedeemedByAccountId = new Map<Id,AggregateResult>();
        
        
        for(AggregateResult totalCreditPurchased: [SELECT SUM(Credits_Purchased__c) purchasedCredit,
                                                   SUM(Credits_Redeemed__c)  redeemedCredit,
                                                   Account__c 
                                                   FROM Professional_Services_Credits__c 
                                                   WHERE Account__c IN :accountIds
                                                   AND RecordType.Name =: recTypeName
                                                   Group by Account__c])
        {
            totalCreditPurchasedAndRedeemedByAccountId.put((Id)totalCreditPurchased.get('Account__c'),totalCreditPurchased);
        }
        return totalCreditPurchasedAndRedeemedByAccountId;
    }
    
    private Map<Id,Account_Extension__c> getAccountExtensions(Set<Id> accountIds) {
        
        Map<Id,Account_Extension__c> accAccountExtensions = new Map<Id,Account_Extension__c>();
        for(Account_Extension__c accExt: [SELECT Id,Account__c,
                                          Total_Expired_PS_Credits__c,Total_Expired_Training_Credits__c,
                                          Total_Purchased_PS_Credits__c,Total_Purchased_Training_Credits__c,
                                          Total_Redeemed_PS_Credits__c,Total_Redeemed_Training_Credits__c
                                          FROM Account_Extension__c WHERE Account__c IN: accountIds])
        {
            accAccountExtensions.put(accExt.Account__c,accExt);
        }
        return accAccountExtensions;
    }
    
    global void execute(SchedulableContext SC) {
        PSCredit_UpdateCreditsOnAccountBatch psCreditBatch = new PSCredit_UpdateCreditsOnAccountBatch(); 
        Id batchId = Database.executeBatch(psCreditBatch);
    }
}