public class BatchDealRegAutoApprovalAD implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchDealRegAutoApprovalAD');
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        String query;        
        if(Test.isRunningTest()){
            query ='SELECT ID,X96_Hours_Passed__c FROM Deal_Reg__c LIMIT 1';
        }
        else{
            query ='SELECT Id,X96_Hours_Passed__c,X96_Hours_after_Approval_Submission__c FROM Deal_Reg__c where X96_Hours_after_Approval_Submission__c = true and X96_Hours_Passed__c = false and Status__c = \'Pending Review\'';
        }
        
        return Database.getQueryLocator(query);
    }
    
    /*public static MAP<ID,ID> getWorkItemMAP(Set<Id> targetObjectIdList)
    {
        MAP<ID,ID> workIDMap = new MAP<ID,ID>();
        for(ProcessInstanceWorkitem workItem  : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                                                 where ProcessInstance.TargetObjectId =: targetObjectIdList]){
            workIDMap.put(workItem.ProcessInstance.TargetObjectId ,workItem.Id);
        }
        return workIDMap;
    }*/
    
    
    public void execute(Database.BatchableContext bc, List<Deal_Reg__c> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        
        /*List<Deal_Reg__c> DealRglist = (list<Deal_Reg__c>) records;
        List<Deal_Reg__c>  UpdateDealRegList = new list<Deal_Reg__c>();
        
        Set<ID> idset = new Set<ID>();
        for(Deal_Reg__c dr :  records){
            idset.add(dr.id);
        }
        MAP<ID,ID> getWorkItemMAP = getWorkItemMAP(idset);
       
        
        List<Deal_Reg__c> UpdateDRList = new List<Deal_Reg__c>();
        List<Approval.ProcessWorkitemRequest> approvalProcessList = new  List<Approval.ProcessWorkitemRequest>();
        
        for (Deal_Reg__c ar : records)  {
            if(getWorkItemMAP.containskey(ar.id)){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Auto Approved request since 96 hours passed');
                req.setAction('Approve');
                req.setWorkitemId(getWorkItemMAP.get(ar.id));
                approvalProcessList.add(req);
                UpdateDRList.add(new Deal_Reg__c(Id=ar.id, X96_Hours_Passed__c=true));
            }
        }
        // Submit the request for approval
        List<Approval.ProcessResult> resultList = Approval.process(approvalProcessList);
        database.update(UpdateDRList, false);
        
        
        /*
        for (Deal_Reg__c ar : records)  {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Auto Approved request since 48 hours passed');
            req.setAction('Approve');
            //req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            Id workItemId = getWorkItemId(ar.id); 
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req); 
        }*/
        
        
        //   if(!UpdateDealRegList.isempty())
        // database.update(UpdateLeadStatusList, false);
        
    }    
    
    /*public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                 where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }
        
        return retVal;
    }*/
    
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(BC);
        
    }  
    public void execute(SchedulableContext sc) {
        BatchDealRegAutoApprovalAD b = new BatchDealRegAutoApprovalAD(); 
        database.executebatch(b,200);
    }
}