//Added by Varun, Rajesh for CR 995
global class CleanCustomerScorecardBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CleanCustomerScorecardBatch');
    String batchSoql;
    
    public CleanCustomerScorecardBatch(String soql){
        batchSoql = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(batchSoql);
    }
    
    global void execute(Database.BatchableContext bc, List<Customer_Score_Card__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        for (Customer_Score_Card__c csc : scope) {
            csc.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = null;
            csc.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = null;
        }
        update scope;
    }

    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        Database.executeBatch(new CustomerScorecardBatch('Select  Account__c, Auth__c, Unauth_Location_Unauth_Bytes__c FROM Cloud_Usage__c  Where Last_31_Days__c =true  and Cloud_Usage_Type__c=\'ZIA\''), 200);
    }
}