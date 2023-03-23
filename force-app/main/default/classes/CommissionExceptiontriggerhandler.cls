//Test Class: CommissionExceptiontriggerhandlerTest
public class CommissionExceptiontriggerhandler{
    public static void beforeInsert(List<Commission_Exception__c> CElist){
        for( Commission_Exception__c CE: CElist){
            if(CE.Opportunity__c!=null){
                CE.Geo__c=CE.Opportunity_Geo__c;
                CE.Account__c=CE.Account_id__c; 
                CE.Request_Status__c='Pending Submission';              
            }
            
            if(CE.Geo__c=='Americas'){ CE.Geo_VP__c='00570000004MiXOAA0'; } //Jesse  
            else if(CE.Geo__c=='International'){ CE.Geo_VP__c='00570000005JLc9AAG'; }//David eastwood
            else if(CE.Geo__c=='Public Sector'){ CE.Geo_VP__c='0050g000005dWfE'; }
        }
    }
    
    public static void beforeUpdate(List<Commission_Exception__c> CElist,Map<id,Commission_Exception__c> OldMap){
        
        Map<Id,Commission_Exception__c> getApproverCommentsMap = new Map<Id,Commission_Exception__c>();
        
        for(Commission_Exception__c CE: CElist){
            
            if(CE.Opportunity__c!=null){
                //Added for CR#3935
                CE.Geo__c=CE.Opportunity_Geo__c;
                CE.Account__c=CE.Account_id__c; 
            }
            
            if(CE.Geo_VP__c==null){
                if(CE.Geo__c=='Americas'){ CE.Geo_VP__c='00570000004MiXOAA0'; } //Jesse  
            	else if(CE.Geo__c=='International'){ CE.Geo_VP__c='00570000005JLc9AAG'; }//David eastwood
            	else if(CE.Geo__c=='Public Sector'){ CE.Geo_VP__c='0050g000005dWfE'; }
            }
            
            if(CE.Request_Status__c=='Completed' && CE.Request_Status__c!=OldMap.get(CE.id).Request_Status__c){
                CE.Locked__c=true;
            }
            
            system.debug('CE.Recent_Approver_Id__c '+CE.Recent_Approver_Id__c);
            
            if(CE.Invoke_Trigger_To_Get_Comment__c){
                getApproverCommentsMap.put(CE.Id, CE);
            }
        }
        
        if(!getApproverCommentsMap.isEmpty()){
            getLastestComment(getApproverCommentsMap);
        }
    }
    
    public static void getLastestComment(Map<Id,Commission_Exception__c> newRecordMap){
        Set<Id> recordIds = newRecordMap.keyset();
    
        Map<Id,ProcessInstanceStep> PISteps= new Map<Id,ProcessInstanceStep>();
        //Map<Id,ProcessInstanceWorkitem> PIWorkitems = new Map<Id,ProcessInstanceWorkitem>();
        List<ProcessInstance> newInstanceList = [SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActorId,
                                                 LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,
                                                 SystemModstamp,TargetObjectId, (SELECT ID, StepStatus,Comments,ActorId,
                                                                                 CreatedById,OriginalActorId,
                                                                                 ProcessInstanceId,CreatedDate FROM Steps ORDER BY CreatedDate DESC) 
                                                 FROM ProcessInstance
                                                 WHERE TargetObjectId IN :recordIds ORDER BY CreatedDate DESC];
        if(!newInstanceList.isEmpty()){
            
            for(ProcessInstance pi : newInstanceList){
                System.debug(pi.Steps);
                System.debug(pi.Steps[0]);
                PISteps.put(pi.TargetObjectId, pi.Steps[0]);
            }    
            
            PISteps.put(newInstanceList[0].TargetObjectId, newInstanceList[0].Steps[0]);
            
            /*
            for(ProcessInstanceWorkitem workitem : [SELECT ActorId,CreatedById,ProcessInstance.TargetObjectId,CreatedDate,Id,
                                                    OriginalActorId,ProcessInstanceId,SystemModstamp
                                                    FROM ProcessInstanceWorkitem 
                                                    WHERE ProcessInstance.TargetObjectId IN :recordIds ORDER BY CreatedDate DESC]){
                PIWorkitems.put(workitem.ProcessInstance.TargetObjectId, workitem);
            }
            */
            
            List<String> reservationKeywordList = System.Label.With_Reservation_Key_Words.split(',');
            
            for(Id ceId: newRecordMap.keySet()){
                Commission_Exception__c ce = newRecordMap.get(ceId);
                String comments = PISteps.get(ceId).Comments;
                if(comments != null && String.isNotBlank(comments)){
                    for(String keyword : reservationKeywordList){
                       if(comments?.containsIgnoreCase(keyword.trim())){
                            ce.Approved_With_Reservation__c = true;
                            ce.Sub_Status__c = 'With Reservation';
                           break;
                        } else {
                            ce.Sub_Status__c = null;
                        } 
                    }                
                } else { ce.Sub_Status__c = null; }
                //ce.Next_Approver__c = PIWorkitems.get(ceId)?.ActorId;
                ce.Invoke_Trigger_To_Get_Comment__c = false;
                ce.Get_Latest_Approver_Comment__c = false;
            }
        }
    }
}