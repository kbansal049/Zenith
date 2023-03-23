/************************************************************************************************************************************
 * Name: RenewContractBatch_2 
 * Description: Batch class to check Renewal Quoted on Contract to create the Renewal Quotes 
************************************************************************************************************************************/ 
global class RenewContractBatch_2 implements Database.Batchable<SObject>,Database.Stateful {
    
    private List<String> contractIds = new List<STring>();
    ZscalerBatchFramework zb = new ZscalerBatchFramework('RenewContractBatch_2');
    
    global Database.QueryLocator start(Database.BatchableContext bc){
       this.zb.callStart();

        return Database.getQueryLocator(
            //The conditions for the records for which renewals are to be created
            'SELECT id,SBQQ__RenewalOpportunity__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c,createdby.name,createddate,EndDate,StartDate,ContractTerm from contract where Split_Contract__c = FALSE AND SBQQ__RenewalOpportunity__c!=null and (SBQQ__RenewalOpportunity__r.StageName !=\'6 - Closed Won\' AND SBQQ__RenewalOpportunity__r.StageName !=\'7 - Closed Lost\') and SBQQ__RenewalQuoted__c=FALSE and SBQQ__RenewalForecast__c=TRUE order by createddate desc'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Contract> scope){
        
        this.zb.callExecute(scope[0]?.Id, scope.size());

        for(Contract objContract :scope){
            objContract.SBQQ__RenewalQuoted__c = TRUE;
            contractIds.add(objContract.id);
        }        
        //updated by Akash 1: CR# 5023 start
        try{
            update scope;
        }
        catch(Exception e){
            ZscalerErrorLogsUtility.insertlogsForAsync('RenewContractBatch_2', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());	
        }
        //updated by Akash 1: CR# 5023 end
    }
  
    global void finish(Database.BatchableContext bc){
        generateYWSforRenewals renewals = new generateYWSforRenewals(contractIds);
		this.zb.callFinish(bc);
    }
    
}