/************************************************************************************************************************************
* Name: renewSelectedContracts 
* Description: Batch class to check Renewal Forecast and Renewal Quoted on legacy contracts
************************************************************************************************************************************/ 
global class renewSelectedContracts implements Database.Batchable<SObject>,Database.Stateful {
	ZscalerBatchFramework zb = new ZscalerBatchFramework('renewSelectedContracts');
    global String query;
    global renewSelectedContracts(string squery){
        query = squery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
		this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contract> scope){
		this.zb.callExecute(scope[0]?.Id, scope.size());
        for(Contract objContract :scope){
            if(objContract.SBQQ__RenewalOpportunity__c==null && objContract.SBQQ__RenewalForecast__c ==TRUE ){
                objContract.SBQQ__RenewalForecast__c = FALSE;
                objContract.SBQQ__RenewalQuoted__c = FALSE;
            }else{
                objContract.SBQQ__RenewalForecast__c = TRUE;
                objContract.SBQQ__RenewalQuoted__c = TRUE;
            }
        }
        
        if(!Test.isRunningTest()){
            update scope;
		}
        List<Contract> listContractToUpdate=new List<Contract>();
        for(Contract objContract :scope){
            if(objContract.SBQQ__RenewalForecast__c==FALSE && objContract.SBQQ__RenewalQuoted__c ==FALSE ){
                objContract.SBQQ__RenewalForecast__c = TRUE;
                objContract.SBQQ__RenewalQuoted__c = TRUE;
                listContractToUpdate.add(objContract);
            }
        }
        if(!listContractToUpdate.isEmpty() && !Test.isRunningTest()){
            update listContractToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
    
}