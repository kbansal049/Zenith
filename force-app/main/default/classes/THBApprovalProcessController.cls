public without sharing class THBApprovalProcessController {
    
    /*@AuraEnabled(cacheable=true)
    public static list<ProcessInstanceWorkItem> DealRegistrationProcessInstanceItems(){
       return [select Id, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.Status from ProcessInstanceWorkItem where OriginalActor.name like '%TBH%' and ProcessInstance.TargetObject.Type='Deal_Reg__c'];   
    }*/
	//added By Swathi Start :CR1338
	@AuraEnabled(Cacheable = true)
    public static list<ProcessInstanceWorkItem> retriveDealRegistration(String strAccName) {
        strAccName = '%' + strAccName + '%';	
        List<Id> targetObjectIds = new List<Id>();
        list<ProcessInstanceWorkItem> lstProcess = [select Id, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.Status from ProcessInstanceWorkItem where OriginalActor.name like '%TBH%' and ProcessInstance.TargetObject.Type='Deal_Reg__c'];
		for(ProcessInstanceWorkItem result : lstProcess){
			targetObjectIds.add(result.ProcessInstance.TargetObjectId);
 		}
        Set<id> targetidlist = new Set<id>();
        for(Deal_Reg__c result : [SELECT Id, Area__c FROM Deal_Reg__c WHERE Id IN:targetObjectIds and Area__c Like:strAccName]){
            targetidlist.add(result.Id);
        }
        list<ProcessInstanceWorkItem> lstAccs = new list<ProcessInstanceWorkItem>();
        list<sobject> lstobj = new list<sobject>();
        if(strAccName!=Null || strAccName!='')
        	lstAccs = [select Id, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.Status from ProcessInstanceWorkItem where ProcessInstance.TargetObjectId In:targetidlist];
        else
            lstAccs = lstProcess;
        System.debug('lstAccs'+lstAccs);
        return lstAccs;
    }
    @AuraEnabled(cacheable=true)
    public static list<Deal_Reg__c> DealRegistration(){
		List<Id> targetObjectIds = new List<Id>();
		for(ProcessInstanceWorkItem result : [select ProcessInstance.TargetObjectId from ProcessInstanceWorkItem where OriginalActor.name like '%TBH%' and ProcessInstance.TargetObject.Type='Deal_Reg__c']){
			targetObjectIds.add(result.ProcessInstance.TargetObjectId);
 		}		
        return [SELECT Id, Area__c,Sub_Region__c FROM Deal_Reg__c  WHERE Id IN:targetObjectIds];
    }
	//added By Swathi End :CR1338
	
}