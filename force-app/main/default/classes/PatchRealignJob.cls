/*
 * Realigns patches after patch criteria changed or member changed
 */
public class PatchRealignJob implements Database.Batchable<SObject>, Database.Stateful
{ 
    ZscalerBatchFramework zb = new ZscalerBatchFramework('PatchRealignJob');
    private List<Id> recordIds;
    private List<Schema.SObjectType> pendingObjTypes;
    private Schema.SObjectType currentObjType;
    public Map<Schema.SObjectType, Integer> successfulCount;
    public Map<Schema.SObjectType, Integer> failedCount;
    public Map<Schema.SObjectType, List<String>> errorMessages;
    public Boolean reassignEverything;
    public Boolean realignOpps;
    
    public PatchRealignJob(List<Id> patchIds, List<Schema.SObjectType> objTypes)
    {
        this.reassignEverything = false;
        this.realignOpps = false;
        this.recordIds = patchIds;
        this.pendingObjTypes = objTypes;
        if(pendingObjTypes.size() > 0)
        {
            this.currentObjType = pendingObjTypes[0];
        }
        successfulCount = new Map<Schema.SObjectType, Integer>();
        failedCount = new Map<Schema.SObjectType, Integer>();
        errorMessages = new Map<Schema.SObjectType, List<String>>();
    }
    
    public PatchRealignJob(List<Id> accIds, List<Schema.SObjectType> objTypes, Boolean realignOpps)
    {
        this.reassignEverything = false;
        this.recordIds = accIds;
        this.pendingObjTypes = objTypes;
        this.realignOpps = realignOpps;
        if(pendingObjTypes.size() > 0)
        {
            this.currentObjType = pendingObjTypes[0];
        }
        successfulCount = new Map<Schema.SObjectType, Integer>();
        failedCount = new Map<Schema.SObjectType, Integer>();
        errorMessages = new Map<Schema.SObjectType, List<String>>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        this.zb.callStart();
        if(currentObjType == null)
        {
            return null;
        }
        successfulCount.put(currentObjType, 0);
        failedCount.put(currentObjType, 0);
        errorMessages.put(currentObjType, new List<String>());
        List<String> criteria = new List<String>();
        if(recordIds != null && recordIds.size() > 0)
        {
            if(this.realignOpps)
            {
                criteria.add('AccountId in :recordIds');   
            }
            else 
            {
                criteria.add(PatchRuleHelper.NamespacePrefix + 'Patch__c in :recordIds');   
            }
        }
        else
        {
            System.assert(reassignEverything, 'ReassignEverything flag must be set if no patch is specified.');
        }
        
        if(currentObjType == Schema.Lead.SObjectType)
        {
            criteria.add('IsConverted=false');
        }
        
        String soql = PatchRuleHelper.buildSQL(currentObjType.getDescribe().getName(), null, criteria);
        System.debug('the query is' + soql + ' LIMIT 1');
        return Database.getQueryLocator(soql);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        this.zb.callExecute(scope[0]?.Id, scope.size());
        TriggerUtility.realignPatch();
        List<Id> sObjectIdList = new List<Id>();
        for(sObject obj : scope)
        {
            sObjectIdList.add(obj.Id);
            obj.put(PatchRuleHelper.NamespacePrefix + 'TriggerPatchAssignment__c', true);
            //obj.put('Batch_Patch_Processed__c', true);
        }
        try
        {
            //Database.Update(scope,false);
            //successfulCount.put(currentObjType, successfulCount.get(currentObjType) + scope.size());
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerHandler.bypass('LeadTriggerHandler');
            update scope;
            successfulCount.put(currentObjType, successfulCount.get(currentObjType) + scope.size());
            PatchRuleEngineStarter starter = new PatchRuleEngineStarter(sObjectIdList);
            starter.start();
            TriggerHandler.clearbypass('AccountTriggerHandler');
            TriggerHandler.clearbypass('OpportunityTriggerHandler');
            TriggerHandler.clearbypass('LeadTriggerHandler');
        }
        catch(Exception ex)
        {
            ZscalerErrorLogsUtility.insertLogsForAsync('PatchRealignJob', 'Execute Method',
                                               'Apex', UserInfo.getUserId(),
                                               'Sales Cloud', ex.getStackTraceString(), 
                                               'UPDATE_FAILED : ' + ex.getMessage() + ', ' + ex.getLineNumber(), ex.getTypeName());
            failedCount.put(currentObjType, failedCount.get(currentObjType) + scope.size());
            List<String> errors = errorMessages.get(currentObjType);
            if(errors.size() < 3)
            {
                errors.add(ex.getMessage());
                errorMessages.put(currentObjType, errors);
            }
        }
        TriggerUtility.realignPatchReset();
        callAfterAction(scope);//TODO cooment this as we are not running any logic
    }
    
    public void finish(Database.BatchableContext context)
    {
        this.zb.callFinish(context);
        pendingObjTypes.remove(0);
        if(pendingObjTypes.size() > 0)
        {
            PatchRealignJob job = new PatchRealignJob(recordIds, pendingObjTypes);
            job.successfulCount = this.successfulCount;
            job.failedCount = this.failedCount;
            job.errorMessages = this.errorMessages;
            job.reassignEverything = this.reassignEverything;
            Integer batchSize = 1;
            Database.executeBatch(job, batchSize);
        }
        else
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setPlainTextBody(getJobResultSummary());
            email.setSaveAsActivity(false);
            email.setSubject('Patch Realignment Finished');
            Messaging.sendEmail(new List<Messaging.Email> { email }, false);
            
            //Added by Sateesh to Call Account Post Patch
            if(!Test.isRunningTest()){
                Database.executeBatch(new accountsPostPatchBatch(recordIds), 10);
            }
            
        }
    }
    
    private String getJobResultSummary()
    {
        String summary = 'Your patch realignment job has finished.\r\n';
        summary += 'There are ';
        if(successfulCount.keyset().size() > 0)
        {
            for(Schema.SObjectType objType : successfulCount.keyset())
            {
                summary += successfulCount.get(objType) + ' ' + objType.getDescribe().getName() + '(s), ';
            }
            summary = summary.removeEnd(', ');
            summary += ' succeeded; ';
        }
        if(failedCount.keyset().size() > 0)
        {
            for(Schema.SObjectType objType : failedCount.keyset())
            {
                summary += failedCount.get(objType) + ' ' + objType.getDescribe().getName() + '(s), ';
            }
            summary = summary.removeEnd(', ');
            summary += ' failed. ';
        }
        summary += '\r\n';
        if(errorMessages.keyset().size() > 0)
        {
            for(Schema.SObjectType objType : errorMessages.keyset())
            {
                List<String> errors = errorMessages.get(objType);
                if(errors != null)
                {
                    for(String error : errors)
                    {
                        summary += error + '\r\n';
                    }
                }
            }
        }
        summary += '\r\n\r\nPatch Manager';
        return summary;
    }
    
    private void callAfterAction(List<sObject> scope)
    {
        if(scope.size() > 0)
        {
            if(scope[0] instanceof Account)
            {
                List<Account> accs = new List<Account>();
                for(sObject obj : scope)
                {
                    accs.add((Account)obj);
                }
                //AccountTriggerHelper.accountPatchHelper(accs);
            }
            else if(scope[0] instanceof Opportunity)
            {
                List<Opportunity> opps = new List<Opportunity>();
                for(sObject obj : scope)
                {
                    opps.add((Opportunity)obj);
                }
                //OpportunitytTriggerHelper.opportunityPatchHelper(opps);
            }
            else if(scope[0] instanceof Lead)
            {
                List<Lead> leads = new List<Lead>();
                for(sObject obj : scope)
                {
                    leads.add((Lead)obj);
                }
                //LeadTriggerHelper.leadPatchHelper(leads);
            }
        }
    }
}