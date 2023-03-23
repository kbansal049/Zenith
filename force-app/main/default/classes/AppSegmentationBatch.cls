/*
TestClass AppSegmentationBatchTest
*/

public class AppSegmentationBatch implements Database.Batchable<sObject>{
        ZscalerBatchFramework zb = new ZscalerBatchFramework('AppSegmentationBatch');
    
    String query;
    
    public AppSegmentationBatch(String query){
        this.query = query;
        //this.query = 'Select Id from Account';
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Account> AccList){
        this.zb.callExecute(AccList[0]?.Id, AccList.size());
        Set<Id> accIds = new Set<Id>();
        List<String> setSKUCodes = new List<String>();
        
        for(Account acc : AccList){
            accIds.add(acc.Id);
        }
        setSKUCodes = Label.App_Segment_SKUs.split(',');
        
        List<AggregateResult> contractSkus = [SELECT Product_SKU__c, count(Id) FROM Contract_Detail__c WHERE Account_Name__c IN :accIds AND Active__c = true AND Product_SKU__c in :setSKUCodes GROUP BY Product_SKU__c];
                                                    
        Integer entitlement = 0;
        
        for(AggregateResult result : contractSkus){
            string SKUCode = String.valueOf(result.get('Product_SKU__c'));
            switch on SKUCode{
                
                when 'ZPA-PRO-EDITION'{
                    entitlement += 10;
                }
                when 'ZPA-BUS-EDITION'{
                    entitlement += 100;
                }
                when 'ZPA-TRANS-EDITION'{
                    entitlement += 1000;
                }
                when 'ZPA-PRO'{
                    entitlement += 5;
                }
                when 'ZPA-BUS'{
                    entitlement += 9999;
                }
                when 'ZPA-ENT'{
                    entitlement += 9999;
                }
                
            }
        }
        
        
        List<AggregateResult> perUnitCountSKU =[SELECT SUM(Quantity__c) Quantity FROM Contract_Detail__c WHERE Active__c = true AND Product_SKU__c = 'ZT-APP-SEGMENT' AND Account_Name__c IN :accIds];
        if(Integer.valueOf(perUnitCountSKU[0].get('Quantity')) != null){
            entitlement += Integer.valueOf(perUnitCountSKU[0].get('Quantity'));
        }
        
        List<Cloud_Usage__c> cloudUsage = [SELECT Id, ZPA_Entitled_App_Segments__c FROM Cloud_Usage__c WHERE Account__c IN :accIds AND Cloud_Usage_Type__c = 'ZPA'];
        
        for(Cloud_Usage__c cu : cloudUsage){
            cu.ZPA_Entitled_App_Segments__c = entitlement;
        }
        
        if(!cloudUsage.IsEmpty() && cloudUsage.size() > 0){
            update cloudUsage;
        }
        
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        
    }
    
}