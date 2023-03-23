/*****************************************************************************************
Name: OpportunitySplitTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Handler class for opportunity split trigger.

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            5-April-2015    Initial Development
2.0            Swathi               17-06-2022      CR# 4867 and CR# 4868
******************************************************************************************/

Public class OpportunitySplitTriggerHelper{
    
    public static void afterUpdateOppSplit(){
        if(Trigger.isUpdate && trigger.isAfter){
            if(!system.isFuture() && !system.isBatch()){
                
                updateOppForSplit();
                set<id> oppIdSet = new set<Id>();
                for(OpportunitySplit oppSplit : (List<OpportunitySplit>)trigger.new ){
                    if(oppSplit.SplitPercentage != ((Map<Id, OpportunitySplit>)trigger.oldMap).get(oppSplit.Id).SplitPercentage ||
                       oppSplit.SplitOwner != ((Map<Id, OpportunitySplit>)trigger.oldMap).get(oppSplit.Id).SplitOwner||
                       oppSplit.Split_Type__c != ((Map<Id, OpportunitySplit>)trigger.oldMap).get(oppSplit.Id).Split_Type__c ){
                           oppIdSet.add(oppSplit.OpportunityId);
                       }
                }
                trackOppSplitHistory(oppIdSet);
                TriggerUtility.isOpportunitySplitsAfterUpdateExecuted();
            }
        }
    }
    
    public static void updateOppForSplit(){
        set<id> oppIdSet = new set<Id>();
        for(OpportunitySplit oppSplit : (List<OpportunitySplit>)trigger.new ){
            if(oppSplit.SplitPercentage != ((Map<Id, OpportunitySplit>)trigger.oldMap).get(oppSplit.Id).SplitPercentage
               || oppSplit.Split_Type__c != ((Map<Id, OpportunitySplit>)trigger.oldMap).get(oppSplit.Id).Split_Type__c){
                   if(oppSplit.SplitPercentage == 100)
                       oppIdSet.add(oppSplit.OpportunityId);
                   if(oppSplit.SplitPercentage < 100)
                       oppIdSet.add(oppSplit.OpportunityId);
               }
        }
        updateOpportunity(oppIdSet);
    }
    @future(callout=true)
    public static void updateOpportunity(set<Id> oppIdSet){
        Map<Id, Opportunity> oppUpdateMap = new Map<Id, Opportunity>();
        for(Opportunity opp : [Select id, Split__c, Type, Has_Multiple_Upsell_Split_Lines__c, (Select id, SplitPercentage, Split_Type__c from OpportunitySplits) from Opportunity Where Id IN: oppIdSet]){
            if(opp.OpportunitySplits.Size() > 1 && opp.Split__c == false)
                oppUpdateMap.put(Opp.Id, new opportunity(Id = Opp.id, Split__c = true));
            if(opp.OpportunitySplits.Size() < 2 && opp.Split__c == true)
                oppUpdateMap.put(Opp.Id, new opportunity(Id = Opp.id, Split__c = false));
            
            if (oppUpdateMap.containsKey(opp.Id)) {
                oppUpdateMap.get(Opp.Id).Total_Upsell_Split_Percent__c = 0.0;
                oppUpdateMap.get(Opp.Id).Number_Of_Upsell_Split_Lines__c = 0;
            } else {
                oppUpdateMap.put(opp.Id, new Opportunity(Id = opp.Id, Total_Upsell_Split_Percent__c = 0.0, Number_Of_Upsell_Split_Lines__c = 0));
            }
            
            for (OpportunitySplit split : Opp.OpportunitySplits) {
                if (split.Split_Type__c == 'Upsell') {
                    oppUpdateMap.get(Opp.Id).Number_Of_Upsell_Split_Lines__c = oppUpdateMap.get(Opp.Id).Number_Of_Upsell_Split_Lines__c + 1;
                    oppUpdateMap.get(Opp.Id).Total_Upsell_Split_Percent__c += split.SplitPercentage;
                }
            }
            
            if (opp.Type == 'Existing Customer (Renewal)') {
                Boolean hasMultipleUpsellSplits = false;
                Integer upsellSplitCounter = 0;
                for (OpportunitySplit split : opp.OpportunitySplits) {
                    if (split.Split_Type__c == 'Upsell') {
                        upsellSplitCounter++;
                    }
                    
                    if (upsellSplitCounter > 1 && opp.Has_Multiple_Upsell_Split_Lines__c != true) {
                        if (oppUpdateMap.containsKey(opp.Id)) {
                            oppUpdateMap.get(opp.Id).Has_Multiple_Upsell_Split_Lines__c = true;
                        } else {
                            oppUpdateMap.put(opp.Id, new Opportunity(Id=opp.Id, Has_Multiple_Upsell_Split_Lines__c = true));
                        }
                        break;
                    }
                }
                
                if (upsellSplitCounter <= 1 && opp.Has_Multiple_Upsell_Split_Lines__c == true) {
                    if (oppUpdateMap.containsKey(opp.Id)) {
                        oppUpdateMap.get(opp.Id).Has_Multiple_Upsell_Split_Lines__c = false;
                    } else {
                        oppUpdateMap.put(opp.Id, new Opportunity(Id=opp.Id, Has_Multiple_Upsell_Split_Lines__c = false));
                    }
                }
            }
        }
        System.debug('>>>> ' + JSON.serialize(oppUpdateMap.values()));
        database.update(oppUpdateMap.values(), false);
        
    }
    @future(callout=true)
    public Static void trackOppSplitHistory(set<id> oppIdSet){
        list<Split_History__c> splitHistoryInsertList = new list<Split_History__c>();
        
        for(OpportunitySplit oppSplit : [Select id, SplitOwnerId, Amount__c, SplitPercentage, Split_Type__c, OpportunityId from OpportunitySplit where opportunityId IN: oppIdSet]){
            splitHistoryInsertList.add(new Split_History__c(Split_Id__c = oppSplit.Id, Opportunity__c =oppSplit.OpportunityId , Split_Amount__c =oppSplit.Amount__c, Split_Owner__c =oppSplit.SplitOwnerId, Split_Percentage__c = oppSplit.SplitPercentage, Split_Type__c = oppSplit.Split_Type__c));
        }
        
        if(!splitHistoryInsertList.isEmpty())
            database.insert(splitHistoryInsertList,false);
        
    }
    
    public static void beforeInsertSplit(list<OpportunitySplit> newOppSplitList){
        set<Id> userIdSet = new set<Id>();
        map<Id, Id> territoryIdUserIdMap = new map<Id, Id>();
        map<Id, Id> userIdTerritoryIdMap = new map<Id, Id>();
        map<id, map<String, Id>> userIdSalesTeamMapMap = new map<id, map<String, Id>>();
        set<Id> splitOwnersWithMultiTerritories = new set<Id>();
        Set<Id> otbOpportunityIds = new Set<Id>();
        set<Id> opportunitiesWithMultipleSplit = new set<Id>();
        Set<Id> multiTerritoriesSplitOwnersOpptyIds = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();
        
        set<Id> oppIdSet = new Set<Id>();
        Map<Id, Id> splitOwnerIdOppIdMap = new Map<Id, Id>();
        map<Id, Id> splitOwnerIdOppOwnerIdMap = new map<Id, Id>();
        map<String, Opportunity> oppIdOppownerIdOppMap = new Map<String, Opportunity>();
        Map<Id, List<OpportunitySplit>> oppIdSplitsToRevisit = new Map<Id, List<OpportunitySplit>>();
        Set<Id> renewalOpportunityIdsWithUpsellSplits = new Set<Id>();
        
        for(OpportunitySplit oppSplit : newOppSplitList){
            splitOwnerIdOppIdMap.put(oppSplit.SplitOwnerId, oppSplit.OpportunityId);
            userIdSet.add(oppSplit.SplitOwnerId);
        }
        
        ZscalerSetting__c setting = ZscalerSetting__c.getInstance('CustomerAdvocacyDepartmentName');
        String CADepartmentName = (setting != null && setting.Value__c != null ? setting.Value__c : '0'); // Vijay: Deliberately assigning '0' as the value to make sure query does not return any value
        //Map<Id, User> mapCustomerAdvocates = new Map<Id, User>([SELECT Id, Department, UserRoleId FROM User WHERE Id IN :userIdSet AND Department = :CADepartmentName]);
        Map<Id, User> mapCustomerAdvocates = new Map<Id, User>();
        if(userIdSet.size()>0){
            for(User usr:[SELECT Id, Department, UserRoleId FROM User WHERE Id IN :userIdSet AND Department = :CADepartmentName]){
                mapCustomerAdvocates.put(usr.id,usr);
            }
        }
        
        Set<Id> renewalOpportunityIds = new Set<Id>();
        //added SE_Name__c in query : Gurjinder :CR# 315 
        for(Opportunity opp : [Select Id,SE_Name__c, OwnerId, Account.OwnerId, Account.Sales_Engineer__c, Account.Customer_Advocate__c, Account.Channel_Manager__c, Account.Sales_Territory__c, /**Account.ZPA_Manager__c,
Account.ZPA_SE__c,**/ Opportunity_Sales_Territory__c, Opportunity_Customer_Advocate__c, Opportunity_Sales_Engineer__c, Opportunity_Channel_Manager__c,
                               Opportunity_ZPA_Manager__c, Split__c, /*Channel_OTB__c, SE_OTB__c, CA_OTB_flag__c, Rep_OTB_Flag__c,*/ RecordTypeId, Type,
                               (Select Id, SplitOwnerId, OpportunityId, Sales_Territory__c, Split_Type__c From OpportunitySplits)
                               FROM Opportunity WHERE Id IN: splitOwnerIdOppIdMap.values()] ){
                                   oppIdOppownerIdOppMap.put(opp.Id , opp);
                                   
                                   if (opp.OpportunitySplits.size() > 0) {
                                       opportunitiesWithMultipleSplit.add(opp.Id);
                                   }
                                   
                                   if (opp.Type == 'Existing Customer (Renewal)') {
                                       renewalOpportunityIds.add(opp.Id);
                                   }
                                   
                                   // if (opp.Channel_OTB__c || opp.SE_OTB__c || opp.CA_OTB_flag__c || opp.Rep_OTB_Flag__c) {
                                   /*if (opp.Rep_OTB_Flag__c && opp.Split__c == true) {
otbOpportunityIds.add(opp.Id);
}*/
                               }
        
        if(userIdSet.size()>0){         
            for(PatchTeamMember__c salesTeam : [Select Id, PatchTeam__c , User__c from PatchTeamMember__c where User__c IN: userIdSet AND PatchTeam__r.Sales_Territory_Year__c = 'Current']){
                
                if (!userIdTerritoryIdMap.containsKey(salesTeam.User__c)) {
                    territoryIdUserIdMap.put(salesTeam.PatchTeam__c, salesTeam.User__c);
                    userIdTerritoryIdMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
                } else if (userIdTerritoryIdMap.containsKey(salesTeam.User__c)
                           && userIdTerritoryIdMap.get(salesTeam.User__c) != salesTeam.PatchTeam__c) {
                               splitOwnersWithMultiTerritories.add(salesTeam.User__c);
                           }
            }
            for(PatchTeamMember__c salesTeam : [Select Id, PatchTeam__c , Role__c, User__c from PatchTeamMember__c where PatchTeam__c IN: territoryIdUserIdMap.keySet() AND PatchTeam__r.Sales_Territory_Year__c = 'Current']){
                map<string, Id> roleUserIdMap = new map<string, Id>();
                if(userIdSalesTeamMapMap != null){
                    if(userIdSalesTeamMapMap.keySet().Contains(territoryIdUserIdMap.get(salesTeam.PatchTeam__c))){
                        roleUserIdMap = userIdSalesTeamMapMap.get(territoryIdUserIdMap.get(salesTeam.PatchTeam__c));
                        if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                            roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                            userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                        }
                    }else{
                        if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                            roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                            userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                        }
                    }
                }else{
                    if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                        roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                        userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                    }
                }
            }
        }
        
        Set<Id> upselplaceholderusers = new Set<Id>();
        upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        
        for(OpportunitySplit oppSplit : newOppSplitList){
            // If the Opportunity has no split entry (upon first entry creation), update the Account Sales Territory and update others with user sales territories
            // If the Opportunity has at least one split entry, check for the following:
            //      If the Split Owner is the same as Account Owner, update the Account Sales Territory in the split record and update others with user sales territories
            //      Else If the Split Owner is not same as Account Owner, update the user sales territory
            if (opportunitiesWithMultipleSplit.contains(oppSplit.OpportunityId)
                && oppIdOppownerIdOppMap.containsKey(oppSplit.OpportunityId) && !upselplaceholderusers.contains(oppSplit.SplitOwnerId) && oppSplit.SplitOwnerId != oppIdOppownerIdOppMap.get(oppSplit.OpportunityId).OwnerId) {
                    system.debug('inside first if condition');
                    Opportunity oppty = oppIdOppownerIdOppMap.get(oppSplit.OpportunityId);
                    
                    if (oppSplit.SplitOwnerId == oppty.Account.OwnerId
                        || (oppty.Type == 'Existing Customer (Renewal)'
                            && mapCustomerAdvocates.containsKey(oppsplit.SplitOwnerId)
                            && oppSplit.Split_Type__c == 'Renewal')) {
                                system.debug('inside Second if condition');
                                oppSplit.Customer_Advocate__c =  oppty.Account.Customer_Advocate__c;
                                //Changes by Gurjinder :CR# 315 :Start
                                //oppSplit.SE__c = oppty.Account.Sales_Engineer__c;
                                if(!oppSplit.Override_SE__c){
                                    oppSplit.SE__c = oppty.SE_Name__c;
                                }
                                //Changes by Gurjinder :CR# 315 :End
                                
                                //oppSplit.Channel_Rep__c = oppty.Account.Channel_Manager__c;
                                oppSplit.Sales_Territory__c = oppty.Account.Sales_Territory__c;
                                //oppSplit.ZPA_RSM__c = oppty.Account.ZPA_Manager__c;
                                //oppSplit.ZPA_SE__c = oppty.Account.ZPA_SE__c;
                                
                                oppIdSplitsToRevisit.put(oppty.Id, oppty.OpportunitySplits);
                            } else {
                                map<string, Id> roleUserIdMap = new map<string, Id>();
                                roleUserIdMap = userIdSalesTeamMapMap.get(oppSplit.SplitOwnerId);
                                if(roleUserIdMap != null){
                                    oppSplit.Customer_Advocate__c =  roleUserIdMap.get('Customer Advocate');
                                    oppSplit.SE__c =  roleUserIdMap.get('Sales Engineer');
                                    //oppSplit.Channel_Rep__c = roleUserIdMap.get('Channel Manager');
                                    oppSplit.Sales_Territory__c = userIdTerritoryIdMap.get(oppSplit.SplitOwnerId);
                                    oppSplit.ZPA_RSM__c = roleUserIdMap.get('ZPA Manager');
                                    oppSplit.ZPA_SE__c = roleUserIdMap.get('ZPA SE');
                                }
                                else{
                                    
                                }
                                // If the split owner belongs to multiple territories, raise a case to sales ops for validation
                                
                                if (oppSplit.Opportunity.Split__c == true || splitOwnersWithMultiTerritories.contains(oppSplit.SplitOwnerId)) {
                                    multiTerritoriesSplitOwnersOpptyIds.add(oppSplit.OpportunityId);
                                }
                            }
                } else if (oppIdOppownerIdOppMap.containsKey(oppSplit.OpportunityId)) {
                    Opportunity oppty = oppIdOppownerIdOppMap.get(oppSplit.OpportunityId);
                    oppSplit.Customer_Advocate__c =  oppty.Account.Customer_Advocate__c;
                    
                    //Changes by Gurjinder :CR# 315 :Start
                    oppSplit.SE__c = oppty.Account.Sales_Engineer__c;
                    //if(!oppSplit.Override_SE__c){
                    //oppSplit.SE__c = oppty.SE_Name__c;
                    //}
                    //Changes by Gurjinder :CR# 315 :End
                    //oppSplit.Channel_Rep__c = oppty.Account.Channel_Manager__c;
                    oppSplit.Sales_Territory__c = oppty.Account.Sales_Territory__c;
                    //oppSplit.ZPA_RSM__c = oppty.Account.ZPA_Manager__c;
                    //oppSplit.ZPA_SE__c = oppty.Account.ZPA_SE__c;
                }
            
            // Existing code: Commenting out to keep track of the changes
            // if(oppIdOppownerIdOppMap.containsKey(''+oppSplit.SplitOwnerId+oppSplit.OpportunityId)){
            //     Opportunity opp = oppIdOppownerIdOppMap.get(''+oppSplit.SplitOwnerId+ oppSplit.OpportunityId);
            //     oppSplit.Customer_Advocate__c =  opp.Account.Customer_Advocate__c;
            //     oppSplit.SE__c = opp.Account.Sales_Engineer__c;
            //     oppSplit.Channel_Rep__c = opp.Account.Channel_Manager__c;
            //     oppSplit.Sales_Territory__c = opp.Account.Sales_Territory__c;
            //     oppSplit.ZPA_RSM__c = opp.Account.ZPA_Manager__c;
            //     oppSplit.ZPA_SE__c = opp.Account.ZPA_SE__c;
            //
            //
            // }else{
            //     map<string, Id> roleUserIdMap = new map<string, Id>();
            //     roleUserIdMap = userIdSalesTeamMapMap.get(oppSplit.SplitOwnerId);
            //     if(roleUserIdMap != null){
            //         oppSplit.Customer_Advocate__c =  roleUserIdMap.get('Customer Advocate');
            //         oppSplit.SE__c = roleUserIdMap.get('Sales Engineer');
            //         oppSplit.Channel_Rep__c = roleUserIdMap.get('Channel Manager');
            //         oppSplit.Sales_Territory__c = userIdTerritoryIdMap.get(oppSplit.SplitOwnerId);
            //         oppSplit.ZPA_RSM__c = roleUserIdMap.get('ZPA Manager');
            //         oppSplit.ZPA_SE__c = roleUserIdMap.get('ZPA SE');
            //     }
            
            
            // }
            
            // If the split type is Upsell and the opportunity is of Renewal type, raise a case to sales ops for Validation
            if (renewalOpportunityIds.contains(oppSplit.OpportunityId) && oppSplit.Split_Type__c == 'Upsell' && oppSplit.ZPA_Amount__c > 0) {
                renewalOpportunityIdsWithUpsellSplits.add(oppSplit.OpportunityId);
            }
            
            // Commenting the below code as ZPA Forecasting has been removed in the new forecasting implementation
            // // Add all splits with blank ZPA Fields
            // if (oppSplit.ZPA_RSM__c == null || oppSplit.ZPA_SE__c == null) {
            //     splitsWithBlankZPAFields.add(oppSplit.OpportunityId);
            // }
        }
        
        if (multiTerritoriesSplitOwnersOpptyIds.size() > 0 || otbOpportunityIds.size() > 0 || renewalOpportunityIdsWithUpsellSplits.size() > 0
            || splitsWithBlankZPAFields.size() > 0) {
                CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(multiTerritoriesSplitOwnersOpptyIds, otbOpportunityIds, renewalOpportunityIdsWithUpsellSplits, splitsWithBlankZPAFields);
            }
        
        if (!TriggerUtility.isRevisitOpportunitySplitsSalesTerritoryExecuted()) {
            updateOtherSplitsWithUserTerritories(oppIdSplitsToRevisit, true);
        }
    }
    
    public static void afterDeleteSplit(List<OpportunitySplit> oppSplits) {
        // Query all other split lines and revisit the sales territory assignment (update it if needed)
        List<Id> opptyIds = new List<Id>();
        Set<Id> splitIdsToExclude = new Set<Id>();
        Map<Id, List<OpportunitySplit>> oppIdSplitsToRevisit = new Map<Id, List<OpportunitySplit>>();
        
        for (OpportunitySplit split : oppSplits) {
            splitIdsToExclude.add(split.Id);
            opptyIds.add(split.OpportunityId);
        }
        
        for (Opportunity oppty : [Select Id, OwnerId, Account.OwnerId, Account.Sales_Engineer__c, Account.Customer_Advocate__c, Account.Channel_Manager__c, Account.Sales_Territory__c, /**Account.ZPA_Manager__c,
Account.ZPA_SE__c,**/ Opportunity_Sales_Territory__c, Opportunity_Customer_Advocate__c, Opportunity_Sales_Engineer__c, Opportunity_Channel_Manager__c,
                                  Opportunity_ZPA_Manager__c, Split__c, /*Channel_OTB__c, SE_OTB__c, CA_OTB_flag__c, Rep_OTB_Flag__c,*/
                                  (Select Id, SplitOwnerId, OpportunityId, Sales_Territory__c, Split_Type__c,Override_SE__c,SE__c From OpportunitySplits)
                                  FROM Opportunity WHERE Id IN: opptyIds]) {
                                      List<OpportunitySplit> splitsToRevisit = new List<OpportunitySplit>();
                                      
                                      for (OpportunitySplit split : oppty.OpportunitySplits) {
                                          if (!splitIdsToExclude.contains(split.Id)) {
                                              splitsToRevisit.add(split);
                                          }
                                      }
                                      
                                      oppIdSplitsToRevisit.put(oppty.Id, splitsToRevisit);
                                  }
        System.debug('>>>> oppIdSplitsToRevisit: ' + JSON.serialize(oppIdSplitsToRevisit));
        updateOtherSplitsWithUserTerritories(oppIdSplitsToRevisit, false);
    }
    
    public static void updateOtherSplitsWithUserTerritories(Map<Id, List<OpportunitySplit>> oppIdSplitsToRevisit, Boolean isBeforeInsert) {
        List<OpportunitySplit> splitsToUpdate = new List<OpportunitySplit>();
        List<Id> splitOwnerIds = new List<Id>();
        Map<Id, Id> splitOwnerIdsSalesTerritoryIds = new Map<Id, Id>();
        Map<Id, Map<String, Id>> splitOwnerIdsAndSalesTeamMembers = new Map<Id, Map<String, Id>>();
        Set<Id> splitOwnersWithMultiTerritories = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();
        
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, OwnerId,SE_Name__c, Account.OwnerId, Account.Sales_Engineer__c,
                                                                          Account.Customer_Advocate__c, Account.Channel_Manager__c,
                                                                          Account.Sales_Territory__c, /**Account.ZPA_Manager__c, Account.ZPA_SE__c,**/
                                                                          Opportunity_Sales_Territory__c, Opportunity_Customer_Advocate__c,
                                                                          Opportunity_Sales_Engineer__c, Opportunity_Channel_Manager__c,
                                                                          Opportunity_ZPA_Manager__c,Split__c, Type,
                                                                          (SELECT Id, OpportunityId,Override_SE__c,SE__c, SplitOwnerId, Split_Type__c FROM OpportunitySplits)
                                                                          FROM Opportunity
                                                                          WHERE Id IN :oppIdSplitsToRevisit.keySet()]);
        
        for (Id opptyId : oppIdSplitsToRevisit.keySet()) {
            for (OpportunitySplit opptySplit : oppIdSplitsToRevisit.get(opptyId)) {
                splitOwnerIds.add(opptySplit.SplitOwnerId);
            }
        }
        
        ZscalerSetting__c setting = ZscalerSetting__c.getInstance('CustomerAdvocacyDepartmentName');
        String CADepartmentName = (setting != null && setting.Value__c != null ? setting.Value__c : '0'); // Vijay: Deliberately assigning '0' as the value to make sure query does not return any value
        //Map<Id, User> mapCustomerAdvocates = new Map<Id, User>([SELECT Id, Department, UserRoleId FROM User WHERE Id IN :splitOwnerIds AND Department = :CADepartmentName]);  Commented as a part of SOQL 101 issue
        
        Map<Id, User> mapCustomerAdvocates = new Map<Id, User>();   
        if(splitOwnerIds.size()>0){
            
            for(User usr:[SELECT Id, Department, UserRoleId FROM User WHERE Id IN :splitOwnerIds AND Department = :CADepartmentName]){
                mapCustomerAdvocates.put(usr.id,usr);
            }
            
            
            for (PatchTeamMember__c member : [SELECT Id, User__c, Role__c, PatchTeam__c
                                              FROM PatchTeamMember__c
                                              WHERE User__c IN :splitOwnerIds
                                              AND PatchTeam__r.Sales_Territory_Year__c = 'Current']) {
                                                  if (!splitOwnerIdsSalesTerritoryIds.containsKey(member.User__c)) {
                                                      splitOwnerIdsSalesTerritoryIds.put(member.User__c, member.PatchTeam__c);
                                                  } else if (splitOwnerIdsSalesTerritoryIds.containsKey(member.User__c)
                                                             && splitOwnerIdsSalesTerritoryIds.get(member.User__c) != member.PatchTeam__c) {
                                                                 splitOwnersWithMultiTerritories.add(member.User__c);
                                                             }
                                              }
            
            for (PatchTeamMember__c member :[SELECT Id, User__c, Role__c, PatchTeam__c
                                             FROM PatchTeamMember__c
                                             WHERE PatchTeam__c IN :splitOwnerIdsSalesTerritoryIds.values()
                                             AND PatchTeam__r.Sales_Territory_Year__c = 'Current']) {
                                                 if (splitOwnerIdsAndSalesTeamMembers.containsKey(member.PatchTeam__c)
                                                     && member.Role__c != null && member.Role__c != '') {
                                                         splitOwnerIdsAndSalesTeamMembers.get(member.PatchTeam__c).put(member.Role__c, member.User__c);
                                                     } else {
                                                         Map<String, String> salesTeamMap = new Map<String, String>();
                                                         salesTeamMap.put(member.Role__c, member.User__c);
                                                         splitOwnerIdsAndSalesTeamMembers.put(member.PatchTeam__c, salesTeamMap);
                                                     }
                                             }
        }
        for (Id opptyId : oppIdSplitsToRevisit.keySet()) {
            for (OpportunitySplit opptySplit : oppIdSplitsToRevisit.get(opptyId)) {
                Opportunity oppty = mapOpportunities.get(opptyId);
                if (opptySplit.SplitOwnerId == oppty.Account.OwnerId
                    || (isBeforeInsert != true && oppty.OpportunitySplits.size() == 1)
                    || (mapCustomerAdvocates.containsKey(opptySplit.SplitOwnerId)
                        && opptySplit.Split_Type__c == 'Renewal'
                        && oppty.Type == 'Existing Customer (Renewal)')) {
                            system.debug('inside if');
                            OpportunitySplit oppspt= new OpportunitySplit(
                                Id = opptySplit.Id,
                                Sales_Territory__c = oppty.Account.Sales_Territory__c,
                                Customer_Advocate__c =  oppty.Account.Customer_Advocate__c
                                /* SE__c = oppty.Account.Sales_Engineer__c, */ //Changes added by Gurjinder: CR# 315
                                //Channel_Rep__c = oppty.Account.Channel_Manager__c
                                //ZPA_RSM__c = oppty.Account.ZPA_Manager__c,
                                //ZPA_SE__c = oppty.Account.ZPA_SE__c
                            );
                            //Changes added by Gurjinder: CR# 315 :Start
                            if(!opptySplit.Override_SE__c){
                                oppspt.SE__c=oppty.SE_Name__c;
                            }else{
                                system.debug('inside else');
                            }
                            splitsToUpdate.add(oppspt);
                            //Changes added by Gurjinder: CR# 315 :End
                            
                            // Commenting the below code as ZPA Forecasting has been removed in the new forecasting implementation
                            // // Add all splits with blank ZPA Fields
                            // if (oppty.Account.ZPA_Manager__c == null || oppty.Account.ZPA_SE__c == null) {
                            //     splitsWithBlankZPAFields.add(opptyId);
                            // }
                        } else {
                            if (opptySplit.Sales_Territory__c != splitOwnerIdsSalesTerritoryIds.get(opptySplit.SplitOwnerId)) {
                                Map<String, Id> salesTeamMap = splitOwnerIdsAndSalesTeamMembers.get(splitOwnerIdsSalesTerritoryIds.get(opptySplit.SplitOwnerId));
                                System.debug('>>>> opptySplit.SplitOwnerId: ' + opptySplit.SplitOwnerId);
                                System.debug('>>>> splitOwnerIdsSalesTerritoryIds.get(opptySplit.SplitOwnerId): ' + splitOwnerIdsSalesTerritoryIds.get(opptySplit.SplitOwnerId));
                                System.debug(JSON.serialize(salesTeamMap));
                                if (salesTeamMap != null) {
                                    splitsToUpdate.add(new OpportunitySplit(
                                        Id = opptySplit.Id,
                                        Sales_Territory__c = splitOwnerIdsSalesTerritoryIds.get(opptySplit.SplitOwnerId),
                                        Customer_Advocate__c =  salesTeamMap.get('Customer Advocate'),
                                        SE__c = salesTeamMap.get('Sales Engineer'),
                                        //Channel_Rep__c = salesTeamMap.get('Channel Manager'),
                                        ZPA_RSM__c = salesTeamMap.get('ZPA Manager'),
                                        ZPA_SE__c = salesTeamMap.get('ZPA SE')
                                    ));
                                    
                                    // Commenting the below code as ZPA Forecasting has been removed in the new forecasting implementation
                                    // // Add all splits with blank ZPA Fields
                                    // if (salesTeamMap.get('ZPA Manager') == null || salesTeamMap.get('ZPA SE') == null) {
                                    //     splitsWithBlankZPAFields.add(opptyId);
                                    // }
                                }
                            }
                        }
            }
        }
        
        // Commenting the below code as ZPA Forecasting has been removed in the new forecasting implementation
        // if (splitsWithBlankZPAFields.size() > 0) {
        //     CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(new Set<Id>(), new Set<Id>(), new Set<Id>(), splitsWithBlankZPAFields);
        // }
        
        System.debug('>>>> splitsToUpdate: ' + splitsToUpdate);
        if (splitsToUpdate.size() > 0) {
            TriggerUtility.opportunitySplitsAfterUpdateExecuted();
            update splitsToUpdate;
            TriggerUtility.opportunitySplitsAfterUpdateReset();
        }
        TriggerUtility.revisitOpportunitySplitsSalesTerritoryExecuted();
    }

    //Modified CR# 4867 and CR# 4868 Start
    public static List<OpportunitySplit> populateOwnerSalesTerritoryAndRAM(List<OpportunitySplit> newSplits, Map<Id, OpportunitySplit> oldSplitsMap, boolean isInsert, boolean isUpdate, boolean isFocusPartnerOppSplitBatchExe) {
        System.debug('111 ==>>> Entered into OpportunitySplitTriggerHelper.populateOwnerSalesTerritoryAndRAM() ...!!');
        System.debug('111(A1A) ==>>> newSplits size: '+newSplits.size()+' and newSplits: '+newSplits);
        System.debug('111(A2A) ==>>> oldSplitsMap: '+oldSplitsMap);
        System.debug('111(A3A) ==>>> isInsert: '+isInsert);
        System.debug('111(A4A) ==>>> isUpdate: '+isUpdate);
        System.debug('111(A5A) ==>>> isFocusPartnerOppSplitBatchExe: '+isFocusPartnerOppSplitBatchExe);
        Set<ID> oppIdSet = new Set<ID>();
        Set<Id> splitOwnerIdSet = new Set<Id>();
        Set<Id> splitOwnerTeritotyIdSet = new Set<Id>();
        for(OpportunitySplit newSplit : newSplits){
            System.debug('7878 ==>>> Current new Oppt Split is: '+newSplit);
            splitOwnerIdSet.add(newSplit.SplitOwnerId);
            
            if(newSplit.Owner_Sales_Territory__c != null){
                system.debug('inside 1 if here');
                splitOwnerTeritotyIdSet.add(newSplit.Owner_Sales_Territory__c);
            }else if(newSplit.Sales_Territory__c != null){
                system.debug('inside 2 if here');
                splitOwnerTeritotyIdSet.add(newSplit.Sales_Territory__c);
            }
            
            if(isUpdate && newSplit.Override_SE__c && (oldSplitsMap != null && newSplit.SE__c != oldSplitsMap.get(newSplit.Id).SE__c)){
                newSplit.SE__c = oldSplitsMap.get(newSplit.Id).SE__c;
            }
            if((isInsert && newSplit.SplitOwnerId != null && newSplit.OpportunityId != null) 
                || (isUpdate 
                    && (isFocusPartnerOppSplitBatchExe
                        || newSplit.Channel_Rep__c == null 
                     // || (oldSplitsMap != null && newSplit.Channel_Rep__c != oldSplitsMap.get(newSplit.Id).Channel_Rep__c) 
                        || (oldSplitsMap != null && newSplit.SplitOwnerId != oldSplitsMap.get(newSplit.Id).SplitOwnerId) 
                        || newSplit.Primary_Reseller__c != oldSplitsMap.get(newSplit.Id).Primary_Reseller__c))){
                oppIdSet.add(newSplit.OpportunityId);
            }
        }
        System.debug('111(A51A) ==>>> oppIdSet: '+oppIdSet);
        System.debug('111(A52A) ==>>> splitOwnerIdSet: '+splitOwnerIdSet);

        List<OpportunitySplit> toBeUpdOpptSplitList = new List<OpportunitySplit>();
        if(!oppIdSet.isEmpty()){
            Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();
            Map<ID, ID> oppVsAccSalesTerMap = new Map<ID, ID>();
            Set<ID> primaryResellerAccIdSet = new Set<ID>();
            Map<Id, Id> opptVsAcctRAMMap = new Map<Id, Id>();
            for(Opportunity opp : [SELECT Id, OwnerID, Primary_Reseller_Partner__c, Account.Sales_Territory__c, Account.Channel_Manager__c,   
                                   Primary_Reseller_Partner__r.Ultimate_Parent_Account__c 
                                   /*Primary_Reseller_Partner__r.Ultimate_Parent_Account__r.Channel_Manager__c, 
                                   Primary_Reseller_Partner__c, 
                                   Primary_Reseller_Partner__r.Channel_Manager__c */ 
                                   FROM Opportunity 
                                   WHERE Id IN :oppIdSet]){
                System.debug('111(A60A) ==>>> opp: '+opp);
                if(opp.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c != null){
                    primaryResellerAccIdSet.add(opp.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c);
                }else if(opp.Primary_Reseller_Partner__c != null){
                    primaryResellerAccIdSet.add(opp.Primary_Reseller_Partner__c);
                }
                oppMap.put(opp.Id, opp);
                oppVsAccSalesTerMap.put(opp.Id, opp.Account.Sales_Territory__c);
                opptVsAcctRAMMap.put(opp.Id, opp.Account.Channel_Manager__c);
            }
            System.debug('111(A6A) ==>>> oppMap: '+oppMap);
            System.debug('111(A7A) ==>>> oppVsAccSalesTerMap: '+oppVsAccSalesTerMap);
            System.debug('111(A81A) ==>>> primaryResellerAccIdSet: '+primaryResellerAccIdSet);
            System.debug('111(A82A) ==>>> opptVsAcctRAMMap: '+opptVsAcctRAMMap);
    
            Map<String, ID> userIdTerritoryIdMap = new Map<String, ID>();
            Map<ID, PatchTeamMember__c> userIdvsTerritoryIdMap = new Map<ID, PatchTeamMember__c>();
            Map<ID, ID> stVsStRAMIdMap = new Map<ID, ID>();
            Map<String, Focus_Partner__c> focusPartnerIdMap = new Map<String, Focus_Partner__c>();
            Map<String, Focus_Partner__c> focusPartnerIdMap2 = new Map<String, Focus_Partner__c>();
            if(!splitOwnerIdSet.isEmpty()){
                for(PatchTeamMember__c salesTeam : [SELECT Id, PatchTeam__c, PatchTeam__r.Channel_Manager__c, User__c 
                                                    FROM PatchTeamMember__c 
                                                    WHERE User__c IN :splitOwnerIdSet 
                                                        AND PatchTeam__r.Sales_Territory_Year__c = 'Current' 
                                                    ORDER BY PatchTeam__c ASC]){
                    if(!userIdTerritoryIdMap.containsKey(salesTeam.User__c)){
                        userIdTerritoryIdMap.put(salesTeam.User__c + '_' + salesTeam.PatchTeam__c, salesTeam.PatchTeam__c);
                        userIdvsTerritoryIdMap.put(salesTeam.User__c,salesTeam);
                    }
                }
                System.debug('111(A9A) ==>>> PatchTeamMember__c - userIdTerritoryIdMap: '+ userIdTerritoryIdMap);
                
                for(Focus_Partner__c currentFP : [SELECT Id, Partner_Account__c, RAM__c, Sales_Territory__c, Sales_Territory__r.Channel_Manager__c 
                                                  FROM Focus_Partner__c 
                                                  WHERE Partner_Account__c IN :primaryResellerAccIdSet
                                                  AND (Sales_Territory__c IN :userIdTerritoryIdMap.values()
                                                    OR Sales_Territory__c IN :oppVsAccSalesTerMap.values())]){
                    System.debug('000 ==>>> Current Focus_Partner__c: '+currentFP);
                    String fpKeyStr = currentFP.Partner_Account__c + '_' + currentFP.Sales_Territory__c;
                    System.debug('010 ==>>> fpKeyStr: '+fpKeyStr);
                    if (!focusPartnerIdMap.containsKey(fpKeyStr) 
                        && ((userIdTerritoryIdMap.values()).contains(currentFP.Sales_Territory__c) 
                        && primaryResellerAccIdSet.contains(currentFP.Partner_Account__c))){
                        System.debug('000(Z1Z) ==>>> Entered into 1st IF block ...!!');
                        focusPartnerIdMap.put(fpKeyStr, currentFP);
                        stVsStRAMIdMap.put(currentFP.Sales_Territory__c, currentFP.Sales_Territory__r.Channel_Manager__c);
                    }
    
                    if (!focusPartnerIdMap2.containsKey(fpKeyStr) 
                        && (oppVsAccSalesTerMap.values()).contains(currentFP.Sales_Territory__c)){
                        System.debug('000(Z2Z) ==>>> Entered into 2nd IF block ...!!');
                        focusPartnerIdMap2.put(fpKeyStr, currentFP);
    
                        if (!focusPartnerIdMap.containsKey(fpKeyStr) 
                            && primaryResellerAccIdSet.contains(currentFP.Partner_Account__c)){
                            System.debug('000(Z21Z) ==>>> Entered into 2nd IF - INNER IF block ...!!');
                            focusPartnerIdMap.put(fpKeyStr, currentFP);
                        }
                    }
    
                    if (focusPartnerIdMap2.containsKey(fpKeyStr) 
                        && (oppVsAccSalesTerMap.values()).contains(currentFP.Sales_Territory__c)
                        && !focusPartnerIdMap.containsKey(fpKeyStr) 
                        && primaryResellerAccIdSet.contains(currentFP.Partner_Account__c)){
                        System.debug('000(Z3Z) ==>>> Entered into 3rd IF block ...!!');
                        focusPartnerIdMap.put(fpKeyStr, currentFP);
                    }
                    
                    if (!stVsStRAMIdMap.containsKey(currentFP.Sales_Territory__c) 
                        && (oppVsAccSalesTerMap.values()).contains(currentFP.Sales_Territory__c)){
                        System.debug('000(Z4Z) ==>>> Entered into 4th IF block ...!!');
                        stVsStRAMIdMap.put(currentFP.Sales_Territory__c, currentFP.Sales_Territory__r.Channel_Manager__c);
                    }
                }
            }
            System.debug('222(A1A) ==>>> focusPartnerIdMap: '+focusPartnerIdMap);
            System.debug('222(A2A) ==>>> focusPartnerIdMap2: '+focusPartnerIdMap2);
            System.debug('222(A3A) ==>>> primaryResellerAccIdSet: '+primaryResellerAccIdSet);
            System.debug('222(A41A) ==>>> Focus_Partner__c - stVsStRAMIdMap: '+stVsStRAMIdMap);
            
            for(PatchTeam__c st : [SELECT Id, Name, Channel_Manager__c  
                                   FROM PatchTeam__c 
                                   WHERE Id IN :splitOwnerTeritotyIdSet 
                                   ORDER BY Name ASC]){
                if(!stVsStRAMIdMap.containsKey(st.Id)){
                    stVsStRAMIdMap.put(st.Id, st.Channel_Manager__c);
                }
            }
            System.debug('222(A42A) ==>>> Focus_Partner__c - stVsStRAMIdMap: '+stVsStRAMIdMap);
    
            for(OpportunitySplit newSplit : newSplits){
                System.debug('777(A0A) ==>>> Current New OpportunitySplit - Before change: '+newSplit);
                Opportunity oppt = oppMap.get(newSplit.OpportunityID);
                System.debug('777(A1A) ==>>> Current Opportunity: '+oppt);
    
                //While INSERT the OpportunitySplit
                if(isInsert){
                    System.debug('333(AA) ==>>> In Insert - Before change, newSplit.Owner_Sales_Territory__c: '+newSplit.Owner_Sales_Territory__c);
                    //Owner Sales Territory Assignment While INSERT the OpportunitySplit
                    if(newSplit.Opportunity_Stage__c != label.Stage_5_Contracts_Complete
                        && newSplit.Opportunity_Stage__c != label.Stage_5A_Opportunity 
                        && newSplit.Opportunity_Stage__c != label.Stage_5B_Opportunity
                        && newSplit.Opportunity_Stage__c != label.Stage_5C_Opportunity 
                        && newSplit.Opportunity_Stage__c != label.Stage_6_Closed_Won 
                        && newSplit.Opportunity_Stage__c != label.Stage_7_Closed_Lost
                        && newSplit.Opportunity_Stage__c != '15 - Subscription Payments-FINANCE ONLY'){
                        newSplit.Owner_Sales_Territory__c = userIdvsTerritoryIdMap.containsKey(newSplit.SplitOwnerId) 
                                                                ? userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c
                                                                : null;
                        if(userIdvsTerritoryIdMap.containsKey(newSplit.SplitOwnerId) && !stVsStRAMIdMap.containsKey(userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c)){
                            stVsStRAMIdMap.put(userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c, userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__r.Channel_Manager__c);
                        }
                    }
                    System.debug('333(AB) ==>>> In Insert - After change, newSplit.Owner_Sales_Territory__c: '+newSplit.Owner_Sales_Territory__c);
                    
                    //RAM Assignment While INSERT the OpportunitySplit
                    if(newSplit.Owner_Sales_Territory__c != null 
                        && oppt != null 
                        && (oppt.Primary_Reseller_Partner__c != null 
                        && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c) 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c != null 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c).Partner_Account__c)){
                        newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c).RAM__c;
                        System.debug('333(B11B) ==>>> Entered into 1st IF block (i.e., Partner Ultimate Parent account FP RAM assignment) ...!!');
                    }
                    else if(newSplit.Owner_Sales_Territory__c != null 
                        && oppt != null 
                        && (oppt.Primary_Reseller_Partner__c != null 
                        && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c) 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == null 
                        && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c).Partner_Account__c)){
                        newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Owner_Sales_Territory__c).RAM__c;
                        System.debug('333(B12B) ==>>> Entered into 2nd IF block (i.e., Partner account FP RAM assignment) ...!!');
                    }
                    else if(newSplit.Sales_Territory__c != null 
                        && oppt != null 
                        && (oppt.Primary_Reseller_Partner__c != null 
                        && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c) 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == null 
                        && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c).Partner_Account__c)){
                        newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c).RAM__c;
                        System.debug('333(B12B) ==>>> Entered into 3nd IF block (i.e., Partner account FP RAM assignment) ...!!');
                    }
                    else if(!stVsStRAMIdMap.isEmpty() 
                        && newSplit.Owner_Sales_Territory__c != null 
                        && stVsStRAMIdMap.containsKey(newSplit.Owner_Sales_Territory__c)){
                        newSplit.Channel_Rep__c = stVsStRAMIdMap.get(newSplit.Owner_Sales_Territory__c);
                        System.debug('333(B13B) ==>>> Entered into 4rd IF block (i.e., Opportunity Split Owner_Sales_Territory__c default RAM assignment) ...!!');
                    }
                    else if(!stVsStRAMIdMap.isEmpty() 
                        && newSplit.Sales_Territory__c != null 
                        && stVsStRAMIdMap.containsKey(newSplit.Sales_Territory__c)){
                        newSplit.Channel_Rep__c = stVsStRAMIdMap.get(newSplit.Sales_Territory__c);
                        System.debug('333(B14B) ==>>> Entered into 5th IF block (i.e., Opportunity Split Sales_Territory__c default RAM assignment) ...!!');
                    }
                    else if(oppt != null 
                        && oppt.Account.Sales_Territory__c != null 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c != null 
                        && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c) 
                        && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c).Partner_Account__c){
                        newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c).RAM__c;
                        System.debug('333(B15B) ==>>> Entered into 6th IF block (i.e., Opportunity Primary Reseller Partner Ultimate Parent + Opportunity Account ST FP RAM assignment) ...!!');
                    }
                    else if(oppt != null 
                        && oppt.Account.Sales_Territory__c != null 
                        && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == null 
                        && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c) 
                        && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c).Partner_Account__c){
                        newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c).RAM__c;
                        System.debug('333(B16B) ==>>> Entered into 7th IF block (i.e., Opportunity Primary Reseller Partner Parent + Opportunity Account ST FP RAM assignment) ...!!');
                    }
                    else if(oppt != null 
                        && !opptVsAcctRAMMap.isEmpty()){
                        newSplit.Channel_Rep__c = opptVsAcctRAMMap.get(oppt.Id);
                        System.debug('333(B17B) ==>>> Entered into 8th IF block (i.e., Opportunity Account default RAM assignment) ...!!');
                    }
                }
                //While UPDATE the OpportunitySplit
                else if(isUpdate){
                    System.debug('444(AA) ==>>> In Update - Before change, newSplit.Owner_Sales_Territory__c: '+newSplit.Owner_Sales_Territory__c);
                    //Sales Territory Owner Assignment While UPDATE the OpportunitySplit
                    if((isFocusPartnerOppSplitBatchExe || (oldSplitsMap != null && newSplit.SplitOwnerId != oldSplitsMap.get(newSplit.Id).SplitOwnerId))
                        && newSplit.Opportunity_Stage__c != label.Stage_5_Contracts_Complete
                        && newSplit.Opportunity_Stage__c != label.Stage_5A_Opportunity 
                        && newSplit.Opportunity_Stage__c != label.Stage_5B_Opportunity
                        && newSplit.Opportunity_Stage__c != label.Stage_5C_Opportunity 
                        && newSplit.Opportunity_Stage__c != label.Stage_6_Closed_Won 
                        && newSplit.Opportunity_Stage__c != label.Stage_7_Closed_Lost
                        && newSplit.Opportunity_Stage__c != '15 - Subscription Payments-FINANCE ONLY'){
                        newSplit.Owner_Sales_Territory__c = userIdvsTerritoryIdMap.containsKey(newSplit.SplitOwnerId) 
                                                                ? userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c 
                                                                : null;
                       if(userIdvsTerritoryIdMap.containsKey(newSplit.SplitOwnerId) && !stVsStRAMIdMap.containsKey(userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c)){
                            stVsStRAMIdMap.put(userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__c, userIdvsTerritoryIdMap.get(newSplit.SplitOwnerId).PatchTeam__r.Channel_Manager__c);
                        }
                    }
                    System.debug('444(AB) ==>>> In Update - After change, newSplit.Owner_Sales_Territory__c:  '+newSplit.Owner_Sales_Territory__c);
                    
                    if(isFocusPartnerOppSplitBatchExe 
                        || newSplit.Channel_Rep__c == null 
                    //  || (oldSplitsMap != null && newSplit.Channel_Rep__c != oldSplitsMap.get(newSplit.Id).Channel_Rep__c)
                        || newSplit.Primary_Reseller__c != oldSplitsMap.get(newSplit.Id).Primary_Reseller__c){
                        //RAM Assignment While UPDATE the OpportunitySplit
                        if(newSplit.Owner_Sales_Territory__c != null 
                            && oppt != null 
                            && (oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c != null 
                            && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + newSplit.Owner_Sales_Territory__c) 
                            && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + newSplit.Owner_Sales_Territory__c).Partner_Account__c)){
                            newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + newSplit.Owner_Sales_Territory__c).RAM__c;
                            System.debug('444(B11B) ==>>> Entered into 1st IF block (i.e., Partner Ultimate Parent account FP RAM assignment) ...!!');
                        }
                        else if(newSplit.Sales_Territory__c != null 
                            && oppt != null 
                            && (oppt.Primary_Reseller_Partner__c != null 
                            && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c) 
                            && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == null 
                            && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c).Partner_Account__c)){
                            newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + newSplit.Sales_Territory__c).RAM__c;
                            System.debug('444(B12B) ==>>> Entered into 2nd IF block (i.e., Partner account FP RAM assignment) ...!!');
                        }
                        else if(!stVsStRAMIdMap.isEmpty() 
                                && newSplit.Owner_Sales_Territory__c != null 
                                && stVsStRAMIdMap.containsKey(newSplit.Owner_Sales_Territory__c)){
                            newSplit.Channel_Rep__c = stVsStRAMIdMap.get(newSplit.Owner_Sales_Territory__c);
                            System.debug('444(B13B) ==>>> Entered into 3rd IF block (i.e., Opportunity Split Owner_Sales_Territory__c default RAM assignment) ...!!');
                        }
                        else if(!stVsStRAMIdMap.isEmpty() 
                                && newSplit.Sales_Territory__c != null 
                                && stVsStRAMIdMap.containsKey(newSplit.Sales_Territory__c)){
                            newSplit.Channel_Rep__c = stVsStRAMIdMap.get(newSplit.Sales_Territory__c);
                            System.debug('444(B14B) ==>>> Entered into 4th IF block (i.e., Opportunity Split Sales_Territory__c default RAM assignment) ...!!');
                        }
                        else if(oppt != null 
                            && oppt.Account.Sales_Territory__c != null 
                            && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c != null 
                            && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c) 
                            && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c).Partner_Account__c){
                            newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c + '_' + oppt.Account.Sales_Territory__c).RAM__c;
                            System.debug('444(B15B) ==>>> Entered into 5th IF block (i.e., Opportunity Primary Reseller Partner Ultimate Parent + Opportunity Account ST FP RAM assignment) ...!!');
                        }
                        else if(oppt != null 
                            && oppt.Account.Sales_Territory__c != null 
                            && oppt.Primary_Reseller_Partner__r.Ultimate_Parent_Account__c == null 
                            && focusPartnerIdMap.containsKey(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c) 
                            && oppt.Primary_Reseller_Partner__c == focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c).Partner_Account__c){
                            newSplit.Channel_Rep__c = focusPartnerIdMap.get(oppt.Primary_Reseller_Partner__c + '_' + oppt.Account.Sales_Territory__c).RAM__c;
                            System.debug('444(B16B) ==>>> Entered into 6th IF block (i.e., Opportunity Primary Reseller Partner + Opportunity Account ST FP RAM assignment) ...!!');
                        }
                        else if(oppt != null 
                            && !opptVsAcctRAMMap.isEmpty()){
                            newSplit.Channel_Rep__c = opptVsAcctRAMMap.get(oppt.Id);
                            System.debug('444(B17B) ==>>> Entered into 7th IF block (i.e., Opportunity Account default RAM assignment) ...!!');
                        }
                    }
                }
                System.debug('555(A1A) ==>>> newSplit.Id: '+ newSplit.Id +' --> newSplit.Channel_Rep__c: '+ newSplit.Channel_Rep__c);
                if(isFocusPartnerOppSplitBatchExe && newSplit.Channel_Rep__c != null){
                    toBeUpdOpptSplitList.add(newSplit);
                }
                
                if(isUpdate && (isFocusPartnerOppSplitBatchExe || (oldSplitsMap != null && newSplit.Channel_Rep__c != oldSplitsMap.get(newSplit.Id).Channel_Rep__c))){
                    TriggerUtility2.reSetOppSplitTeamMemberUpdateProcessExecuted();
                    TriggerUtility2.setOppSplitRAMAssignmentProcessExecuted();
                }
                System.debug('777(B0B) ==>>> Current New OpportunitySplit - After change: '+newSplit);
            }
        }
        System.debug('777(C0C) ==>>> Final toBeUpdOpptSplitList Size is: '+toBeUpdOpptSplitList.size());
        System.debug('777(C1C) ==>>> Final toBeUpdOpptSplitList val is: '+toBeUpdOpptSplitList);
        return toBeUpdOpptSplitList;
    }
    
    public static void createOpportunityTeamforSplit(List<OpportunitySplit> newSplits, Map<Id, OpportunitySplit> oldSplitsMap){
        System.debug('666 Entered into OpportunitySplitTriggerHelper.createOpportunityTeamforSplit() ');
        System.debug('666(A1A) ==>>> newSplits: '+newSplits);
        System.debug('666(A2A) ==>>> oldSplitsMap: '+oldSplitsMap);
        Set<Id> oppTeamMemberSet = new Set<Id>();
        List<OpportunityTeamMember> updateoppTeamMembers = new List<OpportunityTeamMember>();
        Map<ID, OpportunitySplit> oppSplitMap = new Map<ID, OpportunitySplit>();
        for(OpportunitySplit newSplit : newSplits){
            System.debug('6060(A21A) ==>>> newSplit.Id: '+ newSplit.Id +' --> newSplit.OpportunityId: '+ newSplit.OpportunityId +' --> newSplit.Channel_Rep__c: '+ newSplit.Channel_Rep__c +' --> oldSplit.Channel_Rep__c: '+ oldSplitsMap);
            if(newSplit.Channel_Rep__c != null 
                && (oldSplitsMap != null && newSplit.Channel_Rep__c != oldSplitsMap.get(newSplit.Id).Channel_Rep__c)){
                oppSplitMap.put(newSplit.OpportunityId, newSplit);
                oppTeamMemberSet.add(newSplit.Channel_Rep__c);
            }
        }
        System.debug('666(A31A) ==>>> oppSplitMap Size is: '+oppSplitMap.size());
        System.debug('666(A32A) ==>>> oppSplitMap: '+oppSplitMap);
        System.debug('666(A41A) ==>>> oppTeamMemberSet Size is: '+oppTeamMemberSet.size());
        System.debug('666(A42A) ==>>> oppTeamMemberSet: '+oppTeamMemberSet);
        Map<Id, OpportunityTeamMember> userIdOppTeamRecMap = new Map<Id, OpportunityTeamMember>();
        for(OpportunityTeamMember oppTeamRec : [SELECT Id, OpportunityId, TeamMemberRole, UserId 
                                                FROM OpportunityTeamMember 
                                                WHERE OpportunityId IN :oppSplitMap.keySet() 
                                                    AND UserId IN :oppTeamMemberSet]){
            userIdOppTeamRecMap.put(oppTeamRec.UserId, oppTeamRec);
        }
        System.debug('666(A51A) ==>>> userIdOppTeamRecMap Size is: '+userIdOppTeamRecMap.size());
        System.debug('666(A52A) ==>>> userIdOppTeamRecMap: '+userIdOppTeamRecMap);
        System.debug('666(A53A) ==>>> userIdOppTeamRecMap.keySet(): '+userIdOppTeamRecMap.keySet());
        
        for(OpportunitySplit newSplit : newSplits){
            System.debug('666(B1B) ==>>> Current newSplit: '+newSplit);
            System.debug('666(B2B) ==>>> userIdOppTeamRecMap.containsKey('+newSplit.Channel_Rep__c+'): '+ userIdOppTeamRecMap.containsKey(newSplit.Channel_Rep__c) +' --> newSplit.Channel_Rep__c: '+ newSplit.Channel_Rep__c +' --> newSplit.Channel_Rep__c: '+ newSplit.Channel_Rep__c +' --> oldSplit.Channel_Rep__c: '+ oldSplitsMap);
            if(!userIdOppTeamRecMap.containsKey(newSplit.Channel_Rep__c)  
                && newSplit.Channel_Rep__c != null
                && (oldSplitsMap != null && newSplit.Channel_Rep__c != oldSplitsMap.get(newSplit.Id).Channel_Rep__c)){
                System.debug('666(C1C) ==>>> Entered into 1st IF block ...!!');
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = newSplit.OpportunityId;
                oppTeamMember.TeamMemberRole = 'Out of Territory RAM';
                oppTeamMember.OpportunityAccessLevel = 'Edit';
                oppTeamMember.UserId = newSplit.Channel_Rep__c;
                updateoppTeamMembers.add(oppTeamMember);
            }else{
                System.debug('666(C2C) ==>>> Entered into 1st ELSE block ...!!');
            }
        }
        System.debug('666(D1D) ==>>> updateoppTeamMembers: '+updateoppTeamMembers);
        if(!updateoppTeamMembers.isEmpty()){
            List<Database.SaveResult> insertResultList = Database.insert(updateoppTeamMembers);
            System.debug('666(D2D) ==>>> insertResultList: '+insertResultList);
        }
        TriggerUtility2.setOppSplitTeamMemberUpdateProcessExecuted();
        TriggerUtility2.reSetOppSplitRAMAssignmentProcessExecuted();
    }
    //CR# 4867 and CR# 4868 End
}