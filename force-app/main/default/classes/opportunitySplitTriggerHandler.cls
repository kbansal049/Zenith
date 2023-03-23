public class opportunitySplitTriggerHandler {
    public static Boolean isFirstTime = true;
    public static void afterInsert(List<OpportunitySplit> newOpportunitySplit){
        List<OpportunityTeamMember> oppTeamLst = new List<OpportunityTeamMember>();
        List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
        Set<Id> oppIds = new Set<Id>();
        //Set<Id> accountIds = new Set<Id>();
        //Map<Id, List<OpportunitySplit>> opportunitySplitMemberMap = new Map<Id, List<OpportunitySplit>>();
        //CR# 4867 and CR# 4868 Start
        Set<Id> oppTeamMembersset = new Set<Id>();
        Map<ID,OpportunitySplit> OppSplitMap = new Map<ID,OpportunitySplit>();
        //CR# 4867 and CR# 4868 End
        for(OpportunitySplit splitRec : newOpportunitySplit){
            OpportunityTeamMember oppTeamRec = new OpportunityTeamMember();
            oppTeamRec.OpportunityId = splitRec.OpportunityId;
            oppTeamRec.UserId = splitRec.SplitOwnerId;
            oppTeamRec.TeamMemberRole = 'Opportunity Split';
            oppTeamRec.OpportunityAccessLevel = 'Edit';
            oppTeamLst.add(oppTeamRec);
            oppIds.add(splitRec.OpportunityId);
            /**if(opportunitySplitMemberMap.get(splitRec.OpportunityId) == null){
                List<OpportunitySplit> tempSet = new List<OpportunitySplit>();
                tempSet.add(splitRec);
                opportunitySplitMemberMap.put(splitRec.OpportunityId, tempSet);
            }
            else{
                List<OpportunitySplit> tempSet = opportunitySplitMemberMap.get(splitRec.OpportunityId);
                tempSet.add(splitRec);
                opportunitySplitMemberMap.put(splitRec.OpportunityId, tempSet);
            }**/
            OppSplitMap.put(splitRec.OpportunityId,splitRec);
            oppTeamMembersset.add(splitRec.Channel_Rep__c);
        }
        
        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, AccountId from Opportunity where id IN: oppIds]);
        Map<String, String> accountTeamMap = new Map<String, String>();
        Set<Id> accountIdSet = new Set<Id>();
        for(OpportunitySplit splitRec : newOpportunitySplit){
            accountIdSet.add(OppMap.get(splitRec.OpportunityId).AccountId);
            if(accountTeamMap.get(OppMap.get(splitRec.OpportunityId).AccountId + '' + splitRec.SplitOwnerId) == null){
                AccountTeamMember accTeamRec = new AccountTeamMember();
                accTeamRec.AccountId = OppMap.get(splitRec.OpportunityId).AccountId;
                accTeamRec.UserId = splitRec.SplitOwnerId;
                accTeamRec.TeamMemberRole = 'Opportunity Split';
                accTeamRec.AccountAccessLevel = 'Edit';
                accTeamRec.OpportunityAccessLevel = 'Edit';
                accTeamLst.add(accTeamRec);
            }
        }
        //CR# 4867 and CR# 4868 Start
        //Map<Id,AccountTeamMember> AccTeamMembers = new Map<Id,AccountTeamMember>([SELECT Id, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId IN : accountIdSet and UserId IN:oppTeamMembersset]);
        Map<Id,OpportunityTeamMember> userIdOppTeamRecMap = new Map<Id,OpportunityTeamMember>();
        for(OpportunityTeamMember accTeamRec : [SELECT Id, OpportunityId, TeamMemberRole, UserId 
                                            FROM OpportunityTeamMember 
                                            WHERE OpportunityId IN : OppSplitMap.keySet() and UserId IN:oppTeamMembersset]){
            userIdOppTeamRecMap.put(accTeamRec.UserId,accTeamRec);
        }
        for(OpportunitySplit os: newOpportunitySplit){
            if(!userIdOppTeamRecMap.containsKey(os.Channel_Rep__c) && os.Channel_Rep__c!=Null){
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = os.OpportunityId ;
                oppTeamMember.TeamMemberRole = 'Out of Territory RAM';
                oppTeamMember.OpportunityAccessLevel = 'Edit';
                oppTeamMember.UserId = os.Channel_Rep__c;
                oppTeamLst.add(oppTeamMember);
            }
        }
        //CR# 4867 and CR# 4868 End
        if(!oppTeamLst.isEmpty()){
            insert oppTeamLst;
        }
        
        
        if(!accTeamLst.isEmpty()){
            Database.insert(accTeamLst, false);
        }
        // IBA-2245 START
        /*
        List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdSet];
        if(!accountList.isEmpty()){
            for(Account accountRec : accountList){
                accountRec.TriggerPatchAssignment__c = true;   
            }
            update accountList;
        }
        */
        List<Account> accountList = new List<Account>();
        for (Id accountId : accountIdSet) {
            if(accountId != null){
                Account accountToUpdate = new Account();
                accountToUpdate.Id = accountId;
                accountToUpdate.TriggerPatchAssignment__c = true;
                accountList.add(accountToUpdate);
            }
        }
        if (!accountList.isEmpty())  {
            update accountList;
        }
        // IBA-2245 END
        
        /**if(!proposalSharesToInsert.isEmpty()){
            Database.insert(proposalSharesToInsert, false);
        }
        
        if(!prodConfigSharesToInsert.isEmpty()){
            Database.insert(prodConfigSharesToInsert, false);
        }**/
    }
    
    public static void afterDelete(List<OpportunitySplit> newOpportunitySplit){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> ramUserIds = new Set<Id>();
        for(OpportunitySplit splitRec : newOpportunitySplit){
            oppIds.add(splitRec.OpportunityId);
            userIds.add(splitRec.SplitOwnerId);
            ramUserIds.add(splitRec.Channel_Rep__c);//CR# 4867 and CR# 4868
        }
        
        /**List<OpportunityTeamMember> oppTeamToDelete = [Select Id 
                                                            from 
                                                            OpportunityTeamMember
                                                            Where    
                                                            OpportunityId IN: oppIds
                                                            AND
                                                            UserId IN: userIds
                                                            AND
                                                            TeamMemberRole = 'Opportunity Split'];
        if(!oppTeamToDelete.isEmpty()){
            delete oppTeamToDelete;
        }**/
        //Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, AccountId from Opportunity where id IN: oppIds]);
        List<Opportunity> opportunities = [Select Id, AccountId from Opportunity where id IN: oppIds];
        if(!opportunities.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity oppRec : opportunities){
                accountIds.add(oppRec.AccountId);
            }
            List<Opportunity> existingOpp = [Select Id from Opportunity Where AccountId IN: accountIds];
            List<OpportunitySplit> existingOpportunitySplitMembers = [Select Id, SplitOwnerId from OpportunitySplit Where OpportunityId IN: existingOpp AND SplitOwnerId IN: userIds ];
            if(existingOpportunitySplitMembers.isEmpty()){
                               
                List<AccountTeamMember> accTeamMembersToDelete = [Select Id, AccountId from AccountTeamMember Where AccountId IN: accountIds AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split'];
                Set<Id> accountIdsToTriggerPatch = new Set<Id>();
                for(AccountTeamMember accountTeamMemberRec : accTeamMembersToDelete){
                    accountIdsToTriggerPatch.add(accountTeamMemberRec.AccountId);   
                }
                Database.delete(accTeamMembersToDelete, false);
                
                List<OpportunityTeamMember> oppTeamToDelete = [Select Id from OpportunityTeamMember Where (OpportunityId IN: existingOpp AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split')
                                                               OR (OpportunityId IN: oppIds AND UserId IN: ramUserIds AND TeamMemberRole = 'Out of Territory RAM')];
                if(!oppTeamToDelete.isEmpty()){
                    delete oppTeamToDelete;
                }
                
                List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdsToTriggerPatch];
                if(!accountList.isEmpty()){
                    for(Account accountRec : accountList){
                        accountRec.TriggerPatchAssignment__c = true;   
                    }
                    update accountList;
                }
            }
            else{
                Map<String, boolean> userSplitOppTeam = new Map<String, Boolean>();
                for(OpportunitySplit teamMemberRec : existingOpportunitySplitMembers){
                    userSplitOppTeam.put(teamMemberRec.SplitOwnerId, true);
                }
                List<AccountTeamMember> accTeamMembersToDelete = new List<AccountTeamMember>();
                List<AccountTeamMember> accTeamMembers = [Select Id, UserId, AccountId from AccountTeamMember Where AccountId IN: accountIds AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split'];
                Set<Id> accountIdsToTriggerPatch = new Set<Id>();
                for(AccountTeamMember accTeamRec : accTeamMembers){
                    if(userSplitOppTeam.get(accTeamRec.UserId) == null){
                        accTeamMembersToDelete.add(accTeamRec);
                        accountIdsToTriggerPatch.add(accTeamRec.AccountId); 
                    }
                }
                Database.delete(accTeamMembersToDelete, false);

                List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdsToTriggerPatch];
                if(!accountList.isEmpty()){
                    for(Account accountRec : accountList){
                        accountRec.TriggerPatchAssignment__c = true;   
                    }
                    update accountList;
                }
            }
        }
    }
}