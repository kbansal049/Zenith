public class FundRequestServiceLayer {
    
    public class FundRequestServiceLayerException extends Exception {
    }
    
    //Set dummy allocation record on insert of fund request, to by-pass system validations on Approval process
    public void setAllocationRecordOnFundRequest(List<PartnerFundRequest> triggerNew, Map<Id, PartnerFundRequest> triggerMapOld){
        
        List<PartnerFundAllocation> fundAllocationList = new List<PartnerFundAllocation>();
        Map<Id,PartnerFundRequest> channelPartnerIdPartnerFundReqMap = new Map<Id,PartnerFundRequest>();//change it to Set<Id>
        Map<Id,PartnerFundAllocation> channelPartnerIdPartnerFundAllocMap = new Map<Id,PartnerFundAllocation>();
        
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if(String.isNotBlank(fundReqRecord.ChannelPartnerId) && fundReqRecord.CoOp_Status__c == 'Submitted' &&
              triggerMapOld.get(fundReqRecord.Id).CoOp_Status__c == 'Pending Submission'){
                channelPartnerIdPartnerFundReqMap.put(fundReqRecord.ChannelPartnerId,fundReqRecord);
            }            
        }
        if(!channelPartnerIdPartnerFundReqMap.isEmpty()){
            fundAllocationList = [SELECT Id, BudgetId, ChannelPartnerId, Amount 
                                  FROM PartnerFundAllocation
                                  WHERE ChannelPartnerId IN : channelPartnerIdPartnerFundReqMap.keySet()];
            if(!fundAllocationList.isEmpty()){
                for(PartnerFundAllocation fundAllocRecord : fundAllocationList){
                    channelPartnerIdPartnerFundAllocMap.put(fundAllocRecord.ChannelPartnerId,fundAllocRecord);
                }                
            } else {//create PartnerFundAllocation record
                channelPartnerIdPartnerFundAllocMap = createPartnerFundAllocation(channelPartnerIdPartnerFundReqMap.keySet());
            }
        }
        if(!channelPartnerIdPartnerFundAllocMap.isEmpty()){
            for(PartnerFundRequest fundReqRecord : triggerNew){
                if(String.isBlank(fundReqRecord.AllocationId)){
                    fundReqRecord.AllocationId = channelPartnerIdPartnerFundAllocMap.get(fundReqRecord.ChannelPartnerId).Id;
                    System.debug('fundReqRecord.AllocationId : ' + fundReqRecord.AllocationId);
                }            
            }
        }        
    }
    
    //create PartnerFundAllocation record
    private Map<Id,PartnerFundAllocation> createPartnerFundAllocation(Set<Id> channelPartnerIdSet){
        
        Map<Id,PartnerFundAllocation> channelPartnerIdPartnerFundAllocMap = new Map<Id,PartnerFundAllocation>();
        List<PartnerFundAllocation> fundAllocationRecordsToCreate = new List<PartnerFundAllocation>();
        
        Map<Id,Account> partnerAccountMap = new Map<Id,Account>([SELECT Id,Name 
                                                                 FROM Account 
                                                                 WHERE Id IN : channelPartnerIdSet]);
        Map<Id,PartnerMarketingBudget> partnerIdmarketingBudgetMap = getPartnerMarketingBudget(channelPartnerIdSet,partnerAccountMap);
                
        for(Id partnerId : channelPartnerIdSet){
            PartnerFundAllocation fundAllocation = new PartnerFundAllocation();
            fundAllocation.Title = partnerAccountMap.get(partnerId).Name + ' Fund Allocation';
            fundAllocation.ChannelPartnerId = partnerId;
            fundAllocation.Amount = partnerIdmarketingBudgetMap.isEmpty() ? NULL : partnerIdmarketingBudgetMap.get(partnerId).Amount;
            fundAllocation.BudgetId = partnerIdmarketingBudgetMap.isEmpty() ? NULL : partnerIdmarketingBudgetMap.get(partnerId).Id;
            
            fundAllocationRecordsToCreate.add(fundAllocation);
        }
        Set<Id> newPartnerFundAllocationIdSet = new Set<Id>();
        Database.SaveResult[] srList = Database.insert(fundAllocationRecordsToCreate, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted PartnerFundAllocation. ID: ' + sr.getId());
                newPartnerFundAllocationIdSet.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('PartnerFundAllocation fields that affected this error: ' + err.getFields());
                }
            }
        }
        List<PartnerFundAllocation> newPartnerFundAllocationList = [SELECT Id,ChannelPartnerId,
                                                                    Title,Amount,BudgetId
                                                                    FROM PartnerFundAllocation 
                                                                    WHERE ChannelPartnerId IN : channelPartnerIdSet];
        if(!newPartnerFundAllocationList.isEmpty()){
            for(PartnerFundAllocation fundAllocation : newPartnerFundAllocationList){
                channelPartnerIdPartnerFundAllocMap.put(fundAllocation.ChannelPartnerId,fundAllocation);
            }
        }
        
        return channelPartnerIdPartnerFundAllocMap;
    }
    
    //get PartnerMarketingBudget record
    private Map<Id,PartnerMarketingBudget> getPartnerMarketingBudget(Set<Id> channelPartnerIdSet, Map<Id,Account> partnerAccountMap){
        Map<Id,PartnerMarketingBudget> channelPartnerIdPartnerMarketingBudgetMap = new Map<Id,PartnerMarketingBudget>();
        List<PartnerMarketingBudget> partnerMarketingBudgetList = [SELECT Id,ChannelPartnerId,ParentMdfBudgetId,
                                                                   Title,Amount,Type
                                                                   FROM PartnerMarketingBudget 
                                                                   WHERE ChannelPartnerId IN : channelPartnerIdSet];
        
        if(!partnerMarketingBudgetList.isEmpty()){
            for(PartnerMarketingBudget budget : partnerMarketingBudgetList){
                channelPartnerIdPartnerMarketingBudgetMap.put(budget.ChannelPartnerId,budget);
            }
        }else { //create budget record
            channelPartnerIdPartnerMarketingBudgetMap = createPartnerMarketingBudget(channelPartnerIdSet, partnerAccountMap);
        }
        return channelPartnerIdPartnerMarketingBudgetMap;
    }
    
    //create PartnerMarketingBudget record
    private Map<Id,PartnerMarketingBudget> createPartnerMarketingBudget(Set<Id> channelPartnerIdSet, Map<Id,Account> partnerAccountMap){
        
        Map<Id,PartnerMarketingBudget> channelPartnerIdPartnerMarketingBudgetMap = new Map<Id,PartnerMarketingBudget>();
        List<PartnerMarketingBudget> budgetRecordsToCreate = new List<PartnerMarketingBudget>();
        for(Id partnerId : channelPartnerIdSet){
            PartnerMarketingBudget budget = new PartnerMarketingBudget();
            budget.Title = partnerAccountMap.get(partnerId).Name + ' Marketing Budget';
            budget.ChannelPartnerId = partnerId;
            budget.Amount = 99999999999999.99;
            budget.Type = 'Marketing Funds';
            
            budgetRecordsToCreate.add(budget);
        }           
        Set<Id> newPartnerMarketingBudgetIdSet = new Set<Id>();
        Database.SaveResult[] srList = Database.insert(budgetRecordsToCreate, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted PartnerMarketingBudget. ID: ' + sr.getId());
                newPartnerMarketingBudgetIdSet.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('PartnerMarketingBudget fields that affected this error: ' + err.getFields());
                }
            }
        }
        List<PartnerMarketingBudget> newPartnerMarketingBudgetList = [SELECT Id,ChannelPartnerId,ParentMdfBudgetId,
                                                                      Title,Amount,Type
                                                                      FROM PartnerMarketingBudget 
                                                                      WHERE ChannelPartnerId IN : channelPartnerIdSet];
        if(!newPartnerMarketingBudgetList.isEmpty()){
            for(PartnerMarketingBudget budget : newPartnerMarketingBudgetList){
                channelPartnerIdPartnerMarketingBudgetMap.put(budget.ChannelPartnerId,budget);
            }
        }
        return channelPartnerIdPartnerMarketingBudgetMap;
    }
    
    //We need to set Amount, PartnerAccount fields with RequestedAmount, ChannelPartnerId for Approval process validation
    public void setFundRequestFieldValues(List<PartnerFundRequest> triggerNew){        
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if(String.isNotBlank(fundReqRecord.ChannelPartnerId)){
                fundReqRecord.Partner_Account__c = fundReqRecord.ChannelPartnerId;
            }
            if(fundReqRecord.RequestedAmount != NULL){
                fundReqRecord.Amount = fundReqRecord.RequestedAmount;
            }            
        }
    }    
    
    //Check for Approval process approve field validation, PO Number, Amount Approved, Campaign
    public void approvalFieldValidation(List<PartnerFundRequest> triggerNew, Map<Id, PartnerFundRequest> triggerMapOld){
        Map<Id, PartnerFundRequest> approvedFundRequests = new Map<Id, PartnerFundRequest>();
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if(triggerMapOld.get(fundReqRecord.Id).CoOp_Status__c != 'Pre-Approved' && 
               fundReqRecord.CoOp_Status__c == 'Pre-Approved'){
                   String emptyFields = '';
                   if(String.isBlank(fundReqRecord.PO_Number__c)){
                       emptyFields = fundReqRecord.PO_Number__c == NULL ? 'PO Number' : '';
                   }
                   if(String.isBlank(fundReqRecord.CampaignId)){
                       emptyFields += String.isNotBlank(emptyFields) == TRUE ? ', ' : '';
                       emptyFields += fundReqRecord.CampaignId == NULL ? 'Campaign Name' : '';
                   }
                   /*if(fundReqRecord.Amount_Approved__c == NULL){
                       emptyFields += String.isNotBlank(emptyFields) == TRUE ? ', ' : '';
                       emptyFields += fundReqRecord.Amount_Approved__c == NULL ? 'Amount Approved' : '' ;
                   }*/
                   if(String.isNotBlank(emptyFields)){
                       fundReqRecord.addError('Approval Process Error - Required fields are missing : ' + emptyFields);
                   }
                   approvedFundRequests.put(fundReqRecord.Id,fundReqRecord);
               }
        }        
        
        if(!approvedFundRequests.isEmpty()){
            Set<Id> processInstanceIds = new Set<Id>();
            //Get the most recent approval process instance for the object.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            for (PartnerFundRequest fundReqRecs : [SELECT (SELECT ID
                                                           FROM ProcessInstances
                                                           ORDER BY CreatedDate DESC
                                                           LIMIT 1)
                                                   FROM PartnerFundRequest
                                                   WHERE ID IN :approvedFundRequests.keySet()])
            {
                processInstanceIds.add(fundReqRecs.ProcessInstances[0].Id);
            }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments. 
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds
                                       ORDER BY CreatedDate DESC])   
            {
                if (pi.Steps[0].Comments != NULL)
                {
                    if(String.isNotBlank(approvedFundRequests.get(pi.TargetObjectId).Comments__c) && 
                       pi.Steps[0].StepStatus != 'Approved'){
                           approvedFundRequests.get(pi.TargetObjectId).Comments__c += ', ' + pi.Steps[0].Comments.trim();
                       }else {
                           approvedFundRequests.get(pi.TargetObjectId).Comments__c = pi.Steps[0].Comments.trim();
                       }
                }
            } 
        }        
    }
    
    //Check for Approval process reject field validation, Comments
    public void rejectionFieldValidation(List<PartnerFundRequest> triggerNew, Map<Id, PartnerFundRequest> triggerMapOld){
        Map<Id, PartnerFundRequest> rejectedFundRequests = new Map<Id, PartnerFundRequest>();
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if(triggerMapOld.get(fundReqRecord.Id).CoOp_Status__c != 'Rejected/Denied' && 
               fundReqRecord.CoOp_Status__c == 'Rejected/Denied'){
                   rejectedFundRequests.put(fundReqRecord.Id,fundReqRecord);
               }
        }
        
        if(!rejectedFundRequests.isEmpty()){
            Set<Id> processInstanceIds = new Set<Id>();
            //Get the most recent approval process instance for the object.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            for (PartnerFundRequest fundReqRecs : [SELECT (SELECT ID
                                                           FROM ProcessInstances
                                                           ORDER BY CreatedDate DESC
                                                           LIMIT 1)
                                                   FROM PartnerFundRequest
                                                   WHERE ID IN :rejectedFundRequests.keySet()])
            {
                processInstanceIds.add(fundReqRecs.ProcessInstances[0].Id);
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
                if(!pi.Steps.isEmpty() && rejectedFundRequests.containsKey(pi.TargetObjectId)){
                    if (String.isBlank(pi.Steps[0].Comments) &&
                        String.isBlank(rejectedFundRequests.get(pi.TargetObjectId).Comments__c))
                    {
                        rejectedFundRequests.get(pi.TargetObjectId).addError(
                            'Approval Process Error : Please provide Rejection Comment');
                    }else {
                        if(String.isNotBlank(rejectedFundRequests.get(pi.TargetObjectId).Comments__c) && 
                           String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedFundRequests.get(pi.TargetObjectId).Comments__c += ', ' + pi.Steps[0].Comments.trim();
                           }else if(String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedFundRequests.get(pi.TargetObjectId).Comments__c = pi.Steps[0].Comments.trim();
                           }
                    }
                    System.debug('rejectedFundRequests.get(pi.TargetObjectId) : ' + rejectedFundRequests.get(pi.TargetObjectId));
                }                
            }            
        }
    }
    
    //
    public void reEvaluateStatusChangeFundRequests(List<PartnerFundRequest> triggerNew, Map<Id, PartnerFundRequest> triggerMapOld){
        Map<Id, PartnerFundRequest> expiredFundRequestsWithPOList = new Map<Id, PartnerFundRequest>();
        Map<Id, PartnerFundRequest> expiredFundRequestsWithoutPOList = new Map<Id, PartnerFundRequest>();
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if((triggerMapOld.get(fundReqRecord.Id).CoOp_Status__c != 'Expired' ||
               triggerMapOld.get(fundReqRecord.Id).CoOp_Status__c != 'Rejected/Denied' )&& 
               fundReqRecord.CoOp_Status__c == 'Pending Submission'){
                   if(String.isNotBlank(fundReqRecord.PO_Number__c)){
                      fundReqRecord.CoOp_Status__c = 'Pre-Approved';
                   } else {
                      fundReqRecord.CoOp_Status__c = 'Pending Submission';
                   }
                   
               }
        }
    }
    
    //Amount Requested (US$) and Lead follow up cannot be edited by an User
    public void customFieldValidations(List<PartnerFundRequest> triggerNew, Map<Id, PartnerFundRequest> triggerMapOld){
        for(PartnerFundRequest fundReqRecord : triggerNew){
            if(triggerMapOld.get(fundReqRecord.Id).RequestedAmount != fundReqRecord.RequestedAmount){
                fundReqRecord.addError('Requested Amount cannot be edited');
            }
            if(triggerMapOld.get(fundReqRecord.Id).Lead_Follow_Up__c != fundReqRecord.Lead_Follow_Up__c){
                fundReqRecord.addError('Lead Follow Up cannot be edited');
            }
        }
    }
    
}