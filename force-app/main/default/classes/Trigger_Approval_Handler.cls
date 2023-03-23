/**
* @description : 
* @author : ChangeMeIn@UserSettingsUnder.SFDoc
* @group : 
* @last modified on : 03-13-2023
* @last modified by : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public With Sharing class Trigger_Approval_Handler {
    public static Map<Id,SBQQ__Quote__c> UpdateQuote = new Map<Id,SBQQ__Quote__c>();
    public static Map<Id,Quote_Extension__c> UpdateQuoteExtension = new Map<Id,Quote_Extension__c>();
    public static void populatePublicGroupMembers(List<sbaa__Approval__c> approvalList){ 
        List<Id> assignedGroupId = new List<Id>(); 
        Map<String,Set<string>> userGroupkeyMap = new Map<String,Set<string>>();
        Map<String, String> memberGroupMap = new Map<String, String>();
        for(sbaa__Approval__c objAppr: approvalList){
            if(objAppr.sbaa__AssignedGroupId__c != null){
                assignedGroupId.add(objAppr.sbaa__AssignedGroupId__c);
            }
        } 
        
        for(GroupMember grpMember : [SELECT Id,GroupId,UserOrGroupId FROM GroupMember 
                                     WHERE GroupId In:assignedGroupId with SECURITY_ENFORCED]){
                                         if(!userGroupkeyMap.containsKey(grpMember.UserOrGroupId)){
                                             userGroupkeyMap.put(grpMember.UserOrGroupId,new set<String>());
                                         }
                                         userGroupkeyMap.get(grpMember.UserOrGroupId).add(grpMember.GroupId+';'+grpMember.UserOrGroupId);
                                         
                                     }
        string groupId = null;
        for(User usr:[SELECT Id,FirstName,LastName FROM User WHERE Id IN:userGroupkeyMap.keySet() with SECURITY_ENFORCED]){
            for(String userGroupKey : userGroupkeyMap.get(usr.Id)){
                groupId = userGroupKey.split(';')[0];
                if(!memberGroupMap.containsKey(groupId)){
                    memberGroupMap.put(groupId, usr.FirstName +' '+ usr.LastName);
                }else{
                    memberGroupMap.put(groupId,memberGroupMap.get(groupId)+','+usr.FirstName +' '+ usr.LastName);
                }
            }
        }
        
        for(sbaa__Approval__c objAppr: approvalList){
            if(objAppr.sbaa__AssignedGroupId__c != null && memberGroupMap.containsKey(objAppr.sbaa__AssignedGroupId__c)){
                objAppr.Group_Members__c = memberGroupMap.get(objAppr.sbaa__AssignedGroupId__c);
            }
        }
        
    }
    public static void updatePreskuandFullskuFields(List<sbaa__Approval__c> approvalList, Map<Id, sbaa__Approval__c>oldApprovalLst){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> ruleIds = new Set<Id>();
        Set<Id> approvalIds = new Set<Id>();
        Map<Id,Opportunity> oppToUpdateMap = new Map<Id,Opportunity>();
        Map<Id, string> quoteToOpportunityIdMap = new Map<Id, string>(); 
        Map<string, string> pendingFullSkusForApproval = new Map<string, string>();
        Map<string, string> approvedFullSkus = new Map<string, string>();
        Map<string, string> pendingInternalRestrictedPreSKU = new Map<string, string>();
        Map<string, string> approvedInternalRestrictedPreSKUSku = new Map<string, string>();
        Map<string, string> opportunityApprovedSKu = new Map<string, string>();
        for(sbaa__Approval__c objApproval: approvalList){
            sbaa__Approval__c oldApproval = oldApprovalLst?.get(objApproval.Id);
            if(oldApproval != null && objApproval.sbaa__Status__c == 'Approved' && oldApproval.sbaa__Status__c != objApproval.sbaa__Status__c){
                quoteIds.add(objApproval.Quote__c);
                ruleIds.add(objApproval.sbaa__Rule__c);
                approvalIds.add(objApproval.Id);
            }
        }
        for(sbaa__Approval__c objApproval : [Select Id,sbaa__Rule__r.Name,Quote__c,Quote__r.Pending_FullSku_approval__c,Quote__r.Quote_Extension__c,Quote__r.Quote_Extension__r.Approved_FullSku__c, Quote__r.SBQQ__Opportunity2__c,Quote__r.SBQQ__Opportunity2__r.Approved_Product_Use_Case_Products__c, sbaa__Rule__r.PRE_SKU_Category__c,Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c,Quote__r.Pending_Deep_Discounting_Approval__c FROM sbaa__Approval__c WHERE Id IN : approvalIds]){
            if(objApproval.sbaa__Rule__r.PRE_SKU_Category__c != null){
                quoteToOpportunityIdMap = preSkuApproval(objApproval,quoteToOpportunityIdMap);
                opportunityApprovedSKu.put(objApproval.Quote__r.SBQQ__Opportunity2__c,objApproval.Quote__r.SBQQ__Opportunity2__r.Approved_Product_Use_Case_Products__c);
            } 
            else if(objApproval.sbaa__Rule__r.Name == 'Deep Discount Approval Rules for Full SKU'){
                if(!String.isEmpty(objApproval.Quote__r.Quote_Extension__r.Approved_FullSku__c)){
                    approvedFullSkus = (Map<string,string>)JSON.deserialize(objApproval.Quote__r.Quote_Extension__r.Approved_FullSku__c, Map<string,string>.class);
                }
                if(!String.isEmpty(objApproval.Quote__r.Pending_FullSku_approval__c)){
                    pendingFullSkusForApproval = (Map<string,string>)JSON.deserializeStrict(objApproval.Quote__r.Pending_FullSku_approval__c, Map<string,string>.class);
                    approvedFullSkus.putAll(pendingFullSkusForApproval);
                    fullSkuApproval(objApproval,approvedFullSkus,null);
                }
            }
            else if(objApproval.sbaa__Rule__r.Name == 'Deep discounting approval for Internal/Restricted/Pre-SKU'){
                if(!String.isEmpty(objApproval.Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c)){
                    approvedInternalRestrictedPreSKUSku = (Map<string,string>)JSON.deserialize(objApproval.Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c, Map<string,string>.class);
                }
                if(!String.isEmpty(objApproval.Quote__r.Pending_Deep_Discounting_Approval__c)){
                    pendingInternalRestrictedPreSKU = (Map<string,string>)JSON.deserializeStrict(objApproval.Quote__r.Pending_Deep_Discounting_Approval__c, Map<string,string>.class);
                    approvedInternalRestrictedPreSKUSku.putAll(pendingInternalRestrictedPreSKU);
                    fullSkuApproval(objApproval,null,approvedInternalRestrictedPreSKUSku);
                }
            }
        }
        
        
        if(!quoteToOpportunityIdMap.isempty()){
            for(String oppId:quoteToOpportunityIdMap.keySet()){
                Opportunity opp = new Opportunity(Id=oppId,Approved_Product_Use_Case_Products__c = opportunityApprovedSKu.get(oppId)!=null?opportunityApprovedSKu.get(oppId)+','+quoteToOpportunityIdMap.get(oppId):quoteToOpportunityIdMap.get(oppId));
                oppToUpdateMap.put(opp.id,opp);
            }
        }
        if(!oppToUpdateMap.isempty()){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update oppToUpdateMap.values();
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
        if(!UpdateQuoteExtension.isempty()){
            update UpdateQuoteExtension.values();
        }
        if(!UpdateQuote.isEmpty()){
            SBQQ.TriggerControl.disable();
            TriggerUtility.skipentireproposaltriggerExecuted(); 
            update UpdateQuote.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    private static Map<Id, string> preSkuApproval(sbaa__Approval__c objApproval,Map<Id, string> quoteToOpportunityIdMap){
        String oppId = objApproval.Quote__r.SBQQ__Opportunity2__c;
        if(String.isEmpty(objApproval.Quote__r.SBQQ__Opportunity2__r.Approved_Product_Use_Case_Products__c) || (!String.isEmpty(objApproval.Quote__r.SBQQ__Opportunity2__r.Approved_Product_Use_Case_Products__c) && !objApproval.Quote__r.SBQQ__Opportunity2__r.Approved_Product_Use_Case_Products__c.contains(objApproval.sbaa__Rule__r.PRE_SKU_Category__c))){
            if(!quoteToOpportunityIdMap.containsKey(oppId)){
                quoteToOpportunityIdMap.put(oppId,objApproval.sbaa__Rule__r.PRE_SKU_Category__c);
            }else{
                quoteToOpportunityIdMap.put(oppId,quoteToOpportunityIdMap.get(oppId)+','+objApproval.sbaa__Rule__r.PRE_SKU_Category__c);
            }
        }
        return quoteToOpportunityIdMap;
        
    }
    
    @testVisible
    private static void fullSkuApproval(sbaa__Approval__c objApproval, Map<string, string> approvedFullSkus,Map<string, string> approvedPreSkus){
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(Id=objApproval.Quote__c);
        if(UpdateQuote.containsKey(objApproval.Quote__c)){
          quoteRec = UpdateQuote.get(objApproval.Quote__c);
        }
        Quote_Extension__c quoteExt = new Quote_Extension__c(Id = objApproval.Quote__r.Quote_Extension__c);
        if(UpdateQuoteExtension.containsKey(objApproval.Quote__r.Quote_Extension__c)){
            quoteExt = UpdateQuoteExtension.get(objApproval.Quote__r.Quote_Extension__c);
        }
       
        if(approvedFullSkus!=null){
            quoteExt.Approved_FullSku__c = JSON.serialize(approvedFullSkus);
            quoteRec.Pending_FullSku_approval__c = null;
        }if(approvedPreSkus!=null){
            quoteExt.Approved_Internal_Restricted_Pre_SKU__c = JSON.serialize(approvedPreSkus);
            quoteRec.Pending_Deep_Discounting_Approval__c = null;
        }
        UpdateQuote.put(quoteRec.Id,quoteRec);
        UpdateQuoteExtension.put(quoteExt.Id,quoteExt);
    } 
}