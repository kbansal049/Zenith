public class OpportunityShareTriggerHandler {
    
    public static Boolean OpportunityShareTriggerHandlerBypass = false;
    public static Boolean isFirstTime = true;
    
    public static void shareQuoteAndProdConfigToOppTeamMembers(List<Id> oppShareIds){
        if(OpportunityShareTriggerHandlerBypass == true) return;
        
        if(!system.isBatch() && !system.isFuture()){
            if(oppShareIds.size() > 0){
                opportunityShareEngineStarter starter = new opportunityShareEngineStarter(oppShareIds);
                starter.start();
            }
        }
    }

}