trigger OpportunityShareTrigger on Opportunity_Share__c (after insert, after update) {
    
    List<Id> oppShareIds = new List<Id>();
    
    if(trigger.isAfter && OpportunityShareTriggerHandler.isFirstTime){
        for(Opportunity_Share__c oppShareRec : trigger.new){
            if(oppShareRec.Status__c == 'Ready To Share'){
                oppShareIds.add(oppShareRec.Id);
            }
        }
		OpportunityShareTriggerHandler.isFirstTime = False;
    }
    
    if(!oppShareIds.isEmpty()){
        OpportunityShareTriggerHandler.shareQuoteAndProdConfigToOppTeamMembers(oppShareIds);
    }

}