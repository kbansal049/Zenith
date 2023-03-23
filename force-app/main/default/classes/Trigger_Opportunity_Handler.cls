public class Trigger_Opportunity_Handler{
    
    public static void beforeInsertHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){  
        //Method to set renewal opportunity fields
         system.debug('inside handler 1');
		
		//Added by Gurjinder for Opp Creation Issue :Start
		if(!TriggerUtility.isSkipAccTriggerExecuted()){ 
			TriggerUtility.SkipAccTriggerExecuted();
		}
		//Added by Gurjinder for Opp Creation Issue : End
		
        Trigger_Opportunity_Helper.setOpportunityFields(newList);
        //Added by Arsh - CR# 4631
        Trigger_Opportunity_Helper.setCompetitorContext(newList,oldMap);
    }
    
    public static void beforeUpdateHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
        Trigger_Opportunity_Helper.setPSSKUfield(newList,oldMap);
        //Added by Arsh - CR# 4631
        Trigger_Opportunity_Helper.setCompetitorContext(newList,oldMap);
    }
    
    public static void beforeDeleteHandler(List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
            
    }
    
    public static void afterInsertHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
        //Method to create Opportunity Partner Records
        system.debug('inside handler 2');
        Trigger_Opportunity_Helper.createOpportunityPartnerRecords(newList);
    }
      
    public static void afterUpdateHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
         Trigger_Opportunity_Helper.notifyOnDealRegChange(newList,oldMap);
    }
    
    public static void afterDeleteHandler(List<Opportunity> newList, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){

    }
    
    public static void afterUnDeleteHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap){

    }
    
}