public without sharing class OpportunityShareWithSE {
    
    public static void updateSharing(List<Opportunity> opportunityToShareSE, List<Opportunity> opportunityToDeleShareSE){
        
        List<OpportunityTeamMember>  oppTeamMemberLstForInsert  = new List<OpportunityTeamMember>();
        for(Opportunity oppRec : opportunityToShareSE){
            OpportunityTeamMember oppTeamMember  = new OpportunityTeamMember();
            oppTeamMember.OpportunityId  = oppRec.Id;
            oppTeamMember.TeamMemberRole  = 'Out of Territory SE';
            oppTeamMember.OpportunityAccessLevel  = 'Edit';
            oppTeamMember.UserId = oppRec.SE_Name__c;
            oppTeamMemberLstForInsert.add(oppTeamMember);
        }
        
        if(!opportunityToDeleShareSE.isEmpty()){
            List<OpportunityTeamMember> existingOppSETeamToDelete = [Select Id, 
                                                                     UserId 
                                                                     from 
                                                                     OpportunityTeamMember 
                                                                     Where 
                                                                     OpportunityId IN: opportunityToDeleShareSE 
                                                                     and TeamMemberRole = 'Out of Territory SE'];
            if(!existingOppSETeamToDelete.isEmpty()){
                delete existingOppSETeamToDelete;
            }
        }
        if(!oppTeamMemberLstForInsert.isEmpty()){
            insert oppTeamMemberLstForInsert;
        }
    }

}