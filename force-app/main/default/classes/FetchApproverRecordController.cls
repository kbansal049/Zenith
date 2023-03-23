/**
 * @description       : 
 * @author            : Jade Global
 * @group             : 
 * @last modified on  : 11-10-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-09-2021   Jade Global   Initial Version
**/
public with sharing class FetchApproverRecordController {
    
    @AuraEnabled
    public static List<sbaa__Approval__c> itemsToApprove(){

        Set<String> GroupIdSet = new Set<String>();
        for(GroupMember gm : [SELECT GroupId,Id,UserOrGroupId,Group.Type
                            FROM GroupMember 
                            WHERE UserOrGroupId =: userinfo.getUserId() AND Group.Type = 'Regular']){
                            GroupIdSet.add(String.valueOf(gm.GroupId));
        }
        system.debug('grpId '+GroupIdSet);

        List<sbaa__Approval__c> approvalData = [SELECT id,Name,Quote__r.Name,Quote__r.SBQQ__Opportunity2__r.Name, 
                                                Quote__r.SBQQ__Opportunity2__r.CloseDate,Quote__r.TCV__c, 
                                                Quote__r.ACV_New__c,Quote_Number__c,Action__c, 
                                                Quote__r.SubmittedDate__c, Quote__r.Total_Discount__c,
                                                Quote__r.SBQQ__SubscriptionTerm__c,
                                                sbaa__AssignedTo__c,sbaa__Approver__r.sbaa__GroupId__c,
                                                Approval_Rule_Name__c,Opportunity_Name__c,
                                                Submitted_On__c,Quote__r.ACVHeader__c,
                                                sbaa__AssignedGroupId__c,sbaa__Approver__r.Name,
                                                Geo_Approval__c,User_Geo_Approval__c,
                                                Quote__r.SBQQ__Account__r.Sales_Territory__r.District__c,
                                                Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__r.Name,
                                                Quote__r.SBQQ__Opportunity2__c,Quote__r.SBQQ__Opportunity2__r.Owner.Name
                                                FROM sbaa__Approval__c 
                                                WHERE sbaa__Status__c ='Requested' and sbaa__Archived__c=false
                                                AND (sbaa__AssignedTo__c  =: userinfo.getUserId() OR sbaa__AssignedGroupId__c IN : GroupIdSet)
                                                ORDER BY Submitted_On__c DESC];

        system.debug('approvalData before update '+approvalData);
        system.debug('latestData## '+approvalData.size());
        
        return approvalData;
    }
    
}