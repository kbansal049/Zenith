public class opportunitiesPostPatchBatch implements Database.Batchable<SObject>,Database.Stateful {
     ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('opportunitiesPostPatchBatch');
    private List<Id> recordIds;
    
    public opportunitiesPostPatchBatch(List<Id> patchIds){
        this.recordIds = patchIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
		this.zscalerBatchFrameWorkObj.callStart();
        if(recordIds != null && recordIds.size() > 0){
            return Database.getQueryLocator('Select Id from Opportunity Where Account.Patch__c IN: recordIds');
        }
        else{ return Database.getQueryLocator('Select Id from Opportunity');
        }
        
    }
    
    public void execute(Database.BatchableContext context, Opportunity[] opportunities) {
        
        this.zscalerBatchFrameWorkObj.callExecute(opportunities[0]?.Id, opportunities.size());
        opportunities = [Select Id, SE_Name__c,
                                        Sales_Territory_ID__c, 
                                        Opportunity_ZPA_Manager__c,
                                        AccountId,
                                        StageName
                                        From
                                        Opportunity
                                        Where 
                                        ID IN: opportunities];
        
        TriggerUtility.realignPatch();
        
        Set<Id> setSEUserIds = new Set<Id>();
        Map<Id, Set<Id>> mapPatchTeamIdsAndOpptyIds = new Map<Id, Set<Id>>();
        Map<Id, Id> mapOpptySEUsers = new Map<Id, Id>();
        Map<Id, String> mapUserManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapProposalOppty = new Map<Id, Id>();
        Set<Id> setOpptyZPAUsers = new Set<Id>();
        Set<Id> setOpptyZPAManagers = new Set<Id>();

        for (Opportunity opp : opportunities) {
            if (opp.SE_Name__c != null) { setSEUserIds.add(opp.SE_Name__c);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c) && null == opp.SE_Name__c && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                if (!mapPatchTeamIdsAndOpptyIds.containsKey(opp.AccountId)) {
                    mapPatchTeamIdsAndOpptyIds.put(opp.AccountId, new Set<Id> { opp.Id });
                } else { mapPatchTeamIdsAndOpptyIds.get(opp.AccountId).add(opp.Id);
                }
                System.debug('>>>> mapPatchTeamIdsAndOpptyIds: ' + mapPatchTeamIdsAndOpptyIds);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c) && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                setOpptyZPAUsers.add(opp.Id);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c)&& null == opp.Opportunity_ZPA_Manager__c && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                setOpptyZPAManagers.add(opp.Id);
            }

        }

        Map<Id, Account> mapOpptyAccountTeams = new Map<Id, Account>();
        //Query the sales team members and assign SE for the opptys in mapPatchTeamIdsAndOpptyIds
        for (Account account : [SELECT Id, Sales_Engineer__c, Sales_Territory__c, Account_Manager__c, Area_Director__c, Customer_Advocate__c, Channel_Manager__c/**, ZPA_Manager__c, ZPA_SE__c**/ FROM Account
                                           WHERE Id IN :mapPatchTeamIdsAndOpptyIds.keySet()]) {
            for (Id oppId : mapPatchTeamIdsAndOpptyIds.get(account.Id)) {
                mapOpptySEUsers.put(oppId, account.Sales_Engineer__c);
                mapOpptyAccountTeams.put(oppId, account);
            }

            setSEUserIds.add(account.Sales_Engineer__c);
        }

        for (User user : (List<User>)[SELECT Id, ManagerId, Manager.Email FROM User WHERE Id IN :setSEUserIds LIMIT 1000]) {
            mapUserManagerEmail.put(user.Id, user.Manager.Email);
        }
        System.debug('>>>> mapUserManagerEmail: ' + mapUserManagerEmail);
        Map<Id, String> mapOpptySEManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapOpptySEName = new Map<Id, Id>();
        for (Opportunity opp : opportunities) {
            System.debug('>>>> : ' + opp);
            if (opp.SE_Name__c != null) {
                mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(opp.SE_Name__c));
            }
            if (mapOpptySEUsers.containsKey(opp.Id)) {
                mapOpptySEName.put(opp.Id, mapOpptySEUsers.get(opp.Id));
                mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(mapOpptySEUsers.get(opp.Id)));
            }
        }

        if (mapOpptySEManagerEmail.size() > 0 || mapOpptySEName.size() > 0 || mapOpptyAccountTeams.size() > 0) {
            updateOpportunityFieldsInDb(JSON.serialize(mapOpptySEManagerEmail), JSON.serialize(mapOpptySEName), JSON.serialize(mapOpptyAccountTeams), JSON.serialize(setOpptyZPAUsers), JSON.serialize(setOpptyZPAManagers));
        }
    }
    
    public void finish(Database.BatchableContext context) {
		if(context!=null){
        this.zscalerBatchFrameWorkObj.callFinish(context);
        }
        //IBA-5765 - Added recordIds not empty check so that the batch class will not be called for 0 records
        if(!Test.isRunningTest() && !recordIds.isEmpty()) {
            Database.executeBatch(new accountActivitiesPostPatchBatch(recordIds), 10);
        }
    }
    
    public static void updateOpportunityFieldsInDb(String mapOpptySEManagerEmailJSON, String mapOpptySENameJSON, String mapOpptyAccountTeamsJSON, String setOpptyZPAUsersJSON, String setOpptyZPAManagersJSON) {
        Map<Id, String> mapOpptySEManagerEmail = (Map<Id, String>)JSON.deserialize(mapOpptySEManagerEmailJSON, Type.forName('Map<Id, String>'));
        Map<Id, Id> mapOpptySEName = (Map<Id, Id>)JSON.deserialize(mapOpptySENameJSON, Type.forName('Map<Id, Id>'));
        Map<Id, Account> mapOpptyAccountTeams = (Map<Id, Account>)JSON.deserialize(mapOpptyAccountTeamsJSON, Type.forName('Map<Id, Account>'));
        Set<Id> setOpptyZPAUsers = (Set<Id>)JSON.deserialize(setOpptyZPAUsersJSON, Type.forName('Set<Id>'));
        Set<Id> setOpptyZPAManagers = (Set<Id>)JSON.deserialize(setOpptyZPAManagersJSON, Type.forName('Set<Id>'));
        Map<Id, Opportunity> mapOpptyToUpdate = new Map<Id, Opportunity>();

        for (Id oppId : mapOpptySEManagerEmail.keySet()) {
            mapOpptyToUpdate.put(oppId, new Opportunity(Id=oppId, SE_Manager__c=mapOpptySEManagerEmail.get(oppId)));
        }

        if (!mapOpptyToUpdate.isEmpty()) {
            for (Id oppId : mapOpptySEName.keySet()) {
                mapOpptyToUpdate.get(oppId).SE_Name__c = mapOpptySEName.get(oppId);
            }
        }

        List<Opportunity> opptyFlagsToUpdate = new List<Opportunity>();

        if (!mapOpptyAccountTeams.isEmpty()) {
            for (Id oppId : mapOpptyAccountTeams.keySet()) {
                if (mapOpptyToUpdate.containsKey(oppId)) {
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c;

                    if (setOpptyZPAManagers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    }

                    if (setOpptyZPAUsers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    }
                } else {
                    mapOpptyToUpdate.put(oppId, new Opportunity(Id = oppId, Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c, Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c, Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c,Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c, Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c, Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c /*Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c,Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c */));

                    //if (setOpptyZPAManagers.contains(oppId)) { 
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    //}

                    //if (setOpptyZPAUsers.contains(oppId)) { 
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    //}
                }
            }
        }

        if (mapOpptyToUpdate.size() > 0) {
            //IBA-5765 - Added TriggerHandler.byPass
            TriggerHandler.byPass('LeadTriggerHandler');
            TriggerHandler.byPass('AccountTriggerHandler');
            TriggerHandler.byPass('OpportunityTriggerHandler');
            TriggerHandler.byPass('ContactTriggerHandler');
            Database.update(opptyFlagsToUpdate, true);
            Database.update(mapOpptyToUpdate.values(), true);
            TriggerHandler.clearBypass('LeadTriggerHandler');
            TriggerHandler.clearBypass('AccountTriggerHandler');
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
            TriggerHandler.clearBypass('ContactTriggerHandler');
        }
    }
    
}