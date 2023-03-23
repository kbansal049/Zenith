//Added by Varun, Rajesh for CR 995
global class CustomerScorecardBatch implements 
Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CustomerScorecardBatch');
    String batchSoql;
    Map<Id, list<Decimal>> accountVsCSCScore = new Map<Id, list<Decimal>>();
    
    public CustomerScorecardBatch(String soql){
        batchSoql = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(batchSoql);
    }
    
    global void execute(Database.BatchableContext bc, List<Cloud_Usage__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        for (Cloud_Usage__c usage : scope) {
            if(accountVsCSCScore.containsKey(usage.Account__c)){
                List<Decimal> existingCount = accountVsCSCScore.get(usage.Account__c);
                if(usage.Auth__c!=null){
                    existingCount[0]+=usage.Auth__c;
                }
                if(usage.Unauth_Location_Unauth_Bytes__c!=null){
                    existingCount[1]+=usage.Unauth_Location_Unauth_Bytes__c;
                }
                accountVsCSCScore.put(usage.Account__c, existingCount);
            }
            else{
                List<Decimal> newCount = new List<Decimal>();
                Decimal decTotalAmountForAuth=0.0;
                Decimal decTotalAmountForUnAuth=0.0;
                if(usage.Auth__c!=null){
                    decTotalAmountForAuth +=usage.Auth__c;
                }
                if(usage.Unauth_Location_Unauth_Bytes__c!=null){
                    decTotalAmountForUnAuth +=usage.Unauth_Location_Unauth_Bytes__c;
                }
                newCount.add(decTotalAmountForAuth);
                newCount.add(decTotalAmountForUnAuth);
                accountVsCSCScore.put(usage.Account__c, newCount);
            }
        }
         
    }

    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        List<Customer_Score_Card__c> lstCustomer = new List<Customer_Score_Card__c>();
        List<Customer_Score_Card__c> customerScoreCards = [SELECT Account__c, UnAuth_Traffic_From_Auth_Loc_L30D_TB__c, UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c
                                                            FROM Customer_Score_Card__c
                                                            WHERE Account__c IN: accountVsCSCScore.keySet()];
                                                            
        Map<Id, Customer_Score_Card__c> accountVsCSC = new Map<Id, Customer_Score_Card__c>();
        
        for(Customer_Score_Card__c csc : customerScoreCards){
            accountVsCSC.put(csc.Account__c, csc);
        }
        
        for(Id accId : accountVsCSCScore.keySet()){
            List<Decimal> existingCount = accountVsCSCScore.get(accId);
            Decimal decTotalAmountForAuth = existingCount[0];
            Decimal decTotalAmountForUnAuth = existingCount[1];
            // Auth to Terabyte
            decTotalAmountForAuth = (decTotalAmountForAuth/(1024*1024*1024)).setScale(2);
            decTotalAmountForAuth = (decTotalAmountForAuth/(1024)).setScale(2);
            
            // UnAuth to Terabyte
            decTotalAmountForUnAuth = (decTotalAmountForUnAuth/(1024*1024*1024)).setScale(2);
            decTotalAmountForUnAuth = (decTotalAmountForUnAuth/(1024)).setScale(2);
            
            if(accountVsCSC.containsKey(accId)){
                Customer_Score_Card__c customerCSC = accountVsCSC.get(accId);
                customerCSC.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = decTotalAmountForAuth;
                customerCSC.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = decTotalAmountForUnAuth;
                lstCustomer.add(customerCSC);
            }
        }
        
        CustomerScorecardBatchExt batchExt = new CustomerScorecardBatchExt(lstCustomer);
        Database.executebatch(batchExt,2000);
    }
}