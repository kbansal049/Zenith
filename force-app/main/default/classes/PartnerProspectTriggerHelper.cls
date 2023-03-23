/**
* @File Name          : PartnerProspectTriggerHelper.cls
* @TestClass          : PartnerProspectTriggerTest
*==============================================================================
* Ver         Date                     Author                    Modification
* 1.0         2023-01-05               Swathi                    Initialized
*==============================================================================
**/
public without sharing class PartnerProspectTriggerHelper {
    public static Id resellerRecTypeId = Schema.SObjectType.Partner_Prospect__c.getRecordTypeInfosByDeveloperName().get('Reseller').getRecordTypeId();
    
    public static void onBeforeInsert(list<Partner_Prospect__c> newPPList){
        system.debug('--PartnerProspectTriggerHelper--onBeforeInsert--');
        populateDefaultValues(newPPList);
        populateRegionAndSalesTerritory(newPPList);
    }
    
    public static void onBeforeUpdate(MAP<Id,Partner_Prospect__c> oldMap, list<Partner_Prospect__c> newPPList){
        system.debug('--PartnerProspectTriggerHelper--onBeforeUpdate--');
        checkDRamApprovalValidation(oldMap, newPPList);
        onUpdateOfSalesTerritory(oldMap,newPPList); //IBA-7069
    }
    
    
    public static void onAfterupdate(map<ID, Partner_Prospect__c> newMap, map<ID, Partner_Prospect__c> oldMap){
        System.debug('--PartnerProspectTriggerHelper--onAfterupdate--');
        
        List<Partner_Prospect__c> pPUpdateList = new List<Partner_Prospect__c>();
        // added a list for recalling approval process in first D-RAM Approval If partner tier is updated to Zenith
        List<Partner_Prospect__c> pPRecallApprovalList = new List<Partner_Prospect__c>();
        
        for(Partner_Prospect__c newPP : newMap.values()){
            Partner_Prospect__c oldPP = oldMap.get(newPP.Id);
            if(newPP.Application_Status__c != oldPP.Application_Status__c && newPP.Application_Status__c == 'Approved' && newPP.Partner_Account__c == null){
                pPUpdateList.add(newPP);
            }
            //Adding condition to update the list for recalling approval process in first D-RAM Approval If partner tier is updated to Zenith
            if(newPP.Approval_Status__c == 'D-RAM Approval Submitted' &&
               newPP.Partner_Tier__c == 'Zenith' && newPP.Partner_Tier__c != oldPP.Partner_Tier__c)
            {
                pPRecallApprovalList.add(newPP);
            }
        }
        System.debug('--pPUpdateList--'+pPUpdateList);
        if(!pPUpdateList.IsEmpty()){
            PartnerOnboardingUtility.createPartnerAccount(pPUpdateList);
        }
        System.debug('--pPRecallApprovalList--'+pPRecallApprovalList);
        if(!pPRecallApprovalList.IsEmpty()){
            //PartnerOnboardingUtility.recallApproval(pPRecallApprovalList);
            //Update approval Status - First D RamCOmpleted
        }
    }
    
    
    @testvisible
    private static void populateDefaultValues(List<Partner_Prospect__c> ppList){
        for(Partner_Prospect__c ppRecord : ppList){
            if(ppRecord.Source__c == 'Long Form'){
                ppRecord.RecordTypeId = resellerRecTypeId;
                if(PartnerOnboardingUtility.defaultLongFormMappingMdtList.size() >= 1){
                    for(Generic_Field_Mapping_Default_Value__mdt genericMDT : PartnerOnboardingUtility.defaultLongFormMappingMdtList) {
                        PartnerOnboardingUtility.preparePartnerProspectRecord(ppRecord, genericMDT);
                    }
                }
            }
        }
    }
    
    @testvisible
    private static void populateRegionAndSalesTerritory(List<Partner_Prospect__c> newPPRecordsList){
        List<Partner_Prospect_Approval_Fields__mdt> PPApprovalFields = new List<Partner_Prospect_Approval_Fields__mdt>();
        
        Set<String> newRecordsCountrySet = new Set<String>();
        Set<Partner_Prospect__c> ppSetToUpdate = new Set<Partner_Prospect__c>();
        Set<String> salesTerritoryMetadataSet = new Set<String>();
        
        for(Partner_Prospect__c ppt : newPPRecordsList){
            if(ppt.Country__c != null){
                newRecordsCountrySet.add(ppt.Country__c);
            }
        }
        
        PPApprovalFields = [SELECT Id, DeveloperName, MasterLabel, Country__c, Require_DD__c, Sales_Terittory__c, State__c FROM Partner_Prospect_Approval_Fields__mdt Where Country__c IN :newRecordsCountrySet];
        for(Partner_Prospect_Approval_Fields__mdt ppAF : PPApprovalFields){
            salesTerritoryMetadataSet.add(ppAF.Sales_Terittory__c);
        }
        
        MAP<String, PatchTeam__c> salesTerritoryMAP = new MAP<String,PatchTeam__c>();
        for(PatchTeam__c salesTerritory : [SELECT Id, Name, Account_Manager__c, Channel_Manager__c 
                                           FROM PatchTeam__c WHERE Name IN :salesTerritoryMetadataSet])
        {
            salesTerritoryMAP.put(salesTerritory.Name, salesTerritory);
        }
        System.debug('--PartnerProspectTriggerHelper--salesTerritoryMAP--'+salesTerritoryMAP);
        
        for(Partner_Prospect__c pp : newPPRecordsList){
            for(Partner_Prospect_Approval_Fields__mdt ppAF : PPApprovalFields){
                if(salesTerritoryMAP.containskey(ppAF.Sales_Terittory__c)){
                    if(pp.Country__c == ppAF.Country__c && pp.Country__c != 'United States'){
                        pp.Require_DD__c = ppAf.Require_DD__c;
                        pp.Sales_Territory__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Id;
                        pp.Account_Manager__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Account_Manager__c;
                        pp.Sales_Territory_RAM__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Channel_Manager__c;
                    }
                    else if (pp.Country__c == ppAF.Country__c && pp.Country__c == 'United States' && pp.State_Province__c == ppAF.State__c) {
                        pp.Require_DD__c = ppAf.Require_DD__c;
                        pp.Sales_Territory__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Id;
                        pp.Account_Manager__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Account_Manager__c;
                        pp.Sales_Territory_RAM__c = salesTerritoryMAP.get(ppAF.Sales_Terittory__c).Channel_Manager__c;
                    }
                }
            }
        }
    }
    
    //IBA-5717 : Validation for Approval Process
    public static void checkDRamApprovalValidation(Map<Id,Partner_Prospect__c> oldMap, List<Partner_Prospect__c> newList){
        for(Partner_Prospect__c pp : newList){
            if(((pp.Approval_Status__c == 'D-RAM First Approval Completed' && pp.Approval_Status__c != 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Partner_Level__c == 'Tier 2') || 
                (pp.Approval_Status__c == 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Partner_Level__c == 'Tier 2') || 
                (pp.Approval_Status__c == 'Secondary D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Partner_Level__c == 'Tier 2')) && 
               pp.Distributor_Name__c == Null)
            {
                pp.addError(System.Label.Distributor_and_Sell_to_territory_Validation_message);
                continue;
            }
            
            if(((pp.Approval_Status__c == 'D-RAM First Approval Completed' && pp.Approval_Status__c != 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Sell_To_Territory__c == Null) ||
                (pp.Approval_Status__c == 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Sell_To_Territory__c == Null) || 
                (pp.Approval_Status__c == 'Secondary D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c)) && pp.Sell_To_Territory__c == Null)
            {
                pp.addError(System.Label.Sell_to_territory_validation_for_partner_prospect);
                continue;
            }
            
            if(((pp.Approval_Status__c == 'D-RAM First Approval Completed' && pp.Approval_Status__c != 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Terms_and_Conditions_Agreed__c == False) ||
                (pp.Approval_Status__c == 'D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && pp.Terms_and_Conditions_Agreed__c == False) || 
                (pp.Approval_Status__c == 'Secondary D-RAM Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c)) && pp.Terms_and_Conditions_Agreed__c == False)
            {
                pp.addError(System.Label.Terms_and_Condition_validation_for_partner_prospect);
                continue;
            }
            
            if(pp.Application_Status__c == 'Rejected' && pp.Application_Status__c != oldMap.get(pp.Id).Application_Status__c && (pp.Rejection_Comments__c == Null || pp.Rejection_Reason__c == Null)){
                pp.addError(System.Label.Rejection_Reason_Comments_validation_for_Partner_Prospect);
                continue;
            }
            
            if(pp.Approval_Status__c == 'Channel Ops Approval Completed' && pp.Approval_Status__c != oldMap.get(pp.Id).Approval_Status__c && (pp.Anti_Bribery_Certification_Signed_Date__c == Null || pp.Anti_Bribery_Questionnaire_Signed_Date__c == Null)){
                pp.addError(System.Label.Anti_bribery_fields_validation_for_Partner_Prospect);
                continue;
            }
        }
    }
    
    
    //IBA-7069 : 
    @testVisible
    private static void onUpdateOfSalesTerritory(MAP<ID,Partner_Prospect__c> oldMAP, List<Partner_Prospect__c> ppRecList){
        Set<ID> salesTerritoryID = new Set<ID>();
        MAP<ID, Partner_Prospect__c> salesTrChanged = new MAP<ID, Partner_Prospect__c>();
        for(Partner_Prospect__c pp : ppRecList){
            if(pp.Sales_Territory__c !=null && pp.Sales_Territory__c != oldMAP.get(pp.Id).Sales_Territory__c){
            	salesTrChanged.put(pp.Id, pp);
                salesTerritoryID.add(pp.Sales_Territory__c);
            }
        }
        System.debug('--PartnerProspectTriggerHelper--salesTerritoryID--'+salesTerritoryID);
            
        if(!salesTerritoryID.isEmpty()){
            MAP<ID, PatchTeam__c> salesTerritoryMAP = new MAP<ID,PatchTeam__c>([SELECT Id, Name,
                                                                                Account_Manager__c, Channel_Manager__c 
                                                                                FROM PatchTeam__c WHERE Id IN :salesTerritoryID]);
            
            System.debug('--PartnerProspectTriggerHelper--salesTerritoryMAP--'+salesTerritoryMAP);
            
            for(Partner_Prospect__c pp : salesTrChanged.values()){
                if(pp.Sales_Territory__c != null && salesTerritoryMAP.containskey(pp.Sales_Territory__c)){
                    PatchTeam__c pTeam =  salesTerritoryMAP.get(pp.Sales_Territory__c);
                    //pp.Require_DD__c = pTeam.Require_DD__c;
                    pp.Account_Manager__c = pTeam.Account_Manager__c;
                    pp.Sales_Territory_RAM__c = pTeam.Channel_Manager__c;
                }
            }
        }
    }
    
}