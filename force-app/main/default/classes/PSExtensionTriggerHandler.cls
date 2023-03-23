/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* PSExtensionTriggerHandler
* @description    This class is the trigger handler class PS_Extension__c object.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-02-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class PSExtensionTriggerHandler extends TriggerHandler {
    
    public static Set<Id> proecessedPSExtRecordSet = new Set<Id> ();
    
    public override void beforeInsert() {}
    public override void afterInsert() {
        
        System.debug('Inside after insert');
        
        Map<Id, PS_Extension__c> psExtMapForEmailHandler = new Map<Id, PS_Extension__c> ();
        
        for (SObject psExt: Trigger.new) {
            
            PS_Extension__c newPSExt = (PS_Extension__c) psExt;
            
            System.debug('-=- newPSExt.Approval_Status__c -=- '+newPSExt.Approval_Status__c);
            System.debug('-=- newPSExt.Extension_Type__c -=- '+newPSExt.Extension_Type__c);
            
            if (newPSExt.Approval_Status__c.equalsIgnoreCase('Not started') && String.isBlank(newPSExt.Extension_Type__c)) {
                psExtMapForEmailHandler.put(psExt.Id, newPSExt);
            }
            
            proecessedPSExtRecordSet.add(psExt.Id);
            
        }
        
        if (!psExtMapForEmailHandler.isEmpty()) {
            
            PSExtensionApprovalEmailHandler instance = PSExtensionApprovalEmailHandler.getInstance();
            instance.setNewPSExtMap(psExtMapForEmailHandler);
            instance.handle();
        }
    }
    // Added by Ayush kangar as part of CR# 3599 - Start
    // Check for Approval process reject field validation, Comments
    public override void beforeUpdate() {
        Map<Id, PS_Extension__c> oldpsExtMap = new Map<Id,PS_Extension__c>();
        Map<Id, PS_Extension__c> newpsExtMap = new Map<Id,PS_Extension__c>();
        for (SObject psExt: Trigger.new) {
            PS_Extension__c newpsExt = (PS_Extension__c) psExt;
            PS_Extension__c oldpsExt= (PS_Extension__c) Trigger.oldMap.get(newpsExt.Id);
            
            oldpsExtMap.put(oldpsExt.Id, oldpsExt); 
            newpsExtMap.put(newpsExt.Id, newpsExt);
        }
        rejectionFieldValidation(newpsExtMap.values(), oldpsExtMap);
    }
    
    public void rejectionFieldValidation(List<PS_Extension__c> triggerNew, Map<Id, PS_Extension__c> triggerMapOld){
        Map<Id, PS_Extension__c> rejectedPSExtensionRequests = new Map<Id, PS_Extension__c>();
        String fundReqRecs;   
        for(PS_Extension__c psExtRecord : triggerNew){
            if((triggerMapOld.get(psExtRecord.Id).PS_Extension_Approval_Process_Status__c != 'Blank Extension Type Approval Process - Rejected' ||
                triggerMapOld.get(psExtRecord.Id).PS_Extension_Approval_Process_Status__c != '30 Days Extension Type Approval Process - Rejected' ||
                triggerMapOld.get(psExtRecord.Id).PS_Extension_Approval_Process_Status__c != 'Blank Extension Type Approval Process PS- Rejected' ||
                triggerMapOld.get(psExtRecord.Id).PS_Extension_Approval_Process_Status__c != '30 Days Extension Approval Process PS - Rejected'  )
               && 
               (psExtRecord.PS_Extension_Approval_Process_Status__c == 'Blank Extension Type Approval Process - Rejected' ||
                psExtRecord.PS_Extension_Approval_Process_Status__c == '30 Days Extension Type Approval Process - Rejected'||
                psExtRecord.PS_Extension_Approval_Process_Status__c == 'Blank Extension Type Approval Process PS- Rejected'||
                psExtRecord.PS_Extension_Approval_Process_Status__c == '30 Days Extension Approval Process PS - Rejected')){
                    rejectedPSExtensionRequests.put(psExtRecord.Id,psExtRecord);
                }
        }
        
        if(!rejectedPSExtensionRequests.isEmpty()){
            Set<Id> processInstanceIds = new Set<Id>();
            //Map<Id,String> equipmentRequestIdCreatedByEmailMap = new Map<Id,String>();
            //Get the most recent approval process instance for the object.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            for (PS_Extension__c equipReqRecs : [SELECT Id,CreatedBy.Email,
                                                 (SELECT ID
                                                  FROM ProcessInstances
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1)
                                                 FROM PS_Extension__c
                                                 WHERE ID IN :rejectedPSExtensionRequests.keySet()])
            {
                processInstanceIds.add(equipReqRecs.ProcessInstances[0].Id);
                //equipmentRequestIdCreatedByEmailMap.put(equipReqRecs.Id,equipReqRecs.CreatedBy.Email);
            }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments. 
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        WHERE (StepStatus != 'Approved' OR StepStatus != 'Rejected')
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds
                                       ORDER BY CreatedDate DESC])   
            {
                if(!pi.Steps.isEmpty() && rejectedPSExtensionRequests.containsKey(pi.TargetObjectId)){
                    if (String.isBlank(pi.Steps[0].Comments) &&
                        String.isBlank(rejectedPSExtensionRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c))
                    {
                        rejectedPSExtensionRequests.get(pi.TargetObjectId).addError(
                            'Approval Process Error : Please provide Rejection Comment');
                    }else {
                        if(String.isNotBlank(rejectedPSExtensionRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c) && 
                           String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedPSExtensionRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c += ', ' + pi.Steps[0].Comments.trim();
                           }else if(String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedPSExtensionRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c = pi.Steps[0].Comments.trim();
                           }
                    }
                    System.debug('rejectedPSExtensionRequests.get(pi.TargetObjectId) : ' + rejectedPSExtensionRequests.get(pi.TargetObjectId));
                    System.debug('--++-- :' + rejectedPSExtensionRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c);
                }
            }
        }
    }
    // Added by Ayush kangar as part of CR# 3599 - End
    
}