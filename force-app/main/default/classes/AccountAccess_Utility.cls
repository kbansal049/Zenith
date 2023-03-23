public without sharing class AccountAccess_Utility {
    public static void insertAccountShare(list<AccountShare> accountShareList){
        Database.insert(accountShareList, false);
    }
    
    public static void deleteAccountVacationCoverage(Set<Id> AccountIds, Set<Id> coveringUsers){
        List<AccountTeamMember> vacationCoverageAccountTeam = [Select Id 
                                                                        from 
                                                                        AccountTeamMember
                                                                        Where 
                                                                        AccountId IN: AccountIds
                                                                        AND
                                                                        UserId IN: coveringUsers
                                                                        AND
                                                                        TeamMemberRole = 'Vacation Coverage'];
        if(!vacationCoverageAccountTeam.isEmpty()){
            Database.delete(vacationCoverageAccountTeam, false);
        }
    }
    
    public static void deleteOpportunityVacationCoverage(Set<Id> AccountIds, Set<Id> coveringUsers){
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> OppList = [select Id,
                                            Name,
                                            AccountId
                                            from 
                                            Opportunity 
                                            Where 
                                            AccountId IN:AccountIds];
        for(Opportunity Opp:OppList){
            opportunityIds.add(Opp.Id);
        }
        system.debug('---coveringUsers--'+coveringUsers);
        List<OpportunityTeamMember> vacationCoverageOppTeam = [Select Id 
                                                                        from 
                                                                        OpportunityTeamMember
                                                                        Where 
                                                                        OpportunityId IN: opportunityIds
                                                                        AND
                                                                        UserId IN: coveringUsers
                                                                        AND
                                                                        TeamMemberRole = 'Vacation Coverage'];
        
        /*for(OpportunityTeamMember oppTeamMemberRec : vacationCoverageOppTeam){
            opportunityIds.add(oppTeamMemberRec.Id);
        }*/
        
        if(!vacationCoverageOppTeam.isEmpty()){
            Database.delete(vacationCoverageOppTeam, false);
            deleteProposalVacationCoverage(opportunityIds, coveringUsers);
        }
    }
    
    public static void deleteProposalVacationCoverage(Set<Id> oppIds, Set<Id> coveringUsers){
        
        
        Set<Id> QuoteIds = new Set<Id>();
        List<SBQQ__Quote__c> quoteList = [Select Id, Name, SBQQ__Opportunity2__c 
                                                                from 
                                                                SBQQ__Quote__c
                                                                Where 
                                                                SBQQ__Opportunity2__c IN:OppIds];
        
        for(SBQQ__Quote__c qut:quoteList){
            QuoteIds.Add(qut.Id);
        }
        if(!QuoteIds.isEmpty()){
            List<SBQQ__Quote__Share> qtShareToDelete = [Select Id From SBQQ__Quote__Share
                                                                                Where 
                                                                                ParentId IN: QuoteIds
                                                                                AND
                                                                                UserOrGroupId IN: coveringUsers
                                                                                AND
                                                                                RowCause = 'Opportunity_Team__c'];
            if(!qtShareToDelete.isEmpty()){
                Database.delete(qtShareToDelete, false);
            }
        }
    }
    
   
    
    public static void insertAccountTeam(Set<Id> AccountIds, string selectedManager){
        List<AccountTeamMember> AccountTeamInsertList = new List<AccountTeamMember>();
        for(Id accoutId : AccountIds){
            AccountTeamMember accTeamRec = new AccountTeamMember();
            accTeamRec.AccountId = accoutId;
            accTeamRec.UserId = selectedManager;
            accTeamRec.TeamMemberRole = 'Vacation Coverage';
            accTeamRec.AccountAccessLevel = 'Edit';
            accTeamRec.OpportunityAccessLevel = 'Edit';
            AccountTeamInsertList.add(accTeamRec);
        }
        if(!AccountTeamInsertList.isEmpty()){
            Database.insert(AccountTeamInsertList, false);
        }
    }
    
    public static void InsertOpportunityTeam(set<Id> AccountIds, string selectedManager){ 
        Set<Id> OppIds = new Set<Id>();
        Id selectedCoveringManager = selectedManager;
        Map<String, Boolean> OppotunityMap = new Map<String, Boolean>();
        List<OpportunityTeamMember> OpportunityTeamList = new List<OpportunityTeamMember>();
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        if(AccountIds.size()>0){
            OpportunityList = [Select Id, Name, AccountId from Opportunity where AccountId IN:AccountIds];
            
            for(Opportunity Opp:OpportunityList){
                OppIds.Add(Opp.Id);
            }
            List<OpportunityTeamMember> OppTeamMemberList = new List<OpportunityTeamMember>();
            OppTeamMemberList = [select Id, OpportunityId, UserId from 
                                            OpportunityTeamMember 
                                            Where 
                                            OpportunityId IN: OppIds 
                                            And 
                                            UserId != null];
            for(OpportunityTeamMember OTM:OppTeamMemberList){
                OppotunityMap.put(OTM.OpportunityId+'-'+OTM.UserId,true);
            }
            
            for(Opportunity Opp:OpportunityList){
                system.debug('--------Opp map----'+OppotunityMap.get(Opp.Id+'-'+selectedCoveringManager));
                if(OppotunityMap.get(Opp.Id+'-'+selectedCoveringManager) == null){
                    //OppIds.Add(Opp.Id);
                    OpportunityTeamMember OppTeam = new OpportunityTeamMember();
                    OppTeam.OpportunityAccessLevel = 'Edit';
                    OppTeam.OpportunityId = Opp.Id;
                    OppTeam.TeamMemberRole = 'Vacation Coverage';
                    OppTeam.UserId = selectedCoveringManager;
                    OpportunityTeamList.Add(OppTeam);
                    //OppotunityMap.put(Opp.Id, true);
                }
            }
            if(OpportunityTeamList.size()>0){
                Database.insert(OpportunityTeamList, false);
                if(OppIds.size()>0){
                    AccountAccess_Utility.InsertProposalShare(OppIds,selectedCoveringManager);
                }
            }
        }
    }
    
    public static void InsertProposalShare(set<Id> OppIds, string selectedCoveringManager){
        
        
        Set<Id> quoteIds = new Set<Id>();
        List<SBQQ__Quote__Share> quoteShareList = new List<SBQQ__Quote__Share>();
        List<SBQQ__Quote__c> qtList = new List<SBQQ__Quote__c>();
        
        if(!OppIds.isEmpty()){
            Map<String, Boolean> qtMap = new Map<String, Boolean>();
            qtList = [select Id,Name,SBQQ__Opportunity2__c from SBQQ__Quote__c Where SBQQ__Opportunity2__c IN:OppIds];
            for(SBQQ__Quote__c qt:qtList){
                quoteIds.Add(qt.Id);
            }
            
            if(!quoteIds.isEmpty()){
                List<SBQQ__Quote__Share> quotShareList = new List<SBQQ__Quote__Share>();
                quotShareList = [select Id,ParentId,UserOrGroupId from SBQQ__Quote__Share where ParentId IN:quoteIds And UserOrGroupId != null];
                for(SBQQ__Quote__Share PropShare:quotShareList){
                    qtMap.put(PropShare.ParentId+'-'+PropShare.UserOrGroupId,true);
                }
                
                for(SBQQ__Quote__c qt:qtList){
                    if(qtMap.get(qt.Id+'-'+selectedCoveringManager) == null){
                        SBQQ__Quote__Share PropShare = new SBQQ__Quote__Share();
                        PropShare.ParentId = qt.Id;
                        PropShare.UserOrGroupId = selectedCoveringManager;
                        PropShare.AccessLevel = 'Edit';
                        PropShare.RowCause = 'Opportunity_Team__c';
                        quoteShareList.Add(PropShare);
                    }
                }
                
                if(quoteShareList.size()>0){
                    Database.insert(quoteShareList, false);
                }
            }
        }
    }
    
    
    
}