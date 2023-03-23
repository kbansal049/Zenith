public class UnauthTrafficUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UnauthTrafficUpdateBatch');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    private string query; 
    Boolean error = false;
    Set<Id> aliset = new Set<Id>();
    public UnauthTrafficUpdateBatch(String query){
        this.query = query;
        //'select id from Contract_Detail__c'
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<Contract_Detail__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        //ContractDetailTriggerHelper.updateQuantitySumOnScoreCard(scope);
        Map<String,Contract_Detail_Sku__c> gbSkuTypeMap = Contract_Detail_Sku__c.getAll();
        Map<String,Contract_Sku_Bundle_Type__c> bundleSkuType = Contract_Sku_Bundle_Type__c.getAll();
        Map<String,Contract_4GB_Sku_Type__c> sku4GBType = Contract_4GB_Sku_Type__c.getAll();//Contract_4GB_Sku_Type__c.getAll();
        List<String> BUNDLE_SKU =new List<String>();
        List<String> GB_SKU =new List<String>();
        List<String> GB_4SKU =new List<String>();
        Set<Id> actIds =new Set<Id>();
        for(Contract_Detail__c contract : scope){
            actids.add(contract.Account_Name__c);
        }
        
        for(Contract_Detail_Sku__c contdet : gbSkuTypeMap.values()){
            GB_SKU.add(contdet.value__c);
        }
        
        for(Contract_Sku_Bundle_Type__c contdet : bundleSkuType.values()){
            BUNDLE_SKU.add(contdet.value__c);
        }
        for(Contract_4GB_Sku_Type__c contdet : sku4GBType.values()){
            GB_4SKU.add(contdet.value__c);
        }
        GB_SKU.addAll(BUNDLE_SKU);
        GB_SKU.addAll(GB_4SKU);
        //list<account> accountList = [select id,(select id,Contract_Detail_Status__c,APTS_SKU__c,Quantity__c from Contract_Details__r where Contract_Detail_Status__c = 'Active' and APTS_SKU__c in: GB_SKU) from account where id in : actIds];
        Map<id,double> accountSum = new map<id,double>();
        
        
        for(account acnt : [select id,(select id,Contract_Detail_Status__c,APTS_SKU__c,Quantity__c from Contract_Details__r where  Active__c=true and APTS_SKU__c in: GB_SKU) from account where id in : actIds]) {   
            double sum =0;
            List<Contract_Detail__c> contractList = acnt.Contract_Details__r;
            for(Contract_Detail__c contract : contractList){
                if(bundleSkuType.containsKey(contract.APTS_SKU__c)){
                    sum = sum + (contract.Quantity__c/10 + contract.Quantity__c/20);
                }
                if (gbSkuTypeMap.containsKey(contract.APTS_SKU__c)){
                    sum =sum + contract.Quantity__c;
                }
                if (sku4GBType.containsKey(contract.APTS_SKU__c)){
                    sum =sum + contract.Quantity__c*4;
                }
            }
            accountSum.put(acnt.id,sum);
        }
        List<Account_Extension__c> accountExtUpdateList = [select id,account__c,Unauth_Traffic_Entitlement_GB_month__c from Account_Extension__c where account__c in : accountSum.keyset()];
        for(Account_Extension__c singleAccountExtn : accountExtUpdateList){
            singleAccountExtn.Unauth_Traffic_Entitlement_GB_month__c = accountSum.get(singleAccountExtn.Account__c);
        }
        TriggerUtility.stopUpdateCountractDetailsseetTrue();
        //update accountExtUpdateList;
        
            List<Database.SaveResult> srList3 = database.update(accountExtUpdateList, false);

            // Iterate through each returned result
            for(Database.SaveResult dr : srList3) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(''+dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        errorlst.add(dr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        System.debug('errorlst'+errorlst);
        
          

    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(bc);
    }
}