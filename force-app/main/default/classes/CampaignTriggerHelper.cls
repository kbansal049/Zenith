/*****************************************************************************************
Name: CampaignTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Trigger helper class for CampaignTrigger.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Parth Doshi           2-Mar-2021    Initial Development CR# 1520
******************************************************************************************/
public class CampaignTriggerHelper{
    
    @future(callout=true)
    public static void updateRelatedLeads(Set<Id> newCampaignIds){
        TriggerUtility.afterUpdateRelatedLeadExecuted();
        Set<Id> leadIds = new Set<Id>();
        Map<Id, String> campaignMemberVsOutReachSequence = new Map<Id, String>();
        Map<Id, String> leadIdvsCampaignMemberId = new Map<Id, String>();
        if(!newCampaignIds.isEmpty()){
            List<CampaignMember> campaignMembers = [Select Id, LeadId, ContactId, Campaign.Recommended_Outreach_Sequence__c from CampaignMember where CampaignId in :newCampaignIds and (LeadId != null or ContactId != null)];
            for(CampaignMember campaignMember : campaignMembers){
                campaignMemberVsOutReachSequence.put(campaignMember.Id, campaignMember.Campaign.Recommended_Outreach_Sequence__c);
                if(campaignMember.LeadId != null){
                    leadIds.add(campaignMember.LeadId);
                    leadIdvsCampaignMemberId.put(campaignMember.LeadId, campaignMember.Id);
                }
            }
            
            if(!leadIds.isEmpty()){
                List<Lead> leads = [Select Id, Recommended_Outreach_Sequence__c from Lead where Id in :leadIds];
                List<Lead> leadsToUpdate = new List<Lead>();
                for(Lead l : leads){
                    if(campaignMemberVsOutReachSequence != null && leadIdvsCampaignMemberId != null && leadIdvsCampaignMemberId.containsKey(l.Id) && 
                        campaignMemberVsOutReachSequence.containsKey(leadIdvsCampaignMemberId.get(l.Id)) &&
                        l.Recommended_Outreach_Sequence__c != campaignMemberVsOutReachSequence.get(leadIdvsCampaignMemberId.get(l.Id))){
                        l.Recommended_Outreach_Sequence__c = campaignMemberVsOutReachSequence.get(leadIdvsCampaignMemberId.get(l.Id));
                        leadsToUpdate.add(l);
                    }
                }
                if(!leadsToUpdate.isEmpty()){
                    setTriggerUtilityFlags();
                    update leadsToUpdate;
                    resetTriggerUtilityFlags();
                }
            }
        }
    }
    
    @future(callout=true)
    public static void updateRelatedContacts(Set<Id> newCampaignIds){
        TriggerHandler.bypass('ContactTriggerHandler');
        Set<Id> contactIds = new Set<Id>();
        Map<Id, String> campaignMemberVsOutReachSequence = new Map<Id, String>();
        Map<Id, String> contactIdvsCampaignMemberId = new Map<Id, String>();
        if(!newCampaignIds.isEmpty()){
            List<CampaignMember> campaignMembers = [Select Id, LeadId, ContactId, Campaign.Recommended_Outreach_Sequence__c from CampaignMember where CampaignId in :newCampaignIds and (LeadId != null or ContactId != null)];
            for(CampaignMember campaignMember : campaignMembers){
                campaignMemberVsOutReachSequence.put(campaignMember.Id, campaignMember.Campaign.Recommended_Outreach_Sequence__c);
                if(campaignMember.ContactId != null){
                    contactIds.add(campaignMember.ContactId);
                    contactIdvsCampaignMemberId.put(campaignMember.ContactId, campaignMember.Id);
                }
            }
            
            if(!contactIds.isEmpty()){
                List<Contact> contacts = [Select Id, Recommended_Outreach_Sequence__c from Contact where Id in :contactIds];
                List<Contact> contactsToUpdate = new List<Contact>();
                for(Contact c : contacts){
                    if(campaignMemberVsOutReachSequence != null && contactIdvsCampaignMemberId != null && contactIdvsCampaignMemberId.containsKey(c.Id) &&
                        campaignMemberVsOutReachSequence.containsKey(contactIdvsCampaignMemberId.get(c.Id)) && 
                        c.Recommended_Outreach_Sequence__c != campaignMemberVsOutReachSequence.get(contactIdvsCampaignMemberId.get(c.Id))){
                        c.Recommended_Outreach_Sequence__c = campaignMemberVsOutReachSequence.get(contactIdvsCampaignMemberId.get(c.Id));
                        contactsToUpdate.add(c);
                    }
                }
                if(!contactsToUpdate.isEmpty()){
                    setTriggerUtilityFlags();
                    update contactsToUpdate;
                    resetTriggerUtilityFlags();
                }
            }
        }
    }
    
    public static void setTriggerUtilityFlags(){
        TriggerUtility.updateLeadNoOfEmployeesExecuted();
        TriggerUtility.updateContactLeadStageExecuted();
        TriggerUtility.updateLeadSalesTeamEmailFieldsExecuted();
        TriggerUtility.updateLeadContactForCampExecuted();
        TriggerUtility.ActivityleadterritoryinsertExecuted();
        TriggerUtility.ActivityleadterritoryupdateExecuted();
        TriggerUtility.ActivityleadterritoryEventinsertExecuted();
        TriggerUtility.ActivityleadterritoryEventupdateExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.UpdatingMarketsegmentforLeadsettrue();
        TriggerUtility.leadtaskFieldUpdateExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        leadTriggerHelper.skipTrigger = TRUE;
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerUtility.realignPatch();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
        TriggerUtility2.updateTouchesSinceLastOpenExecuted();
        TriggerUtility.contaskFieldUpdateExecuted();
    }
    
    public static void resetTriggerUtilityFlags(){
        TriggerUtility.updateLeadNoOfEmployeesReset();
        TriggerUtility.updateContactLeadStageReset();
        TriggerUtility.updateLeadSalesTeamEmailFieldsReset();
        TriggerUtility.updateLeadContactForCampReset();
        TriggerUtility.isActivityleadterritoryinsertReset();
        TriggerUtility.isActivityleadterritoryupdateReset();
        TriggerUtility.isActivityleadterritoryEventinsertReset();
        TriggerUtility.isActivityleadterritoryEventupdateReset();
        TriggerUtility.caseCreationForLeadTerrirtoryReset();
        TriggerUtility.UpdatingMarketsegmentforLeadsetfalse();
        TriggerUtility.leadtaskFieldUpdateReset();
        TriggerUtility.contactPatchManagerReset();
        leadTriggerHelper.skipTrigger = FALSE;
        TriggerHandler.clearBypass('ContactTriggerHandler');
        TriggerUtility.realignPatchReset();
        TriggerUtility.contactOwnerShipReset();
        TriggerUtility.AutocreateZCloudIDcontactUpdatesetfalse();
        TriggerUtility2.updateTouchesSinceLastOpenReset();
        TriggerUtility.contaskFieldUpdateReset();
    }
    
}