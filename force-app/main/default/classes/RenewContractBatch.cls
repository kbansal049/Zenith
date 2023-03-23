/************************************************************************************************************************************
 * Name: RenewContractBatch 
 * Description: Batch class to check Renewal Forecast and Renewal Quoted on Contract to create the Renewal Opportunity and Quotes 
************************************************************************************************************************************/ 
global class RenewContractBatch implements Database.Batchable<SObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('RenewContractBatch');
    private List<String> contractIds = new List<STring>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        return Database.getQueryLocator(
            //The conditions for the records for which renewals are to be created
            /*'SELECT id,SBQQ__RenewalOpportunity__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c,createdby.name,createddate,EndDate,StartDate,ContractTerm from contract where Split_Contract__c =FALSE AND Migrated_Contract__c = FALSE AND ((SBQQ__RenewalOpportunity__c =null and Status =\'Activated\') or (SBQQ__RenewalOpportunity__c!=null and SBQQ__RenewalQuoted__c=false) )  order by createddate desc '*/
            'SELECT id,SBQQ__RenewalOpportunity__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c,createdby.name,createddate,EndDate,StartDate,ContractTerm from contract where Split_Contract__c =FALSE AND Migrated_Contract__c = FALSE AND SBQQ__RenewalOpportunity__c =null and Status =\'Activated\' and Number_of_renewable_subscriptions__c != 0 order by createddate desc '
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Contract> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        for(Contract objContract :scope){
            if(objContract.SBQQ__RenewalOpportunity__c==null && objContract.SBQQ__RenewalForecast__c ==TRUE ){
                objContract.SBQQ__RenewalForecast__c = FALSE;
                objContract.SBQQ__RenewalQuoted__c = FALSE;
            }else{
                objContract.SBQQ__RenewalForecast__c = TRUE;
              //  objContract.SBQQ__RenewalQuoted__c = TRUE;
                contractIds.add(objContract.id);
            }
        }
        if(!Test.isRunningTest()){
	        update scope;
        }
        List<Contract> listContractToUpdate=new List<Contract>();
        for(Contract objContract :scope){
            if(objContract.SBQQ__RenewalForecast__c==FALSE && objContract.SBQQ__RenewalQuoted__c ==FALSE ){
                objContract.SBQQ__RenewalForecast__c = TRUE;
                //objContract.SBQQ__RenewalQuoted__c = TRUE;
                listContractToUpdate.add(objContract);
               // contractIds.add(objContract.id);
            }
        }
        if(!listContractToUpdate.isEmpty() && !Test.isRunningTest()){
            update listContractToUpdate;
        }
    }
  
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
       // generateYWSforRenewals renewals = new generateYWSforRenewals(contractIds);
    }
    
}