global class Approval_Reassignment_Handler {
    
    public static boolean blnRunOnce = false;
    
    @InvocableMethod
    global static void reassignApproval(reassignApprovalInput[] inputs){  
        system.debug('inputs '+inputs); 
        
        Set<Id> approvalIds = new Set<Id>();       
        for(integer i=0;i<inputs.size();i++){
            approvalIds.add(inputs[i].approvalId);
        }
        system.debug('approvalIds '+approvalIds); 
        
        if(!System.isFuture() && !System.isBatch() && !blnRunOnce){
            blnRunOnce = true;
            reassignApprovalFuture(approvalIds,inputs[0].quoteId);
        }else if((System.isFuture() || System.isBatch()) && !blnRunOnce){
            reassignApprovalMain(approvalIds,inputs[0].quoteId);
        }
    }
    
    @future
    global static void reassignApprovalFuture(Set<Id> approvalIds, String quoteId){
        system.debug('inside future'); 
        reassignApprovalMain(approvalIds,quoteId);
    }
    
    
    global static void reassignApprovalMain(Set<Id> approvalIds, String quoteId){  
    	List<sbaa__Approval__c> updatedAppr = new List<sbaa__Approval__c>();        
        Map<String,Id> approversMapWithGroupId = new Map<String,Id>();
        Map<String,Id> approversWithOriginalApproverId = new Map<String,Id>();         
        Set<String> ApproversTobeUpdated = new Set<String>();
                
        for(Approvers_Group_reassignment_Mapping__mdt quoteMeta : [SELECT Id,MasterLabel,Approver_Group_Id__c,Original_Approver_Id__c 
                                                                   FROM Approvers_Group_reassignment_Mapping__mdt])
        {                                                             
            approversMapWithGroupId.put(quoteMeta.MasterLabel,quoteMeta.Approver_Group_Id__c);
            approversWithOriginalApproverId.put(quoteMeta.MasterLabel,quoteMeta.Original_Approver_Id__c);
        }
		system.debug('approversMapWithGroupId '+approversMapWithGroupId);
		system.debug('approversWithOriginalApproverId '+approversWithOriginalApproverId); 
        
        List<sbaa__Approval__c> approvalData = [SELECT id,Name,sbaa__AssignedTo__c,sbaa__Approver__r.sbaa__GroupId__c,
                                                sbaa__Approver__c,sbaa__Approver__r.Name,sbaa__AssignedGroupId__c,Quote__c
                                                FROM sbaa__Approval__c 
                                                WHERE Id IN:approvalIds];
        system.debug('approvalData before update '+approvalData);
        
        try{
            if(!approvalData.isEmpty()){
                for(sbaa__Approval__c objAppr: approvalData){
                    if(approversMapWithGroupId.containsKey(objAppr.sbaa__Approver__r.Name) && approversWithOriginalApproverId.containsKey(objAppr.sbaa__Approver__r.Name)){                   
                        objAppr.sbaa__AssignedGroupId__c = approversMapWithGroupId.get(objAppr.sbaa__Approver__r.Name);
                        objAppr.sbaa__Approver__c = approversWithOriginalApproverId.get(objAppr.sbaa__Approver__r.Name);
                        objAppr.sbaa__AssignedTo__c = null;
                        updatedAppr.add(objAppr);    
                    }                
                }
            }
            if(!updatedAppr.isEmpty()){
                UPDATE updatedAppr;
            }
        }
        catch(Exception e){
            system.debug('exception '+e);
        }

        system.debug('approvalData after update '+updatedAppr);
            
    }
    
     global class reassignApprovalInput {
        @InvocableVariable(required=true)
        global String approvalId;
        
        @InvocableVariable(required=true)
        global String quoteId;
    }

}