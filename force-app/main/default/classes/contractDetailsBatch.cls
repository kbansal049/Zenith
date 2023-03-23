public class contractDetailsBatch implements Database.Batchable<SObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('contractDetailsBatch');
    
    public string query = null;
    
    public contractDetailsBatch(string reqQuery){
        query = reqQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zb.callStart();
        
        Date todayDate = Date.today()-1;
        if(query == null){
            query = 'SELECT Id,Active__c,Is_Contract_Active__c from Contract_Detail__c WHERE (Start_Date__c <=: todayDate and End_Date__c >=: todayDate) or Contract_Details_Batch_Status__c =\'Failed\'';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Contract_Detail__c> contractDetails) {
        
        this.zb.callExecute(contractDetails[0]?.Id, contractDetails.size());
        
        List<Contract_Detail__c> updateContractStatus = new List<Contract_Detail__c>();
        Map<Id, Contract_Detail__c> idToContractDetails = new Map<Id, Contract_Detail__c>();
        
        for(Contract_Detail__c contDetails : contractDetails){
            if(contDetails.Is_Contract_Active__c != contDetails.Active__c){
                contDetails.Is_Contract_Active__c = contDetails.Active__c;
                idToContractDetails.put(contDetails.id, contDetails);
            }
        }
        if(!idToContractDetails.isEmpty() && idToContractDetails.size()>0){
            try{
                Database.SaveResult[] results = Database.update(idToContractDetails.values(),false);
                system.debug('results'+results);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(index <= idToContractDetails.values().size()) {
                        Contract_Detail__c cDetails= idToContractDetails.values().get(index);
                        if(results[index].isSuccess()){
                            cDetails.Contract_Details_Batch_Status__c = 'Success';
                            updateContractStatus.add(cDetails);
                        }else{
                            cDetails.Contract_Details_Batch_Status__c = 'Failed';
                            updateContractStatus.add(cDetails);
                        }
                    }
                }
                if(!updateContractStatus.isEmpty() && updateContractStatus.size()>0){
                    //Skip triggeres
                    TriggerHandler.bypass('AccountTriggerHandler');
                    TriggerUtility.SkipConDetailTriggerExecuted();
                    update updateContractStatus;
                }       
            }catch(Exception ex){
                ZscalerErrorLogsUtility.insertlogsForAsync('contractDetailsBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
            }
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }
}