public class quoteAndProposalShareUtil {
    
    public static void shareQuoteAndProdConfigWithOppTeamMembers(List<Opportunity_Share__c> oppToShare){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity_Share__c oppShareRec : oppToShare){
            oppIds.add(oppShareRec.Opportunity_Id__c);
        }
        
        List<OpportunityTeamMember> oppTeamMembers = [Select Id, UserId, OpportunityId from OpportunityTeamMember Where OpportunityId IN: oppIds];
        Map<Id, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
        for(OpportunityTeamMember teamMemberRec : oppTeamMembers){
            if(oppTeamMembersMap.get(teamMemberRec.OpportunityId) == null){
                List<OpportunityTeamMember> tempList = new List<OpportunityTeamMember>();
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
            else{
                List<OpportunityTeamMember> tempList = oppTeamMembersMap.get(teamMemberRec.OpportunityId);
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
        }
        
       
        
        //Start CPQ Changes
        Map<Id, List<SBQQ__Quote__c>> oppQuoteMap = new Map<Id, List<SBQQ__Quote__c>>();
        List<SBQQ__Quote__c> oppQuotes = [Select Id, SBQQ__Opportunity2__c from SBQQ__Quote__c Where SBQQ__Opportunity2__c IN: oppIds];
                                                                    
        for(SBQQ__Quote__c proposalRec : oppQuotes){
            if(oppQuoteMap.get(proposalRec.SBQQ__Opportunity2__c) == null){
                List<SBQQ__Quote__c> tempList = new List<SBQQ__Quote__c>();
                tempList.add(proposalRec);
                oppQuoteMap.put(proposalRec.SBQQ__Opportunity2__c, tempList);
            }
            else{
                List<SBQQ__Quote__c> tempList = oppQuoteMap.get(proposalRec.SBQQ__Opportunity2__c);
                tempList.add(proposalRec);
                oppQuoteMap.put(proposalRec.SBQQ__Opportunity2__c, tempList);
            }
        }
                                                                    
        
        
        
        
        Map<String, SBQQ__Quote__Share> existingQuoteSharesMap = new Map<String, SBQQ__Quote__Share>();
       
        
        
            /**if(!proposalShareToDelete.isEmpty()){
                Database.delete(proposalShareToDelete, false);
            }**/
            
            
        
        
        if(!oppQuotes.isEmpty()){
            List<SBQQ__Quote__Share> existingQuoteShares = [Select Id,ParentId,UserOrGroupId from SBQQ__Quote__Share Where ParentId IN: oppQuotes AND RowCause = 'Opportunity_Team__c'];

            for(SBQQ__Quote__Share quoteShareRec : existingQuoteShares){
                existingQuoteSharesMap.put(quoteShareRec.ParentId + '' + quoteShareRec.UserOrGroupId, quoteShareRec);
            }
            
        }
            
        
        
        List<SBQQ__Quote__Share> quoteSharesToInsert = new List<SBQQ__Quote__Share>();

        for(Opportunity_Share__c oppShareRec : oppToShare){
            if(oppTeamMembersMap.get(oppShareRec.Opportunity_Id__c) != null){
                for(OpportunityTeamMember oppTeamRec : oppTeamMembersMap.get(oppShareRec.Opportunity_Id__c)){
                    if(!oppQuoteMap.isEmpty()){
                        if(oppQuoteMap.get(oppShareRec.Opportunity_Id__c) != null){
                            for(SBQQ__Quote__c quoteRec : oppQuoteMap.get(oppShareRec.Opportunity_Id__c)){
                                SBQQ__Quote__Share quoteShareRec = new SBQQ__Quote__Share();
                                quoteShareRec.ParentId = quoteRec.id;
                                quoteShareRec.AccessLevel = 'EDIT';
                                quoteShareRec.UserOrGroupId = oppTeamRec.UserId;
                                quoteShareRec.RowCause = Schema.SBQQ__Quote__Share.RowCause.Opportunity_Team__c;
                                quoteSharesToInsert.add(quoteShareRec);
                            }
                        }
                    }
                }
            }
            oppShareRec.Status__c = 'Sharing Completed';
        }
        
        /**if(!proposalSharesToInsert.isEmpty()){
            //insert proposalSharesToInsert;
            Database.insert(proposalSharesToInsert, false);
        }
        
        if(!prodConfigSharesToInsert.isEmpty()){
            //insert prodConfigSharesToInsert;
            Database.insert(prodConfigSharesToInsert, false);
        }**/
        
        List<SBQQ__Quote__Share> quoteShareToDelete = new List<SBQQ__Quote__Share>();
        List<SBQQ__Quote__Share> quoteShareToInsert = new List<SBQQ__Quote__Share>();
        List<SBQQ__Quote__Share> quoteShareToUpdate = new List<SBQQ__Quote__Share>();
        
        
       
        
        if(!quoteSharesToInsert.isEmpty()){
            for(SBQQ__Quote__Share quoteShareRec : quoteSharesToInsert){
                if(existingQuoteSharesMap.get(quoteShareRec.ParentId + '' + quoteShareRec.UserOrGroupId) != null){
                    quoteShareToUpdate.add(quoteShareRec);
                    existingQuoteSharesMap.remove(quoteShareRec.ParentId + '' + quoteShareRec.UserOrGroupId);
                }
                else{
                    quoteShareToInsert.add(quoteShareRec);
                }
            }  
           
        }
        
       
        
        
        if(!quoteShareToUpdate.isEmpty()){
            Database.insert(quoteShareToInsert, false);
        }
        if(!existingQuoteSharesMap.values().isEmpty()){
            quoteShareToDelete.addAll(existingQuoteSharesMap.values());
            Database.delete(quoteShareToDelete, false);
        }
        
       
        
        if(!oppToShare.isEmpty()){
            Database.update(oppToShare, false);
        }
    }
}